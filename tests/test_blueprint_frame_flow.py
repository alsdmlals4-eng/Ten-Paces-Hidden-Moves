"""Current frame flow must not promote layout references or old captures to runtime."""
import copy
import json
from pathlib import Path
import re
import shutil
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'tools'))
import html_blueprint as model
from html_blueprint_experience import build_contexts
from html_blueprint_reader import refine


class FrameBlueprintTests(unittest.TestCase):
    def test_intro_and_review_are_distinct_routes_in_current_flow(self):
        contexts = build_contexts()
        expected = [('menu', 'prologue'), ('prologue', 'starter'),
                    ('starter', 'tutorial'), ('tutorial', 'first_route'),
                    ('first_route', 'brief'), ('brief', 'plan'),
                    ('plan', 'resolve'), ('resolve', 'result'), ('result', 'review')]
        for origin, destination in expected:
            self.assertIn(destination, contexts[origin]['next'])
        self.assertIn('plan', contexts['resolve']['next'])
        self.assertNotEqual(contexts['result']['title'], contexts['review']['title'])

    def test_current_reader_keeps_ids_and_history_without_old_bundle_rules(self):
        original = model.collect_reader()
        pages = refine(copy.deepcopy(original), model.read(ROOT, 'data/run/giyun_rules.json'))
        self.assertEqual({p['id'] for p in original}, {p['id'] for p in pages})
        for page in pages:
            self.assertEqual(page['original_blocks'], next(p for p in original if p['id'] == page['id'])['blocks'])
            current = json.dumps({k: v for k, v in page.items() if k not in {'original_blocks', 'approved_page'}}, ensure_ascii=False)
            self.assertIsNone(re.search(r'3/3/4|3·3·4|3수\s*[→/]\s*해결|3수\s*/\s*3수', current), page['id'])
        self.assertIn('10초', json.dumps(pages, ensure_ascii=False))

    def test_capture_requires_valid_receipt_and_is_reported_per_screen(self):
        from html_blueprint_frame import screen_media
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            before = screen_media(root)
            self.assertTrue(all(row['runtime_status'] == 'NOT_RUN' for row in before.values()))
            self.assertTrue(all(not row.get('still_capture') for row in before.values()))
            destination = root / 'docs/blueprint/evidence/frame-runtime-20260925/main.png'
            destination.parent.mkdir(parents=True)
            shutil.copyfile(ROOT / 'assets/ui/ink_frame/main_background.png', destination)
            shutil.copyfile(ROOT / 'assets/ui/ink_frame/main_background.png', destination.parent / 'preparation.png')
            pending = screen_media(root)
            self.assertEqual(pending['menu']['runtime_status'], 'CAPTURE_PENDING_VALIDATION')
            self.assertFalse(pending['menu'].get('still_capture'))
            receipt = dict(status='PASS', valid_shots=[dict(key='main',
                path='docs/blueprint/evidence/frame-runtime-20260925/main.png', sha256=model.sha(destination))])
            (destination.parent / 'capture-receipt.json').write_text(json.dumps(receipt), encoding='utf-8')
            after = screen_media(root)
            self.assertEqual(after['menu']['runtime_status'], 'VERIFIED_CAPTURE')
            self.assertEqual(after['menu']['still_capture']['sha256'], model.sha(destination))
            self.assertFalse(after['prologue'].get('still_capture'))
            self.assertFalse(after['plan'].get('still_capture'), 'An unlisted first-pass image must stay unpublished even with a PASS receipt')
            receipt['valid_shots'][0]['sha256'] = '0' * 64
            (destination.parent / 'capture-receipt.json').write_text(json.dumps(receipt), encoding='utf-8')
            with self.assertRaises(ValueError):
                screen_media(root)

    def test_timing_and_observation_text_follow_structured_source(self):
        from html_blueprint_frame import rules_summary
        config = model.read(ROOT, 'data/combat/frame_timeline.json')
        summary = rules_summary(ROOT)
        self.assertEqual(summary['window_seconds'], config['tick_seconds'] * config['window_ticks'])
        self.assertEqual(summary['observation_seconds'], [3, 6, 9])
        self.assertEqual(summary['phases'], ['선딜', '발동', '후딜'])
        self.assertIn('완료', summary['observation_origin'])

    def test_current_movie_requires_pass_hash_and_valid_duration(self):
        from html_blueprint_frame import validated_walkthrough, RUNTIME
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            video = root / RUNTIME / 'walkthrough.mp4'
            video.parent.mkdir(parents=True)
            video.write_bytes(b'fixture-video-content')
            self.assertIsNone(validated_walkthrough(root), 'A movie without a receipt must stay unpublished')
            receipt = dict(status='PENDING', path=RUNTIME + '/walkthrough.mp4',
                           sha256=model.sha(video), duration_seconds=42.5)
            owner = video.parent / 'clip-receipt.json'
            owner.write_text(json.dumps(receipt), encoding='utf-8')
            self.assertIsNone(validated_walkthrough(root))
            receipt['status'] = 'PASS'
            owner.write_text(json.dumps(receipt), encoding='utf-8')
            clip = validated_walkthrough(root)
            self.assertFalse(clip['historical'])
            self.assertEqual(clip['path_sha256'], model.sha(video))
            self.assertEqual(clip['duration_seconds'], 42.5)
            self.assertEqual(clip['manifest'], RUNTIME + '/clip-receipt.json')
            for invalid in [dict(sha256='0' * 64), dict(duration_seconds=0),
                            dict(duration_seconds=float('inf')), dict(path='../walkthrough.mp4')]:
                owner.write_text(json.dumps(dict(receipt, **invalid)), encoding='utf-8')
                with self.assertRaises(ValueError):
                    validated_walkthrough(root)

    def test_separate_win_receipt_enables_win_and_later_route_without_relabeling_loss(self):
        from html_blueprint_frame import screen_media, RUNTIME, CAPTURE_RECEIPT, WIN_CAPTURE_RECEIPT
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / RUNTIME).mkdir(parents=True)
            for key in ['result', 'review', 'victory', 'victory-review', 'journey', 'later-event']:
                shutil.copyfile(ROOT / 'assets/ui/ink_frame/main_background.png', root / RUNTIME / (key + '.png'))
            def receipt(keys):
                return dict(status='PASS', shots=[dict(key=key, path=f'{RUNTIME}/{key}.png',
                    sha256=model.sha(root / RUNTIME / (key + '.png'))) for key in keys])
            (root / CAPTURE_RECEIPT).write_text(json.dumps(receipt(['result', 'review'])), encoding='utf-8')
            pending = screen_media(root)
            self.assertTrue(pending['result']['preview']['path'].endswith('/result.png'))
            self.assertFalse(pending['route'].get('still_capture'))
            win = receipt(['victory', 'victory-review', 'journey', 'later-event'])
            (root / WIN_CAPTURE_RECEIPT).write_text(json.dumps(win), encoding='utf-8')
            media = screen_media(root)
            self.assertTrue(media['result']['preview']['path'].endswith('/victory.png'))
            self.assertTrue(media['review']['preview']['path'].endswith('/victory-review.png'))
            self.assertEqual(media['route']['still_capture']['source'], WIN_CAPTURE_RECEIPT)
            self.assertEqual(media['result']['additional_captures'][0]['source'], CAPTURE_RECEIPT)
            self.assertTrue(media['result']['additional_captures'][0]['path'].endswith('/result.png'))
            self.assertTrue(media['route']['additional_captures'][0]['path'].endswith('/later-event.png'))
            win['shots'][0]['sha256'] = '0' * 64
            (root / WIN_CAPTURE_RECEIPT).write_text(json.dumps(win), encoding='utf-8')
            with self.assertRaises(ValueError):
                screen_media(root)

    def test_layout_references_and_background_layers_have_separate_evidence(self):
        from html_blueprint_frame import frame_assets
        rows = frame_assets(ROOT)
        self.assertEqual(sum(r['kind'] == 'APPROVED_LAYOUT_REFERENCE' for r in rows), 7)
        self.assertEqual(sum(r['kind'] == 'BACKGROUND_LAYER' for r in rows), 3)
        for row in rows:
            self.assertEqual(model.sha(ROOT / row['path']), row['sha256'])
            self.assertNotEqual(row['kind'], 'RUNTIME_CAPTURE')


if __name__ == '__main__':
    unittest.main()
