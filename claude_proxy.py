#!/usr/bin/env python3
"""
NeuroLearn Claude Proxy
將瀏覽器的 AI 生成請求，透過本機 claude CLI 轉送至 Claude claude-sonnet-4-6。
Port: 7734  |  只接受 127.0.0.1 本機請求
"""

import subprocess
import json
import shutil
from http.server import HTTPServer, BaseHTTPRequestHandler

PORT = 7734
ALLOWED_ORIGIN = '*'   # 僅本機使用，CORS 全開


class ProxyHandler(BaseHTTPRequestHandler):

    def log_message(self, format, *args):
        pass  # 靜默執行，不輸出每筆 request log

    # ── CORS preflight ──────────────────────────────────────────────────────
    def do_OPTIONS(self):
        self.send_response(200)
        self._set_cors()
        self.end_headers()

    # ── 健康檢查 ─────────────────────────────────────────────────────────────
    def do_GET(self):
        if self.path == '/health':
            self._json(200, {'ok': True, 'model': 'claude-sonnet-4-6'})
        else:
            self._json(404, {'ok': False, 'error': 'not found'})

    # ── 生成請求 ─────────────────────────────────────────────────────────────
    def do_POST(self):
        try:
            length = int(self.headers.get('Content-Length', 0))
            body   = json.loads(self.rfile.read(length) or b'{}')
            prompt = body.get('prompt', '').strip()
            model  = body.get('model', 'claude-sonnet-4-6')

            if not prompt:
                return self._json(400, {'ok': False, 'error': 'prompt 不可為空'})

            claude_bin = shutil.which('claude')
            if not claude_bin:
                return self._json(500, {
                    'ok': False,
                    'error': '找不到 claude 指令，請確認 Claude Code CLI 已安裝'
                })

            result = subprocess.run(
                [claude_bin, '-p', prompt, '--model', model],
                capture_output=True,
                text=True,
                timeout=180
            )

            text = result.stdout.strip()
            if not text and result.stderr:
                raise RuntimeError(result.stderr.strip())

            self._json(200, {'ok': True, 'text': text})

        except subprocess.TimeoutExpired:
            self._json(504, {'ok': False, 'error': '生成逾時（180 秒），請減少題數後重試'})
        except Exception as e:
            self._json(500, {'ok': False, 'error': str(e)})

    # ── 工具方法 ─────────────────────────────────────────────────────────────
    def _set_cors(self):
        self.send_header('Access-Control-Allow-Origin',  ALLOWED_ORIGIN)
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')

    def _json(self, code, data):
        body = json.dumps(data, ensure_ascii=False).encode()
        self.send_response(code)
        self._set_cors()
        self.send_header('Content-Type',   'application/json; charset=utf-8')
        self.send_header('Content-Length', str(len(body)))
        self.end_headers()
        self.wfile.write(body)


if __name__ == '__main__':
    server = HTTPServer(('127.0.0.1', PORT), ProxyHandler)
    print(f'[NeuroLearn Proxy] 啟動於 http://127.0.0.1:{PORT}  (claude-sonnet-4-6)')
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print('\n[NeuroLearn Proxy] 已停止')
