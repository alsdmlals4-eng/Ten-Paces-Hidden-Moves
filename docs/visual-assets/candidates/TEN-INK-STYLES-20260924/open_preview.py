"""Open only this art-style candidate gallery through the existing loopback preview."""
from __future__ import annotations
import argparse
import hashlib
import json
from pathlib import Path
import secrets
import sys
import threading
import time
import webbrowser

PACKAGE = Path(__file__).resolve().parent
PROJECT = PACKAGE.parents[3]
sys.path.insert(0, str(PROJECT / "tools"))
from serve_html_blueprint import PreviewLease, create_server, resolve_request

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--open", action="store_true")
    parser.add_argument("--minutes", type=int, default=120)
    args = parser.parse_args()
    if not 1 <= args.minutes <= 720:
        parser.error("minutes must be between 1 and 720")
    manifest = json.loads((PACKAGE / "candidates.json").read_text(encoding="utf-8"))
    allowed = {}
    published_images = list(manifest["variants"])
    if manifest.get("hybrid"):
        published_images.append(manifest["hybrid"])
    for candidate in published_images:
        path = (PACKAGE / candidate["file"]).resolve()
        if path.parent != PACKAGE or path.suffix != ".png":
            raise ValueError("Unexpected image path")
        digest = hashlib.sha256(path.read_bytes()).hexdigest()
        if digest != candidate["sha256"]:
            raise ValueError("Image changed: " + candidate["file"])
        allowed[path.relative_to(PROJECT).as_posix()] = digest
    for media in manifest.get("motion", {}).get("files", []):
        path = (PACKAGE / media["file"]).resolve()
        if path.parent not in {PACKAGE / "clash-v1", PACKAGE / "clash-v2"} or path.suffix not in {".png", ".gif", ".mp4"}:
            raise ValueError("Unexpected motion path")
        digest = hashlib.sha256(path.read_bytes()).hexdigest()
        if digest != media["sha256"]:
            raise ValueError("Motion changed: " + media["file"])
        allowed[path.relative_to(PROJECT).as_posix()] = digest
    example = PROJECT / "docs/blueprint/reuse-kit/example/index.html"
    if example.is_file():
        allowed[example.relative_to(PROJECT).as_posix()] = hashlib.sha256(example.read_bytes()).hexdigest()
    index = PACKAGE / "index.html"
    allowed[index.relative_to(PROJECT).as_posix()] = hashlib.sha256(index.read_bytes()).hexdigest()
    token = secrets.token_urlsafe(24)
    for rel in allowed:
        resolve_request(PROJECT, allowed, "/p/" + token + "/" + rel, token)
    lease = PreviewLease(args.minutes * 60)
    server = create_server(allowed, token, 0, review_store=None, lease=lease)
    url = f"http://127.0.0.1:{server.server_port}/p/{token}/" + index.relative_to(PROJECT).as_posix()
    print(url, flush=True)
    if args.open:
        webbrowser.open(url)
    def close_when_idle():
        while not lease.expired():
            time.sleep(30)
        server.shutdown()
    threading.Thread(target=close_when_idle, daemon=True).start()
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()

if __name__ == "__main__":
    main()
