"""Source-backed current frame-rule presentation; never resolves game actions."""
from copy import deepcopy
from pathlib import Path
import hashlib
import math

from html_blueprint import ROOT, local_path, read, sha, verified_file

DECISION = 'docs/decisions/2026-09-25_FRAME_TIMELINE_AND_PROLOGUE.md'
FLOW_OWNER = 'docs/blueprint/CURRENT_FRAME_FLOW.md'
TIMING = 'data/combat/frame_timeline.json'
INTRO = 'data/run/frame_intro.json'
REFERENCES = 'docs/blueprint/evidence/frame-approved/references.json'
LAYERS = 'assets/ui/ink_frame/provenance.json'
RUNTIME = 'docs/blueprint/evidence/frame-runtime-20260925'
CAPTURE_RECEIPT = RUNTIME + '/capture-receipt.json'
WIN_CAPTURE_RECEIPT = RUNTIME + '/capture-win-receipt.json'
CLIP_RECEIPT = RUNTIME + '/clip-receipt.json'
WALKTHROUGH_ID = 'frame-current-walkthrough'

# Existing screen IDs remain stable, including result/route/end. New screens have
# their own IDs so previous comments never migrate onto an unrelated screen.
SCREEN_KEYS = {'menu': 'main', 'prologue': 'prologue', 'starter': 'setup',
               'tutorial': 'tutorial', 'first_route': 'first_journey', 'brief': 'briefing',
               'plan': 'preparation', 'resolve': 'resolution', 'result': 'result',
               'review': 'review', 'route': 'journey', 'end': None}


def image_block(path, root=ROOT, **fields):
    from PIL import Image
    with Image.open(local_path(root, path)) as picture:
        size = list(picture.size)
    return dict(kind='image', path=path, size=size, **fields)


def frame_assets(root=ROOT):
    result = []
    refs = local_path(root, REFERENCES)
    if refs.is_file():
        for row in read(root, REFERENCES)['references']:
            verified_file(root, row['path'], row['sha256'])
            result.append(dict(row, owner=REFERENCES))
    layers = local_path(root, LAYERS)
    if layers.is_file():
        for row in read(root, LAYERS)['assets']:
            verified_file(root, row['path'], row['sha256'])
            result.append(dict(row, kind='BACKGROUND_LAYER', name={
                'main_background': '메인 · 소나무와 산수 배경 레이어',
                'prologue_background': '출사표 · 주인공과 산문 배경 레이어',
                'preparation_background': '전투 준비 · 인물 없는 돌마당 배경 레이어'}[row['id']],
                owner=LAYERS, limit='글자·버튼·상태는 실제 게임 UI에서 별도 표시. 파생 그림의 최종 lock과 실행 검수는 별도.'))
    return result


def screen_media(root=ROOT):
    references = {r['screen']: r for r in frame_assets(root) if r['kind'] == 'APPROVED_LAYOUT_REFERENCE'}
    validated = validated_captures(root)
    result = {}
    for context, screen in SCREEN_KEYS.items():
        row = dict(preview=None, preview_kind='전용 실행 캡처 NOT_RUN', preview_short='촬영 없음', runtime_status='NOT_RUN')
        if screen in references:
            ref = references[screen]
            row.update(preview=image_block(ref['path'], root),
                       preview_kind='승인 배치 참고 · 실행 화면 아님', preview_short='승인 배치 참고', reference=ref)
        runtime_path = f'{RUNTIME}/{screen}.png' if screen else None
        if runtime_path and local_path(root, runtime_path).is_file():
            row['runtime_status'] = 'CAPTURE_PENDING_VALIDATION'
            if not row['preview']:
                row['preview_kind'] = '실행 캡처 검증 대기 · 미공개'
                row['preview_short'] = '촬영 검증 대기'
        preferred = {'result': 'victory', 'review': 'victory-review'}.get(context)
        capture_key = preferred if preferred in validated else screen
        if capture_key in validated:
            still = validated[capture_key]
            runtime_path = still['path']
            preview = image_block(runtime_path, root)
            row.update(preview=preview, preview_kind='검증된 실행 캡처 · Human 별도', preview_short='검증된 실행 캡처',
                       runtime_status='VERIFIED_CAPTURE',
                       still_capture=dict(still, size=preview['size'], screen=still.get('screen', screen.upper()),
                           label='10초 규칙 실행 캡처 확인서 PASS · 완주·재미·기기 검증은 별도'))
        if row['preview']:
            row['preview']['page_id'] = 'screen:' + context
        additional = {'first_route': ('event', '첫 행로 사건 선택'),
                      'route': ('later-event', '승리 후 강호행로 사건 선택'),
                      'result': ('result', '패배 결과 · 별도 실제 진행 사례'),
                      'review': ('review', '패배 복기 · 별도 실제 진행 사례')}.get(context)
        if additional and additional[0] in validated and additional[0] != capture_key:
            extra = validated[additional[0]]
            row['additional_captures'] = [dict(extra, label=additional[1] + ' · 촬영 확인서 PASS · Human 별도')]
        result[context] = row
    return result


