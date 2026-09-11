"""Extract unchanged embedded reference pixels, never recreate historic pages."""
import hashlib
import json
from pathlib import Path
from pypdf import PdfReader

ROOT=Path(__file__).resolve().parents[1]
ORIGINAL=Path('C:/Users/user/Desktop/비교샷/십보강호/블루스크린 ver.1(최신)')
OUT=ROOT/'docs/blueprint/evidence/reference-screens'

def main():
    reader=PdfReader(ORIGINAL)
    OUT.mkdir(parents=True,exist_ok=True)
    rows=[]
    for img in reader.pages[3].images:
        name=img.name.replace('FormXob.','')
        path=OUT/name
        if path.exists() and path.read_bytes()!=img.data: raise ValueError('Existing source differs')
        path.write_bytes(img.data)
        rows.append({'file':name,'sha256':hashlib.sha256(img.data).hexdigest(),'size':list(img.image.size)})
    (OUT/'provenance.json').write_text(json.dumps({
        'source':str(ORIGINAL),'source_sha256':hashlib.sha256(ORIGINAL.read_bytes()).hexdigest(),
        'source_page':4,'status':'HISTORICAL_VISUAL_REFERENCE_NOT_RUNTIME_OR_RULE_CANON',
        'operation':'Lossless extraction of existing embedded image bytes; no generated or repainted content.',
        'images':rows},ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(rows))

if __name__=='__main__':main()
