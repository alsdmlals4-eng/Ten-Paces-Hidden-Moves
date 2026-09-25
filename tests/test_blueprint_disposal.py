"""Disposed media stays auditable without becoming a broken image request."""
import hashlib
import json
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tools'))
import html_blueprint as model
import html_blueprint_experience as experience
import html_blueprint_numbers as numbers


class DisposalTests(unittest.TestCase):
    def test_candidate_disposal_keeps_original_number_and_review_identity(self):
        candidate = {'id': 'pr342-title', 'path': 'title.png', 'scope': 'PR342_CANDIDATE'}
        retired = {**candidate, 'scope': 'MAIN_SOURCE', 'details': {
            'retired': True, 'disposal': {'source_scope': 'PR342_CANDIDATE'}}}
        registry = {numbers.asset_key(candidate): 29}
        key = numbers.asset_key(retired)
        self.assertEqual(numbers.allocate(registry, [key])[key], 29)

    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        owner = self.root / 'docs/blueprint/IMPLEMENTATION_READINESS.json'
        owner.parent.mkdir(parents=True)
        owner.write_text(json.dumps({'retired_images': [
            {'path': 'old.png', 'status': 'DELETED_BY_USER_REQUEST', 'number': 3}
        ]}), encoding='utf-8')

    def test_retired_reader_picture_keeps_identity_without_reading_deleted_file(self):
        with patch.object(model, 'ROOT', self.root):
            reader = model.Reader()
            reader.page('history')
            reader.photo(self.root / 'old.png')
        self.assertEqual(reader.pages[0]['blocks'][0]['kind'], 'retired_image')
        self.assertEqual(reader.pages[0]['blocks'][0]['path'], 'old.png')

    def test_missing_unretired_picture_is_still_an_error(self):
        with patch.object(model, 'ROOT', self.root):
            reader = model.Reader()
            reader.page('current')
            with self.assertRaises(FileNotFoundError):
                reader.photo(self.root / 'unrecorded.png')

    def test_retired_poster_does_not_remove_or_relabel_the_recorded_movie(self):
        movie = self.root / 'recording.mp4'
        movie.write_bytes(b'recorded movie')
        manifest = {'source_hashes': {}, 'clips': [{
            'id': 'recording', 'path': 'recording.mp4',
            'path_sha256': hashlib.sha256(movie.read_bytes()).hexdigest(),
            'poster': 'old.png', 'poster_sha256': 'historical-poster-hash'
        }]}
        (self.root / 'motion.json').write_text(json.dumps(manifest), encoding='utf-8')
        with patch.object(experience, 'ROOT', self.root):
            result = experience.load_clips('motion.json')
        self.assertEqual(result[0]['path'], 'recording.mp4')
        self.assertIsNone(result[0]['poster'])
        self.assertEqual(result[0]['poster_disposal']['path'], 'old.png')


if __name__ == '__main__':
    unittest.main()
