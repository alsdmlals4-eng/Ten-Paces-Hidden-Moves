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
import http.client

import html_blueprint as model

ROOT = model.ROOT


def healthy_session_url(receipt, index):
    """Only reuse a live loopback session serving these exact published bytes."""
    connection = None
    try:
        url = receipt.get('url', '')
        parsed = urlsplit(url)
        if (parsed.scheme != 'http' or parsed.hostname != '127.0.0.1'
                or parsed.username or parsed.password or not parsed.port
                or parsed.query or parsed.fragment
                or not re.fullmatch(r'/p/[A-Za-z0-9_-]+/output/blueprint/index\.html', parsed.path)):
            return None
        expected = model.sha(index)
        if receipt.get('index_sha256') != expected:
            return None
        connection = http.client.HTTPConnection('127.0.0.1', parsed.port, timeout=2)
        connection.request('GET', parsed.path)
        response = connection.getresponse()
        data = response.read(index.stat().st_size + 1)
        return url if response.status == 200 and hashlib.sha256(data).hexdigest() == expected else None
    except (OSError, ValueError, http.client.HTTPException):
        return None
    finally:
        if connection:
            connection.close()


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
    if 'image_inventory_digest' in manifest:
        from html_blueprint_audit import inventory_digest
        if inventory_digest(ROOT) != manifest['image_inventory_digest']:
            raise ValueError('Image inventory or references changed; regenerate before preview')
    for name, expected in manifest['outputs'].items():
        if model.sha(model.local_path(ROOT, 'output/blueprint/'+name)) != expected:
            raise ValueError('Incomplete publication; regenerate before preview')
    allowed = dict(manifest['inputs'])
    allowed.update(manifest.get('media', {}))
    for rel in ['output/blueprint/index.html', 'output/blueprint/manifest.json', 'output/blueprint/resume-index.json']:
        allowed[rel] = model.sha(model.local_path(ROOT, rel))
    return allowed


def create_server(allowed, token, port=0, review_store=None):
    class Handler(BaseHTTPRequestHandler):
        def do_GET(self):
            self.respond(False)

        def do_HEAD(self):
            self.respond(True)

        def do_POST(self):
            if self.path != '/p/'+token+'/_review' or review_store is None:
                self.send_error(405, 'Only the explicit user review endpoint accepts writes')
                return
            if (not valid_peer(self.headers.get('Host'), self.headers.get('Origin'), self.server.server_port)
                    or self.headers.get('Origin') != f'http://127.0.0.1:{self.server.server_port}'
                    or self.headers.get('X-Blueprint-Review') != '1'
                    or self.headers.get('Content-Type', '').split(';')[0] != 'application/json'):
                self.send_error(403, 'Same-origin review request required')
                return
            from blueprint_review_store import LIMIT, Conflict
            try:
                length = int(self.headers.get('Content-Length', '0'))
                if length <= 0 or length > LIMIT or self.headers.get('Transfer-Encoding'):
                    raise ValueError('Invalid review request size')
                self.connection.settimeout(5)
                request = json.loads(self.rfile.read(length))
                if not isinstance(request, dict): raise ValueError('Expected review object')
                data = (review_store.import_document(request['document'], request.get('revision'))
                        if request.get('action') == 'import' else review_store.save(request))
                self.review_response(200, data)
            except Conflict as error:
                self.review_response(409, {'error': str(error)})
            except (ValueError, KeyError, OSError) as error:
                self.review_response(400, {'error': str(error)})

        def review_response(self, status, data, head=False, download=False):
            raw = json.dumps(data, ensure_ascii=False).encode('utf-8')
            self.send_response(status)
            self.send_header('Content-Type', 'application/json; charset=utf-8')
            self.send_header('Content-Length', str(len(raw)))
            self.send_header('Cache-Control', 'no-store')
            self.send_header('X-Content-Type-Options', 'nosniff')
            self.send_header('Cross-Origin-Resource-Policy', 'same-origin')
            if download:
                self.send_header('Content-Disposition', 'attachment; filename="ten-paces-user-review.json"')
            self.end_headers()
            if not head: self.wfile.write(raw)

        def respond(self, head):
            if not valid_peer(self.headers.get('Host'), self.headers.get('Origin'), self.server.server_port):
                self.send_error(403, 'Loopback preview only')
                return
            if self.path in {'/p/'+token+'/_review', '/p/'+token+'/_review/export'} and review_store is not None:
                try:
                    self.review_response(200, review_store.read(), head, self.path.endswith('/export'))
                except (ValueError, OSError) as error:
                    self.review_response(409, {'error': '검토 원본을 보존했습니다. '+str(error)}, head)
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
            self.send_header('Content-Security-Policy', "default-src 'none'; img-src 'self'; media-src 'self'; style-src 'unsafe-inline'; script-src 'unsafe-inline'; connect-src 'self'; frame-ancestors 'none'; base-uri 'none'; form-action 'none'")
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
    from blueprint_review_store import ReviewStore, shared_directory
    review_store = ReviewStore(shared_directory(ROOT))
    server = create_server(allowed, token, args.port, review_store=review_store)
    url = f'http://127.0.0.1:{server.server_port}/p/{token}/output/blueprint/index.html'
    receipt = {'url': url, 'pid': os.getpid(), 'started_at': datetime.now(timezone.utc).isoformat(),
               'lifetime_minutes': args.minutes, 'binding': '127.0.0.1', 'allowed_files': len(allowed),
               'index_sha256': model.sha(ROOT/'output/blueprint/index.html'), 'read_only': False,
               'repository_files_read_only': True, 'review_file': str(review_store.path),
               'write_scope': 'USER_REVIEW_ONLY'}
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
