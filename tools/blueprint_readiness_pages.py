"""Reader-facing projection of the authored readiness owner, not runtime rules."""
import json
from pathlib import Path
from blueprint_layout import source
ROOT=Path(__file__).resolve().parents[1]

def append_pages(book, people):
    content=json.loads(source(ROOT/'docs/blueprint/IMPLEMENTATION_READINESS.json').read_text(encoding='utf-8'))
    labels=[('evidence','근거'),('impact','플레이어 경험'),('action','강화·개선 방안'),('owner','실제 수정 위치'),('acceptance','검증 목표'),('risk','남은 위험')]
    for item in content['swot']:
        book.page(item['title'],item['priority'],'상세 권장안 / 사용자 최종 승인 전')
        for i,(key,label) in enumerate(labels):
            book.panel(label,item[key],36+(i%2)*580,690-(i//2)*201,548,178)
        book.note('검증 목표는 다음 구현·플레이 테스트의 종료 기준이며 이미 통과한 결과가 아니다.',67)
    for i in range(0,len(people),2):
        pair=people[i:i+2]
        book.page('전술과 별호 · '+' / '.join(p['name'] for p in pair),'성수 숫자에 앞서 조합의 이유·약점·대응을 읽는다.','상세 기획 후보 / 실제 AI와 밸런스 검증 전')
        for j,p in enumerate(pair):
            top=689-j*306
            book.photo(ROOT/p['portrait'],36,top-270,174,258)
            book.p(p['name']+' · '+p['role'],233,top,922,20,bold=True)
            y=top-38
            for label,text in [('별호',p['epithet_reason']),('조합',p['tactics']['combination']),('약점',p['tactics']['weakness']),('대응',p['tactics']['counterplay'])]:
                y=book.p(label+'  '+text,233,y,922,12.5)-12
        book.note('습관은 공개된 이력에서 관찰하는 경향이다. 현재 미공개 계획의 확률이나 정답을 보여주지 않는다.',62)
    for page in content['pages']:
        book.page(page['title'],'승인 후 실제 저장소에서 수행할 연결·검증 계약','구현 명세 준비 / 제품 변경·런타임 검증 전')
        for i,panel in enumerate(page['panels']):
            book.panel(panel['title'],panel['body'],36,690-i*200,1128,173)
        book.note('상세 파일·스키마·회귀 조건: docs/blueprint/IMPLEMENTATION_HANDOFF.md',65)

def write_human_owner():
    content=json.loads((ROOT/'docs/blueprint/IMPLEMENTATION_READINESS.json').read_text(encoding='utf-8'))
    lines=['# 상세 SWOT · 구현 준비 설명','', '> IMPLEMENTATION_READINESS.json의 사람용 파생본. 최종 승인 전 기획 후보; 제품·Human PASS 아님.','']
    for item in content['swot']:
        lines+=['## '+item['title'],'']
        for key,label in [('evidence','근거'),('impact','영향'),('action','개선'),('owner','소비자'),('acceptance','검증 목표'),('risk','위험')]: lines += ['- '+label+': '+item[key]]
        lines+=['']
    for p in content['pages']:
        lines+=['## '+p['title'],'']
        for panel in p['panels']:lines+=['### '+panel['title'],'',panel['body'],'']
    (ROOT/'docs/blueprint/IMPLEMENTATION_READINESS.md').write_text('\n'.join(lines),encoding='utf-8')

if __name__=='__main__':write_human_owner()
