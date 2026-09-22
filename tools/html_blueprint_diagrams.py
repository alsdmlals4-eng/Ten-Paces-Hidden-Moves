"""Small, source-linked presentation maps; not runtime graphs or an Archify fork.

Archify's typed relationships, stable IDs and evidence separation informed this
adapter. See the project Skill reference for source revision and adoption limits.
"""
from html_blueprint import ROOT, local_path, unique_ids


def node(id, label, detail, source, x, y):
    return {'id':id,'label':label,'detail':detail,'sources':[source], 'x':x,'y':y,'w':220,'h':90}


def edge(id, source, target, label, points, label_at, variant='normal'):
    return {'id':id,'from':source,'to':target,'label':label,'points':points,'label_at':label_at,'variant':variant}


def build():
    game={'id':'game-loop','kind':'workflow','title':'한 회차가 이어지는 방식','width':1080,'height':720,
        'note':'주요 화면과 분기를 읽는 설명용 흐름입니다. 첫 패배 재도전·저장·보상 세부 규칙은 연결된 원본과 게임 이해에서 확인합니다.',
        'nodes':[
            node('menu','메인 화면','새 여정 또는 저장된 여정 이어하기.','src/ui/main_title_screen.gd',40,40),
            node('starter','시작 무공','새 여정의 시작 무공을 선택한다.','src/run/vertical_slice_starter_manual_catalog.gd',390,40),
            node('brief','상대 브리핑','확정된 상대·공개 정보·제약을 확인한다.','src/run/vertical_slice_shell.gd',740,40),
            node('plan','수를 배치','현재 해금 기술로 3수·3수·4수를 계획한다.','src/ui/action_selection/action_selection_dock.gd',740,290),
            node('resolve','합과 해결','공유 코어가 공개된 행동을 판정한다.','src/combat/combat_resolution_engine.gd',390,290),
            node('result','결과와 복기','승패·보상·첫 패배 재도전·종료를 구분한다.','src/run/vertical_slice_result_model.gd',40,290),
            node('route','강호행로','비무 사이 4회 선택 뒤 다음 상대를 만난다.','src/run/vertical_slice_route_model.gd',40,540),
            node('end','여정 종료','10전 승리 또는 종료 조건에 따라 메인으로 복귀한다.','src/run/vertical_slice_run_state.gd',390,540)],
        'edges':[
            edge('new','menu','starter','새 여정',[[260,85],[390,85]],[325,65]),
            edge('start','starter','brief','선택 확정',[[610,85],[740,85]],[675,65]),
            edge('enter','brief','plan','비무 시작',[[850,130],[850,290]],[900,210]),
            edge('commit','plan','resolve','행동 실행',[[740,335],[610,335]],[675,315]),
            edge('resolved','resolve','result','비무 종료',[[390,335],[260,335]],[325,315]),
            edge('next','result','route','승리·계속',[[150,380],[150,540]],[95,450]),
            edge('finish','result','end','종료 조건',[[220,380],[220,450],[500,450],[500,540]],[355,432]),
            edge('repeat','route','brief','다음 비무',[[260,590],[1030,590],[1030,85],[960,85]],[1020,235],'return') ]}
    # Keep the return corridor below the end node instead of crossing it.
    game['edges'][-1]['points']=[[150,630],[150,680],[1030,680],[1030,85],[960,85]]
    game['nodes'][4]['sources'].append('src/combat/combat_board_preview.gd')
    game['edges'].append(edge('continue-bundle','resolve','plan','다음 묶음 · 3/3/4 반복',[[610,365],[685,365],[685,425],[850,425],[850,380]],[775,454],'return'))
    flow={'id':'source-to-review','kind':'dataflow','title':'기획·자산이 검수 화면으로 연결되는 방식','width':1080,'height':480,
        'note':'기획·승인·게임 원본은 저장소에 남습니다. HTML은 읽기용 파생본이며 사용자 검수는 원본 수정의 근거로 연결됩니다.',
        'nodes':[
            node('owners','기획·승인 원본','본문·데이터·자산 승인·PM의 기존 책임 원본.','docs/blueprint/READING_STRUCTURE.md',40,40),
            node('collect','수집과 대조','내용·파일 해시·사용처·GitHub 관측을 대조한다.','tools/html_blueprint.py',390,40),
            node('render','HTML 발행','표시 모델을 같은 HTML·인덱스로 출력한다.','tools/build_html_blueprint.py',740,40),
            node('view','HTML·구조도','검색·자산·모션·구현·PM을 같은 항목으로 찾는다.','tools/html_blueprint_ui/app.js',740,290),
            node('review','사용자·AI 검수','실제 브라우저의 표시·조작과 자동 근거를 구분해 확인한다.','docs/blueprint/HTML_MIGRATION_SPEC.md',390,290),
            node('update','원본에 반영','승인된 수정을 기존 원본에 반영한 뒤 재발행한다.','[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md',40,290)],
        'edges':[
            edge('read','owners','collect','참조·검사',[[260,85],[390,85]],[325,65]),
            edge('model','collect','render','표시 모델',[[610,85],[740,85]],[675,65]),
            edge('publish','render','view','검사 후 발행',[[850,130],[850,290]],[922,212]),
            edge('inspect','view','review','직접 열람',[[740,335],[610,335]],[675,315]),
            edge('approve','review','update','승인·교정',[[390,335],[260,335]],[325,315]),
            edge('write','update','owners','기존 원본 갱신',[[150,290],[150,130]],[232,215],'return')]}
    sequence={'id':'clash-sequence','kind':'sequence','title':'합 이후 카드 연출을 읽는 순서','width':1080,'height':650,
        'note':'승인된 표현 계약의 설명입니다. 화살표는 실행 영상이 아니며 정확한 타이밍과 포즈는 PR #342 프리셋·실행 근거를 대조합니다.',
        'nodes':[
            node('ui','계획·플레이어','계획 확정과 결과 읽기.','src/ui/action_selection/action_selection_dock.gd',50,30),
            node('core','공유 판정 코어','합·피해·회피 등 규칙을 판정한다.','src/combat/combat_resolution_engine.gd',430,30),
            node('presentation','전투 연출','결과를 포즈·움직임·효과로 전달한다.','docs/10_COMBAT_PRESENTATION_PLAN.md',810,30)],
        'edges':[
            edge('confirm','ui','core','1. 행동 계획 확정',[[160,185],[540,185]],[350,172]),
            edge('resolve','core','presentation','2. 해결 결과 전달',[[540,275],[920,275]],[730,262]),
            edge('clash','presentation','presentation','3. 격돌 → 합 승리·패배',[[920,335],[1005,335],[1005,375],[920,375]],[785,352]),
            edge('card','presentation','presentation','4. 카드별 준비·접근·타격·복귀',[[920,440],[1005,440],[1005,480],[920,480]],[740,458]),
            edge('return','presentation','ui','5. 다음 수 또는 선택 화면으로 복귀',[[920,565],[160,565]],[540,548],'return')]}
    diagrams=[game,flow,sequence]
    for diagram in diagrams:validate(diagram)
    return diagrams


