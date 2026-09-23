"""Conservative source inventory. A missing literal reference is not deletion proof."""
from collections import defaultdict
import hashlib
from pathlib import Path
import subprocess
import json
import re


def group_assets(assets, people, manuals, art_selection=None):
    """Browsing categories are hints, never asset identity/approval/retirement proof."""
    characters = [(p['id'].split('_', 1)[-1], p['name']) for p in people]
    characters += [('wanderer', '강호낭인 · 플레이어'), ('player', '강호낭인 · 플레이어'),
                   ('masked_swordsman', '공용 상대 · 가면 검객·모션'), ('enemy_masked', '공용 상대 · 가면 검객·모션'),
                   ('enemy', '공용 상대 · 가면 검객·모션')]
    screens = [('menu', '메인메뉴', ['title', 'logo', 'main_menu', 'main-menu']),
               ('brief', '비무 브리핑', ['briefing', 'brief', 'bimu-constraints']),
               ('route', '강호행로 · 휴식·수련·정탐·사건', ['jianghu', 'giyun', 'route', 'inn']),
               ('starter', '시작 무공 선택', ['starter', 'starting', 'faction', 'manual-ui', 'martial-summary']),
               ('resolve', '전투 · 격돌·합·피격 연출', ['combat', 'battle', 'clash', '/motion/', 'courtyard', '/vfx/', 'execute', 'execution', 'reveal', 'duel']),
               ('result', '승패 · 복기·성장', ['result', 'review', 'reward', 'growth']),
               ('shared', '공용 UI · 프레임·아이콘', ['frame', 'panel', 'button', '/ui/', 'technique_ink_atlas', 'card_illustration_atlas'])]
    for a in assets:
        path = a['path'].lower()
        tokens = path + ' ' + str(a.get('details', {}).get('source_art', '')).lower()
        role = ('실행·검증 화면' if '/evidence/' in path or '/runtime-captures/' in path else
                '모션·포즈' if any(x in path for x in ['/motion/', 'sequence', 'reaction', 'pose']) else
                '초상·상태창' if 'portrait' in path else '전투 캐릭터' if 'battler' in path else
                '배경' if '/background' in path or 'landscape' in path else
                '제작 원본·후보' if '/visual-assets/' in path else '이미지·삽화')
        group = None
        if path.startswith('addons/'):
            group = ('tools', '개발 도구 이미지', '도구 경로')
        else:
            for key, name in characters:
                if re.search(r'(?<![a-z])' + re.escape(key) + r'(?![a-z])', tokens):
                    identity = 'player' if key in {'player','wanderer'} else 'shared-enemy' if key in {'enemy','masked_swordsman','enemy_masked'} else key
                    group = ('character:' + identity, '캐릭터 · ' + name, '인물 ID·파일 경로 분류')
                    break
            if not group:
                for m in manuals:
                    if (m['manual_id'].lower() in tokens or Path(path).name in [n.lower() for n in (art_selection or {}).get('manuals', {}).get(m['manual_id'], [])]):
                        group = ('manual:' + m['manual_id'], '무공 · ' + m['manual_name'], '무공 ID 경로')
                        break
            if not group:
                for key, name, patterns in screens:
                    if any(x in tokens for x in patterns):
                        group = ('screen:' + key, name, '화면·경로 키워드 분류')
                        break
        if not group and ('runtime-captures/' in path or '/evidence/' in path):
            group = ('evidence', '실행·참고 화면 · 종류 확인', '검증 자료 경로')
        if not group:
            group = ('other', '분류 확인 필요 · 기타 자료', '명시 연결 미확인')
        a['group'] = dict(zip(['id','label','basis'], group), role=role)
    return assets

IMAGE_TYPES = {'.png', '.jpg', '.jpeg', '.webp', '.gif', '.svg'}
TEXT_TYPES = {'.gd', '.tscn', '.tres', '.json', '.md', '.py', '.cfg', '.godot', '.js'}


