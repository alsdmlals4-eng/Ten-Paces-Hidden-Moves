import importlib.util
from pathlib import Path
import unittest
import ast
import re

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('stage_plan', ROOT/'tools/build_opponent_stage_blueprint.py')
plan = importlib.util.module_from_spec(spec)
spec.loader.exec_module(plan)

class TrainingBudgetTests(unittest.TestCase):
    def test_cost_table_matches_actual_progression(self):
        text=(ROOT/'src/run/vertical_slice_progression_state.gd').read_text(encoding='utf-8')
        match=re.search(r'const NEXT_STAR_COSTS\s*:?=\s*(\{[^}]+\})',text,re.S)
        self.assertIsNotNone(match)
        actual=ast.literal_eval(match.group(1))
        planned=plan.read('docs/blueprint/OPPONENT_BUDGET.json')['next_star_costs']
        self.assertEqual({str(k):v for k,v in actual.items()}, planned)

    def test_actual_nonlinear_cost(self):
        self.assertEqual(plan.training_cost([10, 5, 3]), 43)
        self.assertEqual(plan.training_cost([10, 7, 5]), 57)

    def test_every_stage_has_character_specific_distinct_resolved_manuals(self):
        people = plan.build()
        self.assertEqual({len(p['stages'][0]['owned_manuals']) for p in people}, {2, 3, 4, 5})
        for person in people:
            previous = None
            for row in reversed(person['stages']):
                owned = row['owned_manuals']
                self.assertGreaterEqual(len(owned), 2)
                self.assertEqual(len({m['id'] for m in owned}), len(owned))
                self.assertEqual(row['training_spent'], plan.training_cost([m['mastery'] for m in owned]))
                self.assertLessEqual(row['training_spent'], row['training_budget'])
                self.assertTrue(any(m['techniques'] for m in owned))
                if previous:
                    self.assertTrue(all(a['mastery'] >= b['mastery'] for a,b in zip(owned,previous)))
                previous = owned
            self.assertTrue(person['tactics']['weakness'])
            self.assertTrue(person['tactics']['counterplay'])
            self.assertEqual(person['acquisition_count'], len(previous))

    def test_diversity_is_not_equal_power_or_forced_ultimate(self):
        people = plan.build()
        self.assertGreater(len({tuple(m['mastery'] for m in p['stages'][0]['owned_manuals']) for p in people}), 6)
        self.assertTrue(any(not p['stages'][0]['ultimate_unlocked'] for p in people))
        self.assertEqual(plan.training_cost([10, 10]), 76)
        self.assertEqual(plan.training_cost([5, 5, 5, 5, 5]), 25)

if __name__ == '__main__': unittest.main()
