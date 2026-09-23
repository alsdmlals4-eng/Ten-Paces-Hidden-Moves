"""Hashed, bounded display copies. Original URLs, approval hashes and image IDs stay intact."""
from __future__ import annotations

import json
from pathlib import Path

from PIL import Image

from html_blueprint import local_path, sha, verified_file

# The version is part of the cache identity whenever sizing or encoding changes.
PROFILE = 'webp-q85-alpha-v1'
EDGES = (480, 960)


def _previews(source: Path, out: Path, digest: str) -> list[dict]:
    if sha(source) != digest:
        raise ValueError(f'Preview source hash differs: {source}')
    cache = out / 'media' / 'previews'
    record = cache / f'{digest}-{PROFILE}.json'
    if record.is_file():
        rows = json.loads(record.read_text(encoding='utf-8'))
        for row in rows:
            file, _ = verified_file(out, row['url'], row['sha256'])
            with Image.open(file) as image:
                if list(image.size) != row['size'] or max(image.size) > EDGES[-1] or row['source_sha256'] != digest:
                    raise ValueError(f'Preview metadata differs: {file}')
        return rows
    with Image.open(source) as original:
        if max(original.size) <= EDGES[0] or getattr(original, 'n_frames', 1) != 1:
            return []
        original.load()
        image = original.convert('RGBA' if 'A' in original.getbands() or 'transparency' in original.info else 'RGB')
    cache.mkdir(parents=True, exist_ok=True)
    rows = []
    for edge in EDGES:
        thumb = image.copy()
        thumb.thumbnail((edge, edge), Image.Resampling.LANCZOS)
        if rows and rows[-1]['size'] == list(thumb.size):
            continue
        file = cache / f'{digest}-{PROFILE}-{edge}.webp'
        thumb.save(file, 'WEBP', quality=85, method=4, exact=True)
        rows.append({'url': file.relative_to(out).as_posix(), 'size': list(thumb.size),
                     'sha256': sha(file), 'source_sha256': digest})
    record.write_text(json.dumps(rows, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    return rows


def asset_previews(root: Path, out: Path, assets: list[dict]) -> dict[str, str]:
    """Attach only derived metadata; return files for the existing manifest allowlist."""
    media = {}
    generated = {}
    for asset in assets:
        if not asset.get('available'):
            continue
        source = local_path(out, asset['url']) if asset['scope'] == 'PR342_CANDIDATE' else local_path(root, asset['path'])
        if source.suffix.lower() not in {'.png', '.jpg', '.jpeg', '.webp'}:
            continue
        digest = asset['sha256']
        if digest not in generated:
            generated[digest] = _previews(source, out, digest)
        asset['previews'] = generated[digest]
        for row in asset['previews']:
            media[(out / row['url']).relative_to(root).as_posix()] = row['sha256']
    return media
