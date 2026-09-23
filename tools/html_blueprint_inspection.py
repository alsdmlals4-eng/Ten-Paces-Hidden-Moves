"""Derived inspection index. Unknown evidence stays unknown; no new approval owner."""
import hashlib
import json
import re
from html_blueprint import ROOT, local_path, sha


def card_art_paths(selection, manual_id, card):
    return [selection['directory']+'/'+name for name in selection['manuals'][manual_id]
            if re.search(r'star'+str(card['unlock_star'])+r'(?=[^0-9]|$)', name)]


def related_work_items(tasks, sources, scope=None, revision=None):
    return [t for t in tasks if set(t.get('actual_consumers', [])) & set(sources)
            and (scope is None or t.get('scope','MAIN_SOURCE') == scope)
            and (revision is None or t.get('revision') == revision)]


def build(payload):
    records = []
    assets, clips = payload['assets'], payload['experience']['clips']
    names = {'static_clash_explanation_not_animation':'합 설명 삽화 · 정지 이미지',
             'clash-keyscene-v1':'격돌 장면 시안', 'atlas_blue_ink_courtyard_v1':'비무 안뜰 배경',
             'jianghu_blue_ink_landscape_v1':'강호행로 산수 배경','jianghu_rest_inn_v1':'휴식 주막 배경',
             'DOGYEOM_STATUS_PORTRAIT_01_v1':'도겸 · 상태창 초상','KakaoTalk_20260826_193205188_11':'사용자 제공 참고 이미지',
             'clash_sparks_ink_gold_v2':'격돌 불꽃 · 금빛 먹 효과','player_sword_sequence_v1':'플레이어 검술 포즈',
             'enemy_sword_sequence_v1':'상대 검술 포즈','player_reactions_candidate_v2':'플레이어 피격·대응 포즈 후보',
             'enemy_reactions_candidate_v2':'상대 피격·대응 포즈 후보','journey_title_reference_v1':'새 여정 제목 화면 참고'}
    for a in assets: a['name'] = names.get(a['name'],a['name'])
    tasks = payload['pm']['items']
    def record(id, kind, name, route, sources, linked_assets=(), clip_ids=(), planning='원본 기록 있음', match_sources=None, scope=None, revision=None):
        sources = sorted(set(sources))
        related = related_work_items(tasks, sources if match_sources is None else match_sources, scope, revision)
        media = [c for c in clips if c['id'] in clip_ids]
        art = [a for a in assets if a['id'] in linked_assets]
        stale = any(c['freshness']['status'] == 'STALE' for c in media)
        flags = ['human']
        if art and any(not a['consumers'] for a in art): flags.append('unlinked')
        if not media or stale: flags.append('capture')
        if any(c['visual_status'] == 'STATIC_OR_EFFECT_ONLY' for c in media): flags.append('motion')
        states = {
            'planning': planning,
            'asset': '승인 기록 있음' if art and all(a['approval']=='USER_APPROVED' for a in art) else '승인 범위 개별 확인',
            'implementation': '원본 연결 있음 · 실행과 별도' if sources else '직접 연결 미확인',
            'runtime': '촬영 갱신 필요' if stale else '고정 상황 촬영 있음' if media else '이 항목의 현재 촬영 근거 없음',
            'human': '항목별 사용자 검수 미기록',
        }
        row = {'id':id, 'kind':kind, 'name':name, 'route':route, 'sources':sources,
               'asset_ids':list(linked_assets), 'clip_ids':list(clip_ids), 'states':states, 'flags':flags,
               'tasks':[{'id':t['work_item_id'], 'scope':t.get('scope','MAIN_SOURCE'),
                         'title':t.get('title',t['work_item_id']), 'status':t.get('status'),
                         'next_action':t.get('next_action'), 'source':t['source'], 'revision':t.get('revision')}
                        for t in related]}
        dependencies = {}
        for p in sources:
            f = local_path(ROOT,p)
            dependencies[p] = sha(f) if f.is_file() else 'MISSING'
        signature = {'row':row, 'sources':dependencies, 'art':[(a['id'],a['sha256'],a['approval']) for a in art],
                     'clips':[(c['id'],c['path_sha256'],c['freshness']) for c in media]}
        row['fingerprint'] = hashlib.sha256(json.dumps(signature,sort_keys=True,ensure_ascii=False).encode()).hexdigest()
        records.append(row)
        return row

    for id, c in payload['experience']['contexts'].items():
        n = next(n for n in payload['diagrams'][0]['nodes'] if n['id']==id)
        record('screen:'+id,'화면',c['title'],'#maps/game-loop/'+id,
               n['sources']+['docs/blueprint/HTML_MIGRATION_SPEC.md'],
               clip_ids=[c['id'] for c in clips] if id=='resolve' else [], planning='승인 화면 설명 연결')
    for manual in payload['manuals']:
        mid = manual['manual_id']
        for card in manual['cards'].values():
            selected = card_art_paths(payload['art_selection'], mid, card)
            pictures = [a for a in assets if a['path'] in selected or
                        (a['path'].startswith('assets/blueprint/manuals/') and card['id'] in a['path'])]
            for a in pictures: a['name'] = card['name']+' · 무공 삽화'
            record('card:'+card['id'],'무공',card['name'],'#inspect/card:'+card['id'],
                   ['data/cards/martial_manuals/'+mid+'.json','src/combat/combat_board_preview.gd'],
                   [a['id'] for a in pictures], [card['id']], '현재 무공 데이터 연결')
    for item in payload.get('giyun', {}).get('giyun', []):
        record('giyun:'+item['id'],'기연',item['name'],'#giyun/'+item['id'],
               ['data/run/giyun_rules.json','src/run/giyun_rules.gd','src/run/vertical_slice_run_state.gd','src/run/vertical_slice_metrics_combat_resolution_engine.gd'],planning='2026-09-23 승인 회차 한정 효과')
    for person in payload['people']:
        art = [a for a in assets if a['path']==person['portrait']]
        for a in art: a['name'] = person['name']+' · 인물 원화'
        record('person:'+person['id'],'인물',person['name'],'#people/'+person['id'],
               ['data/run/approved_opponent_stages_v2.json','src/run/variable_opponent_roster.gd'],
               [a['id'] for a in art],planning='승인 인물·성장 원본 연결')
    for a in assets:
        row = record('asset:'+a['id'],'자산',a['name'],'#asset/'+a['id'],
                     ([a['owner']] if a['scope']=='MAIN_SOURCE' else []) +
                     (a['consumers'] if a['scope']=='MAIN_SOURCE' else []),[a['id']], planning='자산 등록 원본 연결',
                     match_sources=[a['path'],*a['consumers']],scope=a['scope'],revision=a.get('revision') if a['scope']=='PR342_CANDIDATE' else None)
        row['scope']=a['scope']
        row['candidate_sources'] = ([{'path':p,'revision':a['revision']} for p in [a['owner'],a['path'],*a['consumers']]]
                                    if a['scope']=='PR342_CANDIDATE' else [])
        row['states']['implementation'] = ('후보의 직접 참조 있음 · main 미반영' if a['scope']!='MAIN_SOURCE' else '직접 참조 있음 · 실행과 별도') if a['consumers'] else '직접 참조 미확인'
        row['fingerprint'] = hashlib.sha256(json.dumps(row,sort_keys=True,ensure_ascii=False).encode()).hexdigest()
    for clip in clips:
        record('clip:'+clip['id'],'연출',clip['title'],'#motion/'+clip['id'],
               ['src/combat/combat_board_preview.gd','docs/blueprint/evidence/motion/manifest.json'],
               clip_ids=[clip['id']],planning='촬영 상황·사건 기록 연결')
    return {'records':records, 'freshness_policy':'발행 시점의 원본 대조. 브라우저는 로컬 파일의 이후 변경을 자동 감시하지 않습니다.',
            'filters':{'all':'전체','unlinked':'미연결 자산','capture':'촬영 없음·갱신 필요','motion':'정적 표시·움직임 검토','human':'사용자 확인 미기록'}}
