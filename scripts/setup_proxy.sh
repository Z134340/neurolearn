#!/bin/bash
# NeuroLearn Claude Proxy — 一鍵安裝腳本（只需執行一次）
# 動態產生 launchd plist，不再硬編碼使用者路徑；可放在任意位置執行。

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROXY_PY="$SCRIPT_DIR/claude_proxy.py"
PLIST_DST="$HOME/Library/LaunchAgents/com.neurolearn.proxy.plist"

echo "=== NeuroLearn Claude Proxy 安裝 ==="

# 檢查 claude CLI
if ! command -v claude &>/dev/null; then
  echo "❌ 找不到 claude 指令，請先安裝 Claude Code CLI"
  echo "   https://claude.ai/code"
  exit 1
fi
echo "✅ claude CLI 已找到：$(which claude)"

# 找 python3（動態，不硬編碼）
PY3="$(command -v python3 || true)"
if [ -z "$PY3" ]; then
  echo "❌ 找不到 python3"
  exit 1
fi
echo "✅ python3 已找到：$PY3"

# 確認 proxy 主程式存在
if [ ! -f "$PROXY_PY" ]; then
  echo "❌ 找不到 $PROXY_PY"
  exit 1
fi

# 動態產生 plist（路徑由實際位置計算，避免硬編碼）
mkdir -p "$HOME/Library/LaunchAgents"
cat > "$PLIST_DST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.neurolearn.proxy</string>
  <key>ProgramArguments</key>
  <array>
    <string>$PY3</string>
    <string>$PROXY_PY</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <true/>
  <key>StandardOutPath</key>
  <string>/tmp/neurolearn_proxy.log</string>
  <key>StandardErrorPath</key>
  <string>/tmp/neurolearn_proxy.log</string>
</dict>
</plist>
PLIST
echo "✅ 已產生 launchd 設定：$PLIST_DST"
echo "   → $PY3 $PROXY_PY"

# 若舊服務已在執行，先卸載
launchctl unload "$PLIST_DST" 2>/dev/null || true

# 載入（立即啟動 + 設為開機自動執行）
launchctl load "$PLIST_DST"
echo "✅ 服務已啟動（開機後自動執行）"

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
