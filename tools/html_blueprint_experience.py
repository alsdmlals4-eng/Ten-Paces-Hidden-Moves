"""Source-owned atlas navigation and recorded Godot media, without game simulation."""
from html_blueprint import ROOT, read, sha, local_path, verified_file, unique_ids
import hashlib

MOTION_MANIFEST = 'docs/blueprint/evidence/motion/manifest.json'


def build_contexts():
    rows = {
        'menu': ('메인 화면', ['reader-006','reader-007'], 0, ['starter']),
        'starter': ('시작 무공', ['reader-065','reader-079'], 0, ['brief']),
        'brief': ('상대 브리핑 · 비무 제약', ['reader-015','reader-028','reader-029'], 3, ['plan']),
        'plan': ('수 배치 · 행동 선택', ['reader-017','reader-018','reader-019'], 5, ['resolve']),
        'resolve': ('격돌 · 합 · 카드 연출', ['reader-020','reader-024','reader-025','reader-026'], 6, ['plan','result']),
        'result': ('결과 · 복기 · 보상', ['reader-027'], 8, ['route','end']),
        'route': ('강호행로', ['reader-009','reader-010','reader-011'], 1, ['brief']),
        'end': ('여정 종료', ['reader-027','reader-008'], 8, ['menu']),
    }
    return {key: {'title': title, 'pages': pages, 'atlas_image_index': image, 'next': following,
                  'manuals': key=='starter', 'constraints': key=='brief',
                  'people': key=='brief', 'actions': key=='plan', 'clips': key=='resolve'}
            for key,(title,pages,image,following) in rows.items()}


def load_clips():
    manifest = read(ROOT, MOTION_MANIFEST)
    for path, digest in manifest['source_hashes'].items():
        verified_file(ROOT, path, digest)
    for path, digest in manifest.get('source_text_hashes', {}).items():
        if hashlib.sha256(local_path(ROOT,path).read_text(encoding='utf-8').encode('utf-8')).hexdigest() != digest:
            raise ValueError('Recorded presentation source changed: '+path)
    clips = manifest['clips']
    unique_ids(clips)
    for clip in clips:
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
    contexts['starter']['preview'] = {'kind':'image', 'path':'docs/runtime-captures/TEN-ATLAS-SUCCESSOR-20260908/martial-summary-fixed-1280x800.png','size':[1280,800]}
    contexts['starter']['preview_kind'] = '과거 Godot 무공 선택 화면'
    return {'contexts': contexts, 'clips': load_clips(),
            'constraints': read(ROOT, 'data/run/bimu_constraints.json'),
            'actions': read(ROOT, 'data/cards/basic_cards.json')['cards']}
