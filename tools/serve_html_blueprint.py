"""Explicit loopback-only Blueprint preview, never a general filesystem server."""
from __future__ import annotations

import argparse
from datetime import datetime, timezone
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import hashlib
import json
import mimetypes
import os
from pathlib import Path
import secrets
import re
import threading
from urllib.parse import unquote, urlsplit
import webbrowser

import html_blueprint as model

ROOT = model.ROOT


def valid_peer(host, origin, port):
    hosts = {f'127.0.0.1:{port}', f'localhost:{port}'}
    return host in hosts and (not origin or origin in {'http://'+h for h in hosts})


def resolve_request(root, allowed, request, token):
    route = unquote(urlsplit(request).path)
    prefix = '/p/'+token+'/'
    if not route.startswith(prefix):
        raise ValueError('Unknown preview route')
    rel = route[len(prefix):]
    path = model.local_path(root, rel)
    if rel not in allowed or path.suffix.lower() in {'.exe', '.pck', '.cmd', '.ps1'}:
        raise ValueError('Not in the published read-only allowlist')
    if model.sha(path) != allowed[rel]:
        raise ValueError('Source changed since publication; regenerate and reopen')
    return path


def load_allowlist():
    manifest = model.read(ROOT, 'output/blueprint/manifest.json')
    for name, expected in manifest['outputs'].items():
        if model.sha(model.local_path(ROOT, 'output/blueprint/'+name)) != expected:
            raise ValueError('Incomplete publication; regenerate before preview')
    allowed = dict(manifest['inputs'])
    allowed.update(manifest.get('media', {}))
    for rel in ['output/blueprint/index.html', 'output/blueprint/manifest.json', 'output/blueprint/resume-index.json']:
        allowed[rel] = model.sha(model.local_path(ROOT, rel))
    return allowed


def create_server(allowed, token, port=0):
    class Handler(BaseHTTPRequestHandler):
        def do_GET(self):
            self.respond(False)

        def do_HEAD(self):
            self.respond(True)

        def do_POST(self):
            self.send_error(405, 'Read-only preview')

        def respond(self, head):
            if not valid_peer(self.headers.get('Host'), self.headers.get('Origin'), self.server.server_port):
                self.send_error(403, 'Loopback preview only')
                return
            try:
                path = resolve_request(ROOT, allowed, self.path, token)
            except (ValueError, FileNotFoundError):
                self.send_error(404, 'Not published or changed; regenerate and reopen')
                return
            data = path.read_bytes()
            rel = path.relative_to(ROOT).as_posix()
            if hashlib.sha256(data).hexdigest() != allowed[rel]:
                self.send_error(409, 'Source changed during read; regenerate')
                return
            mime = mimetypes.guess_type(path.name)[0] or 'text/plain'
            if path.suffix in {'.md', '.gd', '.tscn', '.tres', '.godot', '.py'}:
                mime = 'text/plain'
            size = len(data)
            start, end = 0, size-1
            requested = self.headers.get('Range') if not head else None
            if requested:
                match = re.fullmatch(r'bytes=(\d*)-(\d*)',requested)
                if match and any(match.groups()):
                    left,right = match.groups()
                    if left:
                        start=int(left);end=min(int(right),size-1) if right else size-1
                    else:
                        start=max(0,size-int(right))
                else:
                    start=size
                if start >= size or end < start:
                    self.send_response(416)
                    self.send_header('Content-Range',f'bytes */{size}')
                    self.send_header('Content-Length','0')
                    self.end_headers()
                    return
                data=data[start:end+1]
            self.send_response(206 if requested else 200)
            self.send_header('Accept-Ranges','bytes')
            if requested:
                self.send_header('Content-Range',f'bytes {start}-{end}/{size}')
            self.send_header('Content-Type', mime+('; charset=utf-8' if mime.startswith('text/') or mime=='application/json' else ''))
            self.send_header('Content-Length', str(len(data)))
            self.send_header('Cache-Control', 'no-store')
            self.send_header('X-Content-Type-Options', 'nosniff')
            self.send_header('Cross-Origin-Resource-Policy', 'same-origin')
            self.send_header('Referrer-Policy', 'no-referrer')
            self.send_header('Content-Security-Policy', "default-src 'none'; img-src 'self'; media-src 'self'; style-src 'unsafe-inline'; script-src 'unsafe-inline'; connect-src 'none'; frame-ancestors 'none'; base-uri 'none'; form-action 'none'")
            self.end_headers()
            if not head:
                self.wfile.write(data)

        def log_message(self, *args):
            pass

    server = ThreadingHTTPServer(('127.0.0.1', port), Handler)
    server.daemon_threads = True
    return server


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--open', action='store_true', help='Open the verified preview in the default browser')
    parser.add_argument('--no-build', action='store_true', help='Serve an already generated, hash-checked snapshot')
    parser.add_argument('--port', type=int, default=0, help='0 selects a free local port')
    parser.add_argument('--minutes', type=int, default=120, help='Bounded lifetime; reopen the launcher to restart')
    args = parser.parse_args()
    if args.minutes <= 0 or args.minutes > 720:
        parser.error('Preview lifetime must be between 1 and 720 minutes')
    if not args.no_build:
        from build_html_blueprint import build
        build()
    allowed = load_allowlist()
    # Validate the entire allowlist before opening a browser.
    token = secrets.token_urlsafe(24)
    for rel in allowed:
        if Path(rel).suffix.lower() not in {'.exe', '.pck', '.cmd', '.ps1'}:
            resolve_request(ROOT, allowed, '/p/'+token+'/'+rel, token)
    server = create_server(allowed, token, args.port)
    url = f'http://127.0.0.1:{server.server_port}/p/{token}/output/blueprint/index.html'
    receipt = {'url': url, 'pid': os.getpid(), 'started_at': datetime.now(timezone.utc).isoformat(),
               'lifetime_minutes': args.minutes, 'binding': '127.0.0.1', 'allowed_files': len(allowed),
               'index_sha256': model.sha(ROOT/'output/blueprint/index.html'), 'read_only': True}
    (ROOT/'output/blueprint/preview-session.json').write_text(json.dumps(receipt, indent=2)+'\n', encoding='utf-8')
    print(url, flush=True)
    if args.open:
        webbrowser.open(url)
    timer = threading.Timer(args.minutes*60, server.shutdown)
    timer.daemon = True
    timer.start()
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        timer.cancel()
        server.server_close()


if __name__ == '__main__':
    main()
