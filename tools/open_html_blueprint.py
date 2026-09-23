"""Reopen a verified Blueprint, recovering expired sessions without global setup."""
from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
import time
import webbrowser

import serve_html_blueprint as preview


def open_blueprint(open_browser=True):
    root = preview.ROOT
    output = root / 'output/blueprint'
    output.mkdir(parents=True, exist_ok=True)
    # This lock belongs to this launcher instance, not a background server.
    lock = output / '.launcher.lock'
    descriptor = os.open(lock, os.O_CREAT | os.O_RDWR)
    try:
        if os.name == 'nt':
            import msvcrt
            os.lseek(descriptor, 0, os.SEEK_SET)
            deadline = time.monotonic() + 60
            while True:
                try:
                    msvcrt.locking(descriptor, msvcrt.LK_NBLCK, 1)
                    break
                except OSError:
                    if time.monotonic() >= deadline:
                        raise RuntimeError('다른 블루프린트 실행이 준비 중입니다. 잠시 뒤 다시 열어 주세요.')
                    time.sleep(0.1)
            if os.fstat(descriptor).st_size == 0:
                os.write(descriptor, b'0')
        try:
            allowed = preview.load_allowlist()
            for rel in allowed:
                if (root / rel).suffix.lower() not in {'.exe', '.pck', '.cmd', '.ps1'}:
                    preview.resolve_request(root, allowed, '/p/check/' + rel, 'check')
        except (OSError, ValueError, KeyError):
            from build_html_blueprint import build
            build()
        receipt_path = output / 'preview-session.json'
        def live_url():
            try:
                receipt = json.loads(receipt_path.read_text(encoding='utf-8'))
                return preview.healthy_session_url(receipt, output / 'index.html')
            except (OSError, ValueError):
                return None
        url = live_url()
        if not url:
            with (output / 'preview-server.log').open('ab') as log:
                process = subprocess.Popen(
                    [sys.executable, str(root / 'tools/serve_html_blueprint.py'), '--no-build'],
                    cwd=root, stdin=subprocess.DEVNULL, stdout=log, stderr=log,
                    creationflags=subprocess.CREATE_NO_WINDOW if os.name == 'nt' else 0,
                    start_new_session=os.name != 'nt')
            deadline = time.monotonic() + 30
            while time.monotonic() < deadline:
                url = live_url()
                if url: break
                if process.poll() is not None:
                    raise RuntimeError('미리보기를 시작하지 못했습니다. output/blueprint/preview-server.log를 확인하세요.')
                time.sleep(0.2)
            if not url:
                raise RuntimeError('미리보기 준비 시간을 초과했습니다. 잠시 뒤 다시 열어 주세요.')
        if open_browser: webbrowser.open(url)
        print(url, flush=True)
        return url
    finally:
        os.close(descriptor)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--no-open', action='store_true', help='AI 검수용 현재 주소만 출력')
    args = parser.parse_args()
    open_blueprint(not args.no_open)
