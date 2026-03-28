import http.server
import socketserver
import os

PORT = 44702
DIRECTORY = "build/web"

class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

    def end_headers(self):
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
        self.send_header("Access-Control-Allow-Origin", "*")
        super().end_headers()

if __name__ == "__main__":
    if not os.path.exists(DIRECTORY):
        print(f"Error: Directory {DIRECTORY} not found. Run 'flutter build web' first.")
        exit(1)
    
    with socketserver.TCPServer(("", PORT), Handler) as httpd:
        print(f"Serving at http://localhost:{PORT}")
        httpd.serve_forever()
