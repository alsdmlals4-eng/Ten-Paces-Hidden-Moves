"""Reader-facing snapshot: fail closed on unknown effects; never edit old PDFs."""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import subprocess
from pathlib import Path
from xml.sax.saxutils import escape

from PIL import Image
from reportlab.lib.colors import HexColor
from reportlab.lib.pagesizes import A4, landscape
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.utils import ImageReader
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.pdfgen.canvas import Canvas
from reportlab.platypus import Paragraph

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'output/pdf/ten-paces-hidden-moves_HUMAN_BLUEPRINT_20260910_REVIEW.pdf'
W, H = landscape(A4)
INK, PAPER, GOLD, MUTED = map(HexColor, ['#162329', '#f1ebdd', '#ae8141', '#596564'])
SOURCES: dict[str, str] = {}


def source(path: Path) -> Path:
    SOURCES[str(path.resolve())] = hashlib.sha256(path.read_bytes()).hexdigest()
    return path


def data(relative: str):
    return json.loads(source(ROOT / relative).read_text(encoding='utf-8'))


CONDITIONS = dict(zip(
    ['ACTUAL_HP_HIT', 'ACTUAL_HP_HIT_AT_MAX_RANGE', 'ALL_ATTACKS_HIT', 'ALL_MOVES_SUCCEEDED',
     'ANY_ATTACK_HIT', 'CLASH_WIN', 'CLASH_WIN_AT_MAX_RANGE', 'COUNTER_ATTEMPT',
     'EVADE_SUCCESS', 'EXACT_MAX_RANGE', 'FIRST_ATTACK_HIT', 'FULL_ABSORB', 'LOW_RESOURCE',
     'LOW_RESOURCE_AT_START', 'PREPARED_CONSUMED_BEFORE_CLASH', 'SECOND_ATTACK_EXECUTED',
     'STATUS_CONSUMED', 'TARGET_DEFENSE_ZERO'],
    ['실제 체력 피해를 주면', '최대 사거리에서 실제 체력 피해를 주면', '모든 공격이 적중하면',
     '모든 이동이 성공하면', '공격이 하나라도 적중하면', '합에서 이기면', '최대 사거리의 합에서 이기면',
     '반격을 시도할 때', '회피에 성공하면', '정확히 최대 사거리이면', '첫 공격이 적중하면',
     '공격을 완전히 받아내면', '자원 부족 조건이면', '시작 시 자원 부족 조건이면',
     '합 전에 준비를 소비했다면', '두 번째 공격이 실행되면', '해당 상태를 소비했다면', '상대 방어도가 0이면']))
RES = {'health':'체력', 'stamina':'기력', 'internal':'내력', 'defense':'방어도', 'momentum':'절초 기세'}
STATUS = {'clash_power_bonus':'합 위력 보너스', 'evade':'회피', 'fortitude':'강건',
          'observation':'관찰', 'prepared':'준비', 'taiji_stance':'태극 자세', 'telegraph':'전조'}