def classify(asset, runtime, documents, replacements, duplicates):
    flags, reasons = [], []
    if runtime: flags.append('runtime')
    if documents: flags.append('documents')
    if asset.get('approval') != 'USER_APPROVED':
        flags.append('unverified')
        if runtime: flags.append('approval_gap')
    if replacements: flags.append('replaced')
    if duplicates: flags.append('duplicate')
    if not runtime and not documents: flags.append('unreferenced')
    if asset.get('approval') == 'USER_APPROVED':
        flags.append('retain'); reasons.append('승인 이미지 또는 승인 제작 원본 보존')
    if asset.get('scope') != 'MAIN_SOURCE':
        flags.append('retain'); reasons.append('열린 PR의 후보·증빙·사용처 보존')
    if asset.get('derived_asset_id') or '/approved/' in asset.get('path', ''):
        if 'retain' not in flags: flags.append('retain')
        reasons.append('제작 원본·승인 자료 위치: 사용 중지와 폐기는 별도')
    if runtime: reasons.append('코드·씬·데이터에서 참조됨; 정적 참조는 실제 화면 증거와 구분')
    if documents: reasons.append('문서·빌드·테스트·기획의 참조가 남아 있음')
    if replacements: reasons.append('명시된 대체 이미지가 있음; 교체됐어도 과거 승인·재현 근거를 보존')
    if not runtime and not documents:
        reasons.append('직접 참조 미검출; 동적 조회·미커밋 작업·원본 보존을 확인하기 전 이동 금지')
    return {'flags': flags, 'reasons': reasons, 'safe_to_move': False,
            'runtime_references': runtime, 'document_references': documents,
            'replacement_ids': replacements, 'duplicate_ids': duplicates,
            'disposition': '보존' if 'retain' in flags or runtime or documents else '추가 확인 후 정리 검토'}


def tracked(root, revision=None):
    args = ['git', '-c', 'core.quotepath=false']
    args += ['ls-tree', '-r', '--name-only', revision] if revision else ['ls-files']
    return subprocess.check_output(args, cwd=root).decode('utf-8').splitlines()


def inventory_digest(root):
    """Also notice newly tracked images/references, not only existing consumers."""
    digest = hashlib.sha256()
    for rel in sorted(set(tracked(root))):
        if Path(rel).suffix.lower() in IMAGE_TYPES | TEXT_TYPES:
            path = root / rel
            digest.update(rel.encode('utf-8') + b'\0')
            digest.update(hashlib.sha256(path.read_bytes()).digest() if path.is_file() else b'MISSING')
    return digest.hexdigest()


def revision_texts(root, revision):
    paths = [p for p in tracked(root, revision) if Path(p).suffix.lower() in TEXT_TYPES
             and p not in {'assets/ASSET_MANIFEST.json', 'assets/blueprint/APPROVED_ART_MANIFEST.json'}]
    batch = ''.join(f'{revision}:{p}\n' for p in paths).encode('utf-8')
    blobs = subprocess.check_output(['git', 'cat-file', '--batch'], input=batch, cwd=root)
    offset, result = 0, []
    for path in paths:
        end = blobs.index(b'\n', offset)
        header = blobs[offset:end].split()
        if len(header) != 3 or header[1] != b'blob':
            raise ValueError('Candidate source unavailable: ' + path)
        size = int(header[2]); offset = end + 1
        result.append((path, blobs[offset:offset+size].decode('utf-8', errors='replace')))
        offset += size + 1
    return result


