"""Source-bound HTML display model. No gameplay simulation or approval inference."""
from __future__ import annotations

import hashlib
import json
import re
import subprocess
from pathlib import Path, PurePosixPath

ROOT = Path(__file__).resolve().parents[1]


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def local_path(root, relative):
    relative = str(relative).removeprefix('res://')
    if '\\' in relative or ':' in relative or relative.startswith('/') or '..' in PurePosixPath(relative).parts:
        raise ValueError(f'Unsafe repository path: {relative}')
    path = (Path(root) / relative).resolve()
    if not path.is_relative_to(Path(root).resolve()):
        raise ValueError(f'Path escaped repository: {relative}')
    return path


def verified_file(root, relative, expected=None):
    path = local_path(root, relative)
    digest = sha(path)
    if expected and digest != expected:
        raise ValueError(f'Hash mismatch: {relative}')
    return path, digest


def script_json(value):
    return json.dumps(value, ensure_ascii=False).replace('<', '\\u003c').replace('>', '\\u003e').replace('&', '\\u0026').replace('\u2028', '\\u2028').replace('\u2029', '\\u2029')


def unique_ids(items):
    seen = set()
    for item in items:
        if item['id'] in seen:
            raise ValueError(f'Duplicate ID: {item["id"]}')
        seen.add(item['id'])


def read(root, rel):
    return json.loads(local_path(root, rel).read_text(encoding='utf-8'))


def approval_state(entry):
    text = entry.get('approval', '')
    if not text or any(s in text.lower() for s in ['pending', 'unverified', '미승인', '대기']):
        return 'APPROVAL_UNVERIFIED'
    return 'USER_APPROVED' if ('user explicit:' in text.lower() or 'final-lock' in text.lower()) else 'APPROVAL_UNVERIFIED'


def consumer_paths(description):
    return list(dict.fromkeys(re.findall(r'(?:src|scenes|data)/[A-Za-z0-9_/.-]+\.(?:gd|tscn|tres|json)', description)))


def motion_sequence(code, role):
    found = re.search(r'var sequence := (\[[0-9, ]+\]) if actor_role == "player" else (\[[0-9, ]+\])', code)
    return json.loads(found.group(1 if role == 'player' else 2)) if found else []


class Reader:
    """Capture every semantic call of the shared 112-section composition."""
    def __init__(self):
        self.pages = []
        self.c = self

    def add(self, kind, **values):
        self.pages[-1]['blocks'].append({'kind': kind, **values})

    def page(self, title, subtitle='', state='기획·구현 상태는 6부 참조'):
        self.pages.append({'id': f'reader-{len(self.pages)+1:03}', 'title': title, 'subtitle': subtitle, 'historical_state': state, 'blocks': []})

    def p(self, text, x=0, top=0, w=0, size=10, *args, **kwargs):
        self.add('text', text=str(text), source_position=[x, top])
        return top - size * 2

    def note(self, text, *args):
        self.add('note', text=text)

    def table(self, headers, rows, *args, **kwargs):
        self.add('table', headers=headers, rows=rows)
        return 200

    def panel(self, title, text, *args):
        self.add('panel', title=title, text=text)

    def flow(self, items, **kwargs):
        self.add('flow', items=items)

    def photo(self, path, *args):
        relative = Path(path).resolve().relative_to(ROOT).as_posix()
        verified_file(ROOT, relative)
        self.add('image', path=relative)

    def region(self, path, rect, *args):
        self.photo(path)
        self.pages[-1]['blocks'][-1]['region'] = rect

    def picture_page(self, title, subtitle, path, caption):
        self.page(title, subtitle)
        self.photo(path)
        self.note(caption)

    def box(self, *args):
        # Retain source geometry for traceability, not a second combat simulator.
        self.add('geometry', shape='box', coordinates=[str(x) for x in args])

    def arrow(self, points):
        self.add('geometry', shape='arrow', coordinates=points)

    def linkURL(self, url, *args, **kwargs):
        if not url.startswith(('https://', 'http://')):
            raise ValueError(f'Unsafe external link: {url}')
        self.add('link', url=url)

    def setTitle(self, title):
        pass

    def setStrokeColor(self, *args):
        pass

    def line(self, *args):
        self.add('geometry', shape='line', coordinates=args)


