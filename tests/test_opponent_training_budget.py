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

    def test_every_stage_has_three_distinct_resolved_manuals(self):
        for person in plan.build():
            previous = None
            for row in reversed(person['stages']):
                owned = row['owned_manuals']
                self.assertEqual(len(owned), 3)
                self.assertEqual(len({m['id'] for m in owned}), 3)
                self.assertEqual(row['training_spent'], plan.training_cost([m['mastery'] for m in owned]))
                self.assertLessEqual(row['training_spent'], row['training_budget'])
                self.assertTrue(any(m['techniques'] for m in owned))
                if previous:
                    self.assertTrue(all(a['mastery'] >= b['mastery'] for a,b in zip(owned,previous)))
                previous = owned
            self.assertEqual([m['mastery'] for m in person['stages'][0]['owned_manuals']], [10,7,5])

if __name__ == '__main__': unittest.main()
