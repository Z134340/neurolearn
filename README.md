# NeuroLearn 🧠 v1.1 (整合離線本機版 ＆ 雲端同步功能)

> **智能模擬考平台** — 單一 HTML 檔案，完全離線可用，雲端帳號同步

[![Live Demo](https://img.shields.io/badge/Live%20Demo-z134340.github.io-brightgreen?style=flat-square)](https://z134340.github.io/neurolearn/)
[![Single File](https://img.shields.io/badge/架構-Single%20HTML%20141KB-blueviolet?style=flat-square)](index.html)
[![No Framework](https://img.shields.io/badge/框架-Vanilla%20JS-orange?style=flat-square)](index.html)
[![Supabase](https://img.shields.io/badge/雲端-Supabase-3ECF8E?style=flat-square)](https://supabase.com)
[![PWA](https://img.shields.io/badge/PWA-iOS%20%2F%20Android-blue?style=flat-square)](https://z134340.github.io/neurolearn/)

**🌐 立即使用：https://z134340.github.io/neurolearn/**

---

## 目錄

- [功能概覽](#功能概覽)
- [網站架構圖](#網站架構圖)
- [快速開始](#快速開始)
- [題庫格式](#題庫格式)
- [Supabase 設定](#supabase-雲端同步設定)
- [技術規格](#技術規格)
- [資料儲存說明](#資料儲存說明)

---

## 功能概覽

| 功能 | 說明 |
|------|------|
| 📂 **自訂題庫** | 上傳 CSV / XLSX，支援單選、多選（AB / A,B / A+B 格式）|
| 🎯 **三種模式** | 開始新測驗（不重複出題）/ 複習已標記 / 錯誤題目驗測 |
| 🔢 **不重複出題** | 記錄已出過的題目，下次自動排除，顯示剩餘可用題數 |
| ☑️ **多選題** | 自動偵測，勾選框 UI，「可選多個答案」提醒 |
| 📄 **出處標注** | 每題解析下方顯示來源檔名與 CSV 題號 |
| 🔖 **書籤系統** | 任何模式下標記題目，集中複習 |
| ⬅️ **上一題** | 可回頭修改已作答選項 |
| 📈 **儀表板** | 測驗歷史、分數趨勢圖（純 Canvas，無 CDN）|
| ☁️ **雲端同步** | Supabase Auth + RLS，XMLHttpRequest 直連，跨裝置同步 |
| 💾 **進度備份** | 匯出 / 匯入 JSON（含題庫題目）|
| 📱 **PWA** | iPhone / Android 可加到主畫面，完全離線 |

---

## 網站架構圖

```
NeuroLearn
├── 🏠 首頁
│   └── 快速入口卡片
│
├── 📂 資料集
│   ├── 拖曳上傳 CSV / XLSX
│   ├── 自動解析（id / exam / question / option_a~e / answer / explanation）
│   ├── 多選題自動偵測（answer 欄：AB / A,B / A+B）
│   ├── 標籤管理（新增 / 移除 / 篩選）
│   ├── 題目出處記錄（來源檔名 / CSV 題號）
│   └── 下載題目範本 CSV
│
├── 🎯 模擬考
│   ├── ① 選擇題目分類（多選 / 全選 / 清除）
│   │
│   ├── ② 選擇測驗模式
│   │   ├── 開始新測驗
│   │   │   ├── 顯示「N 題未考 / 共 M 題」
│   │   │   └── 抽題自動排除 usedQIds（已考過）
│   │   ├── 複習已標記題目
│   │   │   ├── 📖 呈現題目（折疊式瀏覽）
│   │   │   └── 🎯 重新測驗（逐題作答）
│   │   └── 錯誤題目驗測
│   │       ├── 📖 呈現題目（折疊式瀏覽）
│   │       └── 🎯 重新驗測（逐題作答）
│   │
│   ├── ③ 設定題數（滑桿，最大值 = 未考題數）
│   │
│   ├── 作答介面
│   │   ├── 進度條 + 題號 + 分類標籤
│   │   ├── 單選：A-E 字母按鈕
│   │   ├── 多選：勾選框（可複選）+「可選多個答案」提醒
│   │   ├── ← 上一題 / 確認答案 / 下一題 →
│   │   ├── ✏️ 修改答案
│   │   ├── 🔖 書籤
│   │   └── 解析 + 📄 出處（確認後顯示）
│   │
│   ├── 成績結果
│   │   ├── 答對率 + 分類統計
│   │   ├── 逐題明細（正確/錯誤 + 正確答案 + 出處）
│   │   ├── 🔁 再出一份（相同設定重抽）
│   │   └── 返回選單
│   │
│   └── 折疊式瀏覽（複習 / 錯誤模式）
│       ├── 點標題展開 → 選項 + 解析 + 出處
│       ├── 🔖 書籤（stopPropagation 防誤觸）
│       └── Chevron 動畫指示展開方向
│
├── 📊 儀表板
│   ├── 標籤篩選
│   ├── 統計卡（測驗次數 / 答對率 / 錯誤題 / 已標記）
│   ├── ⬇ 下載：錯誤題目 / 已標記題目（CSV + BOM）
│   ├── 測驗分數趨勢圖（純 Canvas / Bezier 曲線 / 色碼數據點）
│   ├── 測驗歷史列表
│   │   └── ⬇ 每次可單獨下載（錯誤 / 標記 CSV）
│   └── 進度備份 / 還原
│       ├── ⬇ 匯出 JSON（含題庫、書籤、紀錄）
│       ├── ⬆ 匯入 JSON（自動同步雲端）
│       └── ☁️ 立即同步到雲端（XHR + 10s 逾時）
│
└── 👤 帳號
    ├── 登入 / 註冊 / 忘記密碼 / 重寄驗證信
    ├── 登入 → resetState() → loadCloudProgress() → render()
    └── 登出 → resetState() → render()
```

---

## 資料同步架構

```
使用者操作（書籤 / 完成測驗 / 上傳題庫 ...）
         │
         ▼
   saveToStorage()
         ├── localStorage（key: neurolearn_v2_{user_uuid}）
         └── scheduleSyncToCloud()  ← 2 秒 debounce
                    │
                    ▼
              syncToCloud()
              XMLHttpRequest
              10s native timeout
                    │
                    ▼
           Supabase REST API
     POST /rest/v1/user_progress
     （JWT Bearer Token / RLS）
                    │
                    ▼
        ┌─────────────────────────┐
        │   user_progress 表      │
        │  user_id (uuid, unique) │
        │  data (jsonb)           │
        │   ├── history[]         │
        │   ├── bookmarks[]       │
        │   ├── wrongQs[]         │
        │   ├── usedQIds[]        │
        │   ├── files[]           │
        │   ├── extraQs[]         │
        │   ├── dashTag           │
        │   └── tagFilter         │
        └─────────────────────────┘
```

---

## 快速開始

### 直接使用

🌐 **https://z134340.github.io/neurolearn/**

下載 `index.html` → 用任何瀏覽器開啟，進度自動存於 localStorage。

### 加到 iPhone 主畫面（PWA）

1. Safari 開啟網址
2. 點擊分享 → 加到主畫面
3. 像 App 一樣使用，完全離線可用

---

## 題庫格式

### CSV 格式

```csv
id,exam,question,option_a,option_b,option_c,option_d,option_e,answer,explanation
1,AWS AI,單選題範例,選項A,選項B,選項C,選項D,,B,這是解析
2,AWS AI,多選題範例,選項A,選項B,選項C,選項D,選項E,AC,多選題解析
```

| 欄位 | 必填 | 說明 |
|------|:----:|------|
| `id` | ✅ | 唯一數字 ID（用於出處標注）|
| `exam` | ✅ | 分類名稱（對應題庫標籤）|
| `question` | ✅ | 題目文字 |
| `option_a` ~ `option_d` | ✅ | 選項，`option_e` 可留空 |
| `answer` | ✅ | 單選：`B`；多選：`AC`、`A,C`、`A+C` 均可 |
| `explanation` | — | 解析（選填）|

---

## Supabase 雲端同步設定

### Step 1 — 建立資料表

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

### Step 2 — 填入 index.html

```javascript
const SUPA_URL = 'https://你的專案.supabase.co';
const SUPA_KEY = 'sb_publishable_你的key';
```

### Step 3 — 設定 Redirect URL

Supabase → Authentication → URL Configuration：
- **Site URL**：`https://你的網站/`
- **Redirect URLs**：加入同樣網址

### Step 4（建議）— 關閉 Email 驗證

Supabase → Authentication → Providers → Email → 關閉「Confirm email」

> 免費方案每小時限寄 2 封驗證信，關閉可避免新用戶無法登入。

---

## 技術規格

| 項目 | 說明 |
|------|------|
| **架構** | 單一 HTML 檔案（141 KB），零建構工具、零依賴 |
| **框架** | 無（Vanilla JS，97 個函式）|
| **外部依賴** | 僅 Supabase JS SDK（`defer` 載入，失敗不影響功能）|
| **圖表** | 自製 Canvas（Bezier 曲線 / 漸層填色 / Retina 支援）|
| **雲端同步** | XMLHttpRequest + native `timeout` = 10 秒 |
| **Token** | 快取於 `_accessToken`，不重複呼叫 `getSession()` |
| **題庫** | 無內建題庫（`QUESTIONS = []`），全由使用者上傳 |
| **離線** | 完全離線可用（雲端功能除外）|
| **iOS** | `viewport-fit=cover` / `safe-area` / 44px 觸控目標 |
| **瀏覽器** | Chrome / Safari / Firefox / Edge 現代版 |

---

## 資料儲存說明

### 8 個同步欄位

| 欄位 | 內容 |
|------|------|
| `history` | 測驗歷史（含 wrongIds / bkIds）|
| `bookmarks` | 已標記題目 ID |
| `wrongQs` | 累計錯誤題目 ID |
| `usedQIds` | 已出過的題目 ID（不重複出題）|
| `files` | 資料集元資料（不含二進制）|
| `extraQs` | 完整題庫題目（解析後）|
| `dashTag` | 儀表板篩選標籤 |
| `tagFilter` | 資料集標籤篩選 |

### 多帳號隔離

localStorage key = `neurolearn_v2_{user_uuid}`，不同帳號完全隔離。
Supabase RLS 確保每位使用者只能存取自己的資料。

### 同步觸發時機

| 操作 | 觸發方式 |
|------|---------|
| 完成測驗 | 立即（標記 usedQIds）|
| 書籤 / 移除書籤 | 600ms debounce |
| 上傳 / 刪除資料集 | 立即 |
| 新增 / 移除標籤 | 立即 |
| 匯入 JSON 備份 | 立即 |
| 儀表板篩選 | 600ms debounce |
| 立即同步按鈕 | 立即（XHR，10s 逾時）|

---

## License

MIT © NeuroLearn

---

<p align="center">
  <sub>單一 HTML · 零安裝 · 離線可用 · <a href="https://z134340.github.io/neurolearn/">立即試用</a></sub>
</p>