def describe(s):
    op = s['op']
    if op in ('ATTACK', 'INDEPENDENT_ATTACK'):
        result = ('독립 타격' if op == 'INDEPENDENT_ATTACK' else '공격') + f" 위력 {s['power']}"
        result += f" · 거리 {s.get('min_range', 0)}~{s.get('max_range', 0)}"
        if s.get('counter'): result += ' · 반격'
    elif op == 'SPECIAL_CLASH':
        result = f"특수 합 위력 {s.get('power', 0)}"
        if 'stat' in s: result += f" + {s['stat']} × {s.get('coefficient', 0):g}"
        if s.get('counter'): result += ' · 반격'
        if s.get('requires_contact'): result += ' · 접촉 필요'
    elif op in ('MOVE_TOWARD', 'MOVE_AWAY', 'PUSH_TARGET'):
        result = {'MOVE_TOWARD':'접근', 'MOVE_AWAY':'후퇴', 'PUSH_TARGET':'상대 밀기'}[op] + f" {s['tiles']}칸"
    elif op == 'RECHECK_RANGE': result = f"거리 {s['min']}~{s['max']} 충족 여부 재확인"
    elif op == 'GAIN_RESOURCE': result = f"{RES[s['resource']]} +{s['amount']}"
    elif op == 'GAIN_STATUS': result = f"{STATUS[s['status']]} +{s['amount']}"
    elif op == 'CONSUME_STATUS': result = f"{STATUS[s['status']]} 소비" + (' · 있으면 적용' if s.get('optional') else '')
    elif op == 'BREAK_DEFENSE': result = f"상대 방어도 {s['amount']} 파괴"
    elif op == 'REQUIRE_ACTUAL_HP_HITS': result = f"실제 체력 피해 누적 {s['count']}회 필요 · 미충족 시 후속 중단"
    elif op == 'REQUIRE_CLASH_WIN': result = '합 승리 필요 · 미충족 시 후속 중단'
    elif op == 'REQUIRE_DEFENSE_ZERO': result = '상대 방어도 0 필요 · 미충족 시 후속 중단'
    elif op == 'REQUIRE_EVADE_SUCCESS': result = '회피 성공 필요 · 미충족 시 후속 중단'
    elif op == 'START_DEFENSE_LOSS_RECORD': result = '이 구간의 방어도 손실 기록 시작'
    elif op == 'END_DEFENSE_LOSS_RECORD': result = f"방어도 손실 기록 종료 · 보너스 상한 {s.get('bonus_cap', 0)}"
    elif op == 'CONSUME_ONCE_PER_BATTLE': result = '전투당 1회 사용 제한 소비'
    elif op == 'GAIN_MOMENTUM_ON_COMPLETE': result = f"완료 시 절초 기세 +{s['amount']}"
    else: raise ValueError(f'Untranslated effect: {op}')
    if s.get('condition'): result = CONDITIONS[s['condition']] + ': ' + result
    return result


class Book:
    def __init__(self, path):
        self.c = Canvas(str(path), pagesize=(W, H), pageCompression=1)
        self.c.setTitle('십보강호 · 사람용 블루프린트 · 2026.09.10 검토본')
        self.n = 0
        self.titles = []

    def box(self, x, y, w, h, fill=PAPER):
        self.c.setFillColor(fill); self.c.rect(x, y, w, h, fill=1, stroke=0)

    def p(self, txt, x, top, w, size=10, color=INK, bold=False, floor=42):
        style = ParagraphStyle('body', fontName='KB' if bold else 'K', fontSize=size,
                               leading=size*1.48, textColor=color, wordWrap='CJK', spaceAfter=0)
        p = Paragraph(escape(str(txt)).replace('\n', '<br/>'), style)
        _, height = p.wrap(w, H)
        if top-height < floor:
            raise ValueError(f'Page {self.n} overflow: {str(txt)[:70]} ({top-height})')
        p.drawOn(self.c, x, top-height)
        return top-height

    def page(self, title, subtitle, state='현재 기준 검토본'):
        if self.n: self.c.showPage()
        self.n += 1; self.titles.append(title)
        self.box(0, 0, W, H)
        self.box(0, H-100, W, 100, INK)
        self.p('십보강호  /  숨은 수의 비무', 30, H-15, 600, 9, GOLD)
        self.p(title, 30, H-35, W-60, 23, PAPER, True)
        self.p(subtitle, 30, H-72, W-60, 9, PAPER)
        self.p(f'{self.n:02d}   ·   2026.09.10   ·   {state}', 30, 26, W-60, 8, MUTED, floor=0)
        self.c.bookmarkPage(f'page{self.n}')
        self.c.addOutlineEntry(title, f'page{self.n}', 0)

    def photo(self, path, x, y, w, h):
        path = source(path)
        with Image.open(path) as im:
            iw, ih = im.size
            scale = min(w/iw, h/ih)
            self.c.drawImage(ImageReader(im), x+(w-iw*scale)/2, y+(h-ih*scale)/2,
                             iw*scale, ih*scale, mask='auto')

    def rows(self, headers, rows, widths, top=470, size=10):
        x = 30
        for h,w in zip(headers,widths): self.p(h,x+7,top,w-14,size, PAPER,True); x+=w
        # Header fill is drawn first by callers through table().
        y=top-30
        for i,row in enumerate(rows):
            heights=[]
            for value,w in zip(row,widths):
                ps=ParagraphStyle('m',fontName='K',fontSize=size,leading=size*1.48,wordWrap='CJK')
                heights.append(Paragraph(escape(str(value)).replace('\n','<br/>'),ps).wrap(w-14,H)[1])
            rh=max(heights)+16
            if y-rh<48: raise ValueError(f'Table overflow on page {self.n}')
            self.box(30,y-rh,sum(widths),rh,HexColor('#e4dfd2') if i%2==0 else PAPER)
            x=30
            for value,w in zip(row,widths): self.p(value,x+7,y-6,w-14,size); x+=w
            y-=rh
        return y

    def table(self, headers, rows, widths, top=470, size=10):
        self.box(30,top-25,sum(widths),30,INK)
        return self.rows(headers,rows,widths,top,size)