def manual_readable_tables(manual):
    """Describe source data, never execute combat rules in the browser."""
    from blueprint_layout import describe
    progression = (ROOT/'src/run/vertical_slice_progression_state.gd').read_text(encoding='utf-8')
    costs_text = re.search(r'const NEXT_STAR_COSTS := \{([^}]+)', progression).group(1)
    costs = {int(k): int(v) for k, v in re.findall(r'(\d+):\s*(\d+)', costs_text)}
    growth_owner = (ROOT/'docs/06_STARTING_FACTION_MASTERY_DATA.md').read_text(encoding='utf-8')
    planned = {int(star): effect.strip() for star, effect in re.findall(r'\| (\d+)성 \| ([^|]+)\|', growth_owner)}
    growth = []
    for star in range(1, 11):
        card = next((c for c in manual['cards'].values() if c['unlock_star'] == star), None)
        overlay = next((o for o in manual.get('overlays', {}).values() if o['unlock_star'] == star), None)
        if card:
            effect, condition, state = card['name']+' 해금', '해금 후 해당 기술 조건 적용', '기술 데이터·판정 연결'
        elif overlay:
            effect = overlay['name']+' · '+manual['cards'][overlay['target']]['name']+' 강화'
            condition = '조건·순서: '+' → '.join(describe(s) for s in overlay.get('effect_steps', []))
            state = '성수별 조건 효과 연결'
        else:
            effect = planned.get(star, '신규 기술 해금 없음')
            condition = '주 능력치 '+manual['primary_stat']+' / 보조 '+manual['secondary_stat']
            state = '기획 효과 · 현재 main 영구 능력치 지급 미연결' if star in [2,4,6,8] else '기획 단계 / 시작 선택은 3성'
        growth.append([f'{star}성', str(costs[star])+'점' if star in costs else '시작 3성 / 개별 수련 비용 없음', effect, condition, state])
    techniques = []
    for card in manual['cards'].values():
        distance = card.get('range', {})
        techniques.append([card['name'], str(card['unlock_star'])+'성', str(card['action_slots'])+'수',
            f"기력 {card.get('stamina_cost',0)} / 내력 {card.get('internal_cost',0)}",
            f"{distance.get('min','—')}~{distance.get('max','—')}",
            ' → '.join(describe(s) for s in card.get('effect_steps', []))])
    shared = []
    generic = {3:'첫 기술 획득', 5:'3성 기술에 추가 효과', 7:'두 번째 기술 획득',
               9:'7성 기술에 추가 효과', 10:'절초 획득'}
    for row in growth:
        star = int(row[0].removesuffix('성'))
        shared.append([row[0], row[1], generic.get(star, planned.get(star, '신규 기술 해금 없음')),
                       '현재 기술·강화 데이터 연결' if star in generic else row[4]])
    cards = []
    for key, card in manual['cards'].items():
        overlay = next((o for o in manual.get('overlays', {}).values() if o['target'] == key), None)
        cards.append({'id':card['id'], 'name':card['name'], 'unlock_star':card['unlock_star'],
                      'effects':[describe(step) for step in card.get('effect_steps', [])],
                      'enhancement':dict(name=overlay['name'], unlock_star=overlay['unlock_star'],
                                         effects=[describe(s) for s in overlay.get('effect_steps',[])]) if overlay else None})
    return {'growth': growth, 'techniques': techniques, 'shared_growth': shared, 'card_rows': cards}


def collect_reader():
    import build_human_blueprint_complete as source
    book = Reader()
    source.compose(book)
    if len(book.pages) != len(source.PAGE_ORDER):
        raise ValueError('Reader coverage changed; reconcile approved inventory')
    pages = [book.pages[i-1] for i in source.PAGE_ORDER]
    unique_ids(pages)
    return pages


