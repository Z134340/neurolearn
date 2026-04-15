# NeuroLearn 🧠 v2.4

> **智能模擬考平台** — 單一 HTML 檔案，完全離線可用，Firebase 雲端帳號同步，支援 AI 本機生成題目

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
- [AI 生成設定](#ai-生成題目設定)
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
| ✨ **AI 生成題目** | 從教材或考古題自動生成選擇題，透過本機 Claude Proxy 呼叫 claude-sonnet-4-6，免 API 費用 |

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
├── ✨ AI 生成題目（智能模擬考頁面右上角）
│   ├── 選擇來源：教材庫 或 考古題題庫
│   ├── 設定：題數（3-30）/ 難度（基礎 / 應用 / 考試等級）/ 分類標籤
│   ├── 透過本機 Claude Proxy 呼叫 claude-sonnet-4-6
│   ├── 預覽生成結果，可刪除不需要的題目
│   └── 一鍵匯入題庫，自動建立檔案記錄
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

## AI 生成題目設定

AI 生成功能透過本機 Proxy 呼叫你已登入的 Claude Code CLI，**不需要額外的 Anthropic API 費用**。

### 架構

```
瀏覽器（index.html）
  → http://127.0.0.1:7734
  → claude_proxy.py（本機 Python）
  → claude CLI（使用你的 Claude Code Max 訂閱）
  → claude-sonnet-4-6
```

### 首次安裝（只需執行一次）

```bash
cd ~/NeuroLearn && bash setup_proxy.sh
```

安裝後 Proxy 會透過 macOS launchd 在背景自動執行，每次開機自動啟動，無需手動操作。

### 相關檔案

| 檔案 | 說明 |
|------|------|
| `claude_proxy.py` | Proxy 主程式，監聽 port 7734 |
| `com.neurolearn.proxy.plist` | macOS launchd 設定（開機自動啟動）|
| `setup_proxy.sh` | 一鍵安裝腳本 |

### 查看 Proxy 狀態

```bash
# 健康檢查
curl http://127.0.0.1:7734/health

# 查看 log
cat /tmp/neurolearn_proxy.log

# 手動重啟
launchctl unload ~/Library/LaunchAgents/com.neurolearn.proxy.plist
launchctl load ~/Library/LaunchAgents/com.neurolearn.proxy.plist
```

---

## 技術規格

| 項目 | 說明 |
|------|------|
| **架構** | 單一 HTML 檔案，零建構工具、零自製依賴 |
| **框架** | 無（Vanilla JS）|
| **外部依賴** | Firebase JS SDK（compat v10）、Marked.js、SheetJS（xlsx.full.min.js）|
| **AI 生成** | 本機 Claude Proxy（`claude_proxy.py`）+ Claude Code CLI，使用 claude-sonnet-4-6 |
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
| 完成測驗 | 60 秒後（輕量）/ 5 分鐘後（全量）|
| 書籤 / 移除書籤 | 60 秒後 |
| 上傳 / 刪除資料集 | 60 秒後（輕量）/ 5 分鐘後（全量）|
| 新增 / 移除標籤 | 60 秒後 |
| 匯入 JSON 備份 | 60 秒後 |
| 教材上傳 / 筆記標記 | 60 秒後 |
| 立即同步按鈕 | 立即 |
| Firestore quota 超限 | 自動暫停 30 分鐘後恢復 |

---

## 更新紀錄

### v2.4（2026-04-15）

- **[修正]** Firestore quota 超限導致大量 backoff log：sync debounce 由 0.8s/3s 拉長至 60s/5min
- **[新增]** `_syncPausedUntil` 機制：偵測到 `resource-exhausted` 時自動暫停所有 Firestore 同步 30 分鐘
- **[修正]** AI 生成匯入被 Firebase onSnapshot 覆蓋：新增 `_localOnlyFiles` 緩衝，loadCloudData 後自動重新合併本地資料
- **[修正]** `saveToStorage()` QuotaExceededError 三段降級：完整 → 移除 explanation → 僅 metadata
- **[修正]** `aiGenImport()` 先呼叫 `render()` 再 `saveToStorage()`，確保 UI 立即反映匯入結果
- **[修正]** AI Gen 全部 id 比對統一 `String()` 型別轉換（7 處），修正勾選無效 / 計數不準問題
- **[修正]** 儀表板分類統計除零保護（`st.total=0` 回傳 0，結果 clamp 至 100）
- **[修正]** `aiGenRun()` 防重複點擊（生成中再點無效）
- **[優化]** AI Gen Modal 背景點擊可關閉

### v2.3（2026-04-15）

- **[新增]** AI 生成題目功能：在智能模擬考頁面右上角加入「✨ AI 生成題目」按鈕
- **[新增]** 多步驟 Modal：選來源（教材 / 考古題）→ 設定（題數 / 難度 / 標籤）→ 生成中 → 預覽 + 匯入
- **[新增]** 本機 Claude Proxy（`claude_proxy.py`）：透過 Claude Code CLI 呼叫 claude-sonnet-4-6，不需額外 API 費用
- **[新增]** macOS launchd 自動啟動 Proxy（`com.neurolearn.proxy.plist` + `setup_proxy.sh`）
- **[新增]** 考古題選擇改為以檔案為單位顯示（不再依 tag 去重），確保所有上傳檔案都可選
- **[新增]** AI 生成匯入後自動在 `S.files` 建立檔案記錄，題庫頁面立即可見
- **[優化]** AI 生成 Prompt 強化：先萃取高頻考點與易混淆知識點，錯誤選項設計「似是而非」，解析說明排除原因
- **[修正]** `f.id` 型別不一致（數字 vs 字串）導致 Set 比對失敗，統一用 `String(f.id)`
- **[修正]** Modal 開啟自動偵測 Proxy 狀態，顯示連線指示燈

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
