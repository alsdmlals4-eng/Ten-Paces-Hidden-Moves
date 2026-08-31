from __future__ import annotations

import importlib.util
import json
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
TOOL = ROOT / "tools/check_gut_9_7_1_reconciliation.py"
CONTRACT = ROOT / "docs/planning-data/approved_20260807_gut_9_7_1_reconciliation.json"

OBSERVED_NORMALIZED_TEXT_RESOURCE_VARIANCES = [
    "GutScene.tscn",
    "UserFileViewer.tscn",
    "gui/GutControl.tscn",
    "gui/GutLogo.tscn",
    "gui/GutRunner.tscn",
    "gui/GutSceneTheme.tres",
    "gui/MinGui.tscn",
    "gui/NormalGui.tscn",
    "gui/OutputText.tscn",
    "gui/ResizeHandle.tscn",
    "gui/RunAtCursor.tscn",
    "gui/RunExternally.tscn",
    "gui/RunResults.tscn",
    "gui/ShellOutOptions.tscn",
    "gui/ShortcutButton.tscn",
    "gui/run_from_editor.tscn",
    "gut_loader_the_scene.tscn",
]


def load_tool():
    spec = importlib.util.spec_from_file_location("gut_reconciliation", TOOL)
    if spec is None or spec.loader is None:
        raise RuntimeError("GUT reconciliation validator cannot be loaded")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class Gut971ObservedVarianceManifestTests(unittest.TestCase):
    def test_live_observed_variance_manifest_is_exactly_recorded(self) -> None:
        tool = load_tool()
        payload = json.loads(CONTRACT.read_text(encoding="utf-8"))
        self.assertEqual(
            sorted(tool.EXPECTED_NORMALIZED_SCENE_VARIANCES),
            sorted(OBSERVED_NORMALIZED_TEXT_RESOURCE_VARIANCES),
        )
        self.assertEqual(
            payload["expected_normalized_scene_variances"],
            OBSERVED_NORMALIZED_TEXT_RESOURCE_VARIANCES,
        )


if __name__ == "__main__":
    unittest.main()
