# AGENTS.md — NeuroLearn 維運指引（給 Claude Code / AI agent）

> 本檔是 agent 接手本專案的第一讀物。動手前先讀「Golden Rules」與「Code Map」。
> 使用者背景：金融業資深分析師；溝通用繁體中文，技術名詞保留英文；commit message 用繁體中文。

## 1. 專案一句話

NeuroLearn 是**單一 HTML 檔**的智能模擬考平台（Vanilla JS、零建構工具、離線可用、Firebase 雲端同步、本機 Claude Proxy 生成題目）。

- Live：https://z134340.github.io/neurolearn/
- Repo：https://github.com/Z134340/neurolearn （branch：`main`）
- 入口：`public/index.html`（約 4503 行；CSS 內嵌 21–460、JS 內嵌 490 起，行號為約值）
- 部署：GitHub Pages 與 Cloudflare Pages **並行**，兩者皆發布 `public/`（見 `docs/DEPLOY.md`）

## 2. Golden Rules（動手前必讀，違反會破壞產品）

1. **`public/index.html` 是唯一部署入口，root 不得再放 index.html** — Cloudflare Pages 的
   build output 與 GitHub Pages 的 Actions artifact 都指向 `public/`。root 若殘留第二份
   index.html，兩份會分歧且 CI 會擋（validate.yml 有 `test ! -f index.html`）。
2. **不可拆成多檔後直接部署** — 「單一檔、零建構、離線可下載」是核心設計。若要模組化，必須引入「build step（src/ 合併 → 單一 index.html）」並維持產出仍是單檔；這是架構決策，需先與使用者確認（見 BACKLOG B2）。
3. **不可擅自加 npm/bundler/框架** — 目前零自製依賴；任何 `package.json`/建構鏈都是架構決策，先確認。
4. **CDN 依賴版本鎖定（皆已鎖，含 SRI）** — Firebase compat `10.13.2`（gstatic，第一方，無 SRI）、`marked@4.3.0/marked.min.js`、`xlsx@0.18.5/dist/xlsx.full.min.js`（後兩者 jsDelivr，帶 `integrity` sha256 + `crossorigin`）。改 URL／升版必同步更新 `integrity`，否則 SRI 不符會整檔不載入；CI 有守門（見 validate.yml）。注意 `marked@18` 已移除 root `/marked.min.js`，4.3.0 是最後含該檔且 UMD 全域 `marked.parse` 的版本，升 marked 需改走 `lib/marked.umd*.js` 並驗證 API。
5. **不可破壞 Firestore Security Rules 模型** — 隔離靠 `users/{uid}` rules（見 README）。`FIREBASE_CONFIG.apiKey`（public/index.html:507）是 client-side 公開值、非機密，安全性由 rules 保證，**不要**當成洩漏處理。
6. **儲存有兩層、命名不同** — localStorage（單機 blob）vs Firestore（6 個 subcollection）。改任一層先讀 README「資料儲存說明」，避免重演 v2.4 的 onSnapshot 覆蓋資料遺失 bug。
7. **diff sync 優先** — 使用者偏好小步 diff，最後再給完整檔；改動前說明連動範圍。
8. **commit message 用繁體中文**，沿用現有風格（如「修正…」「新增…」「優化…」）。

## 3. Code Map（`public/index.html` 內部）

| 區段 | 行號(約) | 內容 |
|------|---------|------|
| `<style>` | 21–460 | 全站 CSS（含 iOS safe-area、共用 btn 類別、字級與容器尺度 token） |
| `FIREBASE_CONFIG` | 507 | Firebase 設定（公開值） |
| Firebase 同步層 | 523–894 | `syncUserState` / `syncExamFileToCloud` / `loadCloudData` / `syncStudyToCloud` / `loadStudyFromCloud` / onSnapshot / `_syncPausedUntil` / `_localOnlyFiles` |
| `initFirebase()` | 897 |（`appBaseUrl()` 940：部署位置偵測） Auth + Firestore 初始化 |
| STATE | 1110 | 全域 `S` 狀態物件 |
| NAVIGATION | 1143 | 切頁 |
| MASTER RENDER `render()` | 1204 | 總渲染入口 |
| HOME / DATASETS PAGE | 1254 / 1555 | 首頁、考古題題庫（CSV/XLSX 匯入：1923 / 2410） |
| AI 題目生成 | 1944–2390 | `aiGenTestConn` / `aiGenRun` / `aiGenImport`（呼叫本機 proxy） |
| QUIZ PAGE | 2571 | `launchQuiz()` 2978、作答流程 |
| DASHBOARD PAGE | 3652 | 趨勢圖（純 Canvas）、匯出 |
| PERSISTENT STORAGE | 4085 | `saveToStorage()` 4090、`loadFromStorage()` 4133（localStorage 三段降級） |
| STUDY AREA | 4168 | 教材庫 `handleMDFiles()` 4184、筆記 |
| BOOT | 4471 | `loadFromStorage()` → `render()` → `initFirebase()` |

## 4. 本機開發 / 執行 / 測試

- **執行**：直接用瀏覽器開 `public/index.html`（或於 `public/` 下 `python3 -m http.server`）。無建構步驟。
- **AI 生成功能**需本機 proxy：`cd ~/NeuroLearn && bash scripts/setup_proxy.sh`（launchd 開機自動啟動，port 7734）。健康檢查 `curl http://127.0.0.1:7734/health`、log `cat /tmp/neurolearn_proxy.log`。
- **目前無自動化測試**（見 BACKLOG B7）。改動後請手動驗證：登入→上傳題庫→測驗→書籤→儀表板→教材→AI 生成→登出，並確認跨裝置同步與離線重開資料完整。

## 5. 部署

- 推 `main` → GitHub Pages（`.github/workflows/pages.yml`）與 Cloudflare Pages 各自發布 `public/`。
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
├── scripts/                   # 本機 Claude Proxy（不參與網站部署）
│   ├── claude_proxy.py        #   port 7734，轉送至 claude CLI
│   ├── setup_proxy.sh         #   一鍵安裝（動態產生 plist）
│   └── com.neurolearn.proxy.plist  # launchd 參考模板
└── docs/
    ├── DEPLOY.md              # 部署與 Cloudflare 移轉 SOP
    └── 題目匯入範本.xlsx       # 參考用（範本實際由瀏覽器端 SheetJS 即時產生）
```

## 7. 慣例速查

- 語言：UI 與註解繁體中文；變數/函式英文。
- JS：Vanilla、ES6、無模組系統；大量 inline `onclick`（**131 處**）+ `innerHTML`（30 處）為現況技術債（見 BACKLOG B3/B4）。CI 有 ratchet 守門，數量不得超過此基準。
- console：預設靜默（log/warn/info/debug），`?debug=1` 或 `localStorage.neurolearn_debug='1'` 開啟（public/index.html:493 單點攔截，B5 已落地）。
- 同步觸發：60s（輕量）/ 5min（全量）debounce；quota 超限自動暫停 30 分鐘。
