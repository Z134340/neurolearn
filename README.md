# NeuroLearn 🧠 v2.0

> **智能模擬考平台** — 單一 HTML 檔案，離線可用，支援雲端同步

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Single File](https://img.shields.io/badge/架構-Single%20HTML-blueviolet)](index.html)
[![No Dependencies](https://img.shields.io/badge/外部依賴-僅%20Supabase%20SDK-green)](https://supabase.com)
[![Mobile Ready](https://img.shields.io/badge/行動裝置-iOS%20%2F%20Android-blue)](index.html)

---

## 目錄

- [功能概覽](#功能概覽)
- [功能架構圖](#功能架構圖)
- [快速開始](#快速開始)
- [Supabase 雲端同步設定](#supabase-雲端同步設定)
- [題庫格式](#題庫格式)
- [技術規格](#技術規格)
- [資料儲存說明](#資料儲存說明)
- [注意事項](#注意事項)

---

## 功能概覽

| 功能 | 說明 |
|------|------|
| 📂 **自訂題庫** | 上傳 CSV / XLSX 題庫，自動解析匯入 |
| 🎯 **模擬考** | 開始新測驗 / 複習已標記題目 / 錯誤題目驗測，三種模式 |
| 🔖 **書籤系統** | 任何模式下均可標記題目，集中複習 |
| 📊 **儀表板** | 測驗歷史、答對率趨勢、錯誤/標記題下載 |
| ☁️ **雲端同步** | Supabase Auth + RLS，跨裝置進度自動同步 |
| 💾 **進度備份** | 匯出 / 匯入 JSON 備份，支援離線使用 |
| 📱 **行動裝置** | iPhone / iPad 全面適配，可加到主畫面 |

---

## 功能架構圖

```
NeuroLearn
│
├── 🏠 首頁
│   ├── 快速進入各功能區
│   └── 顯示目前題庫統計
│
├── 📂 資料集
│   ├── 拖曳上傳 CSV / XLSX / PDF / DOCX
│   ├── 自動解析題目（id, exam, question, option_a~e, answer, explanation）
│   ├── 標籤管理（新增 / 移除 / 篩選）
│   ├── 下載題目匯入範本
│   └── 清除所有本機資料
│
├── 🎯 模擬考
│   ├── ① 選擇題目分類（多選 / 全選 / 清除）
│   ├── ② 選擇測驗模式
│   │   ├── 開始新測驗（不重複出題 · 顯示共N題/尚未N題）
│   │   ├── 複習已標記題目
│   │   │   ├── 呈現題目（瀏覽模式）
│   │   │   └── 重新測驗（計分模式）
│   │   └── 錯誤題目驗測
│   │       ├── 呈現題目（瀏覽模式）
│   │       └── 重新測驗（計分模式）
│   ├── ③ 設定題數（滑桿）+ 考卷名稱
│   │
│   ├── 作答介面
│   │   ├── 進度條 + 題號 Badge
│   │   ├── 題目文字
│   │   ├── 選項 A～E（點選 → 確認答案）
│   │   ├── 上一題 ← / 下一題 →（可回頭修改）
│   │   ├── ✏️ 修改答案
│   │   ├── 🔖 標記此題（書籤）
│   │   └── 解析展開（確認後顯示）
│   │
│   ├── 成績結果
│   │   ├── 環形分數圖
│   │   ├── 各分類答對率
│   │   ├── 逐題回顧（可展開）
│   │   ├── 🔁 再次挑戰（重抽同設定）
│   │   └── 返回選單
│   │
│   └── 瀏覽模式
│       ├── 題目卡片（折疊 / 展開）
│       ├── 正確答案高亮 + 解析
│       └── 取消標記 / 標記已知道
│
├── 📊 儀表板
│   ├── 標籤篩選（切換顯示分類統計）
│   ├── 統計卡
│   │   ├── 測驗次數
│   │   ├── 答對率
│   │   ├── 累計錯誤題 ⬇ 下載錯誤題目 CSV
│   │   └── 已標記題目 ⬇ 下載標記題目 CSV
│   ├── 趨勢圖（最近10次答對率折線）
│   ├── 分類表現長條圖
│   ├── 測驗歷史紀錄
│   │   ├── 考卷名稱 / 日期 / 答題 / 答對率
│   │   └── ⬇ 錯誤 N  ⬇ 標記 N（各次可單獨下載）
│   └── 進度備份 / 還原
│       ├── 匯出進度備份（.json）
│       └── 匯入進度備份（.json）
│
├── 👤 帳號 / 登入
│   ├── 註冊（Email + 密碼）
│   ├── 登入（自動載入雲端進度）
│   ├── 忘記密碼（信箱重設連結）
│   ├── 帳號頁（Email / 立即同步 / 登出）
│   └── 登出（清空記憶體 + 載入匿名進度）
│
└── ☁️ 雲端同步（Supabase）
    ├── Auth：Email / Password
    ├── RLS：每位使用者只能存取自己的資料
    ├── 自動同步（每次儲存後 2 秒 debounce）
    └── 同步內容：書籤 / 錯誤紀錄 / 測驗歷史 /
                 已使用題目 / 資料集元資料 / 自訂題目
```

---

## 快速開始

### 無需安裝，直接使用

1. 下載 `index.html`
2. 用任何瀏覽器開啟（Chrome / Safari / Firefox）
3. 開始使用——進度自動儲存於瀏覽器 `localStorage`

### 加到 iPhone 主畫面（PWA）

1. Safari 開啟 `index.html`
2. 點擊分享按鈕 → 「加到主畫面」
3. 即可像 App 一樣使用，支援深色主題列

---

## Supabase 雲端同步設定

> 如不需要雲端同步，跳過此步驟，app 仍可完整使用。

### Step 1 — 建立 Supabase 專案

1. 前往 [supabase.com](https://supabase.com) → 用 GitHub 登入 → New project
2. 記下 **Project URL** 和 **Publishable key**（Settings → API）

### Step 2 — 建立資料表

在 Supabase **SQL Editor** 執行：

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

### Step 3 — 填入 index.html

開啟 `index.html`，找到並替換：

```javascript
const SUPA_URL = 'YOUR_SUPABASE_URL';      // ← 填入 Project URL
const SUPA_KEY = 'YOUR_SUPABASE_ANON_KEY'; // ← 填入 Publishable key
```

完成後，app 右上角出現「登入」按鈕，即可跨裝置同步。

---

## 題庫格式

### CSV 匯入格式

下載範本：app 內「資料集」→「下載題目匯入範本」

```csv
id,exam,question,option_a,option_b,option_c,option_d,option_e,answer,explanation
1,AWS AI,這是題目文字,選項A,選項B,選項C,選項D,,B,這是解析文字
```

| 欄位 | 必填 | 說明 |
|------|------|------|
| `id` | ✅ | 唯一數字 ID |
| `exam` | ✅ | 分類名稱（對應題庫標籤）|
| `question` | ✅ | 題目文字 |
| `option_a` ~ `option_e` | ✅ A~D | 選項，E 可留空 |
| `answer` | ✅ | 正確答案字母（A/B/C/D/E）|
| `explanation` | — | 解析文字（選填）|

### 進度備份格式（JSON）

```json
{
  "_version": 1,
  "_app": "NeuroLearn",
  "_exported": "2025-01-15T10:00:00.000Z",
  "bookmarks": ["0", "5", "42"],
  "wrongQs":   ["1", "7"],
  "usedQIds":  ["0", "1", "2"],
  "history": [...],
  "files": [...],
  "extraQs": [...]
}
```

---

## 技術規格

| 項目 | 說明 |
|------|------|
| **架構** | 單一 HTML 檔案（137 KB），零建構工具 |
| **框架** | 無（Vanilla JS）|
| **外部 CDN** | 僅 Supabase JS SDK（登入功能用，可選）|
| **圖表** | 自製 Canvas 折線圖（無 Chart.js）|
| **字型** | 系統字型 fallback（無 Google Fonts）|
| **離線支援** | 完全離線可用（Supabase 功能除外）|
| **瀏覽器** | Chrome / Safari / Firefox / Edge 現代版 |
| **行動裝置** | iOS Safari / Android Chrome |

### 資料儲存架構

```
使用者進度
    │
    ├── localStorage（本機）
    │   key: neurolearn_v2_{user_id}   ← 登入時
    │   key: neurolearn_v2             ← 未登入時
    │
    ├── Supabase（雲端，需設定）
    │   table: user_progress
    │   field: data (jsonb)
    │   security: Row Level Security
    │
    └── JSON 備份（手動匯出）
        NeuroLearn_YYYY-MM-DD.json
```

---

## 資料儲存說明

### 各管道儲存內容對照

| 資料 | localStorage | Supabase | JSON 備份 |
|------|:---:|:---:|:---:|
| 書籤題目 | ✅ | ✅ | ✅ |
| 錯誤題目 | ✅ | ✅ | ✅ |
| 不重複出題紀錄 | ✅ | ✅ | ✅ |
| 測驗歷史 | ✅ | ✅ | ✅ |
| 資料集元資料 | ✅ | ✅ | ✅ |
| 自訂題庫（解析後）| ✅ | ✅ | ✅ |
| 原始上傳檔案 | ❌ | ❌ | ❌ |

> **注意**：原始 PDF / CSV / XLSX 二進制無法序列化，不會被儲存。  
> 但解析後的所有題目（`extraQs`）已完整保存，換裝置後仍可正常作答。

### 兩帳號資料隔離

- localStorage key 包含 `user_id`：`neurolearn_v2_<uuid>`
- Supabase RLS 確保每位使用者只能存取自己的資料
- 登入 / 登出時自動清空記憶體，載入對應帳號資料

---

## 注意事項

- **進度備份建議**：定期使用「儀表板 → 匯出進度備份」保存 JSON 檔
- **清除瀏覽器資料**會清除 localStorage；已設定 Supabase 的用戶再次登入即可還原
- **Publishable key 安全性**：`sb_publishable_` 格式的 key 為設計公開用，安全由 Supabase RLS 保障，可放心寫入 HTML
- **XLSX 匯入**：需要網路連線載入解析器；離線建議使用 CSV 格式

---

## License

MIT © NeuroLearn

---

<p align="center">
  <sub>Built with ❤️ — 單一 HTML，無需安裝，隨時隨地學習</sub>
</p>
