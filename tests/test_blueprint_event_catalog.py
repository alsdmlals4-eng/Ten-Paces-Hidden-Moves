import copy
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tools'))
import html_blueprint as model
from html_blueprint_reader import refine


class EventCatalogTests(unittest.TestCase):
    def test_event_blocks_preserve_every_choice_without_guaranteeing_giyun(self):
        source = model.read(model.ROOT, 'data/run/giyun_rules.json')
        original = model.collect_reader()
        pages = refine(copy.deepcopy(original), source)
        page = next(p for p in pages if p['id'] == 'reader-011')
        catalog = next((b for b in page['blocks'] if b['kind'] == 'event_catalog'), None)
        self.assertIsNotNone(catalog, 'Each event needs its own titled situation and three choices')
        self.assertEqual([e['id'] for e in catalog['events']], [e['id'] for e in source['events']])
        ordinary = 0
        for view, event in zip(catalog['events'], source['events']):
            self.assertEqual(view['text'], event['text'])
            self.assertEqual(len(view['choices']), 3)
            self.assertEqual([c['id'] for c in view['choices']], [c['id'] for c in event['choices']])
            self.assertEqual(view['choices'][2]['check_text'], '안전 선택 · 판정 없음')
            if not any(c.get('rare_bonus') for c in event['choices']):
                ordinary += 1
                self.assertTrue(all(c['rare_text'] == '기연 없음' for c in view['choices']))
            else:
                self.assertIn('성공 후', view['choices'][0]['rare_text'])
                self.assertIn('10%', view['choices'][0]['rare_text'])
        self.assertGreater(ordinary, 0)
        self.assertEqual(page['original_blocks'], next(p for p in original if p['id'] == 'reader-011')['blocks'])

    def test_readable_rows_escape_at_render_and_keep_success_failure_separate(self):
        from html_blueprint_reader import event_catalog
        source = model.read(model.ROOT, 'data/run/giyun_rules.json')
        source['events'][0]['title'] = '<img onerror=alert(1)>'
        block = event_catalog(source)
        self.assertEqual(block['events'][0]['title'], '<img onerror=alert(1)>')
        choice = block['events'][0]['choices'][0]
        self.assertIn('수련 +2', choice['success_text'])
        self.assertIn('체력 -2', choice['failure_text'])
        self.assertIn('신법', choice['check_text'])


if __name__ == '__main__': unittest.main()
