#!/usr/bin/env python3
"""Check that every baseline Ten Paces payload survives the physical move."""
from __future__ import annotations
import argparse,hashlib,json,subprocess
from pathlib import Path
TEXT={'.md','.txt','.json','.yml','.yaml','.gd','.tscn','.tres','.cfg',''}
def d(data,suffix): return hashlib.sha256(data.replace(b'\r\n',b'\n') if suffix in TEXT else data).hexdigest()
def h(p): return d(p.read_bytes(),p.suffix.lower())
def main():
 p=argparse.ArgumentParser();p.add_argument('--before',required=True);p.add_argument('--after',required=True);a=p.parse_args();root=Path.cwd();before=json.loads(Path(a.before).read_text(encoding='utf8'))['files'];by_hash={}
 for f in root.rglob('*'):
  if f.is_file() and '.git' not in f.parts: by_hash.setdefault(h(f),[]).append(f.relative_to(root).as_posix())
 rows=[]
 for item in before:
  raw=subprocess.run(['git','cat-file','-p',item['blob']],check=True,capture_output=True).stdout; expected=d(raw,item['suffix']); matches=by_hash.get(expected,[]); rows.append({'source_path':item['path'],'sha256':item['sha256'],'disposition':item['disposition'],'preserved_paths':matches,'state':'PRESERVED' if matches else 'MISSING'})
 missing=[r for r in rows if r['state']=='MISSING']; Path(a.after).write_text(json.dumps({'baseline_files':len(rows),'missing':missing,'rows':rows},ensure_ascii=False,indent=2)+'\n',encoding='utf8');print(f'preserved={len(rows)-len(missing)} missing={len(missing)}');return bool(missing)
if __name__=='__main__':raise SystemExit(main())
