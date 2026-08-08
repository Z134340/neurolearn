# BACKLOG — NeuroLearn 維運 / 優化待辦

> 由 Cowork 對程式碼掃描產出，供 Claude Code 接手。
> 掃描時檔案為 repo root 的 `index.html`（4438 行）；**現已移至 `public/index.html`（4530 行）**，
> 以下行號僅供參考，請以 AGENTS.md Code Map 為準。
> 嚴重度：🔴 高 / 🟡 中 / ⚪ 低｜工作量：S(<0.5d) / M(0.5–2d) / L(>2d)
> 負責方：**CC** = 需 Claude Code（要瀏覽器執行/迭代/測試）｜**CW** = Cowork 可先處理（靜態產出）

## 優先序總表

| ID | 項目 | 類型 | 嚴重 | 工作量 | 負責 | 驗收條件 |
|----|------|------|:---:|:---:|:---:|------|
| B1 | localStorage 大宗資料改存 IndexedDB（`extraQs`/`materials` 出 blob） | 效能/穩定 | 🟡 | M | CC | 上傳 >5MB 不再觸發三段降級 warning；離線重開資料完整 |
| B2 | 模組化 build step（`src/` 合併→單一 `index.html`），維持單檔部署 | 可維護 | 🟡 | L | CC | `npm run build` 產出與現行 index.html 行為一致的單檔；deploy 不變 |
| B3 | **131 處** inline `onclick` → 事件委派（event delegation） | 可維護/可測 | 🟡 | M | CC | 移除 inline handler，行為不變，可被測試掛載 |
| B4 | 30 處 `innerHTML=` 注入點 XSS 稽核（使用者上傳內容渲染；含 marked 輸出 passthrough HTML） | 安全 | 🟡 | M | CC | 高風險注入點改用 textContent/escape + DOMPurify；附稽核清單 |
| ~~B5~~ | ✅ **已完成（P0）** 35 處 `console.*` 收斂到 debug flag（`?debug=1`） | 整潔 | ⚪ | S | — | public/index.html:501 單點攔截，預設靜默、可開關 |
| B6 | 7×`alert()` + 2×`confirm()` → 站內 toast/modal | UX | ⚪ | S | CC | 阻斷式對話框移除，UX 一致 |
| B7 | 端到端 smoke test（Playwright） | 品質 | 🟡 | M | CC | 涵蓋登入→匯入→測驗→同步→教材→AI 生成 happy path |
| B8 | GitHub Actions CI（lint/validate，PR 觸發） | 品質 | ⚪ | S | **CW** | ✅ **已強化（P0）**：新增 CDN 鎖版+SRI 守門、技術債 ratchet（onclick≤131/innerHTML≤30）為 blocking；html-validate 維持 advisory |
| ~~B9~~ | ✅ **已完成（P0）** 解決現存 1 處 `TODO` | 整潔 | ⚪ | S | — | extractTextFromFile 佔位改為延後功能註記，行為不變 |
| **N1** | ✅ **已完成（P0）** CDN 鎖版+SRI（marked/xlsx 原為 jsDelivr latest floating） | 安全/穩定 | 🔴 | S | CW | marked@4.3.0、xlsx@0.18.5，帶 integrity sha256 + crossorigin；CI 守門 |
| B10 | Firestore Security Rules 部署驗證 + apiKey 公開性註記 | 安全 | 🟡 | S | CW(註記)/人工(驗證) | rules 已部署且符合 README；文件標明 apiKey 為公開值 |
| B11 | 單檔（約 4530 行）內函式分組可導覽（章節 anchor/索引） | 可維護 | ⚪ | S | CW | 已由 AGENTS.md Code Map 部分覆蓋 |
| B12 | Cloudflare Pages `_headers` 安全標頭（`nosniff` / `Referrer-Policy` / `X-Frame-Options` / `Permissions-Policy`） | 安全 | ⚪ | S | CW | `public/_headers` 生效，回應標頭可驗；**不含嚴格 CSP** —— 見下方註記 |
| B13 | `firestore.rules` 納入版控 | 安全/可維護 | ⚪ | S | CW(產出)/人工(比對) | repo 內規則檔與 Firebase Console 現況一致；不接自動部署 CI，避免誤覆蓋線上規則 |
| B14 | 空狀態補行動引導（筆記頁等） | UX | ⚪ | S | CC | 空狀態除說明文字外，附一顆指向下一步的按鈕 |

> **B12 註記（CSP）**：可安全加入的是 `nosniff` / `Referrer-Policy` / `X-Frame-Options` /
> `Permissions-Policy` 等低風險標頭。**不要直接上嚴格 CSP** —— 本站有 131 處 inline
> `onclick` 與大量 inline style，沒有 `'unsafe-inline'` 會整站失效。CSP 應等 B3
> （事件委派重構）完成後再導入，屆時才有意義。

## 部署現況（2026-08 移轉後）

- 網站發布目錄為 **`public/`**，repo root 不得再放 `index.html`（CI 有守門）。
- `main` 推送後由兩支 workflow 各自發布同一份 `public/`：
  `pages.yml`（GitHub Pages）與 `cloudflare.yml`（Cloudflare Pages，wrangler + 兩個 repo secret）。
- 正式站 <https://neurolearn-48v.pages.dev>；舊站 <https://z134340.github.io/neurolearn/> 並行中，
  待觀察期結束後關閉。詳見 `docs/DEPLOY.md`。
- **新增任何部署網域時，必須同步加入 Firebase Console → Authentication → Authorized domains**，
  否則登入會噴 `auth/unauthorized-domain`。

## 給 Claude Code 的建議切入順序

1. **先建護網**：B7（smoke test）+ B8（CI）→ 之後任何重構才有迴歸保護。
2. **再清技術債**：B3（inline handler）→ 解鎖可測性 → B4（XSS）→ B5/B6（log/UX）。
3. **架構升級**：B2（build step 模組化）為大決策，需先與使用者確認；完成後 B1（IndexedDB）與後續維運都更容易。

## B1 IndexedDB 實作方案（Cowork 已備，待瀏覽器測試後 apply）

- 新增 `idbGet/idbSet` helper（Promise 包 IndexedDB，~30 行）。
- `saveToStorage()`：小狀態續寫 localStorage（移除 `extraQs`/`materials`）；大宗改 `idbSet`（try/catch 後援）。
- `loadFromStorage()` 改 async：先同步 render 小狀態，再 `await idbGet` 補大資料 `renderSilent()`。
- BOOT（見 AGENTS.md Code Map）：`loadFromStorage().then(render)`，維持 cloud-first 覆蓋順序。
- 向後相容：IDB 空時 fallback 讀舊 localStorage blob 一次性遷移。
- 風險：async 時序與 onSnapshot 競態，**須瀏覽器實測**（故列為 CC）。
