from __future__ import annotations

import unittest

from tests.check_combat_board_contract import find_conflict_markers


class ConflictMarkerDetectionTests(unittest.TestCase):
    def test_markdown_heading_underline_is_not_a_conflict(self) -> None:
        text = "The MIT License (MIT)\n=====================\n"
        self.assertEqual(find_conflict_markers(text), [])

    def test_complete_conflict_block_is_reported(self) -> None:
        text = "<<<<<<< HEAD\nleft\n=======\nright\n>>>>>>> branch\n"
        markers = find_conflict_markers(text)
        self.assertEqual([line for line, _ in markers], [1, 3, 5])

    def test_unclosed_conflict_start_is_reported(self) -> None:
        text = "before\n<<<<<<< HEAD\nunfinished\n"
        self.assertEqual(find_conflict_markers(text), [(2, "<<<<<<< HEAD")])

    def test_standalone_conflict_end_is_reported(self) -> None:
        text = "before\n>>>>>>> branch\nafter\n"
        self.assertEqual(find_conflict_markers(text), [(2, ">>>>>>> branch")])


if __name__ == "__main__":
    unittest.main()