def build(captures: Path, output: Path):
    output.parent.mkdir(parents=True, exist_ok=True)
    for name,filename in [('K','malgun.ttf'),('KB','malgunbd.ttf')]:
        pdfmetrics.registerFont(TTFont(name,str(Path('C:/Windows/Fonts')/filename)))
    source(Path(__file__))
    basic=data('data/cards/basic_cards.json')['cards']
    manuals=[data(str(p.relative_to(ROOT))) for p in sorted((ROOT/'data/cards/martial_manuals').glob('*.json'))]
    opponents=data('data/run/vertical_slice_opponents.json')['candidates']
    constraints=data('data/run/bimu_constraints.json')['constraints']
    budgets=data('docs/planning-data/approved_20260806_ten_manual_growth_budget_overlay_contract.json')
    records=json.loads(source(captures/'capture.json').read_text(encoding='utf-8'))['frames']
    clash=next(r for r in records if r['vfx'] and r['kind']=='clash')
    actual=captures/clash['file']
    for rel in ['src/run/vertical_slice_route_model.gd','src/run/vertical_slice_run_state.gd',
                'src/run/vertical_slice_opponent_catalog.gd','src/combat/combat_board_preview.gd',
                'docs/decisions/2026-09-09_RUN_START_OPPONENT_ROSTER_AND_GROWTH.md',
                'docs/07_COMBAT_UI_SPEC.md','docs/10_COMBAT_PRESENTATION_PLAN.md']:
        source(ROOT/rel)
    b=Book(output)
    b.page('열 칸의 거리, 세 번의 결단', '플레이 경험 · 화면 · 기술 · 등장인물 · 제작 상태를 함께 읽는 사람용 게임 블루프린트')
    b.photo(captures/'preparation-plan.png',30,130,520,350)
    b.p('숨은 수를 읽고,\n다음 수를 준비한다.',575,455,230,21,bold=True)
    b.p('1대1 무협 전술 게임. 공개된 거리와 지나간 행동으로 상대의 다음 수를 예상한다. 강호에서 얻은 수련과 정보는 판단의 선택지를 넓힌다.',575,355,230,12)
    b.p('이 판은 로컬 구현을 포함한 검토본이다. 화면 완성·모든 요구 구현·GitHub 병합·출시 승인을 뜻하지 않는다.',575,235,230,10)
    b.p('실제 Godot 준비 화면 · 1280×800 · 화면의 자원과 인물은 해당 촬영 시점의 예시',30,105,750,10)

    b.page('읽는 법과 현재의 경계','확정 방향과 실제 구현을 구분해야 다른 프로젝트에서도 안전하게 참고할 수 있다.')
    b.table(['표시','뜻','이번 문서에서의 예'],[
        ['현재 구현','코드·데이터가 연결되어 있음','10전 진행, 행로 4회 선택, 기술 목록'],
        ['실행 촬영','해당 상태를 실제 화면으로 확인','준비 화면, 카드 공개, 합 동작'],
        ['승인 방향 · 구현 남음','만들 방향은 승인됐지만 소비자 연결이 남음','회차 시작 상대 추첨, 성장 별호'],
        ['시각 참고','화풍·구도 목표이며 실제 화면이 아님','이전 화면 아틀라스'],
        ['검토 필요','자료가 있어도 품질·밸런스 결론은 아직 없음','고유 무기 모션, 최종 음향 청감, 모바일 실기기']
    ],[140,255,W-455],size=11)

    b.page('한 번의 여정은 이렇게 흐른다','합·회피·절초는 전투 내부 연출이다. 강호행로에는 비무 종료 후 돌아온다.')
    labels=['메인\n새 여정 / 이어하기','시작 무공\n6권 중 4권','비무 브리핑\n상대 / 제약','비무\n계획 / 실행','결과\n보상 / 재도전']
    for i,t in enumerate(labels):
        x=30+i*159; b.box(x,330,145,110,HexColor('#e0d3bb')); b.p(t,x+10,420,125,13,bold=True)
        if i<4: b.p('→',x+146,390,13,13)
    b.p('승리 후 다음 비무까지: 강호행로에서 후보 3개 중 하나를 선택 × 4회 → 다음 브리핑',45,275,W-90,15,bold=True)
    b.p('10번째 비무를 마치면 여정 완료. 패배 시 재도전 범위와 저장 상태는 해당 진행 규칙을 따른다. 전투 연출이 화면을 바꾸더라도 진행·보상은 별도로 다시 계산하지 않는다.',45,205,W-90,12)
    b.p('핵심 리듬: 3수 계획 → 해결 → 3수 계획 → 해결 → 4수 계획 → 해결. 카드 모양은 행동을 읽는 방식이며 덱·손패·드로우 시스템이 아니다.',45,130,W-90,12)

    b.page('화면 아틀라스 · 시각 목표','기존 9장 구성은 화면 역할을 찾는 지도. 삽화 속 이름·수치는 현재 데이터가 아니다.','이전 시각 참고 / 실제 실행 화면 아님')
    b.photo(ROOT/'docs/visual-assets/candidates/TEN-HUMAN-BLUEPRINT-20260904/TEN_PACES_3X3_SCREEN_ATLAS_20260904_v1.png',30,75,W-60,405)
    b.p('메인 · 시작 무공 · 성장 · 행로 · 브리핑 · 기본 전투 · 합 · 절초 · 결과',30,62,W-60,10,bold=True)

    b.page('강호행로 · 세 후보, 네 번의 선택','현재 구현은 다섯 종류의 사건 풀에서 매 단계 세 후보를 제시한다.')
    b.photo(ROOT/'assets/backgrounds/jianghu_blue_ink_landscape_v1.png',30,180,450,290)
    b.p('1/4 → 2/4 → 3/4 → 4/4',510,450,295,19,bold=True)
    b.p('각 단계에서 하나의 결과만 적용하고 다음 후보로 넘어간다. 시작 시 하나의 긴 경로를 끝까지 고르는 방식이 아니다. 현재 후보 순환은 진행 횟수에 따라 정해지며 무작위 사건 생성기로 설명하지 않는다.',510,385,295,12)
    b.p('한 회차의 비무 사이 구간은 9곳, 모두 진행하면 행로 선택은 36회다. 그림은 행로용 배경 자산이며 완성된 UI 촬영이 아니다.',30,145,W-60,12)

    b.page('행로 사건표 · 현재 다섯 종류','실제 연결된 효과를 적었다. 아직 없는 대화 분기나 고유 사건을 완성 콘텐츠로 세지 않는다.')
    b.table(['선택','즉시 효과','다음 비무에 남는 것'],[
        ['주막에서 휴식','최대 체력의 25% 회복\n기력 +1 · 내력 +1','소모된 자원 정비'],
        ['공터에서 수련','자유 수련 포인트 +3','성장 선택의 여유'],
        ['상대 무공 조사','다음 상대의 보유 무공 단서','공개 정보 기반의 대비'],
        ['길 잃은 행인 돕기','자유 수련 +2 · 내력 +1','성장과 자원 보충'],
        ['남겨진 발자국 조사','보법 단서 · 자유 수련 +1','이동 습관을 읽는 단서']
    ],[180,270,W-510],size=11)
    b.p('기회비용: 한 선택은 그 단계의 나머지 두 선택을 포기한다. 정탐 단서는 미래의 잠긴 행동 정답이나 AI 확률이 아니다.',30,130,W-60,11)

    b.page('주막에서 쉬어 간다','전투의 긴장과 휴식의 온도 차이를 만든다. 아래는 배경 자산이며 현재 UI 촬영은 아니다.')
    b.photo(ROOT/'assets/backgrounds/jianghu_rest_inn_v1.png',30,120,540,350)
    b.p('읽혀야 하는 정보',590,445,220,17,bold=True)
    b.p('회복 전 → 회복 후\n어떤 자원이 얼마나 돌아왔는가\n다음 행로 선택은 몇 번째인가',590,395,220,12)
    b.p('제작 원칙: 삽화에 숫자나 버튼을 굽지 않고 별도 UI로 표시한다. 회복 처리는 한 번만 적용하고 되돌아오거나 이어하기로 중복 지급되지 않아야 한다.',590,290,220,11)

    b.page('전투 준비 · 현재 실행 화면','전투 장면 60%를 지키면서 하단 40%를 계획·기술·상세·관찰에 사용한다.','실행 촬영 / 시각 폴리싱 진행 중')
    b.photo(captures/'preparation-plan.png',30,78,W-60,405)
    b.p('현재 과제: HUD 이름 주변 장식 간섭, 계획 카드의 삽화 비중, 작은 글자와 효과 패널의 여백을 추가 검수한다.',30,65,W-60,9)

    b.page('준비 화면 와이어프레임','정보 구조를 설명하는 도식. 완성 화면이나 새 미술 자산이 아니다.')
    b.box(30,240,W-60,240,HexColor('#ccd4d1')); b.p('전투 영역 60%\n양측 상태 · 라운드 · 거리 · 실제 캐릭터',60,420,W-120,20,bold=True)
    for x,w,t in [(30,400,'현재 계획 → 행동 목록\n기본 / 무공 / 절초 · 5×2'),(440,180,'선택한 기술 상세\n삽화 / 효과 / 조건'),(630,W-660,'상대 행동 관찰\n아래에 행동 실행')]:
        b.box(x,77,w,151,HexColor('#e0d3bb')); b.p(t,x+12,205,w-24,12,bold=True)

    b.page('카드를 공개하고 실제 수를 겨룬다','수행 명령 뒤 현재 수의 공개 카드와 합 동작이 보이는 실제 전투 프레임이다.','실행 촬영 / 최종 연출 승인 아님')
    b.photo(actual,30,78,W-60,405)
    b.p('검수 과제: 장풍도 검 접촉으로 표현되는 임시 공통 모션, 불꽃의 실제 가시성, 몸 겹침을 교정해야 한다.',30,65,W-60,9)

    b.page('합 · 부딪친 뒤의 반응까지 읽힌다','합 승패와 체력 피해는 같은 사실이 아니다. 방어 자세를 무조건 피격으로 바꾸지 않는다.')
    b.table(['순서','승자','패자'],[
        ['접근','상체 높이의 접촉으로 진입','같은 바닥선과 몸 간격 유지'],
        ['충돌','접촉 순간 불꽃·짧은 타격 정지','같은 접촉점을 공유'],
        ['결과 반응','중심을 유지하고 검을 수습','먼저 공간을 내주고 균형 회복'],
        ['복귀','원래 논리 거리에 맞는 대기 자세','원래 논리 거리에 맞는 대기 자세']
    ],[100,330,W-490],size=11)
    b.p('현재 기본 합 연출은 0.90초, 절초는 1.05초. 이 값은 십보강호의 로컬 조정값이지 타 게임의 권장 표준이 아니다. 검 이외의 무기는 별도의 그립·궤적·접촉 검증이 남아 있다.',30,180,W-60,12)

    b.page('모션 제작표 · 양쪽 인물을 함께 검수','승인된 검 대표 캐릭터와 모션은 유지한다. 무기만 바꾸어 같은 그림을 전부 재사용하지 않는다.')
    b.table(['동작군','확인할 연결','재사용 경계'],[
        ['대기 / 이동','발 기준점·크기·거리 변화','무기 그립과 상체 균형은 개별 검수'],
        ['공격 / 절초','예비 동작 → 궤적 → 충돌 → 회수','검·창·비수·권·장풍을 구분'],
        ['방어 / 회피 / 피격','상대 궤적과 반응 시점 일치','맞지 않은 회피를 피격으로 표현하지 않음'],
        ['합 승리 / 합 패배','서로 다른 반동 후 원위치','무기 접촉 없는 행동은 검 맞대기 금지'],
        ['비무 승리 / 패배','진행 종료와 결과 화면 연결','합 한 번의 결과와 비무 종료를 혼동하지 않음']
    ],[150,310,W-520],size=10.5)

    b.page('VFX · 카메라 · 소리의 역할','연출은 판정을 강조한다. 연출이 게임 규칙을 다시 계산하지 않는다.')
    b.table(['요소','현재 연결 / 검수 기준','남은 품질 확인'],[
        ['합 불꽃','상체 접촉점에 짧게 표시','실제 검날 교차점과의 오차, 얼굴 가림'],
        ['베기 궤적','캐릭터와 분리된 효과 계층','무기별 회전축·방향·반전'],
        ['카메라 흔들림','전장만 흔들고 UI는 고정','과도한 흔들림·멀미·강도 선호'],
        ['타격 정지','캐릭터 연출만 짧게 정지','카드 공개·판정·저장 흐름 불변'],
        ['효과음','금속 충돌과 검풍을 별도 큐로 구분','실제 장치 청감·음량·반복 피로'],
        ['모션 감소','움직임을 줄여도 결과는 유지','대체 피드백의 사람이 느끼는 명확성']
    ],[115,335,W-510],size=10)

    b.page('적 구성 · 현재와 다음 구현을 구분한다','적 데이터의 다양성, 고유 이미지의 다양성, 회차 추첨 구현은 서로 다른 상태다.')
    b.p('현재: 15명 후보 데이터, 실제 10전은 고정 순서',35,465,W-70,19,bold=True)
    b.p('승인 방향: 새 게임 시작 시 1~10전 상대를 한 번에 추첨한다. 같은 인물의 이름·정체성은 유지하면서 단계별 별호, 능력치, 보유 무공의 숙련도로 성장한 모습을 보여준다.',35,400,W-70,14)
    b.p('구현 남음: 확정된 상대 10건 저장, 이어하기에서 재추첨 방지, 브리핑·정탐·보상·전투 저장의 같은 상대 사용, 단계별 성장과 무기 모션 연결.',35,310,W-70,13)
    b.p('이 문서의 다음 적 표는 현재 후보의 설정과 시드 데이터다. 새 무작위 스테이지 밸런스가 확정됐다는 뜻이 아니다. 고유 원화 15장·무기 모션 15종 완성으로 세지 않는다.',35,205,W-70,12)

    catalog=(ROOT/'src/run/vertical_slice_opponent_catalog.gd').read_text(encoding='utf-8')
    ids=re.findall(r'"([^"]+)"',re.search(r'const CAMPAIGN_ORDER := \[(.*?)\]',catalog,re.S).group(1))
    by_id={x['candidate_id']:x for x in opponents}; by_manual={x['manual_id']:x for x in manuals}
    b.page('현재 10전 편성표','현재 코드의 고정 편성. 앞으로 만들 무작위 편성의 완성표가 아니다.')
    b.table(['비무','현재 상대','대표 무공','능력치 합계 / 수련도'],[
        [str(i+1),by_id[k]['working_name'],by_manual[by_id[k]['signature_manual_id']]['manual_name'],
         f"{by_id[k]['final_stat_total_seed']} / {by_id[k]['signature_star_seed']}성"] for i,k in enumerate(ids)
    ],[65,150,320,W-595],size=10)

    for start in range(0,len(opponents),5):
        b.page(f'등장인물 도감 · {start//5+1}','현재 후보 설정과 정성적 습관. AI 확률·미확정 계획은 독자에게 노출하지 않는다.')
        rows=[]
        for x in opponents[start:start+5]:
            rows.append([x['working_name']+'\n'+x['martial_identity'],by_manual[x['signature_manual_id']]['manual_name'],
                         x['readable_habit']+'\n반례: '+x['ambiguity_or_counterexample']])
        b.table(['인물 / 무인상','대표 무공','평소 습관과 깨지는 경우'],rows,[130,160,W-350],size=10)

    for start in (0,5):
        b.page(f'기본 행동 · {start//5+1}','실제 카드 데이터. 소요 수와 기력·내력 비용은 서로 다른 항목이다.')
        b.table(['행동','소요 / 비용 / 거리','플레이어가 이해할 효과'],[
            [x['name'],f"{x['action_slots']}수 · 기력 {x['stamina_cost']} · 내력 {x['internal_cost']}\n거리 {x['range_text']}",x['effect_text']]
            for x in basic[start:start+5]], [105,210,W-375],size=11)

    b.page('자원·영구 능력·전투 상태','현재 자원과 성장 능력, 한 수의 결과를 서로 다른 정보로 읽는다.')
    b.table(['구분','플레이어가 읽는 것','혼동하지 않을 것'],[
        ['현재 자원','체력 · 기력 · 내력 · 절초 기세','현재값과 최대값을 구분'],
        ['영구 능력','외공 · 근골 · 신법 · 내공 · 심안','내공 능력치와 소비 자원 내력은 별개'],
        ['거리','시작 거리 2 · 거리 0은 밀착','절대 칸 번호보다 두 인물 사이 거리'],
        ['막기 / 회피','피해 감소와 완전 회피를 구분','합 승패가 곧 체력 피해는 아님'],
        ['강건 / 중단','강건은 다음 중단 1회 방지','피해를 없애는 무적 효과가 아님'],
        ['관찰','획득한 관찰점으로 행동 유형을 확인','기술명·방향·정답 확률을 공개하지 않음']
    ],[120,340,W-520],size=11)

    for start in (0,5):
        b.page(f'비무 제약 · {start//5+1}','브리핑에서 0~2개 · 총 3점 이내 · 상대 강화는 최대 1개. 이번 비무에만 적용한다.')
        b.table(['제약','선택 점수','실제 적용 범위'],[
            [x['display_name_ko'],x['selection_cost'],x['effect_summary_ko'].replace('★','성')]
            for x in constraints[start:start+5]], [130,85,W-275],size=10.5)
        b.p('대상이 필요한 제약은 선택한 무공·능력치를 확인한다. 재도전에서는 같은 제약을 복원한다. 제약 점수와 보상 배율을 자동으로 연결하는 규칙은 현재 없다.',30,112,W-60,10)

    b.page('비무 결과와 다음 성장','비무 종료의 승패, 합 한 번의 승패, 연출의 성공을 구분한다.')
    b.table(['보상 선택','현재 보상 모델의 값','조건'],[
        ['자유 수련','자유 수련 +6','특정 무공 대상 선택 없음'],
        ['집중 수련','자유 수련 +3 · 집중 수련 +5','보유 무공 중 대상 선택'],
        ['문파 전수','상대 대표 무공 · 수련도 3성','해당 상대의 실제 대표 무공 참조']
    ],[145,320,W-525],size=12)
    b.p('결과 화면은 실제 원인과 자원 변화, 보상을 보여 주고 다음 진행으로 연결한다. 최종 평점 계산식은 미확정이므로 임의 점수나 등급을 붙이지 않는다. 보상 데이터가 있다는 사실과 지급·저장·중복 방지 검증은 별개다.',30,260,W-60,13)
    source(ROOT/'src/run/vertical_slice_result_model.gd')

    b.page('무공 성장 · 제작 예산 읽기','예산 단위는 제작 평가값이다. 체력 피해나 게임 내 재화와 혼동하지 않는다.')
    b.table(['항목','현재 제작 기준','해석'],[
        ['행동 슬롯','1수 20 · 2수 50 · 3수 80','기술 설계의 기본 허용 예산'],
        ['자원 허용분','기력 1당 4 · 내력 1당 7','비용에 따른 설계 여유'],
        ['신규 거리 효과','이동 1칸 15 · 추가 사거리 1칸 15','구형 거리 가격을 새 기술에 혼용하지 않음'],
        ['자동 허용 차이','5 이내','설계 검토 기준이며 최종 밸런스 승인 아님'],
        ['3 / 7 / 10성','기술 1 / 기술 2 / 절초','실제 기술 데이터에서 확인'],
        ['5 / 9성','3성 / 7성 기술에 부가 효과','별도 손패나 추가 입력으로 설명하지 않음']
    ],[130,270,W-460],size=10.5)

    b.page('무공별 7성·9성 예산표','승인된 성장 예산 표를 그대로 읽는다. 개별 실행 피해량을 예산에서 역산하지 않는다.')
    profiles=budgets['star7_profiles']
    b.table(['무공','7성 예산','9성 추가','9성 총예산'],[
        [m['manual_name'],profiles[m['manual_id']]['star7_final_budget_ticks'],profiles[m['manual_id']]['star9_bonus_ticks'],profiles[m['manual_id']]['star9_total_budget_ticks']]
        for m in manuals], [330,130,130,W-650],size=10)

    for m in manuals:
        b.page(m['manual_name'],f"{m['faction']} · 주력 {m['primary_stat']} / 보조 {m['secondary_stat']} · 실제 기술 데이터의 처리 순서")
        for col,key in enumerate(('star3','star7','star10')):
            card=m['cards'][key]; x=30+col*263; width=249
            b.box(x,53,width,428,HexColor('#e5dfd1'))
            top=b.p(f"{card['unlock_star']}성 · {card['name']}",x+10,466,width-20,14,bold=True)-8
            rng=card['range']; range_text='자신' if rng['min']==rng['max']==0 else f"거리 {rng['min']}~{rng['max']}"
            top=b.p(f"{card['action_slots']}수 · 기력 {card['stamina_cost']} · 내력 {card['internal_cost']}\n{range_text}",x+10,top,width-20,10)-10
            effects='\n'.join(f'{i+1}. {describe(s)}' for i,s in enumerate(card['effect_steps']))
            top=b.p(effects,x+10,top,width-20,9.2)-14
            overlay_key={'star3':'star5','star7':'star9'}.get(key)
            if overlay_key and overlay_key in m.get('overlays',{}):
                o=m['overlays'][overlay_key]
                top=b.p(f"{o['unlock_star']}성 강화 · {o['name']}",x+10,top,width-20,11,bold=True)-6
                b.p('\n'.join(describe(s) for s in o['effect_steps']),x+10,top,width-20,9.2)

    b.page('다른 프로젝트에서 가져갈 것은 문서의 구조다','이 게임의 전투 숫자·무기 구성·60% 비율을 공용 정답으로 복사하지 않는다.')
    b.table(['재사용할 방식','프로젝트마다 다시 정할 것'],[
        ['전체 흐름 → 화면 아틀라스 → 실제 화면 → 상세 데이터','장르의 핵심 경험과 화면 흐름'],
        ['시안 / 승인 / 연결 / 실행 촬영을 따로 표시','실제 아트 방향과 승인 범위'],
        ['한 장면의 진입·선택·피드백·복귀를 함께 설명','조작 방식과 연출 속도'],
        ['효과의 조건과 후속 중단까지 표기','전투 규칙·자원·밸런스'],
        ['기계 검사와 사람 체감 품질을 구분','장치·접근성·청감·성능 기준'],
        ['검증된 교훈만 Base 기존 owner에 환류','프로젝트 전용 값을 공용 강제 규칙으로 만들지 않음']
    ],[380,W-440],size=11)

    b.page('검토본의 남은 일과 근거','이 페이지는 완성도 점수나 출시 승인서가 아니다.')
    b.table(['범위','이번에 확인한 근거','남은 확인'],[
        ['전투 시각','현재 실제 준비·공개·합 프레임','장풍의 검 모션·불꽃 가시성·몸 겹침·장식 간섭'],
        ['자동 검사','전체 502 통과 / 1 실패 후\n옛 시간 기대값 교정, 관련 5검사 통과','교정 후 전체 회귀·정확한 커밋의 CI'],
        ['10전 여정','현재 고정 10전 코드와 이전 완주 기록','새 추첨·별호·성장 저장 구현 후 다시 완주'],
        ['데이터','기초 10종·무공 10권·후보 15명','최종 수치 밸런스와 인물별 고유 미술'],
        ['배포 / 사람 검수','이번 문서에서 완료로 표시하지 않음','GitHub 병합, 장치·청감·접근성·출시'],
        ['출처','현재 저장소 규칙·실행 코드·데이터\n사용자 9월 8일 참고본·실제 캡처','다음 개정 시 같은 원본과 다시 대조']
    ],[105,330,W-495],size=10)
    b.c.save()
    receipt={'status':'LOCAL_REVIEW_NOT_FINAL','head':subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),
             'source_sha256':SOURCES,'pdf_sha256':hashlib.sha256(output.read_bytes()).hexdigest(),
             'page_count':b.n,'page_titles':b.titles,'counts':{'basic':len(basic),'manuals':len(manuals),'opponents':len(opponents)},
             'evidence_ceiling':'Local snapshot, not merged, not complete implementation or human/release approval'}
    output.with_suffix('.receipt.json').write_text(json.dumps(receipt,ensure_ascii=False,indent=2),encoding='utf-8')
    print(f'BLUEPRINT_CREATED pages={b.n} path={output}')


if __name__=='__main__':
    parser=argparse.ArgumentParser()
    parser.add_argument('--captures',type=Path,required=True)
    parser.add_argument('--output',type=Path,default=OUT)
    args=parser.parse_args()
    build(args.captures.resolve(),args.output.resolve())
