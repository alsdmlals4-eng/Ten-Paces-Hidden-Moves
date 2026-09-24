"""Generate a local, offline HTML Blueprint; publish index only after input validation."""
from __future__ import annotations

import argparse
from datetime import datetime, timezone
import hashlib
import json
import os
import re
from pathlib import Path
import subprocess
import shutil
from urllib.parse import quote

import html_blueprint as model

ROOT = model.ROOT
OUT = ROOT / 'output/blueprint'


def blob(revision, path):
    model.local_path(ROOT, path)
    return subprocess.check_output(['git', 'show', f'{revision}:{path}'], cwd=ROOT)


def candidate(revision, assets, out):
    """Read only observed committed candidate blobs, never the other dirty checkout."""
    manifest = json.loads(blob(revision, 'assets/ASSET_MANIFEST.json'))
    base_hashes = {a['path']: a['sha256'] for a in assets}
    prefix = 'docs/visual-assets/candidates/TEN-OPPONENT-FEEDBACK-20260921/'
    appearance = model.read(ROOT, 'docs/planning-data/current_user_planning_status.json').get('opponent_appearance_approval_20260922', {})
    entries = list(manifest['assets'])
    retired = {r['path'] for r in model.read(ROOT, 'docs/blueprint/IMPLEMENTATION_READINESS.json').get('retired_images', [])}
    for item in appearance.get('files', []):
        entries.append({'id': 'appearance-' + item['candidate_id'], 'path': item['path'], 'role': item['name'] + ' · 전신 외형',
                        'appearance_sha256': item['sha256'], 'appearance_only': True, 'active': False,
                        'approval': 'user explicit: 전신 외형 확정 2026-09-22; 프레임/런타임 검증 별도',
                        'pose_qa': '맞춤 프레임 영역·방향·발 위치 미검증. 자동 균등 분할하지 않음.'})
    source_code = blob(revision, 'src/combat/character_pose_library.gd').decode('utf-8')
    pose_source = 'src/combat/character_pose_library.gd'
    added = []
    candidate_paths = set(model.git('ls-tree', '-r', '--name-only', revision).splitlines())
    for entry in entries:
        path = entry['path'].removeprefix('res://')
        if path in retired:
            continue
        data = blob(revision, path)
        digest = hashlib.sha256(data).hexdigest()
        if entry.get('appearance_sha256') and entry['appearance_sha256'] != digest:
            raise ValueError(f'Appearance approval mismatch: {path}')
        if base_hashes.get(path) == digest:
            continue
        media = out / 'media' / (digest + Path(path).suffix.lower())
        media.parent.mkdir(parents=True, exist_ok=True)
        if not media.is_file():
            media.write_bytes(data)
        elif model.sha(media) != digest:
            raise ValueError(f'Published media modified: {media}')
        row = {'id': 'pr342-' + entry['id'], 'path': path, 'url': 'media/' + media.name,
               'name': entry.get('role', entry['id']), 'scope': 'PR342_CANDIDATE',
               'revision': revision, 'sha256': digest, 'approval': model.approval_state(entry),
               'approval_record': entry.get('approval', '확정 기록 미확인'), 'active': entry.get('active'),
               'available': True, 'owner': 'assets/ASSET_MANIFEST.json', 'details': entry,
               'consumers': model.consumer_paths(entry.get('runtime_consumer', ''))}
        if any(path not in candidate_paths for path in row['consumers']):
            raise ValueError('Candidate consumer missing from exact revision: '+path)
        if entry.get('appearance_only'):
            row['owner'] = 'docs/planning-data/current_user_planning_status.json'
            row['consumers'] = []
        if entry.get('grid'):
            row['grid'] = entry['grid']
            if 'sword_sequence' in path:
                row['sequence'] = model.motion_sequence(source_code, 'player' if 'player' in path else 'enemy')
                row['motion_source'] = pose_source
            else:
                row['sequence'] = []
        added.append(row)
    presets = json.loads(blob(revision, 'data/presentation/combat_motion_presets.json'))
    journal = json.loads(blob(revision, 'docs/operations/AI_USAGE_EVIDENCE_2026_09.json'))
    remaining_path = 'docs/implementation/REMAINING_GAME_IMPLEMENTATION_SPEC.md'
    remaining_spec = blob(revision, remaining_path).decode('utf-8')
    receipts = []
    tree = model.git('ls-tree', '-r', '--name-only', revision, 'docs/operations')
    for path in tree.splitlines():
        if path.endswith('WORK_CONTRACT_RECEIPT.json'):
            doc = json.loads(blob(revision, path))
            for item in doc.get('project_work_kanban', {}).get('work_items', []):
                receipts.append({'source': path, 'scope': 'PR342_CANDIDATE', 'revision': revision, **item})
    for line in remaining_spec.splitlines():
        if re.match(r'^\| P\d\d \|', line):
            cells = [c.strip() for c in line.strip('|').split('|')]
            receipts.append({'work_item_id': cells[0], 'title': cells[1], 'status': cells[-1],
                'priority': cells[2], 'depends_on': [cells[3]], 'next_action': '상세 인수 조건과 최신 실행 기록을 대조한 뒤 재개',
                'source': remaining_path, 'canon_owner': remaining_path,
                'scope': 'PR342_CANDIDATE', 'revision': revision})
    return added, {'revision': revision, 'presets': presets, 'journal': journal, 'work_items': receipts,
                   'remaining_spec': remaining_spec}


