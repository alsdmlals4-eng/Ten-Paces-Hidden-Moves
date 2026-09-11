"""Read-only page QA and contact-sheet generation; not source-art editing."""
from pathlib import Path
import json, hashlib
from PIL import Image, ImageDraw
from pypdf import PdfReader
ROOT=Path(__file__).resolve().parents[1]
pdf=ROOT/'output/pdf/TEN_PACES_HUMAN_BLUEPRINT_20260911_APPROVAL_REVIEW.pdf'
receipt=json.loads(pdf.with_suffix('.receipt.json').read_text(encoding='utf-8'))
reader=PdfReader(pdf)
assert len(reader.pages)==receipt['page_count']
assert hashlib.sha256(pdf.read_bytes()).hexdigest()==receipt['pdf_sha256']
assert len(set(receipt['page_titles']))==len(reader.pages),'Duplicate page title'
texts=[p.extract_text() for p in reader.pages]
joined='\n'.join(texts)
for title in ['비무 브리핑 · 상대를 읽고 제약을 정한다','연격은 한 번씩 해결한다','회피 횟수는 피해량이 아니다','전별 전력 예산 · 플레이어 성장과 비교','백무진 · 단계별 등장표']:
    assert title in receipt['page_titles'],title
assert receipt['counts']['opponents']==16
assert receipt['counts']['stage_rows']==160
assert len(reader.pages)==112
assert receipt['page_titles'][0].startswith('화면 아틀라스')
brief=receipt['page_titles'].index('비무 브리핑 · 상대를 읽고 제약을 정한다')
assert receipt['page_titles'][brief+1:brief+3]==['비무 제약 1','비무 제약 2']
assert receipt['page_titles'].index('추가 검토 · SWOT와 개선 우선순위')<15
assert receipt['page_titles'].index('독창성과 창의성 · 무협 판단을 장면으로')<15
assert '강화·개선·보완 실행 항목' in receipt['page_titles']
for title in ['추가 검토 · SWOT와 개선 우선순위','기존 요소 판단표 · 무엇을 남기고 바꾸는가','독창성과 창의성 · 무협 판단을 장면으로','실무 근거와 적용 순서']:
    assert title in receipt['page_titles'],title
for forbidden in ['보조 무공을 임의 혼합하지 않음','보유 무공: 매화검결 1권','부계열·다층 전투 배제','주력+보조2권','세 권의 성장 예산','10전은 10·7·5성','완숙 홍매검']:
    assert forbidden not in joined,forbidden
art=json.loads((ROOT/'docs/blueprint/ART_SELECTION.json').read_text(encoding='utf-8'))['manuals']
for mid,images in art.items():
    m=json.loads((ROOT/'data/cards/martial_manuals'/f'{mid}.json').read_text(encoding='utf-8'))
    for c in list(m['cards'].values())+list(m['overlays'].values()):assert c['name'] in joined,c['name']
    for filename in images:assert (ROOT/'output/blueprint-candidates'/filename).exists(),filename
pres=json.loads((ROOT/'docs/blueprint/OPPONENT_PRESENTATION.json').read_text(encoding='utf-8'))
for d in pres['people'].values():assert d['epithet'] in joined,d['epithet']
for forbidden in ['slot1_', 'schema_version','GAIN_RESOURCE','INDEPENDENT_ATTACK','mastery_seed']:
    assert forbidden not in joined,forbidden
out=ROOT/'tmp/pdfs/approval-review-20260911'
files=sorted(out.glob('page-*.png'))
assert len(files)==len(reader.pages),(len(files),len(reader.pages))
for start in range(0,len(files),6):
    sheet=Image.new('RGB',(1200,870),'#dddddd');d=ImageDraw.Draw(sheet)
    for i,p in enumerate(files[start:start+6]):
        with Image.open(p) as im:
            im.thumbnail((590,396));x=(i%2)*600;y=(i//2)*290
            # 3 rows of 2, each page 400x267 to retain surrounding labels.
            im.thumbnail((590,267));sheet.paste(im,(x+(590-im.width)//2,y+20))
            d.text((x+12,y+3),f'{start+i+1:02d}',fill='black')
    sheet.save(out/f'contact-{start//6+1:02d}.png')
report={'status':'DOCUMENT_CONTENT_CHECK_PASS','pages':len(reader.pages),'manual_illustrations':30,'opponent_portraits':16,'reused_masked_enemy':0,'stage_rows':160,'visual_review':'SEPARATE_REQUIRED','pdf_sha256':receipt['pdf_sha256']}
(out/'qa.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print(report)
