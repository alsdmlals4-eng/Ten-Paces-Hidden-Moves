"""Publication boundaries: complete content, approval identity and safe local links."""
import json
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'tools'))
import html_blueprint as subject


class HtmlBlueprintTests(unittest.TestCase):
    def test_full_reader_preserves_all_112_sections(self):
        book = subject.collect_reader()
        self.assertEqual(len(book), 112)
        self.assertEqual(len({x['id'] for x in book}), 112)
        self.assertIn('아틀라스', book[0]['title'])
        text = json.dumps(book, ensure_ascii=False)
        for phrase in ['SWOT', '강호행로', '절초', '백무진', '실제']:
            self.assertIn(phrase, text)
        self.assertGreater(sum(len(p['blocks']) for p in book), 650)

    def test_archive_is_immutable(self):
        approval = json.loads((ROOT / 'docs/planning-data/current_user_planning_status.json').read_text(encoding='utf-8'))['blueprint_final_approval']
        self.assertEqual(subject.sha(ROOT / approval['artifact']), approval['artifact_sha256'])
        subject.collect_reader()
        self.assertEqual(subject.sha(ROOT / approval['artifact']), approval['artifact_sha256'])

    def test_approved_gallery_preserves_exact_47_inputs(self):
        gallery = subject.collect_assets(ROOT)
        approval = json.loads((ROOT / 'docs/planning-data/current_user_planning_status.json').read_text(encoding='utf-8'))['blueprint_final_approval']
        by_path = {x['path']: x for x in gallery}
        for item in approval['approved_visual_inputs']:
            self.assertEqual(by_path[item['path']]['sha256'], item['sha256'])
            self.assertEqual(by_path[item['path']]['approval'], 'USER_APPROVED')
        self.assertTrue(any('background' in x['path'] for x in gallery))

    def test_registered_derivative_keeps_exact_source_approval_and_relationship(self):
        rows=subject.collect_assets(ROOT)
        derived=next(a for a in rows if a['id']=='asset-blueprint_portrait_masked_baekmujin_v1')
        self.assertEqual(derived['approval'],'USER_APPROVED')
        self.assertIn('백무진',derived['name'])
        self.assertTrue(derived['related_assets'])

    def test_path_escape_and_external_urls_rejected(self):
        for rel in ['../outside.png', 'C:/private.png', '//host/secret', 'https://host/a', 'javascript:alert(1)']:
            with self.subTest(rel=rel), self.assertRaises(ValueError):
                subject.local_path(ROOT, rel)

    def test_missing_and_mismatched_approved_input_fail(self):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            with self.assertRaises(FileNotFoundError):
                subject.verified_file(root, 'missing.png', '0' * 64)
            (root / 'image.png').write_bytes(b'changed')
            with self.assertRaises(ValueError):
                subject.verified_file(root, 'image.png', '0' * 64)

    def test_candidate_consumer_descriptions_resolve_to_files(self):
        self.assertEqual(subject.consumer_paths('src/combat/combat_board_preview.gd::_show_feedback_vfx; MainTitleScreen in src/ui/main_title_screen.gd'), ['src/combat/combat_board_preview.gd','src/ui/main_title_screen.gd'])

    def test_duplicate_ids_rejected(self):
        with self.assertRaises(ValueError):
            subject.unique_ids([{'id': 'same'}, {'id': 'same'}])

    def test_implementation_permission_is_not_final_visual_approval(self):
        self.assertEqual(subject.approval_state({'approval': 'User authorized replacement and runtime implementation; new reaction final visual lock pending.'}), 'APPROVAL_UNVERIFIED')
        self.assertEqual(subject.approval_state({'approval': 'user explicit: 최종확정 (2026-08-31)'}), 'USER_APPROVED')

    def test_motion_profile_uses_real_sequence_not_entire_grid(self):
        code = 'static func attack_frame():\n    var sequence := [0, 1, 2, 0] if actor_role == "player" else [0, 1, 0]\n'
        self.assertEqual(subject.motion_sequence(code, 'player'), [0, 1, 2, 0])
        self.assertEqual(subject.motion_sequence('', 'player'), [])

    def test_approved_directory_is_not_silently_omitted(self):
        paths = {a['path'] for a in subject.collect_assets(ROOT)}
        expected = {p.relative_to(ROOT).as_posix() for p in (ROOT/'docs/visual-assets/approved').glob('*.png')}
        self.assertFalse(expected - paths)

    def test_stylesheet_delimiters_are_balanced(self):
        text = (ROOT/'tools/html_blueprint_ui/style.css').read_text(encoding='utf-8')
        for left, right in [('(', ')'), ('{', '}')]:
            self.assertEqual(text.count(left), text.count(right))

    def test_embedded_json_cannot_end_script(self):
        result = subject.script_json({'text': '</script><script>alert(1)</script>&\u2028'})
        self.assertNotIn('</script>', result)
        self.assertEqual(json.loads(result)['text'], '</script><script>alert(1)</script>&\u2028')

    def test_old_pr_is_not_active_and_candidate_is_not_main(self):
        pm = subject.collect_pm(ROOT)
        self.assertNotEqual(pm['current']['active_planning_pr'], '337')
        self.assertEqual(pm['github']['prs']['337']['state'], 'MERGED')
        self.assertEqual(pm['github']['prs']['342']['state'], 'OPEN')
        self.assertTrue(pm['github']['prs']['342']['isDraft'])


if __name__ == '__main__':
    unittest.main()
