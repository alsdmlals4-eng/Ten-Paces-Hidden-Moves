import hashlib,json,unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
FRAME_BACKGROUND_IDS = {
    'ink_frame_main_background_20260925',
    'ink_frame_prologue_background_20260925',
    'ink_frame_preparation_background_20260925',
}
def read(p): return json.loads((ROOT/p).read_text(encoding='utf-8-sig'))
class ApprovedBlueprintArtTests(unittest.TestCase):
    def test_exact_approved_set_bytes_and_mapping(self):
        approval=read('docs/planning-data/current_user_planning_status.json')['blueprint_final_approval']
        manifest=read('assets/blueprint/APPROVED_ART_MANIFEST.json')
        records=manifest['assets']
        self.assertEqual(len(records),47)
        self.assertEqual({a.get('prior_source_asset',a['source_asset']):a.get('prior_source_png_sha256',a['source_png_sha256']) for a in records},{a['path']:a['sha256'] for a in approval['approved_visual_inputs']})
        self.assertEqual(len({a['path'] for a in records}),47)
        for asset in records:
            self.assertEqual(hashlib.sha256((ROOT/asset['path'].removeprefix('res://')).read_bytes()).hexdigest(),asset['source_png_sha256'])
            self.assertEqual(hashlib.sha256((ROOT/asset['source_asset']).read_bytes()).hexdigest(),asset['source_png_sha256'])
            self.assertEqual(asset['status'],'IMPLEMENTATION_AUTHORIZED__CANON_REGISTERED' if asset.get('prior_source_asset') else 'USER_APPROVED__CANON_REGISTERED')
        people=read('docs/blueprint/OPPONENT_PRESENTATION.json')['people']
        self.assertEqual(set(manifest['portraits']),set(people))
        by_path={a['path']:a for a in records}
        for candidate,person in people.items():
            source='opponent-baekmujin-v1.png' if candidate=='masked_baekmujin' else 'opponent-'+person['art']+'.png'
            record=by_path[manifest['portraits'][candidate]]
            self.assertEqual(Path(record.get('prior_source_asset',record['source_asset'])).name,source)
        for manual,files in read('docs/blueprint/ART_SELECTION.json')['manuals'].items():
            for star,file in zip(('3','7','10'),files):
                self.assertEqual(Path(by_path[manifest['manuals'][manual][star]]['source_asset']).name,file)
        clash=by_path[manifest['clash_explanation']]
        self.assertEqual(clash['usage'],'static_clash_explanation_not_animation')
    def test_existing_manifest_records_preserved(self):
        manifest=read('assets/blueprint/APPROVED_ART_MANIFEST.json')
        central=read('assets/ASSET_MANIFEST.json')['assets']
        new_ids={a['id'] for a in manifest['assets']}
        ink_names=['background','hero_clash','ink_brush']+[f'{actor}_{i}' for actor in ('player','enemy') for i in range(9)]
        ink_ids={f'ink_wuxia_{name}_20260924' for name in ink_names}
        self.assertEqual({a['id'] for a in central if a['id'] in ink_ids},ink_ids)
        refresh_ids=set(read('docs/visual-assets/candidates/TEN-INK-SCREENS-20260925/replacement-map.json')['added_asset_ids'])
        self.assertEqual({a['id'] for a in central if a['id'] in refresh_ids},refresh_ids)
        reference_ids={f'reference_preparation_{name}_20260925' for name in ('reference_painting','standing_characters','reference_details')}
        self.assertEqual({a['id'] for a in central if a['id'] in reference_ids},reference_ids)
        self.assertEqual({a['id'] for a in central if a['id'] in FRAME_BACKGROUND_IDS},FRAME_BACKGROUND_IDS)
        old=[a for a in central if a['id'] not in new_ids | ink_ids | refresh_ids | reference_ids | FRAME_BACKGROUND_IDS]
        digest=hashlib.sha256(json.dumps(old,ensure_ascii=False,sort_keys=True,separators=(',',':')).encode()).hexdigest()
        self.assertEqual(digest,manifest['preserved_existing_records_sha256'])
        self.assertEqual(len(old),manifest['preserved_existing_record_count'])
        self.assertEqual({a['id'] for a in central if a['id'] in new_ids},new_ids)
        self.assertEqual([a for a in central if a['id'] in new_ids],manifest['assets'])
    def test_exact_frame_background_additions_match_provenance_and_bytes(self):
        central = read('assets/ASSET_MANIFEST.json')['assets']
        records = {a['id']: a for a in central if a['id'] in FRAME_BACKGROUND_IDS}
        owner = 'assets/ui/ink_frame/provenance.json'
        provenance = read(owner)['assets']
        self.assertEqual(len(records), 3)
        self.assertEqual({f"ink_frame_{a['id']}_20260925" for a in provenance}, FRAME_BACKGROUND_IDS)
        for layer in provenance:
            record = records[f"ink_frame_{layer['id']}_20260925"]
            self.assertEqual(record['provenance'], owner)
            self.assertEqual(record['path'].removeprefix('res://'), layer['path'])
            self.assertEqual(record['source_png_sha256'], layer['sha256'])
            self.assertEqual(hashlib.sha256((ROOT / layer['path']).read_bytes()).hexdigest(), layer['sha256'])
            self.assertEqual(record['dimensions'], f"{layer['width']}x{layer['height']}")
            self.assertEqual(record['prompt'], layer['prompts'][-1]['text'])
            self.assertEqual(record['source_asset'], f"docs/blueprint/evidence/frame-approved/{layer['id'].removesuffix('_background')}.png")
            self.assertEqual(hashlib.sha256((ROOT / record['source_asset']).read_bytes()).hexdigest(), layer['source']['sha256'])
if __name__=='__main__': unittest.main()
