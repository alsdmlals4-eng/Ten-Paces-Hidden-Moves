"""Compact HTML reading view; approved PDF content remains attached by stable ID."""
from copy import deepcopy


def reader_groups(pages):
    groups = [
        {'id':'screens','label':'아틀라스·기획서','pages':[]},
        {'id':'route','label':'강호행로 · 비전투','pages':[]},
        {'id':'combat','label':'전투 관련','pages':[]},
        {'id':'player','label':'플레이어 관련','pages':[]},
        {'id':'characters','label':'상대·적 관련','pages':[]},
        {'id':'audit','label':'이미지 모음','pages':[]},
    ]
    for page in pages:
        n = int(page['id'].split('-')[-1])
        group = (1 if 9 <= n <= 14 else 2 if 15 <= n <= 29 or n in {76,77,78,82,83,108}
                 else 3 if 65 <= n <= 75 or n == 79 else 4 if 30 <= n <= 64 or 97 <= n <= 106
                 else 5 if n == 109 else 0)
        groups[group]['pages'].append(page['id'])
    return groups


def table(headers, rows):
    return {'kind': 'table', 'headers': headers, 'rows': rows}


def note(text):
    return {'kind': 'note', 'text': text}


def event_catalog(source):
    """Render source meanings, not game checks. Godot alone computes live odds."""
    stats = {'external':'외공', 'constitution':'근골', 'agility':'신법', 'internal_power':'내공', 'insight':'심안'}
    items = {g['id']: g for g in source['giyun']}
    def effect(row):
        parts = []
        if row.get('training'): parts.append(f"자유 수련 +{row['training']}")
        if row.get('health_cost'): parts.append(f"체력 -{row['health_cost']}")
        if row.get('stamina'): parts.append(f"기력 {row['stamina']:+}")
        return ' · '.join(parts) or '보상·손실 없음'
    events = []
    for event in source['events']:
        choices = []
        for choice in event['choices']:
            check = choice.get('check')
            rare = choice.get('rare_bonus')
            choices.append(dict(id=choice['id'], label=choice['label'],
                check_text=f"{stats[check['stat']]} · 난도 {check['difficulty']}" if check else '안전 선택 · 판정 없음',
                success_text=effect(choice['success']), failure_text=effect(choice['failure']) if check else '실패 판정 없음',
                rare_text=(f"성공 후 추가 {rare['chance']}% · {items[rare['giyun_id']]['name']} / 이미 보유: 당첨 시 수련 +{source['chance_rule']['duplicate_training']}" if rare else '기연 없음'),
                giyun_id=rare['giyun_id'] if rare else ''))
        events.append(dict(id=event['id'], title=event['title'], text=event['text'], choices=choices))
    return dict(kind='event_catalog', events=events, chance_rule=deepcopy(source['chance_rule']))


def compact(blocks):
    result, panels = [], []
    def flush():
        if len(panels) > 1:
            result.append(table(['항목', '내용'], [[p['title'], p['text']] for p in panels]))
        else:
            result.extend(panels)
        panels.clear()
    for block in blocks:
        if block['kind'] == 'geometry':
            continue
        if block['kind'] == 'panel':
            panels.append(block)
            continue
        flush()
        result.append(table(['단계', '선택·피드백'], block['items']) if block['kind'] == 'flow' else block)
    flush()
    return result


