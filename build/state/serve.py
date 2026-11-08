# static server for the v86 pilot + POST /save?img=<name>&file=<fname> to store a saved state
import sys, os, urllib.parse
from http.server import ThreadingHTTPServer, SimpleHTTPRequestHandler
ROOT = sys.argv[1]; PORT = int(sys.argv[2])
class H(SimpleHTTPRequestHandler):
    def __init__(self, *a, **k): super().__init__(*a, directory=ROOT, **k)
    def end_headers(self):
        self.send_header("Cache-Control", "no-store")
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        super().end_headers()
    def log_message(self, *a): pass
    def do_POST(self):
        q = urllib.parse.parse_qs(urllib.parse.urlparse(self.path).query)
        img = os.path.basename(q["img"][0]); fn = os.path.basename(q["file"][0])
        n = int(self.headers["Content-Length"]); data = self.rfile.read(n)
        os.makedirs(os.path.join(ROOT, "img", img), exist_ok=True)
        with open(os.path.join(ROOT, "img", img, fn), "wb") as f: f.write(data)
        self.send_response(200); self.end_headers(); self.wfile.write(str(n).encode())
SimpleHTTPRequestHandler.extensions_map.update({".wasm": "application/wasm", ".zst": "application/octet-stream"})
ThreadingHTTPServer(("127.0.0.1", PORT), H).serve_forever()
