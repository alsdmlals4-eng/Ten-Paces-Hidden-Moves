"""User-authored review history, separate from generated/canonical approval evidence."""
from contextlib import contextmanager
from datetime import datetime, timezone
import json
import os
from pathlib import Path
import re
import subprocess
import time
import uuid

PROJECT = 'ten-paces-hidden-moves'
LIMIT = 2 * 1024 * 1024
STATUSES = {'pending', 'checked', 'changes', 'hold'}


class Conflict(ValueError):
    pass


def shared_directory(root):
    common = subprocess.check_output(['git', 'rev-parse', '--path-format=absolute', '--git-common-dir'], cwd=root, text=True).strip()
    return Path(common) / 'blueprint-review'


def valid_id(value):
    return isinstance(value, str) and bool(re.fullmatch(r'(screen|asset|card|giyun|person|clip|task|reader):[\w.:%+\-]{1,220}', value))


def validate_entry(entry):
    if not isinstance(entry, dict) or entry.get('status') not in STATUSES:
        raise ValueError('Unknown review status')
    for key, maximum in [('comment', 10000), ('fingerprint', 128), ('source_revision', 64)]:
        if not isinstance(entry.get(key), str) or len(entry[key]) > maximum:
            raise ValueError('Invalid review field: ' + key)


def validate_document(data):
    if not isinstance(data, dict) or data.get('project') != PROJECT or data.get('schema_version') != 1:
        raise ValueError('다른 프로젝트 또는 지원하지 않는 검토 파일입니다.')
    if type(data.get('revision')) is not int or data['revision'] < 0 or not isinstance(data.get('items'), dict):
        raise ValueError('Invalid revision/items')
    for key, rows in data['items'].items():
        if not valid_id(key) or not isinstance(rows, list) or not rows:
            raise ValueError('Invalid review history')
        seen = set()
        for row in rows:
            validate_entry(row)
            if not isinstance(row.get('id'), str) or not re.fullmatch(r'[0-9a-f]{32}', row['id']) or row['id'] in seen:
                raise ValueError('Invalid/duplicate history identity')
            seen.add(row['id'])
            try:
                if datetime.fromisoformat(row['updated_at']).tzinfo is None:
                    raise ValueError('Timestamp requires timezone')
            except (TypeError, KeyError):
                raise ValueError('Invalid timestamp')
    if len(json.dumps(data, ensure_ascii=False, indent=2).encode('utf-8')) > LIMIT:
        raise ValueError('검토 기록이 저장 한도를 넘었습니다. 내보내기로 보관해 주세요.')
    return data


class ReviewStore:
    def __init__(self, directory):
        self.path = Path(directory) / 'reviews.json'

    @contextmanager
    def lock(self):
        self.path.parent.mkdir(parents=True, exist_ok=True)
        with (self.path.parent / 'reviews.lock').open('a+b') as handle:
            deadline = time.monotonic() + 4
            while True:
                try:
                    handle.seek(0)
                    if os.name == 'nt':
                        import msvcrt
                        msvcrt.locking(handle.fileno(), msvcrt.LK_NBLCK, 1)
                    else:
                        import fcntl
                        fcntl.flock(handle.fileno(), fcntl.LOCK_EX | fcntl.LOCK_NB)
                    break
                except OSError:
                    if time.monotonic() > deadline:
                        raise Conflict('다른 창에서 저장 중입니다. 다시 불러온 뒤 저장해 주세요.')
                    time.sleep(.03)
            try:
                yield
            finally:
                handle.seek(0)
                if os.name == 'nt':
                    msvcrt.locking(handle.fileno(), msvcrt.LK_UNLCK, 1)
                else:
                    fcntl.flock(handle.fileno(), fcntl.LOCK_UN)

    def _read(self):
        if not self.path.exists():
            return {'schema_version': 1, 'project': PROJECT, 'revision': 0, 'items': {}}
        if self.path.stat().st_size > LIMIT:
            raise ValueError('검토 기록이 너무 큽니다. 원본을 보존하고 확인해 주세요.')
        return validate_document(json.loads(self.path.read_text(encoding='utf-8')))

    def read(self):
        with self.lock():
            return self._read()

    def _write(self, data):
        data['revision'] += 1
        validate_document(data)
        if self.path.exists():
            backup = self.path.with_suffix('.json.bak')
            temp_backup = backup.with_suffix('.bak.tmp')
            temp_backup.write_bytes(self.path.read_bytes())
            os.replace(temp_backup, backup)
        temp = self.path.with_suffix('.json.tmp')
        with temp.open('w', encoding='utf-8', newline='\n') as handle:
            json.dump(data, handle, ensure_ascii=False, indent=2)
            handle.flush()
            os.fsync(handle.fileno())
        os.replace(temp, self.path)
        return data

    def _revision(self, expected, data):
        if type(expected) is not int:
            raise ValueError('Invalid revision')
        if expected != data['revision']:
            raise Conflict('다른 창의 변경이 있습니다. 입력 내용은 유지됩니다. 최신 기록을 불러온 뒤 비교해 주세요.')

    def save(self, request):
        validate_entry(request)
        if not valid_id(request.get('item_id')):
            raise ValueError('Invalid item identity')
        with self.lock():
            data = self._read()
            self._revision(request.get('revision'), data)
            entry = {k: request[k] for k in ['status', 'comment', 'fingerprint', 'source_revision']}
            entry.update(id=uuid.uuid4().hex, updated_at=datetime.now(timezone.utc).isoformat())
            data['items'].setdefault(request['item_id'], []).append(entry)
            return self._write(data)

    def import_document(self, imported, revision):
        validate_document(imported)
        with self.lock():
            data = self._read()
            self._revision(revision, data)
            for key, rows in imported['items'].items():
                current = data['items'].setdefault(key, [])
                known = {r['id']: r for r in current}
                for row in rows:
                    if row['id'] in known and known[row['id']] != row:
                        raise Conflict('동일한 기록 ID의 내용이 다릅니다. 덮어쓰지 않았습니다.')
                    if row['id'] not in known:
                        current.append(dict(row))
                current.sort(key=lambda r: (datetime.fromisoformat(r['updated_at']), r['id']))
            return self._write(data)
