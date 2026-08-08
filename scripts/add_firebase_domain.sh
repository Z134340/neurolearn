#!/usr/bin/env bash
# 安全地將網域加入 Firebase Auth 的 Authorized domains。
#
# 為什麼需要這支腳本：
#   Identity Toolkit 的 config API 對 authorizedDomains 是「整個陣列覆寫」，
#   直接 PATCH 一個只含新網域的陣列，會把 localhost 與既有網域全部刪掉，
#   線上站當場無法登入。本腳本一律先讀取現況、合併、再寫回，且只增不減。
#
# 用法：
#   bash scripts/add_firebase_domain.sh neurolearn.pages.dev
#   bash scripts/add_firebase_domain.sh --dry-run neurolearn.pages.dev
#
# 前置：
#   gcloud auth login          # 需為該 Firebase 專案的 Owner/Editor
#   （或 gcloud auth application-default login）

set -euo pipefail

PROJECT_ID="neurolearn-c13f9"
API="https://identitytoolkit.googleapis.com/admin/v2/projects/${PROJECT_ID}/config"

DRY_RUN=0
DOMAIN=""
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    -*)        echo "未知選項：$arg" >&2; exit 2 ;;
    *)         DOMAIN="$arg" ;;
  esac
done

if [ -z "$DOMAIN" ]; then
  echo "用法：bash scripts/add_firebase_domain.sh [--dry-run] <網域>" >&2
  echo "例：  bash scripts/add_firebase_domain.sh neurolearn.pages.dev" >&2
  exit 2
fi

# 只接受純網域，不接受含 scheme / 路徑 / 埠號的輸入
if ! printf '%s' "$DOMAIN" | grep -qE '^[a-zA-Z0-9]([a-zA-Z0-9.-]*[a-zA-Z0-9])?$'; then
  echo "✗ 網域格式不正確：$DOMAIN" >&2
  echo "  請填純網域，例如 neurolearn.pages.dev（不要含 https:// 或結尾斜線）" >&2
  exit 2
fi

command -v gcloud >/dev/null || { echo "✗ 找不到 gcloud，請先安裝 Google Cloud SDK" >&2; exit 1; }
command -v jq     >/dev/null || { echo "✗ 找不到 jq，請先安裝（brew install jq）" >&2; exit 1; }

echo "→ 取得存取權杖…"
TOKEN="$(gcloud auth print-access-token)" || {
  echo "✗ 無法取得 token，請先執行：gcloud auth login" >&2; exit 1; }

echo "→ 讀取 ${PROJECT_ID} 目前的 Authorized domains…"
CURRENT_JSON="$(curl -sS -H "Authorization: Bearer ${TOKEN}" "${API}")"

if ! printf '%s' "$CURRENT_JSON" | jq -e '.authorizedDomains' >/dev/null 2>&1; then
  echo "✗ 讀取失敗，API 回應如下：" >&2
  printf '%s\n' "$CURRENT_JSON" >&2
  exit 1
fi

echo "目前已授權的網域："
printf '%s' "$CURRENT_JSON" | jq -r '.authorizedDomains[] | "  - " + .'

if printf '%s' "$CURRENT_JSON" | jq -e --arg d "$DOMAIN" '.authorizedDomains | index($d)' >/dev/null; then
  echo "✓ 「${DOMAIN}」已在清單中，無需變更。"
  exit 0
fi

# 只增不減：既有清單 + 新網域
MERGED="$(printf '%s' "$CURRENT_JSON" | jq --arg d "$DOMAIN" '{authorizedDomains: (.authorizedDomains + [$d])}')"

echo
echo "將寫入的完整清單（既有全部保留，新增 ${DOMAIN}）："
printf '%s' "$MERGED" | jq -r '.authorizedDomains[] | "  - " + .'
echo

if [ "$DRY_RUN" -eq 1 ]; then
  echo "（--dry-run：未實際寫入）"
  exit 0
fi

read -r -p "確認寫入？[y/N] " ans
case "$ans" in
  y|Y) ;;
  *)   echo "已取消。"; exit 0 ;;
esac

echo "→ 寫入…"
RESP="$(curl -sS -X PATCH \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d "${MERGED}" \
  "${API}?updateMask=authorizedDomains")"

if printf '%s' "$RESP" | jq -e '.authorizedDomains | index("'"$DOMAIN"'")' >/dev/null 2>&1; then
  echo "✓ 完成。目前授權網域："
  printf '%s' "$RESP" | jq -r '.authorizedDomains[] | "  - " + .'
else
  echo "✗ 寫入結果異常，API 回應：" >&2
  printf '%s\n' "$RESP" >&2
  exit 1
fi
