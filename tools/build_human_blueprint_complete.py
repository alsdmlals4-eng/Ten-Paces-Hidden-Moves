"""One source-bound reader edition; does not mutate Godot or historical PDFs."""
from pathlib import Path
import hashlib, json, re, subprocess
import blueprint_layout as layout
from blueprint_layout import Book, pdfmetrics, TTFont, HexColor, describe, source, SOURCES
from build_opponent_stage_blueprint import build as stage_people

ROOT=Path(__file__).resolve().parents[1]
W,H=1200,800
layout.W,layout.H=W,H
INK=HexColor('#18292e'); PAPER=HexColor('#f1ebdd'); GOLD=HexColor('#aa7c37')
LIGHT=HexColor('#e3d8c2'); BLUE=HexColor('#325f70'); MUTED=HexColor('#61706c')
OUT=ROOT/'output/pdf/TEN_PACES_HUMAN_BLUEPRINT_20260910_COMPLETE.pdf'
CAP=ROOT/'docs/blueprint/evidence'
ART=ROOT/'output/blueprint-candidates'
REF=CAP/'reference-screens'
SCREENS={
    'menu':'158cb5092d39d1960f9c973de2cdf344.png',
    'rest':'17c9efce59e2c227496b4e2d55111800.png',
    'compare':'54d7b849fff7d6b9a639007f08147401.png',
    'brief':'939bf00a7266c6197d592f93b3fae1a0.png',
    'evade':'b0f620fd6acfe845360e15ce3114a03b.png',
    'route':'bc5285da653d3e1abd24486b2cf20ffc.png',
    'result':'df7871ed4f554e76167d50b9bd0a5ffb.png'}

def read(rel):
    return json.loads(source(ROOT/rel).read_text(encoding='utf-8'))

class Edition(Book):
    def photo(self,path,x,y,w,h):
        # Encode only the derived PDF representation; source PNG bytes stay intact.
        from io import BytesIO
        from PIL import Image
        from reportlab.lib.utils import ImageReader
        path=source(path)
        with Image.open(path) as im:
            iw,ih=im.size;scale=min(w/iw,h/ih)
            buffer=BytesIO();im.convert('RGB').save(buffer,format='JPEG',quality=93,subsampling=0)
            buffer.seek(0)
            self.c.drawImage(ImageReader(buffer),x+(w-iw*scale)/2,y+(h-ih*scale)/2,iw*scale,ih*scale)
    def page(self,title,subtitle='',state='기획·구현 상태는 6부 참조'):
        if self.n:self.c.showPage()
        self.n+=1;self.titles.append(title)
        self.box(0,0,W,H,PAPER);self.box(0,H-82,W,82,INK)
        self.p('십보강호  /  사람용 블루프린트',36,786,800,10,GOLD)
        self.p(title,36,764,W-72,25,PAPER,True)
        self.p(subtitle,36,730,W-72,10,PAPER)
        self.c.setStrokeColor(GOLD);self.c.line(36,35,W-36,35)
        self.p(f'{self.n:02d}  ·  2026.09.10  ·  '+state,36,26,W-72,9,MUTED,floor=0)
        self.c.bookmarkPage('page'+str(self.n));self.c.addOutlineEntry(title,'page'+str(self.n),0)
    def table(self,headers,rows,widths,top=688,size=12):
        return super().table(headers,rows,widths,top,size)
    def note(self,text,top=100):self.p(text,36,top,W-72,11,MUTED)
    def panel(self,title,text,x,top,w,h=150):
        self.box(x,top-h,w,h,LIGHT)
        self.p(title,x+16,top-13,w-32,17,INK,True)
        self.p(text,x+16,top-47,w-32,13)
    def flow(self,items,y=470,x=36,w=1128,h=115):
        gap=25;cw=(w-gap*(len(items)-1))/len(items)
        for i,(title,body) in enumerate(items):
            px=x+i*(cw+gap);self.panel(title,body,px,y+h,cw,h)
            if i<len(items)-1:self.p('→',px+cw+4,y+h/2+5,22,18,GOLD,True)
    def picture_page(self,title,subtitle,path,caption):
        self.page(title,subtitle)
        self.photo(path,36,104,1128,596);self.note(caption,83)
    def arrow(self,points):
        self.c.setStrokeColor(GOLD);self.c.setLineWidth(2)
        for a,z in zip(points,points[1:]):self.c.line(*a,*z)
        a,z=points[-2:];dx=z[0]-a[0];dy=z[1]-a[1];n=max((dx*dx+dy*dy)**.5,1)
        ux,uy=dx/n,dy/n
        for s in (-1,1):self.c.line(z[0],z[1],z[0]-9*ux+s*4*uy,z[1]-9*uy-s*4*ux)
    def region(self,path,rect,x,y,w,h):
        # Native PDF placement of an existing atlas region; no edited art file.
        from PIL import Image
        from reportlab.lib.utils import ImageReader
        path=source(path)
        with Image.open(path) as im:
            iw,ih=im.size
        rx,ry,rw,rh=rect;scale=min(w/rw,h/rh)
        dx=x+(w-rw*scale)/2;dy=y+(h-rh*scale)/2
        self.c.saveState();clip=self.c.beginPath();clip.rect(dx,dy,rw*scale,rh*scale)
        self.c.clipPath(clip,stroke=0,fill=0)
        self.c.drawImage(str(path),dx-rx*scale,dy-(ih-ry-rh)*scale,iw*scale,ih*scale,mask='auto')
        self.c.restoreState()