def extend_inventory(root, assets, revision, out):
    """Include unregistered tracked images, including historical evidence and tool icons."""
    known = {(a['scope'], a['path']) for a in assets}
    main_hashes = {a['path']: a['sha256'] for a in assets if a['scope'] == 'MAIN_SOURCE'}
    for ref, scope in [(None, 'MAIN_SOURCE'), (revision, 'PR342_CANDIDATE')]:
        if scope != 'MAIN_SOURCE' and not ref: continue
        different = set()
        if ref:
            for args in [('HEAD', ref), ('HEAD',)]:
                different.update(subprocess.check_output(['git', '-c', 'core.quotepath=false', 'diff', '--name-only', *args], cwd=root).decode('utf-8').splitlines())
        for rel in tracked(root, ref):
            if Path(rel).suffix.lower() not in IMAGE_TYPES or (scope, rel) in known: continue
            if ref and rel not in different and (root / rel).is_file(): continue
            data = subprocess.check_output(['git', 'show', f'{ref}:{rel}'], cwd=root) if ref else (root / rel).read_bytes()
            digest = hashlib.sha256(data).hexdigest()
            if ref and main_hashes.get(rel) == digest: continue
            if ref and (root / rel).is_file() and hashlib.sha256((root / rel).read_bytes()).hexdigest() == digest: continue
            row = {'id': ('pr342-unregistered-' if ref else 'inventory-') + hashlib.sha256(rel.encode()).hexdigest()[:16],
                   'path': rel, 'scope': scope, 'revision': ref, 'name': Path(rel).stem,
                   'sha256': digest, 'available': True, 'active': None, 'details': {}, 'consumers': [],
                   'approval': 'APPROVAL_UNVERIFIED', 'approval_record': '추가 전수 목록 · 별도 승인 근거 확인 필요',
                   'owner': 'assets/ASSET_MANIFEST.json' if ref else 'docs/blueprint/HTML_MIGRATION_SPEC.md'}
            if ref:
                media = out / 'media' / (digest + Path(rel).suffix.lower())
                media.parent.mkdir(parents=True, exist_ok=True)
                media.write_bytes(data)
                row['url'] = 'media/' + media.name
            assets.append(row)
    return assets


def build(root, assets):
    texts = []
    for rel in tracked(root):
        if Path(rel).suffix.lower() in TEXT_TYPES and rel not in {
            'assets/ASSET_MANIFEST.json', 'assets/blueprint/APPROVED_ART_MANIFEST.json'}:
            if (root / rel).is_file():
                texts.append((rel, (root / rel).read_text(encoding='utf-8', errors='replace')))
    candidate_texts = {}
    for revision in {a['revision'] for a in assets if a.get('revision')}:
        candidate_texts[revision] = revision_texts(root, revision)
    duplicates = defaultdict(list)
    for a in assets:
        if a.get('sha256'): duplicates[a['sha256']].append(a['id'])
    for a in assets:
        runtime, documents = [], []
        if a['scope'] == 'MAIN_SOURCE':
            for path, text in texts:
                if a['path'] in text:
                    (runtime if path.startswith(('src/', 'scenes/', 'data/')) else documents).append(path)
        else:
            runtime = list(a['consumers'])
            for path, text in candidate_texts.get(a['revision'], []):
                if a['path'] in text:
                    (runtime if path.startswith(('src/', 'scenes/', 'data/')) else documents).append(path)
            runtime = sorted(set(runtime))
        a['consumers'] = sorted(set(a['consumers'] + runtime))
        replacements = [b['id'] for b in assets if b['scope'] == a['scope'] and
                        b.get('details', {}).get('replaces_active_asset') == a['id'].removeprefix('asset-')]
        same = [i for i in duplicates[a.get('sha256')] if i != a['id']]
        a['audit'] = classify(a, runtime, documents, replacements, same)
        a['audit']['category'] = ('개발 도구' if a['path'].startswith('addons/') else
                                 '실행 증거' if '/evidence/' in a['path'] else '게임·기획 이미지')
    return {'policy': '파일명·미승인·직접 참조 없음만으로 삭제하지 않습니다. 모든 이미지는 독립된 사용/승인/보존 상태를 가집니다.',
            'coverage': '현재 checkout의 추적 이미지와 등록 이미지, 관측한 PR342의 다른 이미지. 원래 checkout의 미커밋 작업은 별도 보존하므로 삭제 판정에 사용하지 않음.',
            'safe_to_move': [], 'move_status': '확정된 이동 대상 없음 · 추가 확인 목록에서 사유를 확인하세요.'}


def attach_intents(payload, configuration):
    """Use explicit source summaries only. No invented per-image creative intent."""
    records = payload['inspection']['records']
    for row in records:
        entry = configuration.get('items', {}).get(row['id'])
        if entry is None: entry = configuration.get('kinds', {}).get(row['kind'])
        row['intent'] = dict(entry) if entry else row.get('intent', {'status': '의도 기록 없음', 'purpose': '', 'sources': []})
        row['intent']['related_items'] = [r['id'] for r in records if row['id'].startswith('asset:') and row['id'][6:] in r['asset_ids'] and r['id'] != row['id']]
        row['fingerprint'] = hashlib.sha256(json.dumps(row, sort_keys=True, ensure_ascii=False).encode()).hexdigest()
