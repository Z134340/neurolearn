#!/bin/bash
# 由 BACKLOG.md 種子化 GitHub Issues。
# 前提：已安裝並登入 gh CLI（gh auth login），且在本 repo 目錄執行。
# 用法：cd ~/NeuroLearn && bash scripts/seed_issues.sh
# 註：B5(console 收斂) 與 B8(CI) 已於 Cowork 完成，故不在此清單。
set -e

command -v gh >/dev/null 2>&1 || { echo "❌ 需先安裝並登入 gh CLI：brew install gh && gh auth login"; exit 1; }

echo "=== 建立 labels（已存在則略過）==="
gh label create "type:perf"            --color FBCA04 --description "效能/穩定"   2>/dev/null || true
gh label create "type:maintainability" --color 0E8A16 --description "可維護性"   2>/dev/null || true
gh label create "type:security"        --color B60205 --description "安全"       2>/dev/null || true
gh label create "type:quality"         --color 1D76DB --description "品質/測試"  2>/dev/null || true
gh label create "type:ux"              --color C5DEF5 --description "使用者體驗" 2>/dev/null || true
gh label create "type:chore"           --color CCCCCC --description "雜項"       2>/dev/null || true
gh label create "prio:high"   --color B60205 2>/dev/null || true
gh label create "prio:medium" --color FBCA04 2>/dev/null || true
gh label create "prio:low"    --color C2E0C6 2>/dev/null || true

mk(){ echo "→ $1"; gh issue create --title "$1" --body "$(printf '%b' "$2")" --label "$3"; }

mk "B1 localStorage 大宗資料改存 IndexedDB" \
"extraQs / materials 移出 localStorage blob 至 IndexedDB，避免 5MB 上限與三段降級。\n實作方案見 BACKLOG.md「B1 IndexedDB 實作方案」。\n驗收：上傳 >5MB 不再觸發降級 warning；離線重開資料完整；登入後 cloud 覆蓋正常。" \
"type:perf,prio:medium"

mk "B2 模組化 build step（src/ 合併→單一 index.html）" \
"以 build 維持單檔部署，同時解開 4438 行單檔的可維護性。架構決策，需先確認。\n驗收：npm run build 產出與現行 index.html 行為一致的單檔；deploy 不變。" \
"type:maintainability,prio:medium"

mk "B3 102 處 inline onclick → 事件委派" \
"移除 inline handler，改 event delegation，解鎖可測性。\n驗收：行為不變、可被測試掛載。" \
"type:maintainability,prio:medium"

mk "B4 30 處 innerHTML 注入點 XSS 稽核" \
"針對渲染使用者上傳內容的 innerHTML 注入點做稽核，高風險者改 textContent/escape。\n驗收：附稽核清單；高風險點修補。" \
"type:security,prio:medium"

mk "B6 alert/confirm → 站內 toast/modal" \
"7×alert() + 2×confirm() 改為站內非阻斷 UI。\n驗收：阻斷式對話框移除，UX 一致。" \
"type:ux,prio:low"

mk "B7 端到端 smoke test（Playwright）" \
"涵蓋登入→匯入→測驗→同步→教材→AI 生成 happy path。重構前的迴歸護網。" \
"type:quality,prio:medium"

mk "B9 解決現存 1 處 TODO" \
"grep -n 'TODO' index.html 定位並清零或轉 issue。" \
"type:chore,prio:low"

mk "B10 Firestore Security Rules 部署驗證 + apiKey 公開性註記" \
"確認 rules 已部署且符合 README；文件標明 FIREBASE_CONFIG.apiKey 為 client-side 公開值（非機密）。" \
"type:security,prio:medium"

mk "B11 單檔函式分組可導覽" \
"4438 行單檔的章節 anchor/索引；部分已由 AGENTS.md Code Map 覆蓋。" \
"type:maintainability,prio:low"

echo "✅ 完成。已建立 9 個 issues（B5/B8 已由 Cowork 完成）。"
