# NeuroLearn 🧠 v2.2

> **智能模擬考平台** — 單一 HTML 檔案，完全離線可用，Firebase 雲端帳號同步

[![Live Demo](https://img.shields.io/badge/Live%20Demo-z134340.github.io-brightgreen?style=flat-square)](https://z134340.github.io/neurolearn/)
[![Single File](https://img.shields.io/badge/架構-Single%20HTML-blueviolet?style=flat-square)](index.html)
[![No Framework](https://img.shields.io/badge/框架-Vanilla%20JS-orange?style=flat-square)](index.html)
[![Firebase](https://img.shields.io/badge/雲端-Firebase-FFCA28?style=flat-square&logo=firebase&logoColor=black)](https://firebase.google.com)
[![PWA](https://img.shields.io/badge/PWA-iOS%20%2F%20Android-blue?style=flat-square)](https://z134340.github.io/neurolearn/)

**🌐 立即使用：https://z134340.github.io/neurolearn/**

---

## 目錄

- [功能概覽](#功能概覽)
- [網站架構圖](#網站架構圖)
- [快速開始](#快速開始)
- [題庫格式](#題庫格式)
- [Firebase 設定](#firebase-雲端同步設定)
- [技術規格](#技術規格)
- [資料儲存說明](#資料儲存說明)
- [更新紀錄](#更新紀錄)

---

## 功能概覽

| 功能 | 說明 |
|------|------|
| 📂 **自訂題庫** | 上傳 CSV / XLSX，支援單選、多選（AB / A,B / A+B 格式）|
| 🎯 **三種模式** | 開始新測驗（不重複出題）/ 複習已標記 / 錯誤題目驗測 |
| 🔢 **不重複出題** | 記錄已出過的題目，下次自動排除，顯示剩餘可用題數 |
| ☑️ **多選題** | 自動偵測，勾選框 UI，「可選多個答案」提醒 |
| 📄 **出處標注** | 每題解析下方顯示來源檔名與題號 |
| 🔖 **書籤系統** | 任何模式下標記題目，集中複習 |
| ⬅️ **上一題** | 可回頭修改已作答選項 |
| 📈 **儀表板** | 測驗歷史、分數趨勢圖（純 Canvas，無 CDN）|
| ☁️ **雲端同步** | Firebase Auth + Firestore，即時同步，跨裝置支援 |
| 💾 **進度備份** | 匯出 / 匯入 JSON（含題庫題目）|
| 📱 **PWA** | iPhone / Android 可加到主畫面，完全離線 |
| 📚 **教材庫** | 上傳 Markdown 教材，章節閱讀 + 筆記標記 |

---

## 網站架構圖

```
NeuroLearn
├── 🏠 首頁
│   └── 快速入口卡片
│
├── 📂 考古題題庫（資料集）
│   ├── 拖曳上傳 CSV / XLSX / PDF / DOCX
│   ├── 自動解析（exam / question / option_a~f / answer / explanation）
│   ├── 多選題自動偵測（answer 欄：AB / A,B / A+B）
│   ├── 標籤管理（新增 / 移除 / 篩選）
│   ├── 日期 / 名稱排序，每頁 10 筆分頁
│   ├── 題目出處記錄（來源檔名 / 題號）
│   └── 下載「題目匯入範本.xlsx」（SheetJS 即時產生，含欄寬 + 範例資料）
│
├── 🎯 智能模擬考
│   ├── ① 選擇題目分類（多選 / 全選 / 清除）
│   │
│   ├── ② 選擇測驗模式
│   │   ├── 開始新測驗
│   │   │   ├── 顯示「N 題未考 / 共 M 題」
│   │   │   └── 抽題自動排除 usedQIds（已考過）
│   │   ├── 複習已標記題目
│   │   │   ├── 📖 折疊式瀏覽
│   │   │   └── 🎯 重新測驗（逐題作答）
│   │   └── 錯誤題目驗測
│   │       ├── 📖 折疊式瀏覽
│   │       └── 🎯 重新驗測（逐題作答）
│   │
│   ├── ③ 設定題數（滑桿，最大值 = 未考題數）
│   │
│   ├── 作答介面
│   │   ├── 進度條 + 題號 + 分類標籤
│   │   ├── 單選：A-F 字母按鈕
│   │   ├── 多選：勾選框（可複選）+「可選多個答案」提醒
│   │   ├── ← 上一題 / 確認答案 / 下一題 →
│   │   ├── ✏️ 修改答案
│   │   ├── 🔖 書籤
│   │   └── 解析 + 📄 出處（確認後顯示）
│   │
│   └── 成績結果
│       ├── 答對率 + 分類統計
│       ├── 逐題明細（正確/錯誤 + 正確答案）
│       ├── 🔁 再出一份（相同設定重抽）
│       └── 返回選單
│
├── 📊 儀表板
│   ├── 標籤篩選
│   ├── 統計卡（測驗次數 / 答對率 / 錯誤題 / 已標記）
│   ├── ⬇ 下載：錯誤題目 / 已標記題目（CSV + BOM）
│   ├── 測驗分數趨勢圖（純 Canvas / Bezier 曲線 / 色碼數據點）
│   ├── 測驗歷史列表（分頁，每頁 10 筆）
│   │   └── ⬇ 每次可單獨下載（錯誤 / 標記 CSV）
│   └── 進度備份 / 還原
│       ├── ⬇ 匯出 JSON（含題庫、書籤、紀錄）
│       ├── ⬆ 匯入 JSON（自動同步雲端）
│       └── ☁️ 立即同步到雲端
│
├── 📚 教材庫
│   ├── 上傳 Markdown (.md) 教材
│   ├── 標籤管理 + 排序 + 分頁（每頁 10 筆）
│   ├── 章節閱讀（目錄側欄 + 閱讀進度記錄）
│   ├── 段落筆記標記（重要 / 複習 / 疑問 / 背誦）
│   └── 筆記中心 + 教材統計總覽
│
└── 👤 帳號
    ├── 登入 / 註冊 / 忘記密碼 / 重寄驗證信
    ├── 登入 → loadCloudData() → render()
    └── 登出 → resetState() → render()
```

---

## 資料同步架構

```
使用者操作（書籤 / 完成測驗 / 上傳題庫 ...）
         │
         ▼
   saveToStorage()
         ├── localStorage（key: neurolearn_v2_{user_uid}）
         └── scheduleSyncToCloud()  ← 2 秒 debounce
                    │
                    ▼
              Firebase SDK
              Firestore batch write
                    │
                    ▼
           Firestore (Cloud)
     /users/{uid}/progress
     （Firebase Auth + Security Rules）
                    │
                    ▼
        ┌─────────────────────────┐
        │   Firestore Document    │
        │  history[]              │
        │  bookmarks[]            │
        │  wrongQs[]              │
        │  usedQIds[]             │
        │  files[]                │
        │  extraQs[]              │
        │  materials[]            │
        │  annotations[]          │
        │  dashTag                │
        │  tagFilter              │
        └─────────────────────────┘
                    │
                    ▼ onSnapshot（即時監聽）
         其他裝置自動收到更新
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

### XLSX / CSV 欄位定義

| 欄位 | 必填 | 說明 |
|------|:----:|------|
| `exam` | ✅ | 分類名稱（對應題庫標籤）|
| `question` | ✅ | 題目文字 |
| `option_a` ~ `option_f` | ✅ | 選項，最多六個，`option_e`、`option_f` 可留空 |
| `answer` | ✅ | 單選：`B`；多選：`AC`、`A,C`、`A+C` 均可 |
| `explanation` | — | 解析（選填）|

### 下載範本

在「考古題題庫」頁面點擊「**下載題目匯入範本.xlsx**」按鈕，即可下載由 SheetJS 在瀏覽器端即時產生的範本（含欄寬格式設定與範例資料列）。

### CSV 格式（仍支援）

```csv
exam,question,option_a,option_b,option_c,option_d,option_e,option_f,answer,explanation
護理師國考,單選題範例,選項A,選項B,選項C,選項D,,,B,這是解析
護理師國考,多選題範例,選項A,選項B,選項C,選項D,選項E,,AC,多選題解析
```

---

## Firebase 雲端同步設定

### Step 1 — 建立 Firebase 專案

1. 前往 [Firebase Console](https://console.firebase.google.com/)
2. 建立新專案
3. 啟用 **Authentication**（Email / 密碼）
4. 啟用 **Firestore Database**（建議選 Asia-east1）

### Step 2 — 設定 Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
  }
}
```

### Step 3 — 填入 index.html

```javascript
const FIREBASE_CONFIG = {
  apiKey:            "YOUR_API_KEY",
  authDomain:        "your-project.firebaseapp.com",
  projectId:         "your-project",
  storageBucket:     "your-project.firebasestorage.app",
  messagingSenderId: "YOUR_SENDER_ID",
  appId:             "YOUR_APP_ID"
};
```

### Step 4（選填）— 設定 Authorized Domains

Firebase → Authentication → Settings → Authorized domains：加入你的網域。

---

## 技術規格

| 項目 | 說明 |
|------|------|
| **架構** | 單一 HTML 檔案，零建構工具、零自製依賴 |
| **框架** | 無（Vanilla JS）|
| **外部依賴** | Firebase JS SDK（compat v10）、Marked.js、SheetJS（xlsx.full.min.js）|
| **圖表** | 自製 Canvas（Bezier 曲線 / 漸層填色 / Retina 支援）|
| **雲端同步** | Firestore SDK + onSnapshot 即時監聽 |
| **題庫** | 無內建題庫（`QUESTIONS = []`），全由使用者上傳 |
| **離線** | 完全離線可用（雲端功能除外）|
| **iOS** | `viewport-fit=cover` / `safe-area` / 44px 觸控目標 |
| **瀏覽器** | Chrome / Safari / Firefox / Edge 現代版 |

---

## 資料儲存說明

### 10 個同步欄位

| 欄位 | 內容 |
|------|------|
| `history` | 測驗歷史（含 wrongIds / bkIds）|
| `bookmarks` | 已標記題目 ID |
| `wrongQs` | 累計錯誤題目 ID |
| `usedQIds` | 已出過的題目 ID（不重複出題）|
| `files` | 資料集元資料（不含二進制）|
| `extraQs` | 完整題庫題目（解析後）|
| `materials` | 教材內容 |
| `annotations` | 段落筆記標記 |
| `dashTag` | 儀表板篩選標籤 |
| `tagFilter` | 資料集標籤篩選 |

### 多帳號隔離

localStorage key = `neurolearn_v2_{user_uid}`，不同帳號完全隔離。  
Firestore Security Rules 確保每位使用者只能存取自己的資料。

### 同步觸發時機

| 操作 | 觸發方式 |
|------|---------|
| 完成測驗 | 立即 |
| 書籤 / 移除書籤 | 600ms debounce |
| 上傳 / 刪除資料集 | 立即 |
| 新增 / 移除標籤 | 立即 |
| 匯入 JSON 備份 | 立即 |
| 教材上傳 / 筆記標記 | 立即 |
| 立即同步按鈕 | 立即 |

---

## 更新紀錄

### v2.2（2026-04-14）

- **[新增]** 考古題題庫加入「下載題目匯入範本.xlsx」按鈕（SheetJS 即時產生，含欄寬與範例資料）
- **[修正]** `quizResultHTML` 除零保護：`activeQs` 為空時回 idle，防止顯示 Infinity%
- **[修正]** `finishQuiz` / `nextQuestion`：所有 `S.answers[i]` 存取加 null 防禦
- **[修正]** `importCSVQuestions` / `importXLSXQuestions`：補 `FileReader.onerror` 回調，讀取失敗有明確提示
- **[修正]** `bindDataset`：加 `_bound` 旗標防止 drag 事件重複綁定
- **[修正]** `launchQuiz`：pool 為空時顯示明確提示訊息
- **[優化]** 新增 `.empty-state`、`.btn-sync`、`.btn-page`、`.btn-danger`、`.btn-sort` 共用 CSS 類別
- **[優化]** 全站 transition 統一為 `.2s ease`，動畫節奏一致
- **[優化]** 測驗作答頁「上一題 / 修改 / 確認 / 下一題」四個按鈕 padding 與字級統一

### v2.1

- **[修正]** 模擬考結果頁逐題明細：多選題答對時仍顯示 ❌ 的問題
- **[修正]** 多項 Bug 修復（resetState 補全、雲端資料 fallback、排序防禦、XSS 修補）
- **[新增]** 引入 SheetJS（`xlsx.full.min.js`），XLSX 上傳解析正式生效
- **[新增]** 教材庫、考古題題庫加入分頁（每頁 10 筆）、日期/名稱排序
- **[新增]** 教材庫貼標：選已用標籤即關閉面板

### v2.0

- 後端從 Supabase 遷移至 Firebase（Firestore + Auth）
- Firestore onSnapshot 即時跨裝置同步
- 新增教材庫：Markdown 上傳、章節閱讀、段落筆記標記
- 多選題支援
- 書籤、錯題、不重複出題系統
- 純 Canvas 趨勢圖

---

## License

MIT © NeuroLearn

---

<p align="center">
  <sub>單一 HTML · 零安裝 · 離線可用 · <a href="https://z134340.github.io/neurolearn/">立即試用</a></sub>
</p>
