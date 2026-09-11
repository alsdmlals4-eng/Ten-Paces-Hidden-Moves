import hashlib,json,unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def read(p): return json.loads((ROOT/p).read_text(encoding='utf-8-sig'))
class ApprovedBlueprintArtTests(unittest.TestCase):
    def test_exact_approved_set_bytes_and_mapping(self):
        approval=read('docs/planning-data/current_user_planning_status.json')['blueprint_final_approval']
        manifest=read('assets/blueprint/APPROVED_ART_MANIFEST.json')
        records=manifest['assets']
        self.assertEqual(len(records),47)
        self.assertEqual({a['source_asset']:a['source_png_sha256'] for a in records},{a['path']:a['sha256'] for a in approval['approved_visual_inputs']})
        self.assertEqual(len({a['path'] for a in records}),47)
        for asset in records:
            self.assertEqual(hashlib.sha256((ROOT/asset['path'].removeprefix('res://')).read_bytes()).hexdigest(),asset['source_png_sha256'])
            self.assertEqual(hashlib.sha256((ROOT/asset['source_asset']).read_bytes()).hexdigest(),asset['source_png_sha256'])
            self.assertEqual(asset['status'],'USER_APPROVED__CANON_REGISTERED')
        people=read('docs/blueprint/OPPONENT_PRESENTATION.json')['people']
        self.assertEqual(set(manifest['portraits']),set(people))
        by_path={a['path']:a for a in records}
        for candidate,person in people.items():
            source='opponent-baekmujin-v1.png' if candidate=='masked_baekmujin' else 'opponent-'+person['art']+'.png'
            self.assertEqual(Path(by_path[manifest['portraits'][candidate]]['source_asset']).name,source)
        for manual,files in read('docs/blueprint/ART_SELECTION.json')['manuals'].items():
            for star,file in zip(('3','7','10'),files):
                self.assertEqual(Path(by_path[manifest['manuals'][manual][star]]['source_asset']).name,file)
        clash=by_path[manifest['clash_explanation']]
        self.assertEqual(clash['usage'],'static_clash_explanation_not_animation')
    def test_existing_manifest_records_preserved(self):
        manifest=read('assets/blueprint/APPROVED_ART_MANIFEST.json')
        central=read('assets/ASSET_MANIFEST.json')['assets']
        new_ids={a['id'] for a in manifest['assets']}
        continuation_ids = {
            'clash_sparks_ink_gold_v2', 'player_sword_sequence_v1',
            'enemy_sword_sequence_v1', 'player_reactions_candidate_v2',
            'enemy_reactions_candidate_v2',
        }
        self.assertEqual({a['id'] for a in central if a['id'] in continuation_ids}, continuation_ids)
        self.assertEqual(len({a['id'] for a in central}), len(central))
        # The frozen pre-Blueprint receipt still covers exactly its original
        # records; later motion additions must not alter that receipt or those records.
        old=[a for a in central if a['id'] not in new_ids | continuation_ids]
        digest=hashlib.sha256(json.dumps(old,ensure_ascii=False,sort_keys=True,separators=(',',':')).encode()).hexdigest()
        self.assertEqual(digest,manifest['preserved_existing_records_sha256'])
        self.assertEqual(len(old),manifest['preserved_existing_record_count'])
        self.assertEqual({a['id'] for a in central if a['id'] in new_ids},new_ids)
        self.assertEqual([a for a in central if a['id'] in new_ids],manifest['assets'])
        for asset in central:
            if asset['id'] in continuation_ids:
                self.assertEqual(hashlib.sha256((ROOT / asset['path'].removeprefix('res://')).read_bytes()).hexdigest(), asset['source_png_sha256'])
                self.assertTrue(asset['approval'])
if __name__=='__main__': unittest.main()