def refine(pages, giyun):
    """An HTML-only layout adapter. It describes the existing GiyunRules contract."""
    by_id = {p['id']: p for p in pages}
    for page in pages:
        page['original_blocks'] = deepcopy(page['blocks'])
        page['blocks'] = compact(page['blocks'])
    # The PDF emits picture then label. Keep them in one card so a label cannot
    # appear to describe the next, unrelated full-width picture.
    # Similar long image lists retain their source order and text in compact views.
    comparison_layouts = {'reader-005': 'image_runs', 'reader-020': 'image_table',
                          'reader-022': 'sequence_table', 'reader-030': 'portrait_gallery'}
    comparison_layouts.update({f'reader-{i:03}': 'tactics_table' for i in range(97, 105)})
    for page_id, layout in comparison_layouts.items():
        by_id[page_id]['layout'] = layout
    # These are whole-screen progress/result labels, not opponent-card text.
    by_id['reader-020']['shared_text_indices'] = [
        i for i, b in enumerate(by_id['reader-020']['blocks'])
        if b['kind'] == 'text' and (b['text'] == '대' or b['text'].startswith('현재 계획'))]
    atlas_page = by_id['reader-006']
    atlas_page['layout'] = 'screen_gallery'
    contexts = iter(['menu','route','status','brief','rest','plan','resolve','evade','result'])
    categories = {'menu': ('메인 메뉴', '새 여정·이어하기'), 'route': ('강호행로', '행로 선택'),
                  'status': ('플레이어', '상태창'), 'brief': ('전투', '비무 브리핑'),
                  'rest': ('강호행로', '주막·휴식'), 'plan': ('전투', '전투 준비 화면'),
                  'resolve': ('전투', '합·해결 설명'), 'evade': ('전투', '회피 연출'), 'result': ('전투', '결과·복기')}
    for index, block in enumerate(atlas_page['blocks']):
        if block['kind'] == 'image':
            label = atlas_page['blocks'][index+1]
            if label['kind'] != 'text':
                raise ValueError('Atlas picture lost its source label')
            context = next(contexts)
            block.update(screen_context=context, screen_label=label['text'],
                         screen_kind=categories[context][0], screen_usage=categories[context][1])
    # The PDF's tiny placement examples must not become 13 full-width pictures.
    atlas = 'assets/ui/cards/basic_technique_ink_atlas_01_v1.png'
    plan = by_id['reader-017']
    plan['blocks'] = [b for b in plan['blocks'] if b.get('path') != atlas]
    plan['blocks'].insert(1, {'kind':'basic_actions'})
    for id, start in [('reader-076',0), ('reader-077',5)]:
        by_id[id]['blocks'] = [{'kind':'basic_actions','start':start,'count':5},
            note('게임의 실제 삽화 영역과 기초 행동 데이터를 연결했습니다. 효과·조건은 삽화 아래에서 바로 확인합니다.')]
    wire = by_id['reader-010']
    wire['blocks'] = [wire['blocks'][0], note('정보 배치 참고용 와이어프레임입니다. 아래 네 번의 선택·활동·사건 표는 현재 게임 데이터와 구현을 따릅니다.')]
    followup = {
        'rest': ('자원 부족을 회복', '상한 안에서 실제 회복량 표시'),
        'training': ('성장 선택에 쓸 점수 확보', '포인트 획득과 성수 상승은 별개 · 무공 성장에서 사용'),
        'recon': ('다음 상대를 읽을 단서 확보', '미확정 계획·숨은 기술은 공개하지 않음'),
        'event': ('능력치·위험·보상 비교', '사건별 3선택 · 일부 성공 선택에만 희귀 기연'),
    }
    by_id['reader-009']['blocks'] = [table(['종류', '선택지', '효과', '선택 목적', '조건·다음 흐름'], [
        [{'rest':'휴식','training':'수련','recon':'정탐','event':'무작위 사건'}[a['id']], a['label'], a['effect'], *followup[a['id']]]
        for a in giyun['activities']]),
        note('비무 사이 9구간 × 4회 = 한 회차 최대 36회 선택. 네 활동 중 세 후보를 제시하며 사건은 포함됩니다. 나머지 휴식·수련·정탐 중 하나를 회차 시드에 따라 제외합니다. 같은 단계에서 고르지 않은 두 후보의 효과는 얻지 않습니다.'),
        table(['현재 화면에서 확인', '읽을 정보'], [
            ['선택 전', '현재 1~4회차 · 후보 셋의 효과·대가 · 나의 자원·보유 무공'],
            ['선택 확정', '선택 결과와 실제 증가량 · 미리보기와 적용 완료를 구분'],
            ['다음 단계', '결과를 보고 자원·단서를 재판단 · 4회 후 다음 비무 브리핑'],
            ['이어하기', '시드·사건·확정 결과를 보존 · 재추첨이나 중복 지급 금지']])]
    by_id['reader-009']['historical_state'] = '현재 main 데이터·구현에서 설명 파생 / 사람 재미 별도'
    by_id['reader-011'].update(title=f"행로 사건 목록 · {len(giyun['events'])}개 사건의 선택과 결과", subtitle='사건의 상황을 읽고, 세 선택지의 성공·실패·희귀 보상을 비교합니다.',
        blocks=[event_catalog(giyun),
                note('기연은 회차 한정·자동 적용·동일 기연 중복 없음. 실패 비용을 내고 체력이 남지 않는 선택은 잠깁니다. 자원은 상한·하한 내에서 적용됩니다. 같은 회차의 사건·선택 결과는 이어하기로 다시 추첨되지 않습니다.')],
        historical_state='기연 규칙v2 · 기존 v1 저장은 당시 규칙 유지 · 사람 재미 별도')
    for id in ['reader-013', 'reader-014']:
        # Keep original identifiers and the full original description, but share one
        # current table instead of repeating old five-event rewards as current data.
        by_id[id]['merged_into'] = 'reader-009'
        by_id[id]['blocks'] = [note('현재 선택지·효과는 강호행로 통합 표에 모았습니다. 원래 설명은 승인 당시 자료에서 비교할 수 있습니다.')]
    by_id['reader-013']['blocks'] += [table(['정보 종류', '해석·활용', '현재 구현과 구분'], [
        ['무공 조사·정탐', '공개된 보유 무공·기술 범위로 거리·수 운용을 예상하고 다음 브리핑에 활용', '다음 상대의 단서만 사용 · 숨은 다음 행동을 보장하지 않음'],
        ['발자국·습관 해석', '이동·위치 습관과 깨진 반례로 추격·대기·역진입을 비교', '과거 설명용 예시 · 신규 회차의 독립 활동이나 추가 보상으로 표시하지 않음'],
        ['정보 흐름', '흔적 발견 → 단서 확인 → 알려진 사실과 반례 해석 → 다음 비무 대비', '정탐 전용 최신 촬영 미확인 · 전투 화면을 대신 붙이지 않음']])]
    by_id['reader-014']['blocks'] += [table(['구분', '게임에 남는 변화', '확인할 것'], [
        ['수련', '자유 수련 포인트를 무공 성장에서 소비', '대상·비용·해금, 5·9성 강화, 저장 후 복구'],
        ['사건·기연', '성공·실패 결과를 한 번 적용 · 일부 성공 선택 뒤 추가 희귀 판정', '능력치·실패 대가·기연 확률·중복·사건 고정'],
        ['과거 행인·발자국 사례', '원래 다섯 사건의 설명은 승인 당시 기록에 보존', '현재 사건 목록과 혼합하지 않음']])]
    # Wireframe first, then current choices, events, rest and information flow.
    ordered = ['reader-010','reader-009','reader-011','reader-012','reader-013','reader-014']
    first = min(i for i,p in enumerate(pages) if p['id'] in ordered)
    pages[:] = [p for p in pages if p['id'] not in ordered]
    pages[first:first] = [by_id[id] for id in ordered]
    # Explicit page ownership makes replacement selection independent of shared paths.
    for page in pages:
        for block in page['blocks']:
            block['page_id'] = page['id']
    return pages
