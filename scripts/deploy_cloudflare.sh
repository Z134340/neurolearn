#!/usr/bin/env bash
# 在本機以 wrangler 將 public/ 部署至 Cloudflare Pages。
#
# 適用情境：在自己的電腦上執行（遠端沙箱的網路政策擋掉 api.cloudflare.com）。
# 首次執行會開瀏覽器要求你登入 Cloudflare 授權，之後憑證由 wrangler 保存。
#
# 用法：
#   bash scripts/deploy_cloudflare.sh              # 部署至 production（main）
#   bash scripts/deploy_cloudflare.sh --preview    # 部署至 preview 分支，不影響正式站
#
# 部署完成後別忘了：
#   bash scripts/add_firebase_domain.sh <配發的 pages.dev 網域>

set -euo pipefail

PROJECT_NAME="neurolearn"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PUBLISH_DIR="${REPO_ROOT}/public"

BRANCH="main"
[ "${1:-}" = "--preview" ] && BRANCH="preview"

command -v npx >/dev/null || { echo "✗ 找不到 npx，請先安裝 Node.js" >&2; exit 1; }

if [ ! -f "${PUBLISH_DIR}/index.html" ]; then
  echo "✗ 找不到 ${PUBLISH_DIR}/index.html" >&2
  echo "  請確認已 git pull 到含 public/ 結構的版本（commit 11e941e 之後）。" >&2
  exit 1
fi

echo "→ 發布目錄：${PUBLISH_DIR}"
echo "→ 目標專案：${PROJECT_NAME}（branch=${BRANCH}）"
echo "→ 內容檢查："
echo "   檔案數 $(find "${PUBLISH_DIR}" -type f | wc -l | tr -d ' ')  大小 $(du -sh "${PUBLISH_DIR}" | cut -f1)"
find "${PUBLISH_DIR}" -type f -printf '     %P\n' 2>/dev/null || find "${PUBLISH_DIR}" -type f | sed "s|${PUBLISH_DIR}/|     |"
echo

# 專案已存在時 create 會回非零，屬預期
echo "→ 確認 Pages 專案存在（已存在則略過）…"
npx --yes wrangler@3 pages project create "${PROJECT_NAME}" \
  --production-branch=main >/dev/null 2>&1 || true

echo "→ 部署中…"
npx --yes wrangler@3 pages deploy "${PUBLISH_DIR}" \
  --project-name="${PROJECT_NAME}" \
  --branch="${BRANCH}" \
  --commit-dirty=true

cat <<'EOF'

──────────────────────────────────────────────
部署完成。接下來務必做這兩件事：

1. 把上方輸出的 *.pages.dev 網域加入 Firebase 白名單，否則新站無法登入：
     bash scripts/add_firebase_domain.sh <網域>

2. 依 docs/DEPLOY.md §4 驗證，其中最關鍵的一項是：
     註冊新帳號 → 收驗證信 → 點連結，回跳網址應為新網域而非 github.io
   （這才能證明 appBaseUrl() 生效）
──────────────────────────────────────────────
EOF
