import unittest, sys, json, copy
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'tools'))

class ReaderCleanupTests(unittest.TestCase):
    def test_route_order_tables_sources_and_preserved_ids(self):
        import html_blueprint as model
        from html_blueprint_reader import refine
        original=model.collect_reader(); pages=copy.deepcopy(original)
        refine(pages,model.read(model.ROOT,'data/run/giyun_rules.json'))
        by_id={p['id']:p for p in pages};ids=[p['id'] for p in pages]
        self.assertEqual(set(ids),{p['id'] for p in original})
        self.assertLess(ids.index('reader-010'),ids.index('reader-009'))
        self.assertEqual(by_id['reader-010']['blocks'][0]['kind'],'image')
        rows=by_id['reader-009']['blocks'][0]['rows']
        self.assertEqual(len(rows),4)
        self.assertEqual(len(by_id['reader-011']['blocks'][0]['rows']),18)
        self.assertTrue(all(b['kind']!='image' for b in by_id['reader-013']['blocks']))
        self.assertNotIn('planning-1440',json.dumps(by_id['reader-015']))
        self.assertIn('939bf00',json.dumps(by_id['reader-015']))
        for p in pages:
            self.assertEqual(p['original_blocks'],next(x for x in original if x['id']==p['id'])['blocks'])
    def test_compact_tables_preserve_all_panel_and_flow_text(self):
        from html_blueprint_reader import compact
        source=[{'kind':'panel','title':'A','text':'one'},{'kind':'panel','title':'B','text':'two'},
                {'kind':'flow','items':[['first','begin'],['last','end']]}]
        result=compact(source)
        self.assertEqual([b['kind'] for b in result],['table','table'])
        self.assertEqual(result[0]['rows'],[['A','one'],['B','two']])
        self.assertEqual(result[1]['rows'],source[-1]['items'])

    def test_six_reader_groups_cover_every_page_once(self):
        from html_blueprint_reader import reader_groups
        import html_blueprint as model
        pages=model.collect_reader();groups=reader_groups(pages)
        self.assertEqual(len(groups),6)
        all_ids=[id for g in groups for id in g['pages']]
        self.assertEqual(len(all_ids),len(set(all_ids)))
        self.assertEqual(set(all_ids),{p['id'] for p in pages})
        self.assertIn('reader-015',groups[2]['pages'])
        self.assertIn('reader-065',groups[3]['pages'])
        self.assertIn('reader-033',groups[4]['pages'])
