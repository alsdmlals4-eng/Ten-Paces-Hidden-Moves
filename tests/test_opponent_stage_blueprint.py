import importlib.util
from pathlib import Path
import unittest
ROOT = Path(__file__).resolve().parents[1]

class StageBlueprintTests(unittest.TestCase):
    def test_all_people_have_ten_monotone_stages(self):
        spec = importlib.util.spec_from_file_location('stage_plan', ROOT / 'tools/build_opponent_stage_blueprint.py')
        mod = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(mod)
        people = mod.build()
        self.assertEqual(len(people), 16)
        for person in people:
            rows = person['stages']
            self.assertEqual([r['stage'] for r in rows], list(range(10, 0, -1)))
            for high, low in zip(rows, rows[1:]):
                self.assertTrue(all(a >= b for a,b in zip(high['stats'], low['stats'])))
                self.assertGreaterEqual(high['mastery'], low['mastery'])
            for r in rows:
                self.assertEqual(sum(r['stats']), r['stat_total'])
                self.assertEqual(r['ultimate_unlocked'], r['mastery'] == 10)
            self.assertEqual(rows[0]['mastery'], 10)
            self.assertEqual(len({r['epithet'] for r in rows}), 10)
            for r in rows:
                self.assertEqual(r['resource_caps'], {'health':30,'stamina':5,'internal':4})
            self.assertTrue((ROOT / person['portrait']).is_file())

if __name__ == '__main__': unittest.main()