def archive_pages(out, count):
    """Read-only rendering preserves spatial learning material without rewriting the PDF."""
    record = model.read(ROOT, 'docs/planning-data/current_user_planning_status.json')['blueprint_final_approval']
    pdf, digest = model.verified_file(ROOT, record['artifact'], record['artifact_sha256'])
    cache = out/'archive'/digest
    index = cache/'pages.json'
    if index.is_file():
        pages = json.loads(index.read_text(encoding='utf-8'))
        if len(pages) != count:
            raise ValueError('Archive page coverage differs')
        for page in pages:
            model.verified_file(out, page['url'], page['sha256'])
        return pages
    renderer = shutil.which('pdftoppm')
    if not renderer:
        bundled = Path.home()/'.cache/codex-runtimes/codex-primary-runtime/dependencies/native/poppler/Library/bin/pdftoppm.exe'
        if bundled.is_file(): renderer = str(bundled)
    if not renderer:
        raise FileNotFoundError('Poppler pdftoppm is required to preserve approved page layouts; install locally or provide it on PATH')
    cache.mkdir(parents=True, exist_ok=True)
    subprocess.run([renderer, '-scale-to', '1600', '-png', str(pdf), str(cache/'page')], check=True, capture_output=True)
    files = sorted(cache.glob('page-*.png'))
    if len(files) != count:
        raise ValueError('Approved PDF page count differs from reader')
    pages = [{'url': file.relative_to(out).as_posix(), 'sha256': model.sha(file)} for file in files]
    index.write_text(json.dumps(pages, indent=2)+'\n', encoding='utf-8')
    return pages


def publish_bundle(out, bundle):
    """Stage all outputs; rollback ordinary I/O failures. Manifest detects interrupted publishes."""
    previous = {name: (out/name).read_bytes() if (out/name).exists() else None for name in bundle}
    installed = []
    try:
        for name, data in bundle.items():
            (out/(name+'.tmp')).write_bytes(data)
        # Manifest last: servers refuse mixed generations rather than certify them.
        for name in sorted(bundle, key=lambda n: n == 'manifest.json'):
            os.replace(out/(name+'.tmp'), out/name)
            installed.append(name)
    except OSError:
        for name in installed:
            if previous[name] is not None:
                restore = out/(name+'.restore')
                restore.write_bytes(previous[name])
                os.replace(restore, out/name)
            else:
                (out/name).unlink(missing_ok=True)
        raise