def validated_captures(root=ROOT):
    """Invalid first-pass images must never become current runtime evidence."""
    result = {}
    for owner in [CAPTURE_RECEIPT, WIN_CAPTURE_RECEIPT]:
        if not local_path(root, owner).is_file():
            continue
        receipt = read(root, owner)
        if receipt.get('status') != 'PASS':
            continue
        for row in receipt.get('valid_shots', receipt.get('shots', [])):
            if not isinstance(row, dict):
                raise ValueError('A valid capture requires key, path and sha256 in the receipt')
            if row.get('status', 'PASS') != 'PASS':
                continue
            key = row['key']
            path = row['path'].removeprefix('res://')
            if path != f'{RUNTIME}/{key}.png' or key in result:
                raise ValueError('Capture receipt path or duplicate key mismatch')
            verified_file(root, path, row['sha256'])
            result[key] = dict(row, path=path, source=owner)
    return result


def validated_walkthrough(root=ROOT):
    """Only a reviewed receipt can publish the actual current-rule movie."""
    if not local_path(root, CLIP_RECEIPT).is_file():
        return None
    receipt = read(root, CLIP_RECEIPT)
    if receipt.get('status') != 'PASS':
        return None
    path = receipt['path'].removeprefix('res://')
    duration = receipt['duration_seconds']
    if path != RUNTIME + '/walkthrough.mp4':
        raise ValueError('Walkthrough receipt path mismatch')
    if isinstance(duration, bool) or not isinstance(duration, (int, float)) or not math.isfinite(duration) or duration <= 0:
        raise ValueError('Walkthrough duration must be a finite positive number')
    verified_file(root, path, receipt['sha256'])
    changed = [source for source, digest in receipt.get('source_hashes', {}).items()
               if not local_path(root, source).is_file() or sha(local_path(root, source)) != digest]
    poster = validated_captures(root).get('preparation')
    return dict(id=WALKTHROUGH_ID, title='현재 10초 규칙 · 출사표부터 결과·복기까지',
                path=path, path_sha256=receipt['sha256'], duration_seconds=duration,
                poster=poster['path'] if poster else None, manifest=CLIP_RECEIPT,
                source_revision=receipt.get('source_revision', '촬영 확인서 참조'),
                caption='실제 Godot 전체 진행 녹화 · 첫 10초는 1배속, 이후 진행은 촬영 확인서의 배속 적용',
                audio_label=receipt.get('audio_label', '소리 검수 별도'),
                outcomes=receipt.get('outcomes', ['출사표', '첫 비무', '실제 결과', '복기']),
                events=[], timeline=[], card_ids=[], visual_status='RECORDED_FLOW',
                historical=False, rule_set='FRAME_TIMELINE_V1',
                freshness=dict(status='STALE' if changed else 'MEDIA_VERIFIED', changed_paths=changed,
                               basis='RECEIPT_SHA256_AND_AVAILABLE_SOURCE_HASHES'),
                limit='촬영 확인서와 영상 파일 일치 · 사람 플레이·재미·기기·최종 자산 승인은 별도')


