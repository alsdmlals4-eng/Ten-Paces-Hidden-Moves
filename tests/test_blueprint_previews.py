"""Derived previews reduce transfer without changing source identities or access boundaries."""
import hashlib
import json
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'tools'))


class BlueprintPreviewTests(unittest.TestCase):
    def helper(self):
        from html_blueprint_previews import asset_previews
        return asset_previews

    def test_decoded_dimensions_alpha_original_identity_and_allowlist(self):
        helper = self.helper()
        import serve_html_blueprint as server
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder); out = root / 'output/blueprint'; out.mkdir(parents=True)
            source = root / 'original.png'
            Image.new('RGBA', (1200, 600), (20, 80, 120, 0)).save(source)
            original = source.read_bytes(); digest = hashlib.sha256(original).hexdigest()
            asset = {'id': 'asset:original', 'path': 'original.png', 'url': '../../original.png',
                     'sha256': digest, 'available': True, 'scope': 'MAIN_SOURCE', 'image_number': 19}
            media = helper(root, out, [asset])
            self.assertEqual(asset['id'], 'asset:original')
            self.assertEqual(asset['url'], '../../original.png')
            self.assertEqual(asset['image_number'], 19)
            self.assertEqual(asset['sha256'], digest)
            self.assertEqual(source.read_bytes(), original)
            self.assertEqual([p['size'] for p in asset['previews']], [[480, 240], [960, 480]])
            for row in asset['previews']:
                file = out / row['url']
                with Image.open(file) as decoded:
                    self.assertEqual(list(decoded.size), row['size'])
                    self.assertEqual(decoded.convert('RGBA').getpixel((0, 0))[3], 0)
                self.assertEqual(hashlib.sha256(file.read_bytes()).hexdigest(), row['sha256'])
                self.assertEqual(media[file.relative_to(root).as_posix()], row['sha256'])
            (out / 'index.html').write_bytes(b'html')
            (out / 'resume-index.json').write_bytes(b'{}')
            (out / 'manifest.json').write_text(json.dumps({'inputs': {'original.png': digest},
                'media': media, 'outputs': {'index.html': hashlib.sha256(b'html').hexdigest()}}))
            with patch.object(server, 'ROOT', root):
                allowed = server.load_allowlist()
            self.assertTrue(set(media).issubset(allowed))
            first = asset['previews'][0]
            (out / first['url']).write_bytes(b'corrupt cache')
            with self.assertRaises(ValueError):
                helper(root, out, [asset])

    def test_small_and_retired_images_keep_original_fallback(self):
        helper = self.helper()
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder); out = root / 'output/blueprint'; out.mkdir(parents=True)
            source = root / 'small.png'; Image.new('RGB', (120, 80)).save(source)
            asset = {'path': 'small.png', 'url': '../../small.png', 'scope': 'MAIN_SOURCE',
                     'available': True, 'sha256': hashlib.sha256(source.read_bytes()).hexdigest()}
            retired = {'path': 'gone.png', 'available': False}
            self.assertEqual(helper(root, out, [asset, retired]), {})
            self.assertFalse(asset.get('previews'))
            self.assertFalse(retired.get('previews'))


if __name__ == '__main__':
    unittest.main()
