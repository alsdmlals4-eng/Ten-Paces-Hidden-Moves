import copy
import sys
import unittest
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'tools'))
import html_blueprint_diagrams as subject


class DiagramTests(unittest.TestCase):
    def test_maps_have_verified_sources_and_stable_relationships(self):
        maps=subject.build()
        self.assertEqual({m['kind'] for m in maps},{'workflow','dataflow','sequence'})
        for diagram in maps:
            subject.validate(diagram)
            self.assertTrue(all(n['sources'] for n in diagram['nodes']))

    def test_bundle_continuation_is_not_battle_termination(self):
        game=subject.build()[0]
        transitions={(e['from'],e['to']):e['label'] for e in game['edges']}
        self.assertIn(('resolve','plan'),transitions)
        self.assertIn('종료',transitions[('resolve','result')])

    def test_unknown_endpoint_fails(self):
        diagram=copy.deepcopy(subject.build()[0]);diagram['edges'][0]['to']='invented'
        with self.assertRaises(ValueError):subject.validate(diagram)

    def test_overlap_and_empty_relationship_label_fail(self):
        diagram=copy.deepcopy(subject.build()[0]);diagram['nodes'][1]['x']=diagram['nodes'][0]['x'];diagram['nodes'][1]['y']=diagram['nodes'][0]['y']
        with self.assertRaises(ValueError):subject.validate(diagram)
        diagram=copy.deepcopy(subject.build()[0]);diagram['edges'][0]['label']=''
        with self.assertRaises(ValueError):subject.validate(diagram)


if __name__=='__main__':unittest.main()