def extend_inventory(assets, root=ROOT):
    """Use the same path-based IDs as tracked-image discovery before git add."""
    known = {a['path'] for a in assets if a['scope'] == 'MAIN_SOURCE'}
    rows = frame_assets(root)
    for key, still in validated_captures(root).items():
        rows.append(dict(id='frame-runtime-' + key, path=still['path'], sha256=still['sha256'],
                         name='10초 규칙 실행 캡처 · ' + key, kind='RUNTIME_CAPTURE',
                         owner=still['source'], limit='촬영 확인서 PASS · 완주·재미·기기 검증은 별도'))
    for row in rows:
        if row['path'] in known:
            continue
        known.add(row['path'])
        assets.append(dict(id='inventory-' + hashlib.sha256(row['path'].encode()).hexdigest()[:16],
                           path=row['path'], name=row['name'], scope='MAIN_SOURCE', revision=None,
                           sha256=row['sha256'], available=True, active=None, consumers=[],
                           approval='APPROVAL_UNVERIFIED', approval_record=row['limit'], owner=row['owner'],
                           details=dict(frame_evidence_kind=row['kind'], usage=row['limit'])))
    return assets


def rules_summary(root=ROOT):
    config = read(root, TIMING)
    tick = config['tick_seconds']
    return dict(window_seconds=round(tick * config['window_ticks'], 6),
                tick_seconds=tick, window_ticks=config['window_ticks'],
                phases=['선딜', '발동', '후딜'],
                observation_seconds=[round(tick * config['observation_ticks_per_level'] * n, 6)
                                     for n in range(1, config['observation_max_level'] + 1)],
                observation_origin='관찰 동작 완료 시점',
                source=TIMING, intro=read(root, INTRO))


def timing_label(card, root=ROOT):
    """Expose the configured timing profile, without simulating its effects."""
    config = read(root, TIMING)
    timing = config['cards'].get(card['id'])
    if timing is None:
        key = 'martial_response_timing_by_slots' if card.get('category') == 'response' else 'martial_timing_by_slots'
        timing = config[key].get(str(max(1, min(3, int(card.get('action_slots', 1))))))
    if not timing:
        return '동작 시간 미확인'
    seconds = [round(timing[phase] * config['tick_seconds'], 6) for phase in ['startup', 'active', 'recovery']]
    return f'{sum(seconds):g}초 · 선딜 {seconds[0]:g} / 발동 {seconds[1]:g} / 후딜 {seconds[2]:g}초'


def attach_timing(cards, root=ROOT):
    overrides = read(root, TIMING).get('effect_text_overrides', {})
    for card in cards:
        card['frame_timing_text'] = timing_label(card, root)
        card['frame_timing_source'] = TIMING
        if card['id'] in overrides:
            card['effect_text'] = overrides[card['id']]
    return cards


