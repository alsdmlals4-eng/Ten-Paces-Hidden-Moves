import unittest
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tools'))
from html_blueprint_experience import build_contexts, load_clips
from html_blueprint_diagrams import build

class ExperienceTests(unittest.TestCase):
    def test_every_game_node_has_real_content_and_a_followup(self):
        contexts = build_contexts()
        self.assertEqual(set(contexts), {n['id'] for n in build()[0]['nodes']})
        self.assertIn('reader-006', contexts['menu']['pages'])
        self.assertTrue(contexts['starter']['manuals'])
        self.assertTrue(contexts['brief']['constraints'])
        self.assertTrue(contexts['plan']['actions'])
        self.assertTrue(contexts['resolve']['clips'])
        for item in contexts.values():
            self.assertTrue(item['pages'])
            self.assertTrue(item['next'])
    def test_movie_manifest_has_required_real_motion_and_hashes(self):
        clips = load_clips()
        self.assertTrue({'clash-win','clash-lose','hit','block','evade','ultimate'} <= {c['id'] for c in clips})
        for clip in clips:
            self.assertGreater(clip['frames'], 10)
            self.assertGreater(clip['distinct_frames'], 0)
            if clip['id'] in {'clash-win','clash-lose','hit','ultimate'}:
                self.assertGreater(clip['arena_distinct_frames'], 1)
            elif clip['arena_distinct_frames'] <= 5:
                self.assertEqual(clip['visual_status'], 'STATIC_OR_EFFECT_ONLY')
            self.assertEqual(clip['evidence_kind'], 'GODOT_PRESENTATION_FIXTURE_CAPTURE')

    def test_losing_actor_does_not_attack_after_losing_clash(self):
        clips={c['id']:c for c in load_clips()}
        loss,attack=clips['clash-lose']['events']
        self.assertEqual(loss['outcome'],'clash_loss')
        self.assertEqual(loss['actor'],'player')
        self.assertEqual(attack['actor'],'enemy')

if __name__ == '__main__': unittest.main()
