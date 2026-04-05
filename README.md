# NeuroLearn 🧠

> **智能模擬考平台** — 單一 HTML 檔案，無需安裝，支援雲端帳號同步

[![Live](https://img.shields.io/badge/🌐_立即使用-z134340.github.io%2Fneurolearn-brightgreen)](https://z134340.github.io/neurolearn/)
[![Size](https://img.shields.io/badge/單檔-141_KB-blueviolet)](index.html)
[![Supabase](https://img.shields.io/badge/雲端-Supabase-3ECF8E)](https://supabase.com)
[![iOS](https://img.shields.io/badge/iOS-PWA_可加主畫面-blue)](https://z134340.github.io/neurolearn/)

**🌐 [https://z134340.github.io/neurolearn/](https://z134340.github.io/neurolearn/)**

---

## 功能一覽

### 📂 自訂題庫
- 上傳 **CSV / XLSX** 題庫，自動解析匯入
- 支援 **單選題**（answer: `A`）與 **多選題**（answer: `AB`、`A,B`、`A+B` 皆可）
- 支援最多 5 個選項（A–E）
- 題庫來源標注：每題解析下方顯示「📄 出處：檔名 · 題 #N」
- 標籤管理（每筆資料集最多 5 個標籤）
- 下載題目匯入 CSV 範本

### 🎯 模擬考（三種模式）

| 模式 | 說明 |
|------|------|
| **開始新測驗** | 不重複出題，追蹤已考題目，顯示「N 題未考 / 共 M 題」|
| **複習已標記題目** | 瀏覽或重新測驗書籤題目 |
| **錯誤題目驗測** | 瀏覽或重新測驗答錯題目 |

**作答功能：**
- 多選題顯示勾選框 + 「⬜ 可選多個答案」提示
- ← 上一題（可回頭修改）
- 確認答案後顯示解析 + 正確答案 + 題目出處
- ✏️ 修改答案
- 🔖 書籤標記（任何模式均有效）

### 📊 儀表板
- 測驗次數、整體答對率、累計錯誤題、已標記題目
- **測驗分數趨勢圖**（純 Canvas，無需網路，Bezier 曲線、色碼數據點）
- 測驗歷史紀錄（含答對率、標記數，可下載錯誤/標記題 CSV）

### ☁️ 雲端同步（Supabase）
- Email 帳號登入 / 註冊 / 忘記密碼 / 重寄驗證信
- 登入後自動載入雲端進度（書籤、錯題、已用題目、測驗歷史、題庫）
- 每次操作後自動背景同步（2 秒 debounce）
- 儀表板「立即同步到雲端」按鈕
- 多帳號資料隔離（localStorage key 以 UUID 區分）

### 💾 進度備份
- 匯出 JSON 備份（含題庫題目）
- 匯入 JSON 備份並自動同步雲端
- 換裝置登入後無需重新上傳題庫

---

## 快速開始

### 直接使用（無需安裝）

🌐 **[https://z134340.github.io/neurolearn/](https://z134340.github.io/neurolearn/)**

### 加到 iPhone 主畫面（PWA）

1. Safari 開啟網址
2. 點分享按鈕 → **「加到主畫面」**

### 本地端執行

下載 `index.html`，用任何瀏覽器開啟即可使用。

---

## 題庫 CSV 格式

```csv
id,exam,question,option_a,option_b,option_c,option_d,option_e,answer,explanation
1,AWS AI,題目文字,選項A,選項B,選項C,選項D,,B,解析文字
2,AWS AI,多選題目,選項A,選項B,選項C,選項D,,AB,解析文字
```

| 欄位 | 必填 | 說明 |
|------|:----:|------|
| `id` | ✅ | 唯一數字（用於不重複出題追蹤）|
| `exam` | ✅ | 分類名稱（對應儀表板標籤）|
| `question` | ✅ | 題目文字 |
| `option_a` ~ `option_d` | ✅ | 選項（`option_e` 可留空）|
| `answer` | ✅ | 單選：`A`–`E`；多選：`AB`、`A,B`、`A+B` 均可 |
| `explanation` | — | 解析文字（選填）|

**下載範本：** 平台內「資料集」→「下載題目匯入範本」

---

## Supabase 雲端設定

> 不設定也可完整使用，進度僅存本機。

### Step 1：建立 Supabase 專案

前往 [supabase.com](https://supabase.com) → New Project，記下 **Project URL** 與 **Publishable key**（Settings → API）

### Step 2：建立資料表

在 SQL Editor 執行：

```sql
create table user_progress (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid references auth.users(id) on delete cascade unique,
  data       jsonb not null default '{}',
  updated_at timestamptz default now()
);

alter table user_progress enable row level security;

create policy "own" on user_progress for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
```

### Step 3：設定 Redirect URL

Supabase → **Authentication → URL Configuration**：

- Site URL：`https://你的網站/`
- Redirect URLs：加入同樣網址

### Step 4：填入 index.html

```javascript
const SUPA_URL = 'https://你的專案.supabase.co';
const SUPA_KEY = 'sb_publishable_你的key';
```

### Step 5（建議）：關閉 Email 驗證

Supabase → **Authentication → Providers → Email** → 關閉 **Confirm email**

> 免費方案每小時限寄 2 封驗證信，關閉可讓使用者直接登入。

---

## 同步欄位說明

| 欄位 | localStorage | Supabase | JSON 備份 |
|------|:---:|:---:|:---:|
| 書籤題目 | ✅ | ✅ | ✅ |
| 錯誤題目 | ✅ | ✅ | ✅ |
| 已考題目（不重複）| ✅ | ✅ | ✅ |
| 測驗歷史 | ✅ | ✅ | ✅ |
| 題庫（解析後）| ✅ | ✅ | ✅ |
| 資料集元資料 | ✅ | ✅ | ✅ |
| 儀表板篩選 | ✅ | ✅ | ✅ |
| 原始上傳檔案 | ❌ | ❌ | ❌ |

---

## 技術規格

| 項目 | 說明 |
|------|------|
| 架構 | 單一 HTML 檔案（141 KB），零框架，零建構工具 |
| 題庫 | 無內建題庫，全依使用者上傳 |
| 圖表 | 自製 Canvas（Bezier 曲線、漸層、色碼、Retina）|
| 雲端同步 | XMLHttpRequest + JWT token，10 秒逾時保護 |
| 離線 | 完全可離線使用（雲端功能除外）|
| 行動裝置 | iOS / Android 全面適配，44px 觸控目標，safe-area |

---

## License

MIT © NeuroLearn

---

<p align="center">
  <sub>單一 HTML · 零安裝 · 自訂題庫 · 跨裝置同步 ·
  <a href="https://z134340.github.io/neurolearn/">立即試用</a></sub>
</p>
