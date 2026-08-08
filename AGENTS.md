# AGENTS.md — NeuroLearn 維運指引（給 Claude Code / AI agent）

> 本檔是 agent 接手本專案的第一讀物。動手前先讀「Golden Rules」與「Code Map」。
> 使用者背景：金融業資深分析師；溝通用繁體中文，技術名詞保留英文；commit message 用繁體中文。

## 1. 專案一句話

NeuroLearn 是**單一 HTML 檔**的智能模擬考平台（Vanilla JS、零建構工具、離線可用、Firebase 雲端同步、本機 Claude Proxy 生成題目）。

- Live（移轉中，兩站並行同一份 `public/`）：
  - Cloudflare Pages：https://neurolearn-48v.pages.dev ← 新，將成為正式站
  - GitHub Pages：https://z134340.github.io/neurolearn/ ← 舊，驗證通過後關閉
- Repo：https://github.com/Z134340/neurolearn （branch：`main`）
- 入口：`public/index.html`（單一檔，約 4.5k 行；CSS 內嵌於 `<style>`、JS 內嵌於其後的 `<script>`）
- 部署：GitHub Pages 與 Cloudflare Pages **並行**，兩者皆發布 `public/`（見 `docs/DEPLOY.md`）

## 2. Golden Rules（動手前必讀，違反會破壞產品）

1. **`public/index.html` 是唯一部署入口，root 不得再放 index.html** — Cloudflare Pages 的
   build output 與 GitHub Pages 的 Actions artifact 都指向 `public/`。root 若殘留第二份
   index.html，兩份會分歧且 CI 會擋（validate.yml 有 `test ! -f index.html`）。
2. **不可拆成多檔後直接部署** — 「單一檔、零建構、離線可下載」是核心設計。若要模組化，必須引入「build step（src/ 合併 → 單一 index.html）」並維持產出仍是單檔；這是架構決策，需先與使用者確認（見 BACKLOG B2）。
3. **不可擅自加 npm/bundler/框架** — 目前零自製依賴；任何 `package.json`/建構鏈都是架構決策，先確認。
4. **CDN 依賴版本鎖定（皆已鎖，含 SRI）** — Firebase compat `10.13.2`（gstatic，第一方，無 SRI）、`marked@4.3.0/marked.min.js`、`xlsx@0.18.5/dist/xlsx.full.min.js`（後兩者 jsDelivr，帶 `integrity` sha256 + `crossorigin`）。改 URL／升版必同步更新 `integrity`，否則 SRI 不符會整檔不載入；CI 有守門（見 validate.yml）。注意 `marked@18` 已移除 root `/marked.min.js`，4.3.0 是最後含該檔且 UMD 全域 `marked.parse` 的版本，升 marked 需改走 `lib/marked.umd*.js` 並驗證 API。
5. **不可破壞 Firestore Security Rules 模型** — 隔離靠 `users/{uid}` rules（見 README）。`FIREBASE_CONFIG.apiKey`（grep `const FIREBASE_CONFIG`）是 client-side 公開值、非機密，安全性由 rules 保證，**不要**當成洩漏處理。
6. **儲存有兩層、命名不同** — localStorage（單機 blob）vs Firestore（6 個 subcollection）。改任一層先讀 README「資料儲存說明」，避免重演 v2.4 的 onSnapshot 覆蓋資料遺失 bug。
7. **diff sync 優先** — 使用者偏好小步 diff，最後再給完整檔；改動前說明連動範圍。
8. **commit message 用繁體中文**，沿用現有風格（如「修正…」「新增…」「優化…」）。

## 3. Code Map（`public/index.html` 內部）

> **以錨點而非行號定位**——行號每次改動都會偏移（歷次已失準三次），錨點欄可直接
> `grep -n '<錨點>' public/index.html` 取得當前位置，永不過時。

| 區段 | 錨點（可直接 grep） | 內容 |
|------|--------------------|------|
| 全站 CSS | `<style>` … `</style>` | iOS safe-area、共用 btn 類別、字級與容器尺度 token（`--w-read` / `--w-list` / `--w-mid` / `--w-dash`） |
| Firebase 設定 | `const FIREBASE_CONFIG` | 公開值，非機密（安全性由 Firestore rules 保證） |
| Firebase 同步層 | `async function syncUserState` | 另含 `syncExamFileToCloud` / `loadCloudData` / `syncStudyToCloud` / `loadStudyFromCloud` / onSnapshot / `_syncPausedUntil` / `_localOnlyFiles` |
| 初始化 | `function initFirebase` | Auth + Firestore |
| 部署位置偵測 | `function appBaseUrl` | Auth action URL 依當前網域自動組出（GitHub Pages 子路徑／Cloudflare 根路徑皆正確） |
| **HTML 轉義** | `function esc` | 使用者可控字串進模板前必經；見 §7 慣例 |
| 全域狀態 | `const S = {` | |
| 切頁 | `function navigate` | |
| 總渲染入口 | `function render()` | 各頁 `innerHTML` 指派與 render 後的事件綁定都在此 |
| 首頁 | `function homeHTML` | |
| 考古題題庫 | `function datasetsHTML` | CSV／XLSX 匯入見 `function importCSVQuestions` / `function importXLSXQuestions` |
| AI 題目生成 | `async function aiGenRun` | 另含 `aiGenTestConn` / `aiGenImport`（呼叫本機 proxy 7734） |
| 測驗 | `function quizMenuHTML` | 作答流程見 `function launchQuiz` |
| 儀表板 | `function dashHTML` | 趨勢圖為純 Canvas，見 `function initChart` |
| localStorage | `function saveToStorage` | 讀取見 `function loadFromStorage`（三段降級） |
| 教材庫／閱讀 | `function libraryHTML` | 匯入 `function handleMDFiles`、解析 `function parseMD`（前置 `hardenMarked`） |
| 筆記 | `function notesHTML` | |
| 漸進式揭露 | `function uploaderToggleHTML` | 上傳區收合／展開，綁定見 `function bindUploaderToggle` |
| BOOT | `loadFromStorage();` （檔尾） | `loadFromStorage()` → `render()` → `initFirebase()` |

