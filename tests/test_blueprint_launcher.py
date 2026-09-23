import hashlib
import json
from pathlib import Path
import sys
import tempfile
import threading
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tools'))
import serve_html_blueprint as server


class LauncherTests(unittest.TestCase):
    def test_live_snapshot_reuse_and_changed_snapshot_rejection(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            output = root / 'output/blueprint'
            output.mkdir(parents=True)
            page = output / 'index.html'
            page.write_bytes(b'<html>verified</html>')
            digest = hashlib.sha256(page.read_bytes()).hexdigest()
            with patch.object(server, 'ROOT', root):
                http = server.create_server({'output/blueprint/index.html': digest}, 'sample')
                worker = threading.Thread(target=http.serve_forever, daemon=True)
                worker.start()
                try:
                    receipt = {'url': f'http://127.0.0.1:{http.server_port}/p/sample/output/blueprint/index.html', 'index_sha256': digest}
                    fn = getattr(server, 'healthy_session_url', None)
                    self.assertIsNotNone(fn, 'Reopening needs verified live-session reuse')
                    self.assertEqual(fn(receipt, page), receipt['url'])
                    page.write_bytes(b'new generation')
                    self.assertIsNone(fn(receipt, page))
                finally:
                    http.shutdown(); http.server_close(); worker.join()

    def test_receipt_cannot_redirect_launcher_to_remote_or_other_path(self):
        fn = getattr(server, 'healthy_session_url', None)
        self.assertIsNotNone(fn, 'Launcher must validate receipt destinations')
        with tempfile.TemporaryDirectory() as directory:
            page = Path(directory) / 'index.html'; page.write_bytes(b'x')
            for url in ['https://example.com/', 'http://127.0.0.1:9/private', 'http://user@127.0.0.1:9/p/a/output/blueprint/index.html']:
                self.assertIsNone(fn({'url': url, 'index_sha256': hashlib.sha256(b'x').hexdigest()}, page))


if __name__ == '__main__': unittest.main()
