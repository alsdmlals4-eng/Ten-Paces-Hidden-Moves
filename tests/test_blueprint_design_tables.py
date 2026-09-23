import json
from pathlib import Path
import sys
import unittest
ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT/'tools'))
import html_blueprint as model


class DesignTableTests(unittest.TestCase):
    def test_growth_table_has_conditional_overlay_and_distinct_main_status(self):
        fn = getattr(model, 'manual_readable_tables', None)
        self.assertIsNotNone(fn, 'Human readers need source-derived growth and technique tables')
        manual = model.read(ROOT, 'data/cards/martial_manuals/mount_hua_plum_blossom_sword.json')
        tables = fn(manual)
        self.assertEqual(len(tables['growth']), 10)
        self.assertEqual(len(tables['techniques']), 3)
        fifth = tables['growth'][4]
        self.assertIn('낙매유향', str(fifth))
        self.assertIn('3', str(fifth))
        self.assertIn('조건', str(fifth))
        self.assertIn('미연결', str(tables['growth'][3]))
        self.assertEqual(tables['techniques'][0][2], '2수')

    def test_design_lens_is_project_definition_and_not_human_pass(self):
        text = (ROOT/'docs/01_GAME_DESIGN.md').read_text(encoding='utf-8')
        self.assertIn('Dopamine Driven Development', text)
        self.assertIn('HUMAN_NOT_RUN', text)
        self.assertIn('기연', text)


if __name__ == '__main__': unittest.main()