## 4. 本機開發 / 執行 / 測試

- **執行**：直接用瀏覽器開 `public/index.html`（或於 `public/` 下 `python3 -m http.server`）。無建構步驟。
- **AI 生成功能**需本機 proxy：`cd ~/NeuroLearn && bash scripts/setup_proxy.sh`（launchd 開機自動啟動，port 7734）。健康檢查 `curl http://127.0.0.1:7734/health`、log `cat /tmp/neurolearn_proxy.log`。
- **自動化 smoke test**（B7 已落地）：`node tests/smoke.mjs`，CI 於 push／PR 自動執行
  （`.github/workflows/smoke.yml`）。本地執行需先 `npm i --no-save playwright@1.49.1`
  與 `npx playwright install chromium`；沙箱內可用 `CHROMIUM_PATH=` 指定既有 chromium。
  **刻意不建立 `package.json`**，依賴只存在執行環境，維持 Golden Rule #3。
- 涵蓋範圍：各頁渲染無例外、六斷點無橫向溢出、CSV 匯入→測驗→儀表板、
  Markdown 教材→閱讀頁、漸進式揭露與空狀態、設計基準（字級／容器／可縮放）。
- **仍需人工驗證**（測試刻意不涵蓋，因需外部服務）：登入／雲端同步（真實 Firebase
  憑證）、AI 題目生成（本機 proxy 7734）、中文檔名上傳（Playwright 在部分容器環境
  無法傳遞非 ASCII 檔名，非產品限制）。另請確認跨裝置同步與離線重開資料完整。

## 5. 部署

- 推 `main` → GitHub Pages（`pages.yml`）與 Cloudflare Pages（`cloudflare.yml`，wrangler + 
  `CLOUDFLARE_API_TOKEN`／`CLOUDFLARE_ACCOUNT_ID` 兩個 repo secret）各自發布 `public/`。
- Cloudflare 專案名 `neurolearn`，配發網域 `neurolearn-48v.pages.dev`（`neurolearn` 已被占用）。
- ⚠️ GitHub → Settings → Pages 的 **Source 必須設為「GitHub Actions」**；資料夾部署只支援 root 或 `/docs`，無法指向 `public/`。`[未能驗證]` 該設定無法從程式碼判定，請以 repo 設定為準。
- ⚠️ 新增部署網域時，必須同步加入 Firebase Console → Authentication → Settings → **Authorized domains**，否則登入會噴 `auth/unauthorized-domain`。
- 完整移轉／回滾步驟見 `docs/DEPLOY.md`。

## 6. 檔案結構

```
NeuroLearn/
├── public/                    # ★ 發布目錄（GitHub Pages / Cloudflare Pages 皆指向此）
│   └── index.html             #   應用程式本體（單一檔，部署入口）
├── README.md                  # 使用者文件（功能、儲存模型、設定）
├── AGENTS.md                  # 本檔（agent 維運指引）
├── BACKLOG.md                 # 維運/優化待辦（優先序）
├── LICENSE                    # MIT
├── .gitignore / .editorconfig
├── scripts/                   # 本機工具（皆不參與網站部署）
│   ├── claude_proxy.py        #   AI 生成用 proxy，port 7734，轉送至 claude CLI
│   ├── setup_proxy.sh         #   一鍵安裝（動態產生 plist）
│   ├── com.neurolearn.proxy.plist  # launchd 參考模板
│   ├── deploy_cloudflare.sh   #   本機部署 public/ 至 Cloudflare Pages（方案 A 之外的後備路徑）
│   └── add_firebase_domain.sh #   安全新增 Firebase Auth 授權網域（只增不減）
├── .claude/
│   └── skills/                # 專案層級 Agent Skills（隨 repo 走，不參與部署）
│       └── frontend-design/   #   Anthropic 官方：UI 視覺方向與字體搭配
├── tests/
│   └── smoke.mjs              # 端到端 smoke test（Playwright，不入 package.json）
└── docs/
    ├── DEPLOY.md              # 部署與 Cloudflare 移轉 SOP
    └── 題目匯入範本.xlsx       # 參考用（範本實際由瀏覽器端 SheetJS 即時產生）
```

## 7. 慣例速查

- 語言：UI 與註解繁體中文；變數/函式英文。
- JS：Vanilla、ES6、無模組系統；大量 inline `onclick`（**131 處**）+ `innerHTML`（30 處）為現況技術債（見 BACKLOG B3）。CI 有 ratchet 守門，數量不得超過此基準。
- **使用者可控字串一律經 `esc()` 才進模板**（題目／選項／解析／檔名／教材標題／標籤）。
  Markdown 走 `parseMD` → `hardenMarked()`，raw HTML token 會被降級為純文字。
  新增任何渲染使用者輸入的位置，請一併補 `esc()`；smoke test 第 7 段會擋未轉義的注入面。
- ⚠️ 註解或字串中避免出現 `<`+`script`／`<`+`style` 的字面組合 —— CI 的標籤配對檢查以
  grep 計數，會把它算成未閉合標籤而失敗。
- console：預設靜默（log/warn/info/debug），`?debug=1` 或 `localStorage.neurolearn_debug='1'` 開啟（grep `預設靜默 console` 單點攔截，B5 已落地）。
- 同步觸發：60s（輕量）/ 5min（全量）debounce；quota 超限自動暫停 30 分鐘。
