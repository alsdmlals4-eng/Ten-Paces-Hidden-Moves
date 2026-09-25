"""Stable user-facing image numbers. Registry keeps retired keys for correspondence."""
import hashlib
import json
from urllib.parse import quote

REGISTRY = 'docs/blueprint/IMAGE_NUMBERS.json'


def usage_label(asset):
    if asset.get('details', {}).get('reference_edit'):
        return asset['details']['usage']
    path = asset['path'].lower()
    known = [('jianghu_rest_inn', '휴식 장소의 주막 배경'),
             ('jianghu_blue_ink', '강호행로 산수 배경'),
             ('frontal_courtyard_banner_overlay', '비무 안뜰 전경 장식'),
             ('frontal_courtyard_duel_sequence_board', '비무 연출 순서 설명'),
             ('frontal_courtyard_duel_background', '비무 안뜰 배경'),
             ('frontal_courtyard_background', '비무 안뜰 배경'),
             ('status_portrait', '상태창 상대 초상'),
             ('status_hud_frame', '체력·기력·내력 상태창 틀'),
             ('basic_technique_ink_atlas', '기초 행동 카드의 삽화 묶음'),
             ('clash_explanation', '합의 격돌을 설명하는 정지 삽화')]
    for token, label in known:
        if token in path:
            return label
    role = asset['group']['role']
    if 'portraits/' in path: return '인물 소개 초상'
    if 'battler' in path: return '전투 화면의 전신 캐릭터'
    if asset.get('grid'): return '여러 동작을 담은 포즈 시트'
    if asset.get('name') and any('\uac00' <= c <= '\ud7a3' for c in asset['name']):
        return asset['name']
    return role


def allocate(registry, keys):
    values = list(registry.values())
    if any(type(v) is not int or v < 1 for v in values) or len(set(values)) != len(values):
        raise ValueError('Invalid or duplicated image number')
    next_number = max(values, default=0) + 1
    for key in keys:
        if key not in registry:
            registry[key] = next_number
            next_number += 1
    return {key: registry[key] for key in keys}


def asset_key(asset):
    scope = asset.get('details', {}).get('disposal', {}).get('source_scope', asset['scope'])
    return ('candidate:' + asset['id']) if scope != 'MAIN_SOURCE' else asset['path']


def attach(payload, root):
    path = root / REGISTRY
    registry = json.loads(path.read_text(encoding='utf-8')) if path.exists() else {}
    rows = {}
    for a in payload['assets']:
        key = asset_key(a)
        refs = a.get('audit', {}).get('runtime_references', [])
        docs = a.get('audit', {}).get('document_references', [])
        use = a.get('details', {}).get('usage') or a.get('details', {}).get('role')
        # A browsing group is only a hint; reference evidence owns actual usage.
        label = a['group']['label']
        kind = label.split(' · ', 1)[-1] if label.startswith(('캐릭터 · ', '무공 · ')) else label.split(' · ', 1)[0]
        evidence = ('후보 코드 참조' if a['scope'] != 'MAIN_SOURCE' else '게임 코드 참조') if refs else '기획·설명 자료' if docs else '사용처 미확인'
        rows[key] = {'key': key, 'url': a['url'], 'path': a['path'], 'name': a['name'], 'size': a.get('size'),
                     'kind': kind, 'usage': usage_label(a), 'usage_evidence': evidence, 'usage_detail': use,
                     'usage_sources': refs or docs, 'record_id': 'asset:' + a['id']}
    # Start with the same group order shown in the complete image audit.
    assets = sorted(payload['assets'], key=lambda a: (a['group']['label'], payload['assets'].index(a)))
    order = [asset_key(a) for a in assets]
    for page in payload['pages']:
        for b in page['blocks']:
            if b['kind'] != 'image' or b['path'] in rows:
                continue
            key = b['path']
            rows[key] = {'key': key, 'path': key, 'url': '../../' + quote(key, safe='/'),
                         'kind': '기획 설명', 'name': page['title'], 'usage': page['title'], 'usage_evidence': '보존된 설명 자료',
                         'usage_sources': ['tools/build_human_blueprint_complete.py'],
                         'record_id': 'reader:image-' + hashlib.sha256(key.encode()).hexdigest()[:16]}
            order.append(key)
    # Context belongs to the specific atlas screen, not a neighboring text caption.
    for page in payload['pages']:
        for b in page['blocks']:
            if b.get('screen_kind') and not b.get('region') and b['path'] in rows:
                rows[b['path']].update(kind=b['screen_kind'], usage=b['screen_usage'])
    allocated = allocate(registry, order)
    for key, row in rows.items():
        row['number'] = allocated[key]
    for a in payload['assets']:
        a['image_number'] = allocated[asset_key(a)]
    existing = {r['id'] for r in payload['inspection']['records']}
    for row in rows.values():
        if row['record_id'] not in existing:
            payload['inspection']['records'].append({
                'id': row['record_id'], 'kind': '설명 이미지', 'name': row['name'],
                'route': '#asset-audit', 'sources': [row['path']], 'asset_ids': [],
                'clip_ids': [], 'states': {'planning': '보존된 설명 자료', 'asset': '원본 승인 범위 확인',
                    'implementation': '설명용 이미지', 'runtime': '현재 실행 증거와 구분', 'human': '항목별 사용자 검수 미기록'},
                'flags': ['human'], 'tasks': [],
                'fingerprint': hashlib.sha256((root / row['path']).read_bytes()).hexdigest()})
    by_record = {row['record_id']: row for row in rows.values()}
    for record in payload['inspection']['records']:
        if row := by_record.get(record['id']):
            record.update(image_number=row['number'], image_kind=row['kind'], image_usage=row['usage'])
    payload['image_catalog'] = list(rows.values())
    # This small tracked registry is the only number owner; removals never free a number.
    text = json.dumps(registry, ensure_ascii=False, indent=2) + '\n'
    if not path.exists() or path.read_text(encoding='utf-8') != text:
        path.write_text(text, encoding='utf-8')