def validate(diagram):
    unique_ids(diagram['nodes']);unique_ids(diagram['edges'])
    by_id={n['id']:n for n in diagram['nodes']}
    for n in diagram['nodes']:
        if not n['label'] or not n['sources']:raise ValueError('Missing node evidence')
        for source in n['sources']:
            if not local_path(ROOT,source).is_file():raise ValueError(f'Missing diagram source {source}')
        if n['x']<0 or n['y']<0 or n['x']+n['w']>diagram['width'] or n['y']+n['h']>diagram['height']:
            raise ValueError('Node out of bounds')
        for other in diagram['nodes']:
            if n['id']<other['id'] and n['x']<other['x']+other['w'] and other['x']<n['x']+n['w'] and n['y']<other['y']+other['h'] and other['y']<n['y']+n['h']:
                raise ValueError('Overlapping nodes')
    for edge in diagram['edges']:
        if edge['from'] not in by_id or edge['to'] not in by_id or not edge['label']:
            raise ValueError('Invalid relationship')
        if diagram['kind']=='sequence':continue
        for a,b in zip(edge['points'],edge['points'][1:]):
            for n in diagram['nodes']:
                if n['id'] in {edge['from'],edge['to']}:continue
                if a[0]==b[0] and n['x']<a[0]<n['x']+n['w'] and max(min(a[1],b[1]),n['y'])<min(max(a[1],b[1]),n['y']+n['h']):
                    raise ValueError('Edge crosses unrelated node')
                if a[1]==b[1] and n['y']<a[1]<n['y']+n['h'] and max(min(a[0],b[0]),n['x'])<min(max(a[0],b[0]),n['x']+n['w']):
                    raise ValueError('Edge crosses unrelated node')
