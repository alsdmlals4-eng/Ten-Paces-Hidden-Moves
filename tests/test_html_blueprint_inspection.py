import unittest
import sys
import tempfile
import json
import hashlib
from unittest.mock import patch
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tools'))
import html_blueprint_experience as experience


class InspectionTests(unittest.TestCase):
    def test_starter_still_has_verified_capture_evidence(self):
        import html_blueprint as model
        context=experience.build(model.collect_reader())['contexts']['starter']
        still=context.get('still_capture')
        self.assertIsNotNone(still, 'Actual setup screenshot must not report missing runtime evidence')
        self.assertEqual(still['path'],context['preview']['path'])
        self.assertEqual(still['sha256'],model.sha(model.ROOT/still['path']))
        self.assertEqual(still['screen'],'SETUP')

    def test_stale_source_keeps_history_but_corrupt_video_is_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory)
            for name in ['source.gd','movie.mp4','poster.jpg']:(root/name).write_bytes(b'original')
            digest=hashlib.sha256(b'original').hexdigest()
            manifest={'source_hashes':{},'source_text_hashes':{'source.gd':digest},'clips':[{'id':'clip','path':'movie.mp4','poster':'poster.jpg','path_sha256':digest,'poster_sha256':digest}]}
            (root/'manifest.json').write_text(json.dumps(manifest),encoding='utf-8')
            with patch.object(experience,'ROOT',root),patch.object(experience,'MOTION_MANIFEST','manifest.json'):
                (root/'source.gd').write_text('changed',encoding='utf-8')
                self.assertEqual(experience.load_clips()[0]['freshness']['status'],'STALE')
                (root/'movie.mp4').write_bytes(b'corrupt')
                with self.assertRaisesRegex(ValueError,'Hash mismatch'):experience.load_clips()

    def test_candidate_work_match_requires_candidate_scope_and_revision(self):
        import html_blueprint_inspection as inspection
        self.assertTrue(callable(getattr(inspection, 'related_work_items', None)), 'Candidate work matching missing')
        tasks=[{'scope':'PR342_CANDIDATE','revision':'current','actual_consumers':['src/a.gd']},
               {'scope':'PR342_CANDIDATE','revision':'old','actual_consumers':['src/a.gd']},
               {'actual_consumers':['src/a.gd']}]
        self.assertEqual(inspection.related_work_items(tasks,['src/a.gd'],'PR342_CANDIDATE','current'),[tasks[0]])

    def test_capture_dependency_closure_includes_global_class_parent(self):
        from encode_blueprint_motion import capture_dependencies
        from html_blueprint import ROOT
        available={p.relative_to(ROOT).as_posix() for folder in ['src','data','scenes','assets'] for p in (ROOT/folder).rglob('*') if p.is_file()}
        deps=capture_dependencies(available)
        self.assertIn('src/ui/action_timing_panel_auto.gd',deps)
        self.assertIn('src/ui/action_timing_panel.gd',deps)

    def test_selected_card_art_links_use_selection_names_not_runtime_ids(self):
        import html_blueprint_inspection as inspection
        self.assertTrue(callable(getattr(inspection, 'card_art_paths', None)), 'Missing selected art mapping')
        selection={'directory':'output/art','manuals':{'m':['plum-star3-v2.png','plum-star7.png']}}
        self.assertEqual(inspection.card_art_paths(selection, 'm', {'unlock_star':3}), ['output/art/plum-star3-v2.png'])

    def test_phase_timeline_uses_observed_time_and_event_identity(self):
        self.assertTrue(callable(getattr(experience, 'observed_timeline', None)), 'Missing observed phase timeline')
        frames = [{'ms': 100, 'phase': 'idle', 'event_index': -1},
                  {'ms': 200, 'phase': 'windup', 'event_index': 0},
                  {'ms': 350, 'phase': 'impact', 'event_index': 0},
                  {'ms': 600, 'phase': 'impact', 'event_index': 1}]
        phases = experience.observed_timeline(frames)
        self.assertEqual([p['start'] for p in phases], [0, .1, .25, .5])
        self.assertEqual(phases[-1]['event_index'], 1)
        self.assertEqual(experience.observed_timeline([{'ms': 20}]), [])

    def test_source_drift_is_scoped_and_missing_dependency_is_stale(self):
        self.assertTrue(callable(getattr(experience, 'clip_freshness', None)), 'Missing dependency freshness')
        manifest = {'source_hashes': {'a.png': 'a', 'b.png': 'b'}, 'source_text_hashes': {}}
        clip = {'dependencies': ['a.png']}
        self.assertEqual(experience.clip_freshness(clip, manifest, {'a.png': 'a', 'b.png': 'changed'})['status'], 'MATCH')
        self.assertEqual(experience.clip_freshness(clip, manifest, {})['status'], 'STALE')
        self.assertEqual(experience.clip_freshness({}, manifest, {'a.png': 'a', 'b.png': 'changed'})['status'], 'STALE')
        manifest['dynamic_roots']=['data/']
        self.assertEqual(experience.clip_freshness(clip, manifest, {'a.png':'a','data/new.json':'new'})['status'],'STALE')


if __name__ == '__main__': unittest.main()