def collect_assets(root):
    approval = read(root, 'docs/planning-data/current_user_planning_status.json')['blueprint_final_approval']
    retired = {row['path']: row for row in read(root, 'docs/blueprint/IMPLEMENTATION_READINESS.json').get('retired_images', [])}
    verified_file(root, approval['artifact'], approval['artifact_sha256'])
    by_path = {}
    for entry in read(root, 'assets/ASSET_MANIFEST.json')['assets']:
        path = entry['path'].removeprefix('res://')
        local_path(root, path)
        approved = approval_state(entry) == 'USER_APPROVED'
        item = {'id': 'asset-' + entry['id'], 'path': path, 'name': entry.get('role', entry['id']),
                'approval': 'USER_APPROVED' if approved else 'APPROVAL_UNVERIFIED',
                'approval_record': entry.get('approval', '자산 등록만으로 최종 승인을 뜻하지 않음'),
                'scope': 'MAIN_SOURCE', 'active': entry.get('active'), 'consumers': [],
                'owner': 'assets/ASSET_MANIFEST.json', 'details': entry}
        if local_path(root, path).is_file():
            item['sha256'] = sha(local_path(root, path))
            item['available'] = True
        else:
            item.update(available=False, sha256=None)
            if approved and entry.get('active', True):
                raise FileNotFoundError(f'Approved asset missing: {path}')
        by_path[path] = item
    for entry in approval['approved_visual_inputs']:
        if entry['path'] in retired and retired[entry['path']]['status'] == 'DELETED_BY_USER_REQUEST':
            if retired[entry['path']]['sha256'] != entry['sha256']:
                raise ValueError('Retired source differs from its historical approval: ' + entry['path'])
            continue
        path, digest = verified_file(root, entry['path'], entry['sha256'])
        item = by_path.setdefault(entry['path'], {'id': 'asset-' + hashlib.sha256(entry['path'].encode()).hexdigest()[:16],
            'path': entry['path'], 'name': path.stem, 'scope': 'MAIN_SOURCE', 'active': None, 'consumers': [], 'details': {}})
        item.update(approval='USER_APPROVED', approval_record='2026-09-11 blueprint_final_approval',
                    owner='docs/planning-data/current_user_planning_status.json', sha256=digest, available=True)
    for item in list(by_path.values()):
        original = item['details'].get('source_asset', '')
        if not original or not original.endswith(('.png', '.jpg', '.webp')):
            continue
        path = local_path(root, original)
        if path.is_file() and original not in by_path:
            by_path[original] = {**item, 'id': item['id']+'-original', 'path': original,
                'name': item['name']+' · 제작 원본', 'sha256': sha(path), 'consumers': [],
                'derived_asset_id': item['id'], 'active': None}
    for folder in ['assets', 'docs/visual-assets/approved', 'output/blueprint-candidates']:
        for path in (Path(root)/folder).rglob('*'):
            if path.suffix.lower() not in {'.png', '.jpg', '.jpeg', '.webp'}:
                continue
            relative = path.relative_to(root).as_posix()
            if relative not in by_path:
                by_path[relative] = {'id': 'asset-'+hashlib.sha256(relative.encode()).hexdigest()[:16],
                    'path': relative, 'name': path.stem, 'scope': 'MAIN_SOURCE', 'active': None, 'consumers': [],
                    'approval': 'APPROVAL_UNVERIFIED', 'approval_record': '파일 존재만 확인; 폴더 이름으로 승인을 추정하지 않음',
                    'owner': 'assets/ASSET_MANIFEST.json', 'sha256': sha(path), 'available': True, 'details': {}}
    # Name/subject associations are read from existing catalog owners.
    from build_opponent_stage_blueprint import build
    for person in build():
        item = by_path.get(person['portrait'])
        if item:
            item['name'] = person['name'] + ' · ' + person['role']
            item['subject'] = person['candidate_id'] if 'candidate_id' in person else person.get('id', person['name'])
    for item in list(by_path.values()):
        original = by_path.get(item['details'].get('source_asset', ''))
        if original and original['id'] != item['id']:
            item.setdefault('related_assets', []).append(original['id'])
            original.setdefault('related_assets', []).append(item['id'])
            if original.get('subject'):
                item['subject'] = original['subject']
                item['name'] = original['name'] + ' · 게임 적용본'
            explicit = item['details'].get('approval') == 'docs/planning-data/current_user_planning_status.json#blueprint_final_approval'
            source_hash = item['details'].get('source_png_sha256')
            if explicit and original['approval'] == 'USER_APPROVED' and source_hash == original['sha256']:
                if not item['available']:
                    raise FileNotFoundError('Approved derivative missing: '+item['path'])
                item['approval'] = 'USER_APPROVED'
                item['approval_record'] = 'blueprint_final_approval 명시 연결 · 승인 원본 해시 일치 (변환본/런타임 검증은 별도)'
    for category in ['src', 'scenes', 'data']:
        for path in (Path(root)/category).rglob('*'):
            if path.suffix not in {'.gd', '.tscn', '.tres', '.json'}:
                continue
            content = path.read_text(encoding='utf-8')
            rel = path.relative_to(root).as_posix()
            for asset_path, item in by_path.items():
                if asset_path in content:
                    item['consumers'].append(rel)
    result = list(by_path.values())
    unique_ids(result)
    return result


def collect_pm(root):
    receipts = []
    for path in sorted((Path(root)/'docs/operations').glob('*WORK_CONTRACT_RECEIPT.json')):
        data = json.loads(path.read_text(encoding='utf-8'))
        items = data.get('project_work_kanban', {}).get('work_items', [])
        for item in items:
            receipts.append({'source': path.relative_to(root).as_posix(), **item})
    return {'current': read(root, 'docs/planning-data/current_operating_state.json'),
            'github': read(root, 'docs/blueprint/HTML_SOURCE_OBSERVATIONS.json'), 'items': receipts}


def git(*args, root=ROOT):
    return subprocess.check_output(['git', *args], cwd=root).decode('utf-8').strip()
