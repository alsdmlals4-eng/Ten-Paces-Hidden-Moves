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
INK_MANIFEST = 'docs/blueprint/evidence/ink-screens-20260925/manifest.json'
SCREEN_CAPTURE = 'docs/blueprint/evidence/ink-screens-20260925/capture.json'
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
        'menu': ('메인 화면', ['reader-006','reader-005'], 0, ['prologue']),
        'prologue': ('출사표', ['reader-007'], 0, ['starter']),
        'starter': ('삽화 시작 무공 · 6권 중 4권', ['reader-065','reader-008'], 0, ['tutorial']),
        'tutorial': ('10초 규칙 익히기', ['reader-008','reader-016','reader-019'], 0, ['first_route']),
        'first_route': ('첫 비전투 행로 · 1회', ['reader-008'], 1, ['brief']),
        'brief': ('상대 브리핑 · 비무 제약', ['reader-015','reader-028','reader-029'], 3, ['plan']),
        'plan': ('10초 행동 설계', ['reader-017','reader-018','reader-019'], 5, ['resolve']),
        'resolve': ('전투 진행 · 합과 사건 기록', ['reader-020','reader-024','reader-025','reader-026'], 6, ['plan','result']),
        'result': ('비무 결과 · 지급·진행', ['reader-027'], 8, ['review','route','end']),
        'review': ('복기 · 해결된 사건 다시 보기', ['reader-027'], 8, ['result']),
        'route': ('강호행로', ['reader-010','reader-009','reader-011','reader-012','reader-013','reader-014'], 1, ['brief']),
        'end': ('여정 종료', ['reader-027','reader-008'], 8, ['menu']),
    }
    return {key: {'title': title, 'pages': pages, 'atlas_image_index': image, 'next': following,
                  'manuals': key=='starter', 'constraints': key=='brief',
                  'people': key=='brief', 'actions': key=='plan', 'clips': key=='resolve'}
            for key,(title,pages,image,following) in rows.items()}


def load_clips(manifest_path=None):
    manifest_path = manifest_path or MOTION_MANIFEST
    manifest = read(ROOT, manifest_path)
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
    retired = {r['path']: r for r in read(ROOT, 'docs/blueprint/IMPLEMENTATION_READINESS.json').get('retired_images', [])}
    unique_ids(clips)
    for clip in clips:
        clip['manifest'] = manifest_path
        clip['freshness'] = clip_freshness(clip, manifest, current)
        verified_file(ROOT, clip['path'], clip['path_sha256'])
        if clip.get('poster') in retired:
            clip['poster_disposal'] = retired[clip['poster']]
            clip['poster'] = None
        elif clip.get('poster'):
            verified_file(ROOT, clip['poster'], clip['poster_sha256'])
        if clip.get('gif'):
            verified_file(ROOT, clip['gif'], clip['gif_sha256'])
    return clips


def build(pages):
    contexts = build_contexts()
    page_ids = {p['id'] for p in pages}
    for context in contexts.values():
        if not set(context['pages']) <= page_ids:
            raise ValueError('Atlas context links to an unknown explanation')
    from html_blueprint_frame import screen_media, rules_summary, attach_timing, frame_assets, validated_walkthrough
    for key, media in screen_media(ROOT).items():
        contexts[key].update(media)
    clips = load_clips(INK_MANIFEST)+load_clips()
    for clip in clips:
        clip['historical'] = True
        clip['rule_set'] = 'SUPERSEDED_SLOT_TIMELINE'
        clip['caption'] = '이전 규칙의 Godot 촬영 · 현재 10초 규칙의 실행 근거 아님'
    walkthrough = validated_walkthrough(ROOT)
    if walkthrough:
        clips.insert(0, walkthrough)
    return {'contexts': contexts, 'clips': clips, 'frame_rules': rules_summary(ROOT),
            'frame_assets': frame_assets(ROOT),
            'constraints': read(ROOT, 'data/run/bimu_constraints.json'),
            'actions': attach_timing(basic_actions(), ROOT)}
