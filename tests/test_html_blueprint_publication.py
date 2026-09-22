import sys, tempfile, unittest
from pathlib import Path
from unittest.mock import patch
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'tools'))
import build_html_blueprint as subject
import serve_html_blueprint as preview
import json,hashlib

class PublicationTests(unittest.TestCase):
    def test_publication_failure_preserves_last_good_bundle(self):
        with tempfile.TemporaryDirectory() as d:
            root=Path(d)
            for name in ['index.html','manifest.json','resume-index.json']:
                (root/name).write_bytes(b'old')
            original=subject.os.replace
            def fail_one(src,dst):
                if str(src).endswith('manifest.json.tmp'):
                    raise OSError('simulated publication failure')
                original(src,dst)
            with patch.object(subject.os,'replace',side_effect=fail_one):
                with self.assertRaises(OSError):
                    subject.publish_bundle(root,{n:b'new' for n in ['index.html','manifest.json','resume-index.json']})
            self.assertTrue(all((root/n).read_bytes()==b'old' for n in ['index.html','manifest.json','resume-index.json']))

    def test_successful_bundle_replaces_all_outputs(self):
        with tempfile.TemporaryDirectory() as d:
            root=Path(d)
            subject.publish_bundle(root,{'index.html':b'html','manifest.json':b'{}','resume-index.json':b'{}'})
            self.assertEqual((root/'index.html').read_bytes(),b'html')

    def test_preview_rejects_interrupted_mixed_generation(self):
        with tempfile.TemporaryDirectory() as d:
            root=Path(d);out=root/'output/blueprint';out.mkdir(parents=True)
            (out/'index.html').write_bytes(b'new')
            (out/'manifest.json').write_text(json.dumps({'outputs':{'index.html':hashlib.sha256(b'old').hexdigest()},'inputs':{}}),encoding='utf-8')
            with patch.object(preview,'ROOT',root), self.assertRaises(ValueError):
                preview.load_allowlist()

if __name__=='__main__': unittest.main()
