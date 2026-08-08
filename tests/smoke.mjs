/**
 * NeuroLearn smoke test（BACKLOG B7）
 *
 * 範圍界定 —— 只測「不依賴外部服務」的部分，故意不涵蓋：
 *   · Firebase 登入／雲端同步 —— 需真實憑證，CI 不該持有
 *   · AI 題目生成 —— 需本機 proxy 127.0.0.1:7734，runner 沒有
 * 上述兩項維持人工驗證（見 docs/DEPLOY.md §4）。
 *
 * 執行：
 *   npm i --no-save playwright   # 刻意不建立 package.json（AGENTS.md Golden Rule #3）
 *   npx playwright install chromium
 *   node tests/smoke.mjs
 *
 * 環境變數：
 *   CHROMIUM_PATH  指定 chromium 執行檔（本地沙箱用；CI 交給 playwright 自行解析）
 */

import { chromium } from 'playwright';
import { fileURLToPath, pathToFileURL } from 'node:url';
import path from 'node:path';
import fs from 'node:fs';
import os from 'node:os';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const APP = pathToFileURL(path.join(ROOT, 'public', 'index.html')).href;

let pass = 0, fail = 0;
const failures = [];
function check(cond, label, detail = '') {
  if (cond) { pass++; console.log(`  ✓ ${label}`); }
  else { fail++; failures.push(label + (detail ? ` — ${detail}` : '')); console.log(`  ✗ ${label}${detail ? ' — ' + detail : ''}`); }
}
function section(t) { console.log(`\n── ${t} ──`); }

// ── fixtures ────────────────────────────────────────────────────────────────
// 注意：欄位內不可含半形逗號（此處未做引號包裹），否則欄位會被切錯
const CSV = [
  'exam,question,option_a,option_b,option_c,option_d,answer,explanation',
  '金融法規,商業銀行辦理住宅建築放款之總額上限為何？,百分之二十,百分之三十,百分之四十,百分之五十,B,銀行法第 72-2 條明定為百分之三十。',
  '金融法規,下列何者屬於貨幣市場工具？,公司債,國庫券,普通股,不動產,B,國庫券期限一年以內屬貨幣市場工具。',
  '金融法規,我國金融監理採何種架構？,多元分業,一元化,委外監理,自律監理,B,由金管會統籌銀行證券保險三業。',
].join('\n');

const MD = `# 第一章　金融市場總論

## 1.1 市場分類

金融市場依到期期限可分為**貨幣市場**與**資本市場**。

- 國庫券：期限一年以內
- 公司債：期限一年以上

## 1.2 監理架構

我國採一元化監理。
`;

/* fixture 檔名刻意使用 ASCII —— 在部分容器環境（LC_CTYPE=POSIX）下，
   Playwright 將非 ASCII 檔名傳給 Chromium 時檔案不會進入 input.files。
   這是測試工具的環境限制，**不是產品限制**：程式端以
   file.name.split('.').pop() 取副檔名，對中文檔名完全正常。
   中文檔名的上傳請以人工驗證涵蓋。 */
const tmp = fs.mkdtempSync(path.join(os.tmpdir(), 'nl-smoke-'));
const csvPath = path.join(tmp, 'sample-questions.csv');
const mdPath = path.join(tmp, 'sample-material.md');
fs.writeFileSync(csvPath, CSV, 'utf8');
fs.writeFileSync(mdPath, MD, 'utf8');

// ── helpers ─────────────────────────────────────────────────────────────────
/* file:// 下 localStorage 由同一 browser 實例共用，各段測試前必須清乾淨，
   否則前一段匯入的題庫／教材會殘留到下一段，造成偽陽性或偽陰性。 */
async function freshPage(ctx) {
  const page = await ctx.newPage();
  const errs = [];
  page.on('pageerror', e => errs.push(String(e)));
  page._errs = errs;                       // 供各段斷言取用
  // 以 addInitScript 在腳本執行前清空，避免「載入→clear→reload」的二次載入；
  // 離線環境下每次載入都要等 CDN 逾時，省掉一次可大幅縮短總時長。
  await page.addInitScript(() => { try { localStorage.clear(); } catch (e) {} });
  await page.goto(APP, { waitUntil: 'domcontentloaded' });
  await page.waitForFunction(() => typeof render === 'function', { timeout: 15000 });
  return page;
}