def build(out=OUT, include_candidate=True):
    out = Path(out).resolve()
    if out != OUT.resolve():
        raise ValueError('Use the fixed output/blueprint directory; relative source links depend on it')
    out.mkdir(parents=True, exist_ok=True)
    pages = model.collect_reader()
    originals = archive_pages(out, len(pages))
    for page, original in zip(pages, originals):
        page['approved_page'] = original
    from html_blueprint_reader import refine, reader_groups
    refine(pages, model.read(ROOT, 'data/run/giyun_rules.json'))
    assets = model.collect_assets(ROOT)
    pm = model.collect_pm(ROOT)
    candidate_info = None
    if include_candidate:
        candidate_sha = pm['github']['prs']['342']['headRefOid']
        added, candidate_info = candidate(candidate_sha, assets, out)
        assets.extend(added)
        pm['items'].extend(candidate_info['work_items'])
    import html_blueprint_audit as audit_model
    audit_model.extend_inventory(ROOT, assets, candidate_info['revision'] if candidate_info else None, out)
    decisions = model.read(ROOT, 'docs/blueprint/IMPLEMENTATION_READINESS.json')
    for replacement in decisions.get('image_replacements', []):
        asset = next(a for a in assets if a['scope']=='MAIN_SOURCE' and a['path']==replacement['path'])
        asset.update(id=replacement['id'], name=replacement['name'], approval='APPROVAL_UNVERIFIED',
                     approval_record=replacement['description'], details={'reference_edit':True, 'usage':replacement['usage'], 'provenance':replacement},
                     owner='docs/blueprint/IMPLEMENTATION_READINESS.json')
    asset_audit = audit_model.build(ROOT, assets)
    retired = model.read(ROOT, 'docs/blueprint/IMPLEMENTATION_READINESS.json').get('retired_images', [])
    if retired:
        asset_audit['move_status'] = f'사용자 폐기 요청 {len(retired)}개 처리 · 개별 삭제/이동 결과는 폐기 이력에서 확인'
    for entry in retired:
        assets.append({**entry, 'scope':'MAIN_SOURCE', 'revision':None, 'available':False, 'active':False,
            'details':{'retired':True,'disposal':entry}, 'consumers':[], 'approval':'USER_DISCARDED',
            'approval_record':'사용자 요청으로 파일 삭제' if entry['status']=='DELETED_BY_USER_REQUEST' else '사용자 폐기 요청 처리 · 삭제대기 폴더로 이동',
            'owner':'docs/blueprint/IMPLEMENTATION_READINESS.json',
            'audit':{'flags':['discarded'], 'reasons':[entry['reason']], 'safe_to_move':False,
                'runtime_references':[], 'document_references':[], 'replacement_ids':[], 'duplicate_ids':[],
                'disposition':'삭제 완료' if entry['status']=='DELETED_BY_USER_REQUEST' else '삭제대기 이동 완료 · 사용자가 최종 삭제', 'category':'폐기 이력'}})
    for asset in assets:
        asset['related_work'] = [item['work_item_id'] for item in pm['items']
            if set(item.get('actual_consumers', [])) & {asset['path'], *asset['consumers']}
            and (item.get('scope') == 'PR342_CANDIDATE') == (asset['scope'] == 'PR342_CANDIDATE')]
    model.unique_ids(assets)
    from build_opponent_stage_blueprint import build as people
    from blueprint_layout import SOURCES
    import build_human_blueprint_complete as narrative
    from PIL import Image
    art = model.read(ROOT, 'docs/blueprint/ART_SELECTION.json')
    manuals = [model.read(ROOT, f'data/cards/martial_manuals/{mid}.json') for mid in art['manuals']]
    for manual in manuals:
        manual['readable_tables'] = model.manual_readable_tables(manual)
        for card in manual['cards'].values():
            card['effect_descriptions'] = [narrative.describe(step) for step in card.get('effect_steps',[])]
    from html_blueprint_diagrams import build as diagram_views
    diagrams = diagram_views()
    for asset in assets:
        asset.setdefault('url', '../../' + quote(asset['path'], safe='/'))
        file = out / asset['url'] if asset['scope'] == 'PR342_CANDIDATE' else model.local_path(ROOT, asset['path'])
        if asset['available'] and file.suffix.lower() in {'.png', '.jpg', '.jpeg', '.webp'}:
            with Image.open(file) as im:
                asset['size'] = list(im.size)
    for page in pages:
        for block in page['blocks']:
            if block['kind'] == 'image':
                with Image.open(model.local_path(ROOT, block['path'])) as im:
                    block['size'] = list(im.size)
    import html_blueprint_experience as experience_model
    experience = experience_model.build(pages)
    inputs = {Path(path).resolve().relative_to(ROOT).as_posix(): digest for path, digest in SOURCES.items()}
    source_paths = ['tools/blueprint_layout.py', 'tools/blueprint_readiness_pages.py', 'tools/build_opponent_stage_blueprint.py', 'tools/build_human_blueprint_complete.py', 'tools/html_blueprint.py', 'tools/html_blueprint_reader.py', 'tools/build_html_blueprint.py',
                    'tools/html_blueprint_ui/app.js', 'tools/html_blueprint_ui/style.css',
                    'tools/html_blueprint_ui/event_catalog.js', 'tools/html_blueprint_ui/event_catalog.css',
                    'src/run/jianghu_event_checks.gd', 'data/run/giyun_rules_v1.json',
                    'docs/decisions/2026-09-24_EVENT_CHECKS_AND_HTML_READABILITY.md',
                    'docs/blueprint/evidence/jianghu-events-v2-native-20260924.png',
                    'docs/blueprint/HTML_MIGRATION_SPEC.md', 'docs/blueprint/HTML_SOURCE_OBSERVATIONS.json',
                    'docs/operations/AI_USAGE_EVIDENCE_2026_09.json',
                    'assets/ASSET_MANIFEST.json', 'docs/planning-data/current_operating_state.json',
                    'docs/planning-data/current_user_planning_status.json', '[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md']
    for path in source_paths:
        inputs[path] = model.sha(model.local_path(ROOT, path))
    for diagram in diagrams:
        for node in diagram['nodes']:
            for path in node['sources']:
                inputs[path] = model.sha(model.local_path(ROOT, path))
    inputs['tools/html_blueprint_diagrams.py'] = model.sha(ROOT/'tools/html_blueprint_diagrams.py')
    experience_paths = ['tools/html_blueprint_experience.py','tools/html_blueprint_ui/experience.js',
        'tools/capture_blueprint_motion.gd','tools/encode_blueprint_motion.py',experience_model.MOTION_MANIFEST,
        experience_model.INK_MANIFEST,experience_model.SCREEN_CAPTURE,
        'data/run/bimu_constraints.json','data/cards/basic_cards.json']
    experience_paths.extend(c['preview']['path'] for c in experience['contexts'].values())
    for clip in experience['clips']:
        experience_paths.extend([clip['path'],clip['poster']])
    for path in experience_paths:
        inputs[path] = model.sha(model.local_path(ROOT,path))
    # The selected style comparison is a reviewed local page, with an explicit
    # media allowlist under its public artifact directory.
    for path in (ROOT/'docs/visual-assets/candidates/TEN-INK-STYLES-20260924').rglob('*'):
        if path.is_file() and path.suffix in {'.html','.png','.jpg','.gif','.mp4','.json','.md'}:
            inputs[path.relative_to(ROOT).as_posix()] = model.sha(path)
    for item in pm['items']:
        if item.get('scope') != 'PR342_CANDIDATE':
            inputs[item['source']] = model.sha(model.local_path(ROOT, item['source']))
    for asset in assets:
        if asset['scope'] == 'MAIN_SOURCE' and asset['available']:
            inputs[asset['path']] = asset['sha256']
        for path in asset['consumers']:
            if asset['scope'] == 'MAIN_SOURCE' and model.local_path(ROOT, path).is_file():
                inputs[path] = model.sha(model.local_path(ROOT, path))
    for page in pages:
        for block in page['blocks']:
            if block['kind'] == 'image':
                inputs[block['path']] = model.sha(model.local_path(ROOT, block['path']))
    for path in ['AGENTS.md','project.godot','docs/04_ROADMAP.md','docs/blueprint/READING_STRUCTURE.md',
                 'docs/blueprint/evidence/capture.json','docs/blueprint/HTML_MIGRATION_SPEC.md',
                 'docs/operations/2026-09-11_VARIABLE_ROSTER_IMPLEMENTATION.md',
                 'data/run/approved_opponent_stages_v2.json','src/run/variable_opponent_roster.gd',
                 'scenes/run/vertical_slice_shell.tscn', *[f'data/cards/martial_manuals/{m["manual_id"]}.json' for m in manuals]]:
        inputs[path] = model.sha(model.local_path(ROOT, path))
    approval = model.read(ROOT, 'docs/planning-data/current_user_planning_status.json')['blueprint_final_approval']
    inputs[approval['artifact']] = approval['artifact_sha256']
    payload = {'generated_at': datetime.now(timezone.utc).isoformat(), 'source_revision': model.git('rev-parse', 'HEAD'),
               'branch': model.git('branch', '--show-current'), 'workspace': str(ROOT),
               'dirty_paths': model.git('status', '--short'), 'inputs': inputs,
               'journal': model.read(ROOT, 'docs/operations/AI_USAGE_EVIDENCE_2026_09.json'),
               'pages': pages, 'assets': assets, 'people': people(), 'manuals': manuals, 'art_selection': art,
               'pm': pm, 'candidate': candidate_info, 'diagrams': diagrams, 'experience': experience,
               'active_context': (ROOT/'[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md').read_text(encoding='utf-8').split('## 현재 운영 구조')[0],
               'roadmap': (ROOT/'docs/04_ROADMAP.md').read_text(encoding='utf-8'),
               'historical_reader': {'approval_date': '2026-09-11', 'approved_revision': model.read(ROOT, 'docs/planning-data/current_user_planning_status.json')['blueprint_final_approval']['approved_revision']}}
    payload['giyun'] = model.read(ROOT, 'data/run/giyun_rules.json')
    payload['giyun_capture'] = 'docs/blueprint/evidence/giyun-route-20260923.png'
    inputs[payload['giyun_capture']] = model.sha(ROOT/payload['giyun_capture'])
    for path in ['data/run/giyun_rules.json','src/run/giyun_rules.gd','src/run/vertical_slice_metrics_combat_resolution_engine.gd','src/run/vertical_slice_run_state.gd','docs/decisions/2026-09-23_GIYUN_DDD_BLUEPRINT.md']:
        inputs[path] = model.sha(ROOT/path)
    payload['current_design'] = (ROOT/'docs/01_GAME_DESIGN.md').read_text(encoding='utf-8').split('## 2026-09-23 · 현재 게임 설명과 DDD', 1)[1]
    payload['current_swot'] = model.read(ROOT, 'docs/blueprint/IMPLEMENTATION_READINESS.json')['current_swot']
    payload['visual_revisions'] = model.read(ROOT, 'docs/blueprint/IMPLEMENTATION_READINESS.json').get('visual_revisions', {})
    for row in payload['visual_revisions'].values():
        for path in row['current_images']:
            inputs[path] = model.sha(ROOT/path)
    for path in ['docs/01_GAME_DESIGN.md','docs/06_STARTING_FACTION_MASTERY_DATA.md','docs/blueprint/IMPLEMENTATION_READINESS.json','src/run/vertical_slice_progression_state.gd','tools/html_blueprint_ui/design.js','tools/open_html_blueprint.py','tools/serve_html_blueprint.py']:
        inputs[path] = model.sha(ROOT/path)
    from html_blueprint_inspection import build as inspection_index
    audit_model.group_assets(assets, payload['people'], manuals, art)
    for asset in assets:
        if asset['details'].get('reference_edit'):
            asset['group'] = {'id':'screen:plan','label':'전투 · 수 배치','role':'상태창 여백 편집 참고안','basis':'사용자142 수정 요청'}
    for a in assets:
        if a.get('details',{}).get('retired'):
            a['group']={'id':'retired','label':'폐기 처리 이력','role':a['audit']['disposition'],'basis':'사용자 요청·원본 사용처 확인'}
    payload['inspection'] = inspection_index(payload)
    from html_blueprint_numbers import attach as attach_image_numbers, REGISTRY as image_numbers_path
    attach_image_numbers(payload, ROOT)
    audit_model.attach_intents(payload, model.read(ROOT, 'docs/blueprint/IMPLEMENTATION_READINESS.json')['intent_catalog'])
    payload['asset_audit'] = asset_audit
    payload['retired_images'] = retired
    payload['image_replacements'] = decisions.get('image_replacements', [])
    payload['reader_groups'] = reader_groups(pages)
    # Display derivatives must not change the source fingerprints used by saved reviews.
    from html_blueprint_previews import asset_previews
    preview_media = asset_previews(ROOT, out, assets)
    inputs['tools/html_blueprint_previews.py'] = model.sha(ROOT/'tools/html_blueprint_previews.py')
    from blueprint_review_store import shared_directory
    payload['review_location'] = str(shared_directory(ROOT) / 'reviews.json')
    for path in ['tools/html_blueprint_audit.py', 'tools/blueprint_review_store.py', 'tools/html_blueprint_ui/review_state.js', 'tools/html_blueprint_ui/review.js', 'tools/html_blueprint_numbers.py', image_numbers_path, 'tools/html_blueprint_ui/inline.js']:
        inputs[path] = model.sha(ROOT/path)
    for a in assets:
        for path in a['audit']['document_references'] + a['audit']['runtime_references']:
            if a['scope'] == 'MAIN_SOURCE': inputs[path] = model.sha(ROOT/path)
    for path in ['tools/html_blueprint_inspection.py','tools/html_blueprint_ui/inspection.js']:
        inputs[path] = model.sha(ROOT/path)
    css = ''.join((ROOT/'tools/html_blueprint_ui'/name).read_text(encoding='utf-8') for name in ['style.css','event_catalog.css'])
    js = (ROOT/'tools/html_blueprint_ui/app.js').read_text(encoding='utf-8')
    js = js.removesuffix('render();\n') + ''.join((ROOT/'tools/html_blueprint_ui'/name).read_text(encoding='utf-8') for name in ['experience.js','inspection.js','design.js','review_state.js','review.js','inline.js','event_catalog.js']) + '\nrender();followLocation();\n'
    html = '''<!doctype html><html lang="ko"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>십보강호 · 살아 있는 블루프린트</title><style>''' + css + '''</style></head><body>
<a class="skip" id="skip-content" href="#main">본문으로</a><header><a href="#maps" class="brand">십보강호 <small>숨은 수의 비무</small></a><span class="edition">프로젝트 블루프린트</span><button id="resume-copy">재개 요청 복사</button></header>
<div class="shell"><div class="section-navigation"><nav aria-label="본문 구역 바로가기" id="nav"></nav><div class="navigation-tools"><label class="search-label" for="search">내용 찾기</label><input id="search" type="search" placeholder="번호 · 인물 · 무공 · 자산 · 작업"><details><summary>발행 정보</summary><p id="freshness"></p><a href="../../AGENTS.md">작업 규칙 원본 ↗</a></details></div></div><main id="main" tabindex="-1"></main></div>
<dialog id="viewer"><button id="close-viewer" autofocus>닫기 · Esc</button><div id="viewer-body"></div></dialog><div id="notice" role="status" aria-live="polite"></div>
<script id="blueprint-data" type="application/json">''' + model.script_json(payload) + '</script><script>' + js + '</script></body></html>'
    manifest = {'role': 'DERIVED_VIEW_NOT_CANON', 'source_revision': payload['source_revision'],
                'image_inventory_digest': audit_model.inventory_digest(ROOT),
                'generated_at': payload['generated_at'], 'inputs': inputs, 'reader_ids': [p['id'] for p in pages],
                'asset_ids': [a['id'] for a in assets], 'candidate_revision': candidate_info['revision'] if candidate_info else None,
                'media': {**preview_media, **{'output/blueprint/'+a['url']:a['sha256'] for a in assets if a['scope']=='PR342_CANDIDATE'},
                          **{'output/blueprint/'+p['url']:p['sha256'] for p in originals}}}
    resume = {'role': 'DERIVED_VIEW_NOT_CANON', 'source_revision': payload['source_revision'],
        'generated_at': payload['generated_at'], 'read_order': ['AGENTS.md', 'docs/BASE_RULES_VERSION.md', 'docs/PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION.md', '[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md'],
        'assets': [{k:a.get(k) for k in ['id','path','scope','revision','approval','owner','consumers','audit','group']} for a in assets],
        'user_review': {'path': payload['review_location'], 'role': 'USER_AUTHORED_REVIEW_NOT_IMPLEMENTATION_PROOF', 'read_on_resume': True,
                        'disposal_requests':'status=discard; inspect references before recoverable move; preserve comments and stable IDs'},
        'retired_images': retired,
        'image_catalog': payload['image_catalog'],
        'work_items': pm['items'], 'inspection': payload['inspection'],
        'motion_evidence': [{'id':c['id'],'path':c['path'],'timeline':c.get('timeline',[]),'freshness':c['freshness']} for c in experience['clips']]}
    encoded = lambda obj: (json.dumps(obj, ensure_ascii=False, indent=2)+'\n').encode('utf-8')
    bundle = {'index.html': html.encode('utf-8'), 'resume-index.json': encoded(resume)}
    manifest['outputs'] = {name: hashlib.sha256(data).hexdigest() for name, data in bundle.items()}
    bundle['manifest.json'] = encoded(manifest)
    publish_bundle(out, bundle)
    print(json.dumps({'pages': len(pages), 'assets': len(assets), 'work_items': len(pm['items']), 'output': str(out/'index.html')}, ensure_ascii=False))
    return payload


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--main-only', action='store_true', help='Omit PR342; final migration requires the candidate catalog too')
    args = parser.parse_args()
    build(include_candidate=not args.main_only)
