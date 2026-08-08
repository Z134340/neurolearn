# 部署指南 — Cloudflare Pages 移轉 SOP

> 對象：專案維運者（你）。本文只涵蓋「部署」，版控與 CI 仍在 GitHub，不受影響。
> 現況：`main` 推送後，GitHub Pages 與 Cloudflare Pages **並行**發布同一份 `public/`。

---

## 0. 先搞清楚哪些東西動了、哪些沒動

| 項目 | 移轉後 |
|------|--------|
| 版控（git remote） | **不變** — `https://github.com/Z134340/neurolearn` |
| CI（`validate.yml`） | **不變** — 繼續在 GitHub Actions 跑 |
| 網站發布目錄 | `public/`（原本是 repo root） |
| GitHub Pages | 改由 `pages.yml` 從 `public/` 部署（需改 Source 設定，見 §1） |
| Cloudflare Pages | 新增，同樣從 `public/` 發布 |
| Firebase 專案 | **不變** — `neurolearn-c13f9`；但 Auth 網域白名單要加（見 §3） |

**Cloudflare 只是多一個「消費 GitHub repo 的發布者」，不是搬家。** 你 push 的目的地永遠是 GitHub。

---

## 1. 先讓 GitHub Pages 不要掛掉（必做，否則舊站 404）

`index.html` 已從 root 移入 `public/`。GitHub Pages 的資料夾部署只支援 root 或 `/docs`，**不支援 `public/`**，所以本 repo 改用 Actions 部署。

1. GitHub → **Settings** → **Pages**
2. **Source** 從「Deploy from a branch」改成 **「GitHub Actions」**
3. 儲存後，`.github/workflows/pages.yml` 會在下次 push（或手動 `workflow_dispatch`）時發布 `public/`

> 沒做這一步 → 舊站 `https://z134340.github.io/neurolearn/` 會 404，「並行驗證」就失去意義。

---

## 2. 建立 Cloudflare Pages 專案

有三條路，**擇一**即可。

| 方案 | 誰執行 | 你要做的事 | 適用 |
|------|--------|-----------|------|
| **C 本機腳本** | 你的電腦 | 跑兩支腳本，瀏覽器登入一次 | 手上就有電腦、想一次做完 |
| **A GitHub Actions** | GitHub runner | 產一個 API Token、貼兩個 secret | 想要往後全自動 |
| **B Dashboard 連 Git** | Cloudflare | 授權 GitHub、填四個 build 欄位 | 偏好圖形介面 |

> 遠端沙箱（Claude Code on the web）的網路政策擋掉 `dash.cloudflare.com`、
> `api.cloudflare.com`、`console.firebase.google.com`，因此方案 B、C 無法由
> 遠端 session 代為執行；方案 A 的部署動作跑在 GitHub runner 上，不受此限。

### 方案 C — 在自己的電腦上跑腳本（最快做完）

若你在本機執行 Claude Code，可直接請它跑這兩支：

```bash
git pull                                              # 取得含 public/ 的版本
bash scripts/deploy_cloudflare.sh                     # 首次會開瀏覽器登入 Cloudflare
bash scripts/add_firebase_domain.sh <配發的網域>       # 例：neurolearn.pages.dev
```

- `deploy_cloudflare.sh`：確認 `public/` 內容 → 建立 Pages 專案（已存在則略過）→ 部署。
  加 `--preview` 可先發到 preview 分支，不影響正式站。
- `add_firebase_domain.sh`：**先讀取現有 Authorized domains，合併後只增不減再寫回**。
  Identity Toolkit 的 API 是整個陣列覆寫，直接 PATCH 會把 `localhost` 與既有網域
  全部刪掉導致線上站無法登入，故必須走這支腳本或手動在 Console 操作。
  支援 `--dry-run` 先看結果，實際寫入前也會要求確認。
  前置：`gcloud auth login`（需為該 Firebase 專案的 Owner/Editor）與 `jq`。



