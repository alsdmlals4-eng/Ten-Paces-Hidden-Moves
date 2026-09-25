import hashlib
import http.client
import sys
import tempfile
import threading
import unittest
from pathlib import Path
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tools'))
import html_blueprint as model
import html_blueprint_reader as reader
import serve_html_blueprint as preview


class MediaTableTests(unittest.TestCase):
    def test_atlas_labels_belong_to_their_picture_and_route_has_no_battle_art(self):
        pages = reader.refine(model.collect_reader(), model.read(model.ROOT, 'data/run/giyun_rules.json'))
        atlas = next(p for p in pages if p['id'] == 'reader-006')
        self.assertEqual(atlas.get('layout'), 'screen_gallery')
        pictures = [b for b in atlas['blocks'] if b['kind'] == 'image']
        self.assertEqual(len(pictures), 11)
        self.assertEqual(len({b['path'] for b in pictures}), 11)
        for name in ('library', 'settings'):
            menu = next(b for b in pictures if b['path'].endswith(f'/{name}.png'))
            self.assertEqual(menu['screen_context'], 'menu')
        combat = next(b for b in pictures if b['path'].endswith('/preparation.png'))
        self.assertEqual(combat['screen_context'], 'plan')
        self.assertIn('전투 준비',combat['screen_label'])
        self.assertEqual(combat['screen_kind'],'전투')
        for page in pages:
            if page['id'] in {'reader-009','reader-010','reader-011','reader-012','reader-013','reader-014'}:
                self.assertFalse(any(b.get('path','') == combat['path'] or 'preparation-hud' in b.get('path','') for b in page['blocks']))

    def test_event_effects_keep_all_choices_but_group_repeated_event_context(self):
        pages = reader.refine(model.collect_reader(), model.read(model.ROOT, 'data/run/giyun_rules.json'))
        table = next(p for p in pages if p['id'] == 'reader-011')['blocks'][0]
        self.assertEqual(table['kind'], 'event_catalog')
        self.assertEqual(len(table['events']), 10)
        self.assertEqual(len(set(e['id'] for e in table['events'])), 10)
        self.assertTrue(all(len(e['choices']) == 3 for e in table['events']))

    def test_similar_image_lists_and_comparisons_share_compact_layouts(self):
        pages = {p['id']: p for p in reader.refine(model.collect_reader(), model.read(model.ROOT, 'data/run/giyun_rules.json'))}
        expected = {'reader-005': 'image_runs', 'reader-020': 'image_table', 'reader-022': 'sequence_table', 'reader-030': 'portrait_gallery'}
        expected.update({f'reader-{i:03}': 'tactics_table' for i in range(97, 105)})
        for page_id, layout in expected.items():
            self.assertEqual(pages[page_id].get('layout'), layout, page_id)
            self.assertTrue(pages[page_id]['original_blocks'], 'Original explanation remains available')

    def test_shared_growth_and_card_specific_overlays_are_separate(self):
        manual = model.read(model.ROOT, 'data/cards/martial_manuals/mount_hua_plum_blossom_sword.json')
        tables = model.manual_readable_tables(manual)
        self.assertEqual(len(tables['shared_growth']), 10)
        self.assertNotIn('매화삼첩', str(tables['shared_growth']))
        rows = tables['card_rows']
        self.assertEqual([r['unlock_star'] for r in rows], [3, 7, 10])
        self.assertEqual(rows[0]['enhancement']['unlock_star'], 5)
        self.assertEqual(rows[1]['enhancement']['unlock_star'], 9)
        self.assertIsNone(rows[2]['enhancement'])
        self.assertIn('3회', str(rows[0]['enhancement']['effects']))

    def test_open_reading_session_survives_old_fixed_deadline_but_idle_expires(self):
        clock = [0]
        lease = preview.PreviewLease(120, clock=lambda: clock[0])
        clock[0] = 119; lease.touch()
        clock[0] = 121
        self.assertFalse(lease.expired())
        clock[0] = 240
        self.assertTrue(lease.expired())

    def test_session_health_is_token_scoped_and_reports_changed_publication(self):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder); out = root / 'output/blueprint'; out.mkdir(parents=True)
            index = out / 'index.html'; index.write_bytes(b'first')
            with patch.object(preview, 'ROOT', root):
                clock = [0]
                lease = preview.PreviewLease(120, clock=lambda: clock[0])
                server = preview.create_server({'output/blueprint/index.html': hashlib.sha256(b'first').hexdigest()}, 'token', lease=lease)
                worker = threading.Thread(target=server.serve_forever, daemon=True); worker.start()
                try:
                    for path, status, headers in [('/p/token/_session', 200, {}), ('/p/wrong/_session', 404, {}), ('/p/token/_session', 403, {'Origin': 'https://untrusted.example'})]:
                        clock[0] += 10
                        conn = http.client.HTTPConnection('127.0.0.1', server.server_port)
                        conn.request('GET', path, headers=headers); response = conn.getresponse()
                        self.assertEqual(response.status, status); response.read(); conn.close()
                        self.assertEqual(lease.last_activity, 10)
                    index.write_bytes(b'second')
                    conn = http.client.HTTPConnection('127.0.0.1', server.server_port)
                    conn.request('GET', '/p/token/_session'); response = conn.getresponse()
                    self.assertIn(b'SUPERSEDED', response.read()); conn.close()
                finally:
                    server.shutdown(); server.server_close(); worker.join()


if __name__ == '__main__': unittest.main()
