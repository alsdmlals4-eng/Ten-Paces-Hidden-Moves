import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "src" / "ui" / "action_timing_panel_auto.gd"


class ActionTimingLinkedLayerLayoutTests(unittest.TestCase):
    def test_full_rect_linked_layer_does_not_receive_manual_size(self) -> None:
        source = SOURCE.read_text(encoding="utf-8")

        self.assertIn(
            "_linked_block_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)",
            source,
        )
        self.assertNotIn("_linked_block_layer.size = size", source)


if __name__ == "__main__":
    unittest.main()