### 方案 A — GitHub Actions 用 wrangler 推送

部署由 `.github/workflows/cloudflare.yml` 執行，你只需要提供兩個值。
好處：不必在 Cloudflare 授權 GitHub、不必設定 build 參數，部署邏輯留在版控裡。

1. **取得 Account ID**
   <https://dash.cloudflare.com> → 進入任一 Workers & Pages 頁面 → 右側欄 **Account ID**，複製。

2. **建立 API Token**
   右上角頭像 → **My Profile** → **API Tokens** → **Create Token** → **Create Custom Token**
   - Token name：`neurolearn-pages-deploy`（隨意）
   - Permissions：**Account** → **Cloudflare Pages** → **Edit**（只要這一項）
   - Account Resources：選你的帳號
   - 建立後**立刻複製**，離開頁面就看不到了

3. **放進 GitHub Secrets**
   GitHub repo → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

   | Name | Value |
   |------|-------|
   | `CLOUDFLARE_API_TOKEN` | 上一步的 token |
   | `CLOUDFLARE_ACCOUNT_ID` | 第 1 步的 Account ID |

4. **觸發部署**
   Actions → `deploy-cloudflare-pages` → **Run workflow**（或直接推一個 commit 到 `main`）。
   兩個 secret 未設定時，此 workflow 會標記 skipped 並成功結束，不會擋 CI。

5. 從 workflow log 取得配發的網域，形如 `https://neurolearn.pages.dev`

> Token 權限僅限 Cloudflare Pages 編輯，無法讀取 DNS、帳單或其他資源。
> 日後要撤銷，回到 My Profile → API Tokens 直接 Revoke 即可。

### 方案 B — Cloudflare Dashboard 連接 Git

Cloudflare 免費方案對本站綽綽有餘：無限請求與頻寬、每月 500 次建置、自訂網域免費。

1. 登入 <https://dash.cloudflare.com> → 左側 **Workers & Pages** → **Create** → **Pages** → **Connect to Git**
2. 授權 GitHub，選擇 repo **`Z134340/neurolearn`**
3. 設定建置參數 —— **本站零建構工具，三個欄位都很重要**：

   | 欄位 | 值 | 說明 |
   |------|-----|------|
   | Production branch | `main` | |
   | Framework preset | **None** | 選錯會硬塞 build 指令 |
   | Build command | **（留空）** | 沒有建構步驟 |
   | Build output directory | **`public`** | 關鍵：只發布網站本體 |
   | Root directory | `/` | 保持預設 |

4. **Save and Deploy**
5. 記下配發的網域，形如 `https://neurolearn.pages.dev`（實際名稱以 Cloudflare 顯示為準）

> 選了方案 B 的話，`.github/workflows/cloudflare.yml` 就不需要，可以刪除或不設 secret 讓它保持 skipped。
> 兩者並用會造成同一專案被兩套流程部署，請擇一。

> 設成 `public` 之後，`scripts/`、`AGENTS.md`、`BACKLOG.md`、`README.md` 都不會上 CDN。
> 這正是把 `index.html` 移進 `public/` 的目的。

---

## 3. Firebase Auth 白名單（**不做的話登入 100% 壞掉**）

新網域不在白名單，登入會直接噴 `auth/unauthorized-domain`。

1. <https://console.firebase.google.com> → 專案 **`neurolearn-c13f9`**
2. **Authentication** → **Settings** → **Authorized domains**
3. **Add domain**，加入 Cloudflare 配發的網域（例：`neurolearn.pages.dev`）
4. 若之後綁自訂網域，同樣要加

> `z134340.github.io` 請**先保留**，並行期間舊站還要能登入。

程式端已無硬編碼網域：`appBaseUrl()`（`public/index.html`）會依當前部署位置自動組出
驗證信／重設密碼信的回跳網址，GitHub Pages 子路徑與 Cloudflare 根路徑都正確。
但該函式回傳的網域**必須**在上述白名單內，否則 Firebase 會拒絕寄信。