def main():
    for n,f in [('K','malgun.ttf'),('KB','malgunbd.ttf')]:pdfmetrics.registerFont(TTFont(n,'C:/Windows/Fonts/'+f))
    OUT.parent.mkdir(parents=True,exist_ok=True)
    source(Path(__file__));source(ROOT/'tools/blueprint_layout.py');source(ROOT/'tools/build_opponent_stage_blueprint.py')
    arts=read('docs/blueprint/ART_SELECTION.json')['manuals']
    pres=read('docs/blueprint/OPPONENT_PRESENTATION.json')
    manuals=[read('data/cards/martial_manuals/'+mid+'.json') for mid in arts]
    basic=read('data/cards/basic_cards.json')['cards']
    candidates=read('data/run/vertical_slice_opponents.json')['candidates']+read('docs/blueprint/ADDITIONAL_OPPONENTS.json')['candidates']
    bymanual={m['manual_id']:m for m in manuals};bycandidate={p['candidate_id']:p for p in candidates}
    people=stage_people()
    source(ROOT/'data/run/vertical_slice_opponent_archetypes.json')
    source(ROOT/'src/run/vertical_slice_run_state.gd')
    source(ROOT/'docs/blueprint/OPPONENT_BUDGET.json')
    source(REF/'provenance.json')
    for required in ['preparation-plan.png','execution-024.png','capture.json']:
        if not (CAP/required).is_file():raise FileNotFoundError(CAP/required)
    for rel in ['src/run/vertical_slice_route_model.gd','src/run/vertical_slice_opponent_catalog.gd','src/run/vertical_slice_result_model.gd','data/combat/combat_hud_preview.json','docs/02_COMBAT_RULES.md','docs/07_COMBAT_UI_SPEC.md','docs/10_COMBAT_PRESENTATION_PLAN.md','docs/decisions/2026-09-09_RUN_START_OPPONENT_ROSTER_AND_GROWTH.md']:
        source(ROOT/rel)
    atlas=ROOT/'docs/visual-assets/candidates/TEN-HUMAN-BLUEPRINT-20260904/TEN_PACES_3X3_SCREEN_ATLAS_20260904_v1.png'
    bg=ROOT/'assets/backgrounds/jianghu_blue_ink_landscape_v1.png'
    inn=ROOT/'assets/backgrounds/jianghu_rest_inn_v1.png'
    courtyard=ROOT/'assets/backgrounds/atlas_blue_ink_courtyard_v1.png'
    b=Edition(OUT);b.c.setTitle('십보강호 · 사람용 블루프린트 · 통합 완성 편집판 2026.09.10')
    b.page('열 칸의 거리, 세 번의 결단','기획 · 시각 경험 · 강호행로 · 전투 · 상대 · 무공 · 구현 지도')
    b.p('상대의 수를 읽고,\n나의 무공으로 답한다.',70,637,1060,39,bold=True)
    b.p('1대1 무협 전술 게임 · 10칸의 일자 전장 · 열 번의 비무',70,498,1060,22)
    b.flow([('읽기','공개 상태와 지난 수에서 가설을 세운다'),('결단','3수 → 해결 → 3수 → 해결 → 4수'),('복기','승패의 이유와 다음 성장 방향을 찾는다')],y=253,h=156)
    b.p('기획의 설명과 게임의 실제 구현을 구분한 통합 블루프린트다. 도감 후보·시각 목표·실제 촬영은 각각 표시하며, 문서 완성을 게임 개발 완료로 취급하지 않는다.',70,188,1060,16)

    b.page('읽는 순서와 문서의 경계','같은 규칙을 여러 곳에 복제하지 않고, 역할별 책임 페이지로 나눴다.')
    sections=[('1부 · 게임 기획','핵심 재미와 경험 / 전체 플로우 / 화면 아틀라스'),('2부 · 강호행로','비전투 선택 / 사건 / 휴식 / 조사·정탐 / 비무 브리핑'),('3부 · 전투 시스템','준비와 계획 / 거리·관찰 / 합·연격·회피·방어 / 절초·결과'),('4부 · 강호의 상대','16명 / 주력+보조2권 / 전력 예산 / 10→1전 표'),('5부 · 무공과 데이터','10권 × 기술·절초 3종 / 5·9성 강화 / 기본 행동 / 제작 예산'),('6부 · 구현 이해와 체크','기획→상세→자산→구현→검증 / 한글 연결 지도 / 검수와 출처')]
    b.table(['종류','찾을 내용'],sections,[240,900],size=15)
    b.panel('표시의 뜻','시각 목표 = 도달하려는 구도  /  실제 촬영 = 해당 시점의 실행 화면  /  권장안 = 구체화한 설계, 게임 연결은 별도\n신규 원화 = 제작·검수한 도감 후보, 최종 시각 채택과 전투용 투명 모션은 별도',36,205,1128,138)

    b.page('1부 · 어떤 경험을 만드는가','핵심 재미는 검증 완료된 성과가 아니라 플레이 테스트에서 확인할 경험 가설이다.')
    for i,(t,s) in enumerate([('읽어냈다','지나간 행동과 공개 거리를 보고 다음 수를 예상한다. 상대의 숨은 계획을 보거나 정답 확률을 읽는 게임이 아니다.'),('내 무공으로 풀었다','성장은 공격 숫자만 올리는 것이 아니라 거리·방어·반격·연계 선택지를 넓힌다.'),('한 수가 장면으로 남는다','예비 동작, 칼끝 궤적, 상단 충돌, 서로 다른 반동과 복귀가 판정을 설명한다.')]):
        b.panel(t,s,36,685-i*190,1128,165)
    b.note('검수 질문: 패배한 이유를 설명할 수 있는가? 다른 계획을 다시 시험하고 싶은가? 효과를 꺼도 판정이 읽히는가?',91)

    b.page('핵심 시스템의 관계','성장·정보·거리·전투 결과가 하나의 선택으로 이어진다.')
    b.flow([('강호행로','회복·수련·단서 중 선택'),('준비','보유 기술과 상대 성향 비교'),('계획','해금 기술을 수에 배치'),('해결','판정 → 모션·효과 → 결과')],y=500)
    b.flow([('복기','성공과 실패의 원인 확인'),('보상','수련·전수의 방향 선택'),('다음 상대','같은 회차의 확정 상대 사용')],y=250,x=170,w=860)
    b.arrow([(1020,500),(1020,438),(305,438),(305,365)])
    b.note('보호 원칙: UI는 전투·보상 규칙을 다시 계산하지 않는다. 상대 AI는 플레이어의 미확정 계획과 UI 의도를 읽지 않는다.',140)
    b.note('인물 정의 / 단계 성장 / 확정된 만남 / 현재 전투 상태를 분리한다. 같은 이름의 재등장이 이전 전투 자원 복제를 뜻하지 않는다.',100)

    b.page('한 회차 전체 플로우맵','새 여정과 이어하기, 비무 승패, 행로 복귀를 한 지도에서 읽는다.')
    b.flow([('메인','새 여정 / 이어하기'),('시작 무공','시작 후보 6권 중 4권'),('브리핑','상대·보유 무공·제약'),('전투 준비','거리·관찰·기술 배치'),('전투 실행','3수 / 3수 / 4수 해결')],y=500,h=155)
    for i,key in enumerate(['menu',None,'brief','prep','compare']):
        if key:b.photo(CAP/'preparation-plan.png' if key=='prep' else REF/SCREENS[key],43+i*230.6,506,198,62)
    b.flow([('승리·보상','수련 또는 무공 전수'),('강호행로','3후보 중 1개 × 4회'),('다음 비무','2전부터 10전까지')],y=285,x=180,w=840,h=145)
    for i,key in enumerate(['result','route','brief']):b.photo(REF/SCREENS[key],190+i*288.3,290,250,62)
    b.arrow([(1050,500),(1050,451),(315,451),(315,400)])
    b.arrow([(885,400),(885,427),(600,427),(600,500)])
    b.panel('패배 분기','첫 패배: 복기 → 동일 비무 1회 재도전 또는 종료. 재패배: 여정 종료. 재도전으로 상대나 제약을 다시 추첨하지 않는다.',36,223,548,125)
    b.panel('10전 승리 분기','여정 종료 → 결과 확인 → 메인. 10전 이후 행로 4회를 추가하지 않는다.',615,223,549,125)
    b.note('새 상대 편성: 새 게임 시작 시 10건 일괄 확정·저장하는 방향. 현재 게임의 고정 10전 순서와는 아직 다르다.',76)

    b.page('화면 아틀라스 · 한눈에 보는 여정','화면을 찾는 지도. 참고 시안의 옛 수치·기술명은 현행 정본이 아니며 준비 화면만 실행 촬영이다.')
    for i,(key,label) in enumerate([('menu','메인 · 여정 시작'),('route','강호행로 · 다음 선택'),('status','나의 상태 · 보유 무공'),('brief','비무 브리핑 · 상대와 제약'),('rest','주막 · 휴식'),('prep','전투 준비 · 현재 계획'),('compare','전투 · 효과 비교'),('evade','회피 · 피해와 구별'),('result','종료 · 보상과 복기')]):
        xx=36+(i%3)*380;yy=77+(2-i//3)*206
        b.box(xx,yy,368,196,INK)
        if key=='status':b.region(REF/SCREENS['route'],[1070,0,602,941],xx+6,yy+30,356,160)
        else:b.photo(CAP/'preparation-plan.png' if key=='prep' else REF/SCREENS[key],xx+6,yy+30,356,160)
        b.p(label,xx+12,yy+23,342,12,PAPER,True)
    screens=[('메인','새 여정·이어하기','저장 상태 확인','시작 무공 / 저장 지점'),('시작 무공','6권 후보','4권 선택과 확인','브리핑'),('성장','보유 무공·수련 자원','어떤 기술을 열 것인가','행로 / 다음 비무'),('강호행로','현재 1~4번째 선택','회복·수련·정보의 기회비용','결과 / 다음 후보'),('브리핑','상대 인물·무공·제약','알려진 사실과 소문 구분','전투 준비'),('준비','거리·자원·현재 계획','해금된 기술을 수에 배치','실행'),('공개·합','이번 수 양측 행동','접촉과 승패·잔여 흐름 읽기','다음 수 / 결과'),('절초','발동 조건을 충족한 기술','고유 무공의 결정적 장면','해결 흐름 복귀'),('결과·복기','승패·원인·보상','다음 성장 또는 재도전','행로 / 메인')]
    for j in range(0,9,5):
        b.page('화면별 진입·선택·복귀 '+str(j//5+1),'화면이 바뀌어도 진행 상태와 지급 결과는 한 번만 적용한다.')
        b.table(['화면','보여 줄 것','플레이어가 판단할 것','다음 화면'],screens[j:j+5],[140,300,420,280],size=14)
        b.note('실제 촬영과 시각 목표를 혼합해 구현 완료처럼 보이지 않게 한다. 카드·버튼의 문구와 수치는 이미지가 아니라 UI로 표시한다.',150)

    b.page('2부 · 강호행로의 네 번의 선택','비무 사이 9구간 × 4회 = 한 회차 최대 36회 선택')
    b.table(['각 단계의 후보','선택하면 얻는 것','포기하는 것'],[
        ['휴식','현재 자원 회복','수련 또는 단서 기회'],['수련','무공 성장에 쓸 수련 점수','회복 또는 단서 기회'],
        ['조사·사건','공개 정보·해당 사건 효과','다른 후보의 효과']], [180,235,270],top=680,size=14)
    b.panel('지금 필요한 것은 무엇인가','체력이 부족하면 휴식, 무공 성장이 필요하면 수련, 상대를 읽기 어렵다면 조사. 같은 단계의 나머지 두 후보를 포기하는 대가가 있다.',752,683,412,223)
    b.panel('현재 구현의 범위','5종 사건 풀에서 진행 횟수에 따라 3후보를 제시한다. 현재 방식은 정해진 순환이며, 무작위 사건 생성기로 설명하지 않는다.',752,429,412,205)
    b.flow([('선택 1/4','후보 셋 비교'),('선택 2/4','결과를 보고 재판단'),('선택 3/4','남은 자원과 단서'),('선택 4/4','다음 브리핑으로')],y=73,h=125)

    b.page('강호행로 와이어프레임','배경을 넓게 두되 선택의 대가와 결과가 읽히는 구성을 목표로 한다.','설명용 구조도 / 실제 실행 화면 아님')
    b.photo(REF/SCREENS['route'],36,310,780,385)
    b.panel('현재 선택과 나의 상태','현재 몇 번째 선택인가 → 후보 셋의 효과·대가 → 나의 자원과 보유 무공 → 확정 결과.\n\n그림은 위치·정보 위계 참고다. 실제 연결된 사건 수치는 다음 페이지의 표를 따른다.',844,678,320,337)
    for i,(title,desc) in enumerate([('주막에서 휴식','체력 25% · 기력 +1 · 내력 +1'),('공터에서 수련','자유 수련 +3'),('상대 무공 조사','다음 상대의 보유 무공 단서')]):
        b.panel(title,desc,36+i*380,275,368,122)
    b.panel('결과 영역','선택한 결과 → 실제 증가량 → 다음 선택. 적용 전 미리보기와 적용 완료를 시각적으로 구분한다.',36,137,1128,78)

    b.page('행로 사건 목록 · 실제 연결된 다섯 종류','새 대화 분기·장편 사건을 구현된 콘텐츠처럼 섞지 않는다.')
    events=[['주막에서 휴식','최대 체력의 25% 회복\n기력 +1 · 내력 +1','자원 정비. 상한 초과분은 현재 적용 규칙에 따름'],['공터에서 수련','자유 수련 포인트 +3','이후 무공 성장 선택에 사용'],['상대 무공 조사','다음 상대 보유 무공 단서','미래의 확정 행동이나 정답 확률은 아님'],['길 잃은 행인 돕기','자유 수련 +2 · 내력 +1','사건 해결 후 다음 선택'],['남겨진 발자국 조사','보법 단서 · 자유 수련 +1','이동 습관을 읽는 재료']]
    b.table(['사건','즉시 효과','판단과 다음 흐름'],events,[240,365,535],size=14)
    b.note('공통 대가: 이 단계의 다른 두 후보와 효과를 포기한다. 자원 변화는 다음 전투로, 수련 점수는 성장으로, 상대 단서는 다음 브리핑으로 이어진다.',220)
    b.note('취소·재진입·이어하기 검수: 선택 확정 전에는 보상이 없어야 하며, 확정 후 같은 결과가 두 번 지급되지 않아야 한다.',180)

    b.page('핵심 장면 · 주막의 휴식','전투의 차가운 긴장과 쉬어 가는 온도의 대비')
    b.photo(inn,36,272,700,425)
    b.panel('장면의 시작','다음 비무를 앞두고 지친 몸을 정비한다. 주막은 회복 선택의 배경이며 새로운 상점 기능을 뜻하지 않는다.',766,680,398,166)
    b.panel('보여 줄 피드백','회복 전 → 실제 회복 후의 자원 변화. 상한 때문에 줄어든 실회복량을 숨기지 않는다.',766,486,398,166)
    b.flow([('도착','따뜻한 실내와 낮은 환경음'),('결정','회복 내용 확인 후 선택'),('회복','숫자와 짧은 숨 고르기'),('출발','다음 행로 또는 브리핑')],y=91,h=135)
    b.note('배경 자산을 사용한 연출 계획. 정교한 호흡 동작·환경음·장면 전환의 최종 게임 검증은 별도다.',62)

    b.page('핵심 장면 · 조사와 정탐','정보는 상대를 단정하는 답지가 아니라 가설을 만드는 단서다.')
    b.region(REF/SCREENS['brief'],[1200,30,455,760],36,275,550,420)
    b.panel('무공 조사','보유 무공과 알려진 기술 범위 → 거리와 수의 운용을 예상한다. 다음 상대가 바뀌면 다른 인물의 단서를 섞지 않는다.',622,686,542,160)
    b.panel('발자국 조사','보법과 위치 운용의 습관 → 추격·기다림·역진입을 비교한다. 습관이 깨진 반례도 함께 보여 준다.',622,504,542,160)
    b.flow([('흔적 발견','관찰할 대상을 제시'),('단서 확인','알려진 사실만 정리'),('해석','습관 + 깨진 사례'),('대비','브리핑과 계획에 활용')],y=98,h=135)
    b.note('예: 비연은 사거리 밖으로 벗어나지만 추격을 예상하면 역진입한다. 이것은 현재 숨은 행동을 보장하는 문장이 아니다.',66)

    b.page('사건과 수련 · 선택이 다음 비무에 남는 방식','서사 문구와 게임 효과를 따로 관리한다.')
    b.flow([('길 잃은 행인','도움 요청을 발견'),('돕기 선택','이번 행로 선택을 사용'),('결과','자유 수련 +2 · 내력 +1'),('다음 후보','보상 적용은 한 번')],y=490,h=140)
    b.panel('공터에서 수련','자유 수련 +3을 얻는다. 포인트 획득과 실제 성수 상승은 다른 처리다. 무공 성장 화면에서 대상·필요량·해금 내용을 확인한다.',36,405,550,210)
    b.panel('추가 기획의 경계','고유 NPC 대사·선택 분기·실패 연출은 별도 콘텐츠 명세로 다듬을 항목이다. 현재 다섯 효과에 없는 수치 보상이나 새 전투를 이미지 설명만으로 추가하지 않는다.',614,405,550,210)
    b.note('후속 검수: 포인트 사용 전후, 해금된 기술 목록, 5·9성 강화 반영, 저장 복구 후 같은 상태를 유지하는지 확인한다.',130)

    b.page('비무 브리핑 · 상대를 읽고 제약을 정한다','정탐으로 확보한 정보와 미확인 정보를 구분한다. 그림은 이전 시각 목표이며 수치 정본은 본문이다.')
    b.photo(REF/SCREENS['brief'],36,208,830,478)
    b.panel('좌우의 같은 정보 순서','현재/최대 자원 → 영구 능력 → 보유 무공·성수. 상대는 정탐으로 허용된 범위만 공개하며 미확인은 ?로 남긴다.',887,680,277,202)
    b.panel('제약은 시작 전에','0~2개 · 총 3점 이내 · 상대 강화 최대 1개. 대상이 필요한 경우 무공/능력까지 확정한다. 전투 중 변경하지 않는다.',887,450,277,202)
    b.flow([('상대 확인','이름·성장 별호·공개 무공'),('제약 선택','선택 비용·대상·효과 확인'),('대전 시작','이번 만남과 제약을 고정')],y=73,h=115)
    b.note('그림의 시작 거리3 제약은 채택하지 않는다. 현행 시작 거리2를 유지한다. 제약은 아래 상세 목록을 따른다.',64)

    b.page('3부 · 전투의 판단 단위','한 라운드 안에서 세 번 계획하고, 각 묶음을 해결한다.')
    b.flow([('첫 묶음','3수 계획 → 해결'),('둘째 묶음','3수 계획 → 해결'),('마지막 묶음','4수 계획 → 해결')],y=490,h=145)
    b.panel('수와 비용은 다르다','기술의 1·2·3수는 계획에서 차지하는 길이다. 기력·내력은 별도 비용이며 두 항목을 같은 숫자로 취급하지 않는다.',36,412,550,165)
    b.panel('현재 해금 기술을 배치한다','기본 / 무공 / 절초 탭에서 조건을 만족한 기술을 본다. 무공서를 골라 하위 기술을 좁히는 탭과 덱·손패·드로우는 쓰지 않는다.',614,412,550,165)
    b.note('공개 상태와 지난 해결 결과를 읽고 다음 묶음을 다시 계획한다. 상대의 미확정 계획을 AI가 읽는 방식은 금지한다.',173)

    # Exact 60/40 structural wireframe, atlas artwork is placed without rewriting pixels.
    b.page('준비 화면 · 전장 60%, 판단 영역 40%','현재 계획·5×2 기술·상세 효과·상대 관찰을 동시에 읽는 목표 구조','설명용 와이어프레임 / 현재 구현과 차이는 6부')
    x,y,fw,fh=36,62,1128,630;bottom=fh*.4;top=fh*.6
    if (CAP/'preparation-plan.png').exists():
        from PIL import Image
        with Image.open(CAP/'preparation-plan.png') as capture:iw,ih=capture.size
        b.region(CAP/'preparation-plan.png',[0,0,iw,ih*.6],x,y+bottom,fw,top)
    else:b.photo(courtyard,x,y+bottom,fw,top)
    b.box(36,62,650,252,LIGHT);b.p('현재 계획  /  현재 행동 묶음 1 · 3수',48,306,620,12,bold=True)
    for i,ci in enumerate([4,0,2]):
        bx=48+i*206;b.box(bx,233,188,52,PAPER)
        ill=basic[ci]['illustration'];b.region(ROOT/ill['atlas'].replace('res://',''),ill['region'],bx+3,236,49,46)
        b.p(basic[ci]['name']+'  '+str(basic[ci]['action_slots'])+'수',bx+57,276,124,12,bold=True)
        b.p('선택 / 교체 / 취소',bx+57,255,124,10)
    b.p('3수 → 해결   3수 → 해결   4수 → 해결',48,226,624,11,GOLD,True)
    b.p('기본     무공     절초',48,205,624,12,bold=True)
    for i,c in enumerate(basic):
        bx=48+(i%5)*126;by=66+(1-i//5)*60
        b.box(bx,by,119,56,PAPER)
        ill=c['illustration'];b.region(ROOT/ill['atlas'].replace('res://',''),ill['region'],bx+3,by+3,46,49)
        b.p(c['name']+'\n'+str(c['action_slots'])+'수',bx+51,by+49,66,11,bold=True)
    b.panel('상세 효과','',697,314,228,252)
    b.photo(ART/'plum-star3-framing-v2.png',710,180,202,96)
    b.p('매화삼첩 · 2수\n실제 효과와 발동 조건\n후속 중단 사유\n기력 1 · 내력 1 · 거리 1',710,165,202,12)
    b.panel('상대 행동 관찰','관찰량 1\n1수  [전조: 공격]\n2수  ?\n3수  ?',936,314,228,195)
    b.box(936,62,228,46,GOLD);b.p('행동 실행',972,96,170,19,PAPER,True)

    b.page('현재 계획과 기술 카드 · 읽는 순서','하단 빈 공간을 활용해 삽화를 키우고, 효과를 숨기는 중복 설명은 줄인다.')
    b.flow([('첫 행동','기술 삽화 + 소요 수'),('다음 행동','연결 화살표와 순서'),('마지막 행동','남은 수와 배치 상태')],y=515,h=134)
    b.photo(ART/'plum-star3-framing-v2.png',36,102,380,380)
    b.panel('계획 카드','기술명 · 삽화 · 소요 수 · 핵심 조건. 여러 수를 쓰는 기술은 이어진 자리로 보여 주어 같은 기술이 중복 선택된 것처럼 보이지 않게 한다.',455,484,709,147)
    b.panel('선택한 기술 상세','카드의 작은 요약만으로는 읽기 어려운 조건·효과 순서·중단을 넓게 표시한다. 기력·내력 비용을 없애는 것이 아니라 반복된 소모 섹션을 없애는 것이다.',455,311,709,147)
    b.note('준비 화면의 카드 그리드는 5×2. 부족한 개수는 임의 기술로 채우지 않으며 잠긴 기술의 별도 무공서 탭을 만들지 않는다.',92)

    b.page('거리와 관찰 · 보이는 것과 모르는 것','시작 거리 2. 거리 0은 밀착. 플레이어에게 절대 칸 번호를 강요하지 않는다.')
    for i,(dist,label) in enumerate([(0,'밀착'),(2,'기본 간격'),(5,'원거리')]):
        yy=620-i*159;b.p('거리 '+str(dist)+' · '+label,48,yy+45,250,17,bold=True)
        b.c.setStrokeColor(GOLD);b.c.line(340,yy,1115,yy)
        gap=58+dist*35
        for xx,name in [(730-gap,'나'),(730+gap,'상대')]:b.panel(name,'논리 위치',xx-53,yy+51,106,91)
    b.note('인물 표시 위치는 논리 거리의 변화를 따라 부드럽게 벌어지거나 가까워진다. 연출용 접근·반동은 최종 논리 위치를 덮어쓰지 않는다.',157)
    b.note('관찰은 정해진 공개 범위의 행동 유형을 확인한다. 미래 기술명·방향·정답 확률을 자동 공개하는 시스템이 아니다.',104)

    b.page('실행 화면 · 카드 공개와 연출을 함께 본다','준비 하단 UI는 물러나고, 전투 장면이 주인공이 된다.','설명용 연출 배치 / 실제 촬영과 구분')
    b.photo(ART/'clash-keyscene-v1.png',36,105,1128,584)
    for px,name in [(54,'나'),(903,'상대')]:
        b.box(px,579,240,88,INK);b.p(name+'\n체력 / 기력 / 내력',px+14,650,212,15,PAPER,True)
    for px,filename,title in [(408,'plum-star3-framing-v2.png','이번 수 · 나'),(648,'sky-star3-tip-v3.png','이번 수 · 상대')]:
        b.box(px,584,144,93,PAPER);b.photo(ART/filename,px+4,604,136,69);b.p(title,px+7,598,130,10,bold=True)
    b.p('대',581,602,40,24,PAPER,True)
    b.box(424,139,352,91,INK);b.p('현재 계획  1 / 3\n즉시 결과  ·  합 승리 / 합 패배',442,212,316,15,PAPER,True)
    b.note('카드와 결과 문구는 얼굴·무기 접점·VFX를 가리지 않는 별도 영역에 둔다. 큰 “합” 글자를 충돌점 위에 얹지 않는다.',82)

    b.page('핵심 장면 · 합의 네 단계','상체 높이의 접촉 → 서로 다른 반응 → 자연스러운 거리 복귀')
    b.flow([('예비·접근','양쪽 무기 궤적을 먼저 읽힘'),('상단 충돌','검날 접점에 불꽃·짧은 정지'),('승패 분리','승자 중심 유지 / 패자 후퇴'),('수습·복귀','두 인물의 공간 회복')],y=514,h=150)
    b.photo(ART/'clash-keyscene-v1.png',36,95,430,384)
    b.panel('승자와 패자의 차이','승자는 자세를 지키고 무기를 거둔다. 패자는 먼저 공간을 내주고 균형을 회복한다. 합 패배와 실제 체력 피해는 구분하며, 피해가 없으면 과장된 피격을 넣지 않는다.',510,474,654,175)
    b.panel('속도와 타격감','로컬 조정 기록의 기본 합 0.90초·절초 1.05초는 출발점이다. 무기마다 예비·충돌·회수 시간을 나누고 양측 반응을 비교한다. 이 값은 보편적 업계 표준이 아니다.',510,270,654,158)
    b.note('삽화는 무기 운용 참고. 위 타임라인을 재생한 실제 게임 캡처나 애니메이션 프레임이 아니다.',75)

    b.page('연격은 한 번씩 해결한다','매화삼첩의 실제 효과 순서. 세 타격을 합쳐 위력10의 한 타격으로 계산하지 않는다.')
    for i,(power,condition) in enumerate([(4,'첫 타격을 독립 판정'),(3,'앞선 실제 체력 피해 1회 필요'),(3,'누적 실제 체력 피해 2회 필요')]):
        xx=36+i*380
        b.photo(ART/'plum-star3-framing-v2.png',xx+32,421,304,266)
        b.p(['첫째','둘째','셋째'][i]+' 타격 · 위력 '+str(power),xx,399,368,21,BLUE,True)
        b.p(condition,xx,361,368,14)
        if i<2:b.p('→',xx+350,539,30,25,GOLD,True)
    b.table(['상황','후속 처리','플레이어에게 보여 줄 것'],[
        ['첫 타격에 체력 피해 없음','다음 조건 불충족 → 남은 연격 종료','첫 판정과 후속 미발동 사유'],
        ['첫 타격에 체력 피해 발생','둘째를 새로 판정 → 누적 조건 재확인','현재 타격 강조·변한 상태'],
        ['세 타격 모두 체력 피해 + 5성','낙매유향: 후퇴1칸 → 방어도2','추가 이동·방어, 별도 기술 카드 없음']
    ],[340,370,430],top=300,size=13)
    b.note('위력과 실제 체력 피해는 다르다. 방어·회피·합과 사거리 결과를 각 타격에서 확인한다. 연격 전체를 한 번에 성공 처리하지 않는다.',80)

    b.page('회피 횟수는 피해량이 아니다','공격 위력10과 회피1은 서로 다른 단위다. 10-1=9 피해로 읽히는 화면을 만들지 않는다.')
    b.photo(REF/SCREENS['evade'],36,197,832,491)
    b.panel('결과를 먼저','유효한 회피가 공격을 피하면 피해 없음. 공격 궤적에서 벗어나는 동작과 회피 소모·상태 변화를 연결한다.',890,677,274,192)
    b.panel('위력 비교와 분리','공격 대 공격의 합과 달리, 회피 횟수를 공격 위력과 빼서 남은 피해를 만들지 않는다. 현재 판정의 회피 잔여 횟수를 표시한다.',890,457,274,218)
    b.panel('표현 통일','참고 그림의 원형 체력·기력·내력은 옛 표현이다. 최종 자원은 막대+현재/최대 숫자. 회피 성공에 타격 불꽃·피격음은 쓰지 않는다.',36,165,1128,104)

    b.page('방어·회피·피격·중단','서로 다른 판정을 같은 몸 떨림으로 표현하지 않는다.')
    b.table(['상황','판정에서 읽을 것','연출의 차이'],[
        ['막기','방어도 적용과 같은 수 피해 감소','받아내는 자세·짧은 밀림, 실제 피해가 있으면 분리 표시'],
        ['회피','같은 수의 공격을 완전히 피함','공격 궤적에서 이탈, 타격 불꽃과 피격음 금지'],
        ['피격','실제 체력 피해 발생','피해 위치의 반동·짧은 타격음·체력 변화'],
        ['중단','후속 타격이 더 이어지지 못함','잔여 공격·효과를 취소하고 회수 자세'],
        ['강건','다음 중단 1회를 방지','버티는 반응, 피해를 없애는 무적으로 표현하지 않음'],
        ['합 무승부','확정된 합 결과를 그대로 읽음','한쪽을 승자로 연출하지 않으며 후속 규칙은 실제 판정 사용']
    ],[150,360,630],size=14)
    b.note('검·도·창의 금속 접촉과 맨손·장풍의 충돌을 구분한다. 맞지 않은 회피에 피격 스프라이트나 피가 나오는 오류를 검사한다.',140)

    b.page('절초 · 무공의 정체성을 가장 크게 보여 준다','해금은 발동이 아니다. 기세·자원·거리와 기술의 실제 조건을 만족해야 한다.')
    b.photo(ART/'dragon-star10-candidate.png',36,120,660,570)
    b.panel('공개','실제로 발동한 절초 카드만 강조한다. 단순 전조나 조건 미충족 기술을 절초 발동으로 연출하지 않는다.',738,678,426,150)
    b.panel('고유 연출','장법의 기류, 창의 회전, 도의 중량감, 검의 연격을 구별한다. 그림의 용이나 잔상이 새 소환 개체나 추가 타격 판정이 되지는 않는다.',738,500,426,177)
    b.panel('복귀','효과가 끝나면 현재 수·잔여 타격·실제 거리로 이어진다. 빠른 넘김이나 모션 감소에서도 판정과 저장은 동일해야 한다.',738,293,426,150)
    b.note('절초별 정확한 비용·거리·처리 순서·후속 중단 조건은 5부의 각 무공 책임 페이지에 모았다.',84)

    b.page('VFX·카메라·효과음 제작표','효과는 캐릭터와 분리하고, 실제 접점과 확정 사건에 묶는다.')
    b.table(['효과군','위치·시간 기준','공유할 것 / 별도로 만들 것'],[
        ['베기 / 찌르기','칼끝·창끝의 실제 궤적','재생 구조 공유 / 무기별 방향·속도·폭 별도'],
        ['합 불꽃','양측 무기의 상단 교차점','금속 접촉 재사용 / 맨손 접촉에는 다른 효과'],
        ['장풍 / 암기','손의 방출점 → 타격 위치','투사체 계층 공유 / 기류·표·침 외형 별도'],
        ['카메라','전장만 흔들고 카드·HUD 고정','충돌 강도별 작은 진폭 / 모션 감소 제공'],
        ['타격 정지','충돌 순간 연출만 잠깐 멈춤','논리 타이머·저장·입력 상태를 깨지 않음'],
        ['효과음','검풍 → 충돌 → 잔향 분리','금속·천·둔탁한 장력 구분, 동시 재생 음량 제한']
    ],[170,405,565],size=13)
    b.note('검수는 VFX 끔/켬, 카메라 끔/켬, 소리 끔/켬을 각각 비교한다. 화려함만으로 접점·판정 오류를 가리지 않는다.',165)
    b.note('음향 최종 품질은 실제 스피커·헤드폰 청감과 반복 피로 확인이 필요하다. 파일 생성·연결만으로 청감 승인을 대신하지 않는다.',114)

    b.page('비무 결과·보상·재도전','합 한 번의 승패가 아니라 비무 전체의 종료를 정리한다.')
    b.flow([('종료 판정','확정 승패를 한 번 기록'),('결과 연출','승리 / 패배 고유 반응'),('복기','원인·자원 변화 확인'),('다음 흐름','보상 / 재도전 / 종료')],y=506,h=139)
    b.table(['승리 보상 선택','현재 보상 값','대상'],[
        ['자유 수련','자유 수련 +6','대상 무공 선택 없음'],
        ['집중 수련','자유 수련 +3 · 집중 수련 +5','보유 무공 중 하나'],
        ['문파 전수','상대 주력 무공 · 3성','실제로 만난 상대의 대표 무공']
    ],[225,475,440],top=439,size=15)
    b.note('최종 평점·등급 계산식은 확정 근거가 없어 임의로 추가하지 않았다. 결과 화면의 복귀·재실행으로 보상이 중복되지 않아야 한다.',154)

    constraints=read('data/run/bimu_constraints.json')['constraints']
    for start in (0,5):
        b.page('비무 제약 '+str(start//5+1),'브리핑에서 0~2개, 총 3점 이내, 상대 강화 최대 1개. 이번 비무에만 적용한다.')
        b.table(['제약','선택 점수','적용 범위'],[[c['display_name_ko'],str(c['selection_cost']),c['effect_summary_ko'].replace('★','성')] for c in constraints[start:start+5]],[235,120,785],size=14)
        b.note('대상이 필요한 제약은 대상 무공·능력까지 확인한다. 재도전에서 같은 제약을 복원한다. 점수와 보상 배율을 자동 연결하지 않는다.',156)

    b.page('4부 · 강호의 상대들','기존15명과 가면 검객 백무진: 총16명, 한 회차10전. 기존 인물을 빼지 않고 확장한다.','새 원화 최종 채택·게임 연결은 별도')
    for i,p in enumerate(people):
        xx=36+(i%4)*285;yy=72+(3-i//4)*155
        b.photo(ROOT/p['portrait'],xx,yy+26,269,125)
        b.p(p['name']+' · '+p['manual'],xx+5,yy+23,261,11,bold=True)

    b.page('상대의 성장과 등장 규칙','10전 완성형에서 하위 단계로 약화한다. 인물 자체와 이번 만남의 난도를 분리한다.')
    b.table(['항목','이번 상세 권장안','보호 기준'],[
        ['단계 능력 합계','1→10전: 20·22·24·26·28·30·32·34·37·40','기존 성향 배분을 유지, 성장 보너스를 다시 더하지 않음'],
        ['보유 무공','주력 1권 + 보조 2권. 10전은 10·7·5성','거리·방어·회복·보조 공격의 조합. 동일 무공 중복 금지'],
        ['공통 자원 상한','체력 30 · 기력 5 · 내력 4','현재 자원 상한 유지. 능력→자원 새 공식은 추가하지 않음'],
        ['성장 별호','고유 별호 + 단계별 성장 수식','같은 인물의 이름·성별·주력 무공 유지'],
        ['상대 확정','새 게임 시작에 10건 일괄 확정·저장','이어하기·재도전·정탐에서 재추첨 금지'],
        ['중복 정책','연속 같은 타입 편중을 줄이는 방향','중복 제한의 정확한 추첨 규칙은 후속 구현 명세에서 검증']
    ],[165,480,495],size=13)
    b.note('160행은 인물별 등장 설계표다. 현재 게임이 이 수치를 사용한다는 뜻이 아니다. 사람 밸런스·추첨 분포·저장 호환 검증은 6부에 남겼다.',122)

    budget_plan=read('docs/blueprint/OPPONENT_BUDGET.json')
    b.page('전별 전력 예산 · 플레이어 성장과 비교','추가 수련은 3성 취득 후 비용. 총 성수·위력·능력 포인트와 혼합하지 않는다.')
    rows=[]
    for r in reversed(budget_plan['stages']):
        n=r['stage']-1
        rows.append([str(r['stage'])+'전',str(r['stat_total']), ' / '.join(map(str,r['masteries'])), str(r['training_budget']), str(6*n),str(12*n),str(20*n)])
    b.table(['비무','능력 합계','주력 / 보조1 / 보조2 성수','상대 추가 수련','승리 자유수련만','승리+행로2수련','최대 획득 상계'],rows,[65,115,280,160,175,175,170],size=12)
    b.p('비교 경로',36,223,1128,16,bold=True)
    b.p('승리 자유수련만: 이전 승리당6. 보통 비교: 승리6 + 행로4회 중 수련2회×3. 최대 상계: 집중보상8 + 행로 수련4회×3이며, 집중분은 지정 무공에만 사용한다. 전수·휴식·조사를 고르면 수련량은 줄어든다.',36,187,1128,13)
    b.note('플레이어 시작4권·상대3권의 선택지 폭도 비교해야 한다. 10·5·3성=43점 대안은 완만한 난도 후보. 채택 시작값은57점이며 사람 대전 검증 전이다.',100)
    b.note('능력 합계는 성장 보너스 포함 최종 목표다. 플레이어의 영구 능력 성장 적용 범위가 일치하기 전에는 위 표만으로 공정한 대전이 입증되지 않는다.',65)

    for p in people:
        c=bycandidate[p['id']];m=bymanual[c['signature_manual_id']];top=p['stages'][0]
        b.page(p['name']+' · '+top['epithet'],'10전 최고 성장 기준  /  '+p['identity'],('기존 가면 검객 실행 이미지 참고 · 인물 연결 전' if p['id']=='masked_baekmujin' else '신규 초상 · 수치 상세 권장안 / 게임 연결 전'))
        b.photo(ROOT/p['portrait'],36,68,433,628)
        b.p(p['personality'],505,677,657,23,BLUE,True)
        b.box(505,543,659,42,LIGHT)
        for si,(label,value) in enumerate(zip(['외공','근골','신법','내공','심안'],top['stats'])):
            b.p(label,520+si*131,609,119,16,bold=True)
            b.p(str(value),520+si*131,575,119,22,BLUE,True)
        b.p('능력 합계 40   /   체력 30 · 기력 5 · 내력 4',505,527,657,14)
        b.p('보유 무공 · 추가 수련 '+str(top['training_spent'])+'점',505,480,650,18,BLUE,True)
        for oi,owned in enumerate(top['owned_manuals']):
            b.p(['주력','보조1','보조2'][oi]+'  '+owned['name']+' '+str(owned['mastery'])+'성',505,445-oi*32,650,15,bold=True)
        b.p('관찰 포인트',505,332,650,18,bold=True)
        b.p(p['habit'],505,296,650,15)
        b.p('습관이 깨지는 경우',505,228,650,18,bold=True)
        b.p(p['counterexample'],505,192,650,15)
        b.p('주력 무공의 자세한 비용·조건·처리 순서는 5부 '+p['manual']+' 참조.',505,107,650,11,MUTED)
        b.page(p['name']+' · 단계별 등장표','10전 → 1전. 세 권의 성장 예산을 함께 적용한다. 자원 상한: 체력30·기력5·내력4.','단계별 수치 권장안 / 런타임·사람 밸런스 검증 전')
        rows=[]
        for r in p['stages']:
            scope='기술 1'+(' + 기술 2' if r['mastery']>=7 else '')+(' + 절초' if r['ultimate_unlocked'] else '')
            upgrade='5·9성' if r['mastery']>=9 else '5성' if r['mastery']>=5 else '없음'
            rows.append([str(r['stage'])+'전',r['epithet'],' / '.join(map(str,r['stats'])),str(r['stat_total']), ' / '.join(str(m['mastery']) for m in r['owned_manuals']),str(r['training_spent']),scope])
        b.table(['비무','등장 별호','외공 / 근골 / 신법 / 내공 / 심안','합계','주력 / 보조1 / 보조2','수련 점수','주력 해금'],rows,[60,185,300,65,190,110,230],size=11.5)
        b.p('보유 순서: '+' / '.join(m['name'] for m in top['owned_manuals']),36,221,1128,13,BLUE,True)
        b.p('기술 1: '+m['cards']['star3']['name']+'  /  기술 2: '+m['cards']['star7']['name']+'  /  절초: '+m['cards']['star10']['name'],36,171,1128,13,bold=True)
        b.note('각 권은3성 기술1·5성 강화·7성 기술2·9성 강화·10성 절초를 적용한다. 해금 후에도 자원·기세·거리 조건을 충족해야 한다.',125)
        b.note('성별과 나이 인상은 원화의 개성이다. 성별 자체로 능력치·기술 비용을 차등 적용하지 않는다.',82)

    b.page('5부 · 무공은 선택지를 넓힌다','3성 기술 · 7성 기술 · 10성 절초는 각각 전용 삽화. 5·9성 강화는 아래 설명만.')
    b.table(['무공','문파','주력 / 보조','해금 구조'],[[m['manual_name'],m['faction'],m['primary_stat']+' / '+m['secondary_stat'],'3성 → 5성 강화 → 7성 → 9성 강화 → 10성'] for m in manuals],[240,170,190,540],size=12)
    b.note('그림은 기술의 주제와 움직임을 보여 준다. 잔상·용·기류 개수로 실제 타격 횟수나 소환 판정을 추정하지 않는다.',146)
    b.note('효과 설명은 현재 기술 데이터의 순서를 유지한다. 신법·내공 같은 능력과 내력 같은 소모 자원은 별개다.',101)
    for m in manuals:
        b.page(m['manual_name'],m['faction']+'  /  주력 '+m['primary_stat']+' · 보조 '+m['secondary_stat']+'  /  기술의 실제 처리 순서','신규 도감 삽화 / 5·9성은 종속 강화 설명')
        for j,star in enumerate([3,7,10]):
            x=36+j*380;cw=368;c=m['cards']['star'+str(star)]
            b.p(str(star)+'성 · '+c['name'],x,697,cw,17,BLUE,True)
            b.photo(ART/arts[m['manual_id']][j],x,352,cw,315)
            rng=c['range'];range_text='자신' if rng['min']==rng['max']==0 else f"거리 {rng['min']}~{rng['max']}"
            t=b.p(f"{c['action_slots']}수  ·  기력 {c['stamina_cost']}  ·  내력 {c['internal_cost']}  ·  {range_text}",x+4,343,cw-8,11.5,bold=True)-10
            for idx,step in enumerate(c['effect_steps']):
                t=b.p(str(idx+1)+'. '+describe(step),x+4,t,cw-8,10.8)-3
            if star in [3,7]:
                o=m['overlays']['star'+str(star+2)]
                t=b.p(f"{star+2}성 강화 · {o['name']}",x+4,t-11,cw-8,13,BLUE,True)-8
                for step in o['effect_steps']:t=b.p(describe(step),x+4,t,cw-8,10.8)-3

    for start in (0,5):
        b.page('기본 행동 '+str(start//5+1),'무공 밖에서도 거리·관찰·회복·준비로 다음 수를 만든다.')
        for j,c in enumerate(basic[start:start+5]):
            yy=685-j*116;ill=c['illustration']
            b.region(ROOT/ill['atlas'].replace('res://',''),ill['region'],36,yy-103,95,99)
            b.p(c['name'],152,yy-4,177,19,BLUE,True)
            b.p(f"{c['action_slots']}수 · 기력 {c['stamina_cost']} · 내력 {c['internal_cost']}\n거리 {c['range_text']}",152,yy-40,220,12)
            b.p(c['effect_text'],410,yy-13,745,14)
        b.note('기본 행동 삽화는 기존 승인 아틀라스의 각 영역을 그대로 배치했다. 생성된 새 무공 삽화와 혼동하지 않는다.',74)

    budget=read('docs/planning-data/approved_20260806_ten_manual_growth_budget_overlay_contract.json')
    b.page('제작 예산 · 효과를 비교하는 공통 단위','예산은 설계 평가값이다. 체력 피해·재화·개발 완료율이 아니다.')
    b.table(['항목','현재 제작 기준','해석'],[
        ['행동 슬롯','1수 20 · 2수 50 · 3수 80','기술 길이에 따른 기본 허용 예산'],
        ['자원 허용분','기력 1당 4 · 내력 1당 7','비용에 따른 설계 여유'],
        ['거리 효과','이동 1칸 15 · 거리1을 넘는 사거리 1칸당15','거리 가격을 다른 구형 예산과 혼용하지 않음'],
        ['허용 차이','5 이내','설계 검토 기준. 사람 밸런스 승인은 별도'],
        ['5·9성','3·7성 기술 강화','별도 기술 카드·삽화를 만들지 않음'],
        ['영구 능력 성장','외공·근골·신법·내공·심안','단계별 상대표는 보너스 포함 최종 배분, 이중 합산 금지']
    ],[190,390,560],size=14)
    b.note('자료와 실제 효과가 충돌하면 예산 수치에서 피해량을 역산해 덮어쓰지 않는다. 해당 기술 데이터와 승인 명세를 다시 대조한다.',139)
    b.page('무공별 성장 예산표','승인된 7성·9성 제작 예산을 사람용 이름으로 정리했다.')
    bp=budget['star7_profiles']
    b.table(['무공','7성 예산','9성 추가','9성 총예산'],[[m['manual_name'],str(bp[m['manual_id']]['star7_final_budget_ticks']),str(bp[m['manual_id']]['star9_bonus_ticks']),str(bp[m['manual_id']]['star9_total_budget_ticks'])] for m in manuals],[450,220,220,250],size=13)
    b.note('9성 추가 = 10 + 7성 예산의 20%를 내린 값. 이 예산 표와 기술의 실제 효과·조건은 함께 검수한다.',141)

    b.page('6부 · 기획에서 구현까지 보는 지도','비개발자도 “어디서 바꾸고 무엇을 확인해야 하는가”를 따라갈 수 있게 한다.')
    b.flow([('기획','사람이 읽는 규칙·화면'),('상세 데이터','무공·상대·단계·보상'),('게임 연결','진행·전투·저장'),('화면과 연출','UI·인물·모션·VFX'),('검증','자동 검사 + 실제 촬영')],y=510,h=139)
    b.table(['바꾸고 싶은 것','먼저 볼 책임 자료','연결해서 확인할 것'],[
        ['상대가 누구인가','상대 도감 / 단계 등장표','새 여정 → 저장 → 브리핑 → 정탐 → 전투 → 보상'],
        ['기술의 효과','무공 도감 / 기술 상세 데이터','해금 목록 → 계획 → 판정 → 로그 → 저장'],
        ['전투가 어떻게 보이는가','준비 와이어프레임 / 핵심 장면','카드 공개 → 무기 궤적 → VFX → 승패 반응'],
        ['행로 결과','사건표 / 진행 규칙','선택 → 지급 → 다음 후보 → 이어하기']
    ],[225,340,575],top=453,size=13)
    b.note('이 지도는 설명용 읽기 전용 연결도다. Godot 내부에 새로운 노드 편집 도구가 구현되었다는 뜻이 아니다.',122)

    b.page('단계별 구현 체크 · 전체 범위','기획 확정과 문서 작성만으로 구현·실행·사용자 승인을 완료 처리하지 않는다.')
    checklist=[
        ['10칸 / 3·3·4 / 기본 판정','확정','있음','있음','기존 구현','후속 전체 회귀'],
        ['무공10권 / 기술30종 / 강화20종','확정','있음','새 삽화30','기술 데이터 연결','새 원화 연결·촬영 전'],
        ['강호행로 5종 / 4회 선택','확정','있음','배경 있음','현재 순환 방식','완주·중복지급 재검증'],
        ['상대16명 / 여성·백무진 포함','확정 방향','인물별 정리','초상15+기존1','기존15명 소비','가면 검객 신규 연결 전'],
        ['10전별 능력·세 권 성수·별호','확정 방향','160행·수련 예산','도감 있음','미연결','밸런스·저장 검증 전'],
        ['시작 시 상대10건 추첨','확정 방향','반복 정책 보완','해당 없음','현재 고정 순서','추첨·저장·완주 전'],
        ['전장60% / 5×2 / 현재 계획','확정','구조도 있음','시각 목표 있음','로컬 부분 교정','최종 가독성 미승인'],
        ['무기별 모션 / 합 승패 / VFX','확정 방향','제작표 있음','검 중심 부분','공통 임시 표현 남음','무기별 실행·청감 전']]
    b.table(['항목','기획','상세','자산','구현','검증'],checklist,[255,115,155,150,210,255],size=11)
    b.note('주의: 천기비성술5성의 관찰 강화는 적 허용 범위와 충돌한다. 해금표와 실제 적이 사용할 수 있는 기술 목록을 구분하고 정보 차단 회귀를 수행해야 한다.',188)
    b.note('단계: 아이디어 → 조사 → 구현 가능 → 상세화 → 자산 준비 → 구현 → 기계 검증 → 실행 검증 → 사용자 승인.',145)
    b.note('이 책의 신규 그림은 도감 원화다. 투명 전신·공격·피격·회피·방어·합·승패 모션을 새로 만든 것으로 세지 않는다.',95)

    if (CAP/'preparation-plan.png').exists():
        b.picture_page('실제 구현 대조 · 준비 화면','2026.09.10 로컬 Godot 촬영 / 시각 목표와 비교하는 실행 근거',CAP/'preparation-plan.png','삽화 비중·작은 글자·장식 간섭·패널 여백의 추가 검수가 남아 있다. 새 도감 원화가 모두 연결된 화면이 아니다.')
    if (CAP/'capture.json').exists():
        rec=json.loads(source(CAP/'capture.json').read_text(encoding='utf-8'))['frames']
        r=next((r for r in rec if r.get('vfx') and r.get('kind')=='clash'),None)
        if r:
            b.picture_page('실제 구현 대조 · 카드 공개와 합','2026.09.10 로컬 Godot 촬영 / 최종 연출 품질 승인 아님',CAP/r['file'],'남은 차이: 장풍에도 검 접촉을 쓰는 임시 모션, 인물 중첩, 불꽃 가시성·접점. 실제 결과를 과장하거나 생성 이미지로 대체하지 않았다.')

    b.page('최종 구현 검수표 · 종료 조건','이 체크가 모두 충족되어야 “블루프린트 전체 구현 완료”라고 말할 수 있다.')
    checks=[['새 회차와 저장','시작 즉시 상대10건 확정 / 이어하기 불변 / 중간 재시작 / 제약 복원'],['10전 완주','각 전의 상대·수치·무공·보상 일치 / 9개 행로 / 최종 종료'],['양측 모션','대기·이동·공격·피격·회피·방어·합 승패·비무 승패 / 발 기준과 무기 연속성'],['실행 화면','카드 공개와 함께 재생 / UI 고정 / 거리 변화 / 효과 접점 / skip·resize'],['미술과 음향','새 원화 최종 확정 / 무기별 VFX / 소리 on·off / 실제 장치 청감'],['증거와 전달','자동 검사 / 실제 촬영·GIF / 정확한 변경의 CI / 안전한 병합 / main 재확인'],['사람·기기','가독성·타격감·접근성 / Android 실기기 / 성능 / 출시 권리']]
    b.table(['검수 묶음','필수 확인'],checks,[245,895],size=14)
    b.note('현재 전 항목 완료가 아니다. 사용자에게 재승인을 반복 요구할 이유는 없지만, 미실행 검증을 통과로 적을 수도 없다.',115)

    b.page('문서 품질을 유지하는 방식','다른 프로젝트에서도 재사용할 것은 과정과 증거 구분이며, 이 게임의 고유 수치는 아니다.')
    b.table(['이번 문제에서 얻은 교훈','재사용할 작업 방식'],[
        ['요약 PDF에서 시각 디테일 퇴행','원본의 화면·흐름·핵심장면·상세 표를 coverage 목록으로 대조'],
        ['구버전과 신버전의 중복','한 사실은 한 책임 페이지, 이전 PDF는 역사 비교용으로 보존'],
        ['무기 손·창대·검끝 오류','인물 전체 → 양팔 관절 → 그립 → 무기 연결 → 끝 여백 순으로 확대 검수'],
        ['원화 생성과 런타임 적용 혼동','후보 / 채택 / 정본 등록 / 연결 / 실행 촬영 상태를 따로 기록'],
        ['기획 숫자를 구현으로 오인','단계별 기획·상세·자산·구현·기계·실행·사람 검증 칸 유지'],
        ['복구 라우터가 진단을 차단','승인된 제한 복구는 owner에서 허용하고 생성 라우터는 원형 유지']
    ],[390,750],size=14)
    b.note('공용 교훈은 Base의 해당 책임 규칙과 중복 여부를 확인한 뒤 반영한다. 이 문서가 Base 병합 완료를 뜻하지 않는다.',140)

    b.page('출처와 검증 범위','2026.09.10 확인 기준. 기획·구현·이미지의 책임 원본을 보존했다.')
    b.panel('프로젝트 기준','현재 프로젝트 규칙·활성 문맥·승인 결정, 전투 규칙과 UI·연출 명세, 기본 행동10종·무공10권·기존 상대15명과 가면 검객 추가 명세, 행로·보상·저장 소비자. 상세 출처 해시는 문서와 함께 보존한 검증 기록에 남긴다.',36,689,550,226)
    b.panel('시각 기준','사용자 기존 36쪽 블루프린트는 보존. 화면 아틀라스·행로 배경·기본 행동 아틀라스를 구분해 재사용하고, 무공30장·상대15장 신규 도감 원화를 제작했다. 생성 이미지와 실제 Godot 캡처는 별도 표시했다.',614,689,550,226)
    b.panel('외부 비교의 한계','공식 제품 설명에서 위치·행동 연계·반복 회차·성장 선택 구조를 비교했다. 타 게임 수치나 성공 사례를 복제하지 않았고, 직접 플레이 테스트·통계적 밸런스 검증을 했다고 주장하지 않는다.',36,430,550,190)
    b.panel('완성 범위','이 파일은 6개 부를 갖춘 사람용 통합 편집판이다. 새 이미지 최종 채택, 무작위 상대·단계 성장의 게임 연결, 전 무기 모션, 실기기·청감·사람 체감·출시는 각각 후속 확인 대상이다.',614,430,550,190)
    b.note('외부 참고: Yomi 2 공식 소개 · Shogun Showdown · Into the Breach · Hades · FTL · Slay the Spire · Battle Brothers · Dead Cells · Spelunky 2 · Darkest Dungeon · Monster Train.',170)
    b.note('다음 페이지의 링크는 조사 범위 확인용이다. 삽화나 게임 내 콘텐츠를 해당 작품에서 복제하지 않았다.',109)
    b.page('조사 링크 · 채택과 배제','공식 설명에서 확인한 구조만 제한적으로 참고했다. 아래 판단은 십보강호에 대한 적용 판단이다.')
    refs=[('Yomi 2','https://www.sirlin.net/posts/introducing-yomi-2','행동 카드와 슈퍼 게이지 구분. 손패 교환은 배제.'),('Shogun Showdown','https://store.steampowered.com/app/2084000/','위치·공격 타이밍 연계 참고. 덱은 배제.'),('Into the Breach','https://store.steampowered.com/app/590380/','전조 가독성 참고. 적 의도 전면 공개는 배제.'),('Hades','https://www.supergiantgames.com/blog/hades-faq/','반복 회차와 인물 인지의 공존 참고.'),('FTL','https://store.steampowered.com/app/212680/','매 회차 구성 변화와 선택의 대가 참고.'),('Slay the Spire','https://store.steampowered.com/app/646570/','회차별 상대 다양성 참고. 덱·유물 시스템은 배제.'),('Battle Brothers','https://store.steampowered.com/app/365360/','개체 특성과 성장의 구분 참고. 부대 전투 배제.'),('Dead Cells','https://store.steampowered.com/app/588650/','반복 속 학습 참고. 체크포인트 부재는 복제하지 않음.'),('Spelunky 2','https://store.steampowered.com/app/418530/','다양한 상황과 일관된 상호작용 참고.'),('Darkest Dungeon','https://store.steampowered.com/app/262060/','인물 특성·회복 부담 참고. 스트레스 시스템 배제.'),('Monster Train','https://store.steampowered.com/app/1102190/','주력·보조 상호보완 참고. 덱·다층 전투 배제.')]
    for i,(name,url,note) in enumerate(refs):
        yy=690-i*55;b.p(name,36,yy,190,13,BLUE,True);b.p(note,232,yy,924,12)
        b.p(url,232,yy-23,924,9,MUTED);b.c.linkURL(url,(232,yy-40,1136,yy-20),relative=0)
    b.c.save()
    receipt={'status':'COMPLETE_READER_EDITION_NOT_PRODUCT_COMPLETION','page_count':b.n,'page_titles':b.titles,'base_head':subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),'pdf_sha256':hashlib.sha256(OUT.read_bytes()).hexdigest(),'source_sha256':SOURCES,'counts':{'manuals':10,'manual_illustrations':30,'opponents':len(people),'opponent_portraits':15,'reused_masked_enemy':1,'stage_rows':len(people)*10},'visual_lock':'NEW_ASSETS_PENDING_FINAL_USER_LOCK','runtime':'UNCHANGED_BY_THIS_BUILDER','human_test':'NOT_RUN'}
    receipt['pdf_image_encoding']='JPEG quality93 4:4:4, original resolution; source PNGs unchanged'
    OUT.with_suffix('.receipt.json').write_text(json.dumps(receipt,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print('COMPLETE_READER_EDITION_CREATED',b.n,'pages',OUT)

if __name__=='__main__':main()
