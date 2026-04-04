# NeuroLearn 🧠v2.0 (整合離線本機版 ＆ 雲端同步功能)

> **智能模擬考平台** — 單一 HTML 檔案，離線可用，支援 Supabase 雲端同步

[![Single File](https://img.shields.io/badge/架構-Single%20HTML%20144KB-blueviolet)](#)
[![No Framework](https://img.shields.io/badge/框架-Vanilla%20JS-orange)](#)
[![Supabase](https://img.shields.io/badge/雲端-Supabase-green)](https://supabase.com)
[![Mobile Ready](https://img.shields.io/badge/行動裝置-iOS%20%2F%20Android-blue)](#)

**🌐 線上版本：[https://z134340.github.io/neurolearn/](https://z134340.github.io/neurolearn/)**

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
| 🎯 **模擬考** | 開始新測驗 / 複習標記題目 / 錯誤題目驗測，三種模式 |
| 🔖 **書籤系統** | 任何模式下均可標記題目，集中複習 |
| ⬅️ **上一題** | 作答中可回頭查看並修改答案 |
| 📊 **儀表板** | 測驗歷史、答對率趨勢、分類分析、題目下載（含標籤）|
| ☁️ **雲端同步** | Supabase Auth + RLS，跨裝置進度自動同步 |
| 👤 **帳號管理** | 註冊 / 登入 / 忘記密碼 / 重寄驗證信 |
| 🔒 **多帳號隔離** | 不同帳號資料完全隔離，localStorage key 含 user UUID |
| 💾 **進度備份** | 匯出 / 匯入 JSON 備份，無需登入也可使用 |
| 📱 **行動裝置** | iPhone / iPad 全面適配，可加到主畫面（PWA）|

---

## 功能架構圖

```
NeuroLearn
│
├── 🏠 首頁
│   └── 快速進入各功能區
│
├── 📂 資料集
│   ├── 拖曳上傳 CSV / XLSX
│   ├── 自動解析題目（id, exam, question, option_a~e, answer, explanation）
│   ├── 標籤管理（新增 / 移除 / 篩選）
│   ├── 下載題目匯入範本
│   └── 清除所有本機資料
│
├── 🎯 模擬考
│   ├── ① 選擇題目分類（多選 / 全選 / 清除）
│   ├── ② 選擇測驗模式
│   │   ├── 開始新測驗（不重複出題 · 共N題 / 尚未N題）
│   │   ├── 複習已標記題目 → 呈現題目 / 重新測驗
│   │   └── 錯誤題目驗測   → 呈現題目 / 重新測驗
│   ├── ③ 設定題數 + 考卷名稱
│   │
│   ├── 作答介面
│   │   ├── 進度條 + 題號
│   │   ├── ← 上一題（可回頭修改）/ 確認答案 / 下一題 →
│   │   ├── ✏️ 修改答案 / 🔖 標記此題（全模式有效）
│   │   └── 解析展開（確認後顯示）
│   │
│   ├── 成績結果
│   │   ├── 環形分數圖 + 各分類答對率 + 逐題回顧
│   │   └── 🔁 再次挑戰
│   │
│   └── 瀏覽模式（書籤 / 錯誤題目）
│       ├── 折疊卡片 + 正確答案 + 解析
│       └── 取消標記 / 已知道移除
│
├── 📊 儀表板
│   ├── 統計卡：錯誤題 / 標記題 → ⬇ 下載 CSV（含資料集標籤）
│   ├── 趨勢圖 + 分類長條圖
│   ├── 測驗歷史：各次 ⬇ 錯誤N / ⬇ 標記N（含標籤 + 考卷名稱）
│   └── 進度備份 / 還原（JSON 匯出 / 匯入）
│
├── 👤 帳號
│   ├── 註冊 → Email 驗證 → 登入
│   ├── 忘記密碼 / 重寄驗證信
│   ├── 帳號頁（立即同步 / 登出）
│   └── 登出：完整清除全部狀態（resetState）
│
└── ☁️ Supabase 雲端同步
    ├── Auth + Email 驗證 / 密碼重設
    ├── RLS：每位使用者只能存取自己的資料
    ├── 同步 8 欄位：書籤 / 錯誤 / usedQIds / 歷史 / 題庫 / 資料集 / 篩選
    └── 即時同步：資料集匯入 / 刪除後立即觸發
```

---

## 快速開始

### 直接開啟

1. 下載 `index.html`，用瀏覽器開啟
2. 前往「資料集」上傳 CSV 題庫
3. 開始使用——進度自動存於 `localStorage`

### 線上版

直接前往 **[https://z134340.github.io/neurolearn/](https://z134340.github.io/neurolearn/)**

### 加到 iPhone 主畫面

Safari → 分享 → 「加到主畫面」，即可像 App 使用。

---

## Supabase 雲端同步設定

### Step 1 — 建立專案

[supabase.com](https://supabase.com) → New project → 記下 **Project URL** 和 **Publishable key**

### Step 2 — 建立資料表（SQL Editor）

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

### Step 3 — 設定 Redirect URL

Authentication → URL Configuration：
- **Site URL** = 你的網址
- **Redirect URLs** 加入同樣網址

### Step 4 — 填入 index.html

```javascript
const SUPA_URL = 'https://your-project.supabase.co';
const SUPA_KEY = 'your-publishable-key';
```

### Step 5 — 關閉 Email 驗證（建議）

Authentication → Providers → Email → 關閉 **「Confirm email」**

> Supabase 免費方案每小時只能寄 2 封驗證信，關閉後使用者可直接登入。
> 若需保留驗證，可改用自訂 SMTP（Resend / SendGrid 均有免費額度）。

---

## 題庫格式

### CSV 格式

```csv
id,exam,question,option_a,option_b,option_c,option_d,option_e,answer,explanation
1,AI治理,這是題目文字,選項A,選項B,選項C,選項D,,B,這是解析
```

| 欄位 | 必填 | 說明 |
|------|------|------|
| `id` | ✅ | 唯一數字 ID |
| `exam` | ✅ | 分類名稱（對應標籤）|
| `question` | ✅ | 題目文字 |
| `option_a`~`option_e` | ✅ A-D | 選項，E 可空 |
| `answer` | ✅ | 正確答案（A/B/C/D/E）|
| `explanation` | — | 解析（選填）|

### 下載 CSV 格式

每個下載的 CSV 開頭含說明：

```
# 資料集：AI治理
# 類型：錯誤題目
# 題數：12 題
# 匯出時間：2025/1/15 上午10:30:00
#
id,exam,question,...
```

---

## 技術規格

| 項目 | 說明 |
|------|------|
| **架構** | 單一 HTML 檔案（144 KB），零建構工具 |
| **框架** | Vanilla JS（無框架，92 個函式）|
| **外部依賴** | 僅 Supabase JS SDK（雲端功能，可選）|
| **圖表** | 自製 Canvas（無 Chart.js）|
| **字型** | 系統字型 fallback（無 Google Fonts）|
| **離線** | 完全離線可用（Supabase 功能除外）|
| **瀏覽器** | Chrome / Safari / Firefox / Edge |

---

## 資料儲存說明

### 儲存內容對照

| 資料 | localStorage | Supabase | JSON 備份 |
|------|:---:|:---:|:---:|
| 書籤 / 錯誤 / usedQIds | ✅ | ✅ | ✅ |
| 測驗歷史 | ✅ | ✅ | ✅ |
| 資料集元資料 + 題庫 | ✅ | ✅ | ✅ |
| 篩選設定 | ✅ | ✅ | ✅ |
| 原始上傳檔案 | ❌ | ❌ | ❌ |

### 多帳號隔離

```
localStorage key：neurolearn_v2_{user_uuid}   ← 每帳號唯一
Supabase：user_id FK + RLS                    ← 完全隔離
```

### 同步時機

| 操作 | 時機 |
|------|------|
| 答題 / 書籤 / 紀錄 | 2 秒 debounce |
| 資料集匯入 / 刪除 | 立即同步 |
| 登入 | 載入雲端進度 |
| 登出 | resetState() 清除全部狀態 |

---

## 注意事項

- **Email 驗證超額**：免費方案每小時 2 封上限，建議關閉或改用自訂 SMTP
- **清除瀏覽器資料**：localStorage 會消失；登入 Supabase 帳號即可還原
- **Publishable key**：`sb_publishable_` 格式為設計公開用，安全由 RLS 保障
- **原始檔案**：CSV/XLSX 二進制不可序列化；但解析後的題目完整保存

---

## License

MIT © NeuroLearn

---

<p align="center">
  <sub>Built with ❤️ — 單一 HTML，無需安裝，隨時隨地學習</sub>
</p>