async function overflowOf(page) {
  return page.evaluate(() => {
    const de = document.documentElement;
    return { over: de.scrollWidth > de.clientWidth, sw: de.scrollWidth, cw: de.clientWidth };
  });
}

const launchOpts = { args: ['--no-sandbox'] };
if (process.env.CHROMIUM_PATH) launchOpts.executablePath = process.env.CHROMIUM_PATH;

const browser = await chromium.launch(launchOpts);

try {
  // ══ 1. 各頁渲染無 JS 例外 ══
  section('1. 頁面渲染');
  {
    const ctx = await browser.newContext({ viewport: { width: 1440, height: 900 } });
    const page = await freshPage(ctx);
    const errs = page._errs;
    await page.waitForTimeout(600);

    for (const [zone, p] of [['study', 'library'], ['study', 'notes'], ['exam', 'datasets'],
                             ['exam', 'quiz'], ['dash', 'dashboard'], ['dash', 'studystats'], [null, 'home']]) {
      await page.evaluate(([z, pg]) => { if (z) window._currentZone = z; navigate(pg); }, [zone, p]);
      await page.waitForTimeout(250);
      const has = await page.evaluate(() => !!document.querySelector('#page-content .page'));
      check(has, `${p} 頁渲染出內容`);
    }
    check(errs.length === 0, '全程無 JS 例外', errs.slice(0, 2).join(' | '));
    await ctx.close();
  }

  // ══ 2. 六個斷點無橫向溢出 ══
  section('2. 響應式版面（無橫向溢出）');
  for (const w of [2560, 1920, 1440, 1024, 768, 390]) {
    const ctx = await browser.newContext({ viewport: { width: w, height: 900 } });
    const page = await freshPage(ctx);
    await page.waitForTimeout(400);
    const r = await overflowOf(page);
    check(!r.over, `${w}px 無橫向溢出`, r.over ? `scrollW ${r.sw} > clientW ${r.cw}` : '');
    await ctx.close();
  }

  // ══ 3. CSV 匯入 → 測驗 → 儀表板（核心 happy path）══
  section('3. 匯入 → 測驗 → 儀表板');
  {
    const ctx = await browser.newContext({ viewport: { width: 1440, height: 900 } });
    const page = await freshPage(ctx);
    const errs = page._errs;

    await page.evaluate(() => { window._currentZone = 'exam'; navigate('datasets'); });
    await page.waitForTimeout(400);
    await page.setInputFiles('#fileInput', csvPath);
    await page.waitForFunction(() => S.extraQs.length >= 3, { timeout: 15000 });
    const imported = await page.evaluate(() => S.extraQs.length);
    check(imported === 3, `CSV 匯入 3 題`, `實得 ${imported}`);

    const parsed = await page.evaluate(() => {
      const q = S.extraQs[0];
      return { opts: q.options.length, ans: q.answer, cat: q.category, hasExpl: !!q.explanation };
    });
    check(parsed.opts === 4, '選項數正確（4）', `實得 ${parsed.opts}`);
    check(parsed.ans === 1, 'answer=B 正確轉為索引 1', `實得 ${parsed.ans}`);
    check(parsed.cat === '金融法規', 'exam 欄位成為分類', `實得 ${parsed.cat}`);
    check(parsed.hasExpl, '解析欄位有匯入');

    // 需先為檔案貼標，測驗頁才會出現分類
    await page.evaluate(() => { S.files[0].tags = ['金融法規']; navigate('quiz'); });
    await page.waitForTimeout(400);
    await page.evaluate(() => {
      S.quizSetup.cats = new Set(['金融法規']);
      S.quizSetup.mode = 'new';
      S.quizSetup.count = 3;
      render();
    });
    await page.waitForTimeout(300);
    await page.evaluate(() => launchQuiz());
    await page.waitForTimeout(500);
    const active = await page.evaluate(() => S.activeQs.length);
    check(active === 3, '測驗載入 3 題', `實得 ${active}`);

    const optCount = await page.evaluate(() => document.querySelectorAll('.opt').length);
    check(optCount === 4, '作答頁渲染 4 個選項', `實得 ${optCount}`);

    // 全部答對 → 完成 → 應寫入歷史
    await page.evaluate(() => {
      S.activeQs.forEach((q, i) => { S.answers[i] = { selected: q.answer, confirmed: true }; });
      finishQuiz();
    });
    await page.waitForTimeout(600);
    const hist = await page.evaluate(() => ({ n: S.history.length, correct: S.history[0]?.correct, total: S.history[0]?.total }));
    check(hist.n === 1, '完成測驗寫入 1 筆歷史', `實得 ${hist.n}`);
    check(hist.correct === 3 && hist.total === 3, '全對計分正確（3/3）', `實得 ${hist.correct}/${hist.total}`);

    await page.evaluate(() => { window._currentZone = 'dash'; navigate('dashboard'); });
    await page.waitForTimeout(700);
    const dash = await page.evaluate(() => document.body.innerText.includes('100%'));
    check(dash, '儀表板顯示 100% 答對率');
    check(errs.length === 0, '此流程無 JS 例外', errs.slice(0, 2).join(' | '));
    await ctx.close();
  }

  // ══ 4. Markdown 教材 → 閱讀頁 ══
  section('4. 教材匯入與閱讀');
  {
    const ctx = await browser.newContext({ viewport: { width: 1440, height: 900 } });
    const page = await freshPage(ctx);
    // marked 由 CDN 載入；等待它就緒（順帶驗證 SRI 沒把檔案擋掉）
    const markedOk = await page.waitForFunction(() => typeof marked !== 'undefined', { timeout: 20000 })
      .then(() => true).catch(() => false);
    // 資訊性、不計入 fail：marked 來自外部 CDN，其暫時性故障不應讓 CI 變紅。
    // SRI 若真的擋掉檔案，這裡也會顯示未載入，可據以人工判斷。
    console.log(`  ${markedOk ? 'ⓘ' : '⚠'} marked CDN 載入${markedOk ? '成功' : '失敗（離線環境屬正常，教材相關斷言略過）'}`);

    if (markedOk) {
      await page.evaluate(() => { window._currentZone = 'study'; navigate('library'); });
      await page.waitForTimeout(400);
      await page.setInputFiles('#study-file-input', mdPath);
      await page.waitForFunction(() => S.materials.length >= 1, { timeout: 15000 });
      const mat = await page.evaluate(() => ({ n: S.materials.length, secs: S.materials[0].sections.length, toc: S.materials[0].toc.length }));
      check(mat.n === 1, '教材匯入 1 份');
      check(mat.secs >= 3, 'Markdown 切出 ≥3 個章節', `實得 ${mat.secs}`);
      check(mat.toc >= 2, 'TOC 產生 ≥2 個項目', `實得 ${mat.toc}`);

      await page.evaluate(() => { S.currentMat = S.materials[0].id; navigate('reader'); });
      await page.waitForTimeout(700);
      const rd = await page.evaluate(() => ({
        h1: !!document.querySelector('.md-sec h1'),
        strong: !!document.querySelector('.md-sec strong'),
        li: document.querySelectorAll('.md-sec li').length,
      }));
      check(rd.h1 && rd.strong && rd.li >= 2, '閱讀頁正確渲染標題／粗體／清單',
            `h1=${rd.h1} strong=${rd.strong} li=${rd.li}`);
      const r = await overflowOf(page);
      check(!r.over, '閱讀頁無橫向溢出');
    }
    await ctx.close();
  }

  // ══ 5. 漸進式揭露與空狀態 ══
  //   刻意以注入狀態取代真實上傳：本段測的是 UI 條件邏輯（有無內容 → 收合/展開），
  //   與 markdown 解析無關；綁上 marked 會讓本段在無外網環境失敗。
  section('5. 漸進式揭露與空狀態');
  {
    const ctx = await browser.newContext({ viewport: { width: 1440, height: 900 } });
    const page = await freshPage(ctx);

    await page.evaluate(() => { window._currentZone = 'study'; navigate('library'); });
    await page.waitForTimeout(300);
    check(await page.evaluate(() => !!document.querySelector('.drop-zone') && !document.querySelector('[data-uploader]')),
          '教材庫空狀態直接展開 dropzone');

    await page.evaluate(() => {
      S.materials = [{ id: 'm-test', title: 'test', sections: [], toc: [], raw: '', uploadedAt: new Date().toISOString(), matTags: [] }];
      render();
    });
    await page.waitForTimeout(300);
    check(await page.evaluate(() => !!document.querySelector('[data-uploader]') && !document.querySelector('.drop-zone')),
          '有內容後 dropzone 收合為按鈕');

    await page.click('[data-uploader]');
    await page.waitForTimeout(300);
    check(await page.evaluate(() => !!document.querySelector('.drop-zone')), '點擊後可重新展開');

    // 題庫頁同樣行為
    await page.evaluate(() => {
      S.files = [{ id: 1, name: 'x.csv', type: 'csv', size: '1 KB', status: 'ready', date: '2026/01/01', tags: [] }];
      window._currentZone = 'exam'; navigate('datasets');
    });
    await page.waitForTimeout(300);
    check(await page.evaluate(() => !!document.querySelector('[data-uploader]') && !document.querySelector('.drop-zone')),
          '題庫頁有內容時同樣收合');

    // 筆記空狀態的行動引導：依有無教材給不同去處
    await page.evaluate(() => { window._currentZone = 'study'; S.annotations = []; navigate('notes'); });
    await page.waitForTimeout(300);
    check(await page.evaluate(() => document.querySelector('[data-goto]')?.dataset.goto) === 'reader',
          '有教材時筆記空狀態導向閱讀頁');

    await page.evaluate(() => { S.materials = []; navigate('notes'); });
    await page.waitForTimeout(300);
    check(await page.evaluate(() => document.querySelector('[data-goto]')?.dataset.goto) === 'library',
          '無教材時筆記空狀態導向教材庫');

    check(page._errs.length === 0, '此流程無 JS 例外', page._errs.slice(0, 2).join(' | '));
    await ctx.close();
  }

  // ══ 6. 設計基準（防止字級／容器被意外改回過小）══
  section('6. 設計基準');
  {
    const ctx = await browser.newContext({ viewport: { width: 1600, height: 900 } });
    const page = await freshPage(ctx);
    const base = await page.evaluate(() => {
      const cs = getComputedStyle(document.documentElement);
      const px = v => parseFloat(getComputedStyle(document.body).fontSize) * parseFloat(v);
      return {
        bodyLH: parseFloat(getComputedStyle(document.body).lineHeight) / parseFloat(getComputedStyle(document.body).fontSize),
        read: cs.getPropertyValue('--w-read').trim(),
        list: cs.getPropertyValue('--w-list').trim(),
        userScalable: (document.querySelector('meta[name=viewport]')?.content || '').includes('user-scalable=no'),
      };
    });
    check(base.bodyLH >= 1.5, `body line-height ≥1.5（CJK 可讀性）`, `實得 ${base.bodyLH.toFixed(2)}`);
    check(base.read === '760px', '--w-read 維持 760px（閱讀行長上限）', `實得 ${base.read}`);
    check(base.list.startsWith('min('), '--w-list 為響應式 min()', `實得 ${base.list}`);
    check(!base.userScalable, '未停用縮放（WCAG 1.4.4）');
    await ctx.close();
  }

} finally {
  await browser.close();
  fs.rmSync(tmp, { recursive: true, force: true });
}

console.log(`\n${'─'.repeat(52)}`);
console.log(`通過 ${pass} 項，失敗 ${fail} 項`);
if (fail) {
  console.log('\n失敗項目：');
  failures.forEach(f => console.log(`  · ${f}`));
  process.exit(1);
}
console.log('smoke test 全數通過');
