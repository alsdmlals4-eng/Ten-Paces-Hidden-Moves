import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tools'))
import html_blueprint_numbers as numbers


class ImageNumbersTests(unittest.TestCase):
    def test_courtyard_usage_distinguishes_background_overlay_and_storyboard(self):
        for basename, expected in [
            ('FRONTAL_COURTYARD_DUEL_BACKGROUND_02_v1.png', '비무 안뜰 배경'),
            ('FRONTAL_COURTYARD_BANNER_OVERLAY_01_v1.png', '비무 안뜰 전경 장식'),
            ('FRONTAL_COURTYARD_DUEL_SEQUENCE_BOARD_v1.png', '비무 연출 순서 설명')]:
            self.assertEqual(numbers.usage_label({'path': 'docs/approved/' + basename,
                'group': {'role': '설명 자료'}}), expected)

    def test_number_registry_is_not_usage_evidence(self):
        import html_blueprint_audit as audit
        import tempfile
        from unittest.mock import patch
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            (root / numbers.REGISTRY).parent.mkdir(parents=True)
            (root / numbers.REGISTRY).write_text('{"unused.png": 1}', encoding='utf-8')
            asset = {'id': 'a', 'path': 'unused.png', 'scope': 'MAIN_SOURCE',
                     'sha256': 'x', 'details': {}, 'consumers': [], 'approval': 'APPROVAL_UNVERIFIED'}
            with patch.object(audit, 'tracked', return_value=[numbers.REGISTRY]):
                audit.build(root, [asset])
            self.assertEqual(asset['audit']['document_references'], [])

    def test_numbers_survive_reordering_removal_and_replacement(self):
        registry = {}
        self.assertEqual(numbers.allocate(registry, ['a', 'b', 'a']), {'a': 1, 'b': 2})
        self.assertEqual(numbers.allocate(registry, ['b', 'c']), {'b': 2, 'c': 3})
        self.assertEqual(numbers.allocate(registry, ['a', 'c', 'b'])['a'], 1)
        self.assertEqual(registry, {'a': 1, 'b': 2, 'c': 3})

    def test_corrupt_duplicate_numbers_are_rejected(self):
        with self.assertRaises(ValueError):
            numbers.allocate({'a': 1, 'b': 1}, ['c'])

    def test_candidates_do_not_share_main_number(self):
        self.assertNotEqual(numbers.asset_key({'scope':'MAIN_SOURCE','path':'x.png','id':'a'}),
                            numbers.asset_key({'scope':'PR342_CANDIDATE','path':'x.png','id':'b'}))


if __name__ == '__main__':
    unittest.main()
