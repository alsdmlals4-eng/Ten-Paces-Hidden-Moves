import sys
import unittest
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'tools'))
from blueprint_layout import describe

class EffectDescriptionTest(unittest.TestCase):
    def test_attack_preserves_counter_semantics(self):
        for op in ['ATTACK','INDEPENDENT_ATTACK']:
            self.assertIn('반격',describe({'op':op,'power':5,'min_range':1,'max_range':2,'counter':True}))
            self.assertNotIn('반격',describe({'op':op,'power':5,'min_range':1,'max_range':2}))
