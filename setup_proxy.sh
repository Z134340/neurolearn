#!/bin/bash
# NeuroLearn Claude Proxy — 一鍵安裝腳本（只需執行一次）

set -e

PLIST_SRC="$(cd "$(dirname "$0")" && pwd)/com.neurolearn.proxy.plist"
PLIST_DST="$HOME/Library/LaunchAgents/com.neurolearn.proxy.plist"

echo "=== NeuroLearn Claude Proxy 安裝 ==="

# 檢查 claude CLI
if ! command -v claude &>/dev/null; then
  echo "❌ 找不到 claude 指令，請先安裝 Claude Code CLI"
  echo "   https://claude.ai/code"
  exit 1
fi
echo "✅ claude CLI 已找到：$(which claude)"

# 複製 plist
cp "$PLIST_SRC" "$PLIST_DST"
echo "✅ 已安裝 launchd 設定到 $PLIST_DST"

# 若舊服務已在執行，先卸載
launchctl unload "$PLIST_DST" 2>/dev/null || true

# 載入（立即啟動 + 設為開機自動執行）
launchctl load "$PLIST_DST"
echo "✅ 服務已啟動（開機後自動執行）"

# 等待啟動
sleep 1

# 健康檢查
if curl -sf http://127.0.0.1:7734/health | grep -q '"ok":true'; then
  echo ""
  echo "🎉 安裝完成！Proxy 正在 http://127.0.0.1:7734 執行"
  echo "   往後開機自動啟動，無需手動操作"
else
  echo ""
  echo "⚠️  Proxy 已安裝但尚未回應，請查看 log："
  echo "   cat /tmp/neurolearn_proxy.log"
fi
