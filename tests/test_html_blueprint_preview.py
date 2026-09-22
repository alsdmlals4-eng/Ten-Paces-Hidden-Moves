import hashlib
import http.client
import threading
from unittest.mock import patch
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]/'tools'))
import serve_html_blueprint as subject


class PreviewBoundaryTests(unittest.TestCase):
    def test_only_allowlisted_exact_file_is_served(self):
        with tempfile.TemporaryDirectory() as folder:
            root=Path(folder)
            (root/'visible.txt').write_text('visible',encoding='utf-8')
            (root/'private.txt').write_text('private',encoding='utf-8')
            allow={'visible.txt':hashlib.sha256(b'visible').hexdigest()}
            self.assertEqual(subject.resolve_request(root,allow,'/p/token/visible.txt','token'),root/'visible.txt')
            for url in ['/p/token/private.txt','/p/other/visible.txt','/p/token/../visible.txt','/p/token/%2e%2e/private.txt','/p/token/.git/config']:
                with self.subTest(url=url),self.assertRaises(ValueError):
                    subject.resolve_request(root,allow,url,'token')

    def test_changed_source_is_not_silently_served_as_verified(self):
        with tempfile.TemporaryDirectory() as folder:
            root=Path(folder);(root/'visible.txt').write_text('changed',encoding='utf-8')
            with self.assertRaises(ValueError):
                subject.resolve_request(root,{'visible.txt':hashlib.sha256(b'original').hexdigest()},'/p/token/visible.txt','token')

    def test_real_http_read_only_boundary(self):
        with tempfile.TemporaryDirectory() as folder:
            root=Path(folder);(root/'visible.txt').write_bytes(b'visible')
            allow={'visible.txt':hashlib.sha256(b'visible').hexdigest()}
            with patch.object(subject,'ROOT',root):
                server=subject.create_server(allow,'token')
                thread=threading.Thread(target=server.serve_forever,daemon=True);thread.start()
                try:
                    for method,url,expected in [('GET','/p/token/visible.txt',200),('HEAD','/p/token/visible.txt',200),('GET','/p/token/private.txt',404),('POST','/p/token/visible.txt',405),('GET','/p/token/%2e%2e/private.txt',404)]:
                        connection=http.client.HTTPConnection('127.0.0.1',server.server_port)
                        connection.request(method,url);response=connection.getresponse()
                        self.assertEqual(response.status,expected)
                        body=response.read()
                        if method=='GET' and expected==200:self.assertEqual(body,b'visible')
                        if method=='HEAD':self.assertEqual(body,b'')
                        connection.close()
                finally:
                    server.shutdown();server.server_close();thread.join()

    def test_external_host_and_origin_rejected(self):
        self.assertTrue(subject.valid_peer('127.0.0.1:1234',None,1234))
        self.assertFalse(subject.valid_peer('evil.test:1234',None,1234))
        self.assertFalse(subject.valid_peer('127.0.0.1:1234','https://evil.test',1234))


if __name__=='__main__':unittest.main()
