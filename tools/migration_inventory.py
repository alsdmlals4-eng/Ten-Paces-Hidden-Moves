#!/usr/bin/env python3
"""Read-only file-level baseline inventory for the Ten Paces documentation migration."""
from __future__ import annotations
import argparse, hashlib, json, subprocess
from pathlib import Path

def git(*args: str) -> bytes:
    return subprocess.run(["git", *args], check=True, capture_output=True).stdout

def disposition(path: str) -> str:
    if path.startswith(("[백업]/", "archive/", "docs/archive/", ".superpowers/")): return "[백업]"
    if path.startswith(("[보류]/", "docs/proposals/", "docs/notes/")): return "[보류]"
    if path.startswith(("assets/", "tests/", "data/")): return "[증거]"
    if path.endswith((".md", ".docx", ".pdf", ".html")): return "[본책 이주]"
    return "[증거]"

def headings(data: bytes) -> list[str]:
    try: text=data.decode('utf-8')
    except UnicodeDecodeError: return []
    return [line.lstrip('#').strip() for line in text.splitlines() if line.startswith(('# ', '## '))]

def main() -> int:
    p=argparse.ArgumentParser(); p.add_argument('--ref',required=True); p.add_argument('--output',required=True); a=p.parse_args(); rows=[]
    for entry in git('ls-tree','-r','-z',a.ref).split(b'\0'):
        if not entry: continue
        meta,raw=entry.split(b'\t',1); _,kind,blob=meta.decode().split()
        if kind!='blob': continue
        data=git('cat-file','-p',blob); path=raw.decode()
        rows.append({'path':path,'blob':blob,'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest(),'suffix':Path(path).suffix.lower(),'headings':headings(data),'disposition':disposition(path)})
    output=Path(a.output); output.parent.mkdir(parents=True,exist_ok=True); output.write_text(json.dumps({'baseline_ref':a.ref,'files':rows},ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print(f'Inventoried {len(rows)} tracked file(s).'); return 0
if __name__=='__main__': raise SystemExit(main())