---

## 4. 驗證清單（在 Cloudflare 新網域上逐項確認）

> **驗證進度（2026-08-08）**
> - [x] 首頁載入正常
> - [x] 發布邊界正確（`/AGENTS.md` 無內容；部署 log `Uploaded 1 files`）
> - [x] **登入成功** —— 同時證明 Firebase 白名單生效與 Firestore 跨網域同步正常
> - [ ] 註冊新帳號 → 驗證信回跳網址為新網域（唯一無法從程式碼確認的項目）
> - [ ] 手機開啟版面確認
>
> 目前實際狀態（2026-08-08）：
> - Cloudflare 專案 `neurolearn`，正式網域 **https://neurolearn-48v.pages.dev**
> - 走方案 A，由 `.github/workflows/cloudflare.yml` 以 wrangler 部署
> - 首次部署 log 顯示 `Uploaded 1 files`，確認只發布 `public/index.html`
> - 每次部署另會產生 `<hash>.neurolearn-48v.pages.dev` 快照網址；該類網址
>   因 hash 每次不同無法加入 Firebase 白名單，**登入功能僅在正式網域可用**


- [ ] 首頁載入，字型與版面正常（Google Fonts 需能載入）
- [ ] **註冊新帳號 → 收到驗證信 → 點連結回跳到 Cloudflare 網域**（不是 github.io）
- [ ] 登入成功（沒有 `auth/unauthorized-domain`）
- [ ] 上傳一份 CSV/XLSX 題庫 → 題目正確解析（SRI 生效，`xlsx` 有載入）
- [ ] 上傳一份 Markdown 教材 → 閱讀頁正常渲染（`marked` 有載入）
- [ ] 做一次測驗 → 儀表板出現紀錄
- [ ] **換一台裝置登入同帳號 → 資料同步過來**（Firestore 正常）
- [ ] 重設密碼信的回跳網址也是新網域
- [ ] 手機開啟，版面無橫向捲動

> AI 題目生成依賴本機 proxy（`127.0.0.1:7734`），與部署平台無關，不必列入驗證。
> 但注意：從 https 網站呼叫 http 本機端點屬 mixed content，行為與原本在 GitHub Pages 上一致，
> 未因移轉而改變。

---

## 5. 收尾：關閉 GitHub Pages（**驗證全過之後才做**）

1. GitHub → Settings → Pages → Source 改為 **None**（或停用 `pages.yml`）
2. 更新對外連結：`README.md` 徽章與連結、`AGENTS.md` 的 Live 網址
3. Firebase Authorized domains 可移除 `z134340.github.io`（非必要，留著無害）

---

## 6. 回滾

| 狀況 | 做法 |
|------|------|
| Cloudflare 建置失敗 | 舊站仍在，直接在 Cloudflare Dashboard 看 build log 修正即可，零停機 |
| 想完全退回 GitHub Pages 單軌 | Cloudflare 專案刪除或暫停即可；`pages.yml` 已在發布 `public/`，不需改動程式 |
| 想連目錄結構一起退回 | `git revert` 該次結構調整的 commit，`index.html` 會回到 root；同時要把 Settings → Pages 的 Source 改回「Deploy from a branch」 |

---

## 7. 已知未處理項目

- **未加 `_headers` 安全標頭**。可加 `nosniff` / `Referrer-Policy` / `X-Frame-Options` 等低風險標頭；
  但**不建議直接上嚴格 CSP** —— 本站有 131 處 inline `onclick` 與大量 inline style，
  沒有 `'unsafe-inline'` 會整站失效。CSP 應等 BACKLOG B3（事件委派重構）完成後再導入。
- **`firestore.rules` 未納入版控**。目前規則只存在 Firebase Console。
- 以上兩項皆為獨立工項，與本次移轉無相依。