def reader_current(pages, root=ROOT):
    """Adapt current reading only; original_blocks/PDF bytes remain historical."""
    from html_blueprint_reader import table, note
    by_id = {p['id']: p for p in pages}
    media = screen_media(root)
    rules = rules_summary(root)
    intro = rules['intro']
    def picture(context):
        row = media[context]
        if not row['preview']:
            return [note('이 화면의 실제 실행 캡처는 아직 없습니다. NOT_RUN · 연결된 현재 설명을 확인합니다.')]
        return [deepcopy(row['preview']), note(row['preview_kind'])]
    def update(id, title, subtitle, blocks):
        page = by_id[id]
        page.pop('shared_text_indices', None)
        page.update(title=title, subtitle=subtitle, blocks=blocks, current_owner=FLOW_OWNER,
                    historical_state='2026-09-25 승인 현재 설명 · 실행/Human 증거 별도')
    stages = [['메인', '새 게임 또는 저장된 진행 이어하기'],
              ['출사표', '주인공의 첫 여정과 목표 소개'],
              ['시작 무공', '삽화로 후보 6권 중 4권 선택 · 각 3성'],
              ['규칙 익히기', '10초·선딜/발동/후딜·관찰과 배치 연습'],
              ['첫 강호행로', '비전투 사건 1회 · 선택 결과는 한 번만 적용'],
              ['비무 브리핑', '나의 상태·대치·공개 상대 정보·삽화 제약'],
              ['행동 설계', '0.1초 논리 눈금으로 10초의 행동을 배치'],
              ['전투 진행', '같은 확정 사건으로 인물 동작·먹 효과·시간축·큰 결과 표시'],
              ['비무 결과', '승패·지급 결과·계속 또는 종료'],
              ['복기', '이미 해결된 사건을 재생 · 판정/보상 중복 없음']]
    update('reader-001', '열 칸의 거리, 열 초에 담는 수', '공개된 사실을 읽고 10초의 행동으로 답한다.',
           [table(['핵심 경험', '현재 규칙'], [['읽기', '공개 상태·해결 이력·관찰한 범위로 상대를 추론'],
            ['설계', '현재 해금 기술을 10초 시간축에 직접 배치'], ['해결과 복기', '같은 사건의 원인과 결과를 읽고 다음 계획을 수정']]),
            note('AI는 편집 중 계획과 UI 의도를 읽지 않습니다. 덱·손패·드로우·장착 기술 제한은 없습니다.')])
    update('reader-005', '새 여정부터 결과·복기까지', '출사표와 첫 행로를 거쳐 첫 비무로 이어지는 현재 흐름',
           picture('menu') + [table(['화면', '선택·피드백'], stages),
            note('첫 행로는 도입 사건 1회입니다. 이후 비무 사이의 기존 행로·성장 자료는 이어서 재사용합니다.')])
    update('reader-007', '출사표 · 강호에 첫발을 내딛다', intro['prologue']['subtitle'],
           picture('prologue') + [note(intro['prologue']['text']), table(['다음 단계', '확인할 것'], stages[2:5])])
    update('reader-008', '규칙 익히기와 첫 비전투 선택', '도입 진행과 선택 결과를 저장하고 한 번만 적용한다.',
           [table(['규칙 안내', '플레이어가 배우는 내용'], [[x['title'], x['text']] for x in intro['lessons']]),
            note(intro['event']['title'] + '\n' + intro['event']['text']),
            table(['첫 사건 선택', '판정 근거'], [[c['label'],
                ({'external':'외공', 'constitution':'근골', 'agility':'신법', 'internal_power':'내공', 'insight':'심안'}[c['check']['stat']] + ' · 난도 ' + str(c['check']['difficulty'])) if c.get('check') else '안전 선택 · 별도 확률 판정 없음']
                for c in intro['event']['choices']]),
            note('여기 표시한 첫 사건은 data/run/frame_intro.json의 현재 데이터입니다. 후속 행로 사건 목록과 구분합니다.')])
    for capture in media['first_route'].get('additional_captures', []):
        by_id['reader-008']['blocks'].extend([image_block(capture['path'], root), note(capture['label'])])
    update('reader-015', '비무 브리핑 · 상태와 제약을 한눈에', '나의 상태·대치·공개 상대 정보와 삽화 제약 선택',
           picture('brief') + [table(['영역', '표시할 정보'], [['나의 상태', '체력·기력·내력·보유 무공'],
            ['상대와 대치', '공개 상대 정보와 시작 거리 2'], ['비무 제약', '선택 비용과 조건을 비교한 뒤 확정']]),
            note('배치 참고 그림의 예시 수치는 실제 상대·저장 데이터와 구분합니다. 미확정 적 계획을 브리핑에서 공개하지 않습니다.')])
    update('reader-016', '전투의 판단 단위 · 10초', '100논리 틱 · 한 눈금 0.1초 · 렌더링 프레임과 분리',
           [table(['구분', '현재 규칙'], [['계획 창', f"{rules['window_seconds']:g}초 / {rules['window_ticks']}틱"],
            ['선딜', '기술을 준비하는 시간'], ['발동', '실제 공격·방어·회피 등 효과가 유효한 구간'],
            ['후딜', '동작을 마무리하는 시간'], ['동작 겹침', '같은 인물의 동작은 겹치지 않음'],
            ['창의 경계', '남은 동작은 다음 창에 이어짐 · 비용/타격 중복 적용 없음']]),
            note('확정하면 편집을 마치고 같은 사건 기록으로 연출합니다. 해금 기술을 직접 배치하며 덱·드로우 제한을 만들지 않습니다.')])
    update('reader-017', '전투 준비 · 10초 행동 설계', '전장·관찰 범위·나와 상대의 시간축·삽화 선택',
           picture('plan') + [{'kind': 'basic_actions'}, table(['영역', '표시와 조작'], [
            ['전장', '실제 거리와 살아 있는 인물'], ['관찰 정보', '관찰 완료 시점부터 확인된 적 행동 3·6·9초'],
            ['시간축', '선딜·발동·후딜 길이, 겹침과 다음 창 이월'], ['기술 삽화', '현재 해금 기술·효과·자원 비용'],
            ['확정', '유효한 계획을 잠그고 전투 진행']])])
    update('reader-018', '기술의 길이와 배치 시점', '시간·자원·거리 조건을 각각 읽고 확정한다.',
           [table(['기초 행동', '현재 시간 배분', '효과'], [[c['name'], timing_label(c, root),
               read(root, TIMING).get('effect_text_overrides', {}).get(c['id'], c.get('effect_text', ''))]
               for c in read(root, 'data/cards/basic_cards.json')['cards']]),
            note('초 단위는 frame_timeline.json의 값에서 표시했습니다. 공격 성공은 실제 거리와 발동 구간·대응 상태에 따라 게임 코어가 판정합니다.')])
    update('reader-019', '거리와 관찰 · 확인된 미래만 읽는다', '시작 거리 2 · 거리 0은 밀착',
           [table(['관찰 단계', '완료 시점부터 확인하는 구간'], [[str(i + 1) + '단계', f'{value:g}초'] for i, value in enumerate(rules['observation_seconds'])]),
            note('적은 플레이어의 편집 중 계획을 읽지 않고 먼저 확정됩니다. 관찰 이후에도 잠긴 계획을 바꾸지 않습니다. 확인 범위 밖은 미확인으로 유지합니다.'),
            note('절대 칸 번호 대신 거리 N으로 읽습니다. 관찰은 완료 시점부터 시작하며 창 시작까지 거슬러 공개하지 않습니다.')])
    update('reader-020', '전투 진행 · 같은 사건을 화면으로 읽는다', '확정된 기록 → 인물 동작·먹 효과·시간축·큰 결과',
           picture('resolve') + [table(['읽는 순서', '표현'], [['행동 구간', '양측 기술의 선딜·발동·후딜 진행'],
            ['접촉과 판정', '실제 거리·합·방어·회피·중단'], ['즉시 결과', '하단에 크게 표시하는 원인과 결과'],
            ['다음 판단', '비무가 계속되면 다음 10초 계획 · 종료되면 결과 화면']]),
            note('이전 슬롯 규칙의 녹화는 역사 자료입니다. 현재 10초 판정의 실행 증거로 대체하지 않습니다.')])
    update('reader-023', '회피 · 발동 구간과 공격을 대조한다', '회피의 유효 시간과 공격 위력은 서로 다른 정보다.',
           [table(['확인할 것', '현재 읽기 기준'], [['기초 회피', read(root, TIMING)['effect_text_overrides']['basic_evade']],
            ['발동 구간', '선딜이나 후딜을 회피 성공 구간으로 표시하지 않음'],
            ['결과', '실제로 회피한 공격은 피해 없음 · 회피를 공격 위력에서 빼는 수치로 설명하지 않음'],
            ['연출', '공격 궤적 이탈과 실제 판정을 연결 · 빗나간 공격에 타격 불꽃·피격음을 붙이지 않음']]),
            note('회피·필중·추가 효과의 실제 조건은 게임 코어와 무공 데이터가 소유합니다. 이전 슬롯·잔여 횟수 그림은 승인 당시 자료로 보존합니다.')])
    update('reader-024', '방어·회피·피격·중단의 다른 결과', '동작의 유효 구간과 확정 사건을 함께 읽는다.',
           [table(['상황', '판정에서 읽을 것', '표현'], [
            ['기초 막기', read(root, TIMING)['effect_text_overrides']['basic_guard'], '받아내는 자세와 실제 피해를 분리'],
            ['기초 회피', read(root, TIMING)['effect_text_overrides']['basic_evade'], '궤적 이탈 · 성공한 회피에 피격 표시 없음'],
            ['피격', '실제 체력 피해 발생', '피해 위치의 반동과 체력 변화'],
            ['중단', '실제 취소된 준비·후속 사건', '남은 동작 취소와 회수 자세'],
            ['강건', '코어가 기록한 중단 방지', '피해 면역과 구분'],
            ['합', '공유 코어의 승리·패배·무승부 기록', '결과에 맞는 양측 반응']]),
            note('화면과 복기는 이미 계산된 결과를 재사용하며 별도의 판정을 만들지 않습니다.')])
    update('reader-027', '비무 결과와 복기를 분리해서 읽는다', '결과는 지급·진행, 복기는 이미 해결된 사건의 재생',
           picture('result') + [table(['화면', '역할'], [['비무 결과', '승패·실제 지급·계속/종료'],
            ['복기', '같은 사건을 다시 보며 원인 확인 · 전투 판정/보상 재실행 없음']])] + picture('review'))
    update('reader-078', '기술 시간과 제작 예산의 경계', '동작 시간의 현재 원본은 0.1초 논리 틱 데이터다.',
           [table(['대상', '현재 읽기 기준'], [['동작 길이', '선딜·발동·후딜의 합'], ['자원 비용', '기력·내력·절초 조건은 시간과 별개'],
            ['이전 슬롯 예산', '승인 당시 PDF의 역사 비교값 · 현재 초 단위 밸런스 검증이 아님'],
            ['5·9성', '기존 기술의 효과 강화 · 해금 및 실제 조건은 무공 데이터 참조']]),
            note('시간표 존재는 사람 밸런스 PASS가 아닙니다. 실제 판정·실행·가독성·재미 근거를 분리합니다.')])
    layers = [r for r in frame_assets(root) if r['kind'] == 'BACKGROUND_LAYER']
    update('reader-082', '그림 레이어와 살아 있는 UI의 연결', '승인 시안에서 분리한 실제 배경 파일 · 상태와 버튼은 게임이 그린다.',
           [b for row in layers for b in [image_block(row['path'], root), note(row['name'] + '\n' + row['limit'])]])
    by_id['reader-082']['layout'] = 'image_runs'
    atlas = []
    seen = set()
    labels = {'menu': ('메인 메뉴', '메인 화면'), 'prologue': ('도입', '출사표'), 'starter': ('도입', '삽화 시작 무공'),
              'tutorial': ('도입', '10초 규칙 안내'), 'first_route': ('강호행로', '첫 행로'),
              'brief': ('전투', '비무 브리핑'), 'plan': ('전투', '전투 준비'), 'resolve': ('전투', '전투 진행'),
              'result': ('전투', '비무 결과'), 'review': ('전투', '복기'), 'route': ('강호행로', '후속 강호행로')}
    for context, (kind, label) in labels.items():
        row = media[context]
        candidates = [(row['preview'], row['preview_kind'])]
        if row.get('reference'):
            candidates.append((image_block(row['reference']['path'], root), '승인 배치 참고 · 실행 화면 아님'))
        candidates.extend((image_block(capture['path'], root), capture['label'])
                          for capture in row.get('additional_captures', []))
        for preview, state in candidates:
            if not preview or preview['path'] in seen:
                continue
            seen.add(preview['path'])
            atlas.append(dict(preview, screen_context=context, screen_label=label + ' · ' + state,
                              screen_kind=kind, screen_usage=label, evidence_kind='RUNTIME_CAPTURE' if preview['path'].startswith(RUNTIME) else 'APPROVED_LAYOUT_REFERENCE'))
    # Unchanged menu utilities keep their earlier evidence explicitly labelled.
    for screen, label in [('library', '강호 도감'), ('settings', '감상 설정')]:
        path = f'docs/blueprint/evidence/ink-screens-20260925/{screen}.png'
        if local_path(root, path).is_file():
            atlas.append(image_block(path, root, screen_context='menu', screen_label=label + ' · 이전 촬영 참고',
                         screen_kind='메인 메뉴', screen_usage=label, evidence_kind='HISTORICAL_CAPTURE'))
    update('reader-006', '현재 화면 연결과 승인 배치 참고', '실행 캡처가 있는 화면만 촬영으로 표시합니다. 시안·그림 레이어·역사 기록은 구분합니다.', atlas)
    by_id['reader-006']['layout'] = 'screen_gallery'
    # Older strategy pages keep their stable IDs and explanations. Replace the
    # obsolete timing premise only; the exact approved original stays attached.
    replacements = [('3·3·4수', '10초 행동 시간축'), ('3·3·4', '10초'), ('3/3/4', '10초 계획 창'),
                    ('3수 → 해결 → 3수 → 해결 → 4수', '10초 설계 → 해결 → 다음 10초 설계'),
                    ('3수 / 3수 / 4수 해결', '10초 행동 해결')]
    def current_text(value):
        if isinstance(value, str):
            for old, new in replacements:
                value = value.replace(old, new)
            return value
        if isinstance(value, list): return [current_text(v) for v in value]
        if isinstance(value, dict): return {k: current_text(v) for k, v in value.items()}
        return value
    for page in pages:
        for key in ['title', 'subtitle', 'blocks']:
            page[key] = current_text(page[key])
        for block in page['blocks']:
            block['page_id'] = page['id']
    return pages
