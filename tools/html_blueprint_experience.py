"""Source-owned atlas navigation and recorded Godot media, without game simulation."""
from html_blueprint import ROOT, read, sha, local_path, verified_file, unique_ids
import hashlib


def observed_timeline(frames):
    """Only time actual sampled engine phases; never infer approach/return timing."""
    if not frames or not all('phase' in f and 'event_index' in f for f in frames):
        return []
    result = []
    for frame in frames:
        key = (frame['phase'], frame['event_index'])
        time = round((frame['ms'] - frames[0]['ms']) / 1000, 3)
        if not result or key != (result[-1]['phase'], result[-1]['event_index']):
            if result:
                result[-1]['end'] = time
            result.append({'phase': key[0], 'event_index': key[1], 'start': time})
    result[-1]['end'] = round((frames[-1]['ms'] - frames[0]['ms']) / 1000 + 1/30, 3)
    return result


def clip_freshness(clip, manifest, current):
    expected = {**manifest.get('source_hashes', {}), **manifest.get('source_text_hashes', {})}
    dependencies = clip.get('dependencies') or manifest.get('capture_dependencies') or list(expected)
    changed = [p for p in dependencies if not expected.get(p) or current.get(p) != expected[p]]
    changed.extend(p for p in current if p not in expected and any(p.startswith(prefix) for prefix in manifest.get('dynamic_roots', [])))
    return {'status': 'STALE' if changed else 'MATCH', 'changed_paths': changed,
            'basis': 'CAPTURE_DEPENDENCIES' if clip.get('dependencies') or manifest.get('capture_dependencies') else 'CONSERVATIVE_CAPTURE_INPUTS'}

MOTION_MANIFEST = 'docs/blueprint/evidence/motion/manifest.json'
HUD_REFERENCE = 'docs/blueprint/evidence/reference-screens/preparation-hud-edited-v2.png'


def basic_actions():
    from PIL import Image
    cards = read(ROOT, 'data/cards/basic_cards.json')['cards']
    for card in cards:
        art = card['illustration']
        art['path'] = art['atlas'].removeprefix('res://')
        with Image.open(local_path(ROOT, art['path'])) as image:
            art['size'] = list(image.size)
        x, y, w, h = art['region']
        if min(x, y) < 0 or min(w, h) <= 0 or x+w > art['size'][0] or y+h > art['size'][1]:
            raise ValueError('Invalid game illustration region: ' + card['id'])
    return cards


def build_contexts():
    rows = {
        'menu': ('메인 화면', ['reader-006','reader-007'], 0, ['starter']),
        'starter': ('시작 무공', ['reader-065','reader-079'], 0, ['brief']),
        'brief': ('상대 브리핑 · 비무 제약', ['reader-015','reader-028','reader-029'], 3, ['plan']),
        'plan': ('수 배치 · 행동 선택', ['reader-017','reader-018','reader-019'], 5, ['resolve']),
        'resolve': ('격돌 · 합 · 카드 연출', ['reader-020','reader-024','reader-025','reader-026'], 6, ['plan','result']),
        'result': ('결과 · 복기 · 보상', ['reader-027'], 8, ['route','end']),
        'route': ('강호행로', ['reader-010','reader-009','reader-011','reader-012','reader-013','reader-014'], 1, ['brief']),
        'end': ('여정 종료', ['reader-027','reader-008'], 8, ['menu']),
    }
    return {key: {'title': title, 'pages': pages, 'atlas_image_index': image, 'next': following,
                  'manuals': key=='starter', 'constraints': key=='brief',
                  'people': key=='brief', 'actions': key=='plan', 'clips': key=='resolve'}
            for key,(title,pages,image,following) in rows.items()}


def load_clips():
    manifest = read(ROOT, MOTION_MANIFEST)
    current = {}
    for path, digest in manifest['source_hashes'].items():
        file = local_path(ROOT, path)
        if file.is_file():
            current[path] = sha(file)
    for path, digest in manifest.get('source_text_hashes', {}).items():
        file = local_path(ROOT, path)
        if file.is_file():
            current[path] = hashlib.sha256(file.read_text(encoding='utf-8').encode('utf-8')).hexdigest()
    for prefix in manifest.get('dynamic_roots', []):
        for file in local_path(ROOT,prefix).rglob('*'):
            if file.is_file() and file.suffix in {'.gd','.json','.tscn','.tres'}:
                path = file.relative_to(ROOT).as_posix()
                if path not in current:
                    current[path] = hashlib.sha256(file.read_text(encoding='utf-8').encode('utf-8')).hexdigest()
    clips = manifest['clips']
    unique_ids(clips)
    for clip in clips:
        clip['freshness'] = clip_freshness(clip, manifest, current)
        for field in ['path','poster']:
            verified_file(ROOT, clip[field], clip[field+'_sha256'])
        if clip.get('gif'):
            verified_file(ROOT, clip['gif'], clip['gif_sha256'])
    return clips


def build(pages):
    contexts = build_contexts()
    images = [b for p in pages if p['id']=='reader-006' for b in p['blocks'] if b['kind']=='image']
    page_ids = {p['id'] for p in pages}
    for context in contexts.values():
        if not set(context['pages']) <= page_ids:
            raise ValueError('Atlas context links to an unknown explanation')
        context['preview'] = images[context['atlas_image_index']]
        context['preview_kind'] = '승인 기획의 화면 자료'
    contexts['starter']['preview'] = {'kind':'image', 'path':'docs/blueprint/evidence/current-ui/starter-selection-1280.png','size':[1280,800]}
    contexts['starter']['preview_kind'] = '실제 Godot 시작 무공 선택 · 격리 촬영'
    from PIL import Image
    with Image.open(local_path(ROOT, HUD_REFERENCE)) as image:
        width, height = image.size
    contexts['plan']['preview'] = {'kind':'image', 'path':HUD_REFERENCE, 'size':[width,height], 'region':[0,0,width,round(height*.60)]}
    contexts['plan']['preview_kind'] = '상태창 여백 편집 참고안 · 실제 재촬영 아님'
    contexts['resolve']['preview'] = {'kind':'image', 'path':'assets/blueprint/clash_explanation_v1.png', 'size':[1672,940]}
    contexts['resolve']['preview_kind'] = '현재 승인 그림체 · 합 설명 삽화'
    for key, context in contexts.items():
        context['preview'] = dict(context['preview'], page_id='screen:'+key)
    return {'contexts': contexts, 'clips': load_clips(),
            'constraints': read(ROOT, 'data/run/bimu_constraints.json'),
            'actions': basic_actions()}
