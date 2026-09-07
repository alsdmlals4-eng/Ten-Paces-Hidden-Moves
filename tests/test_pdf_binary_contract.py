"""Generated PDFs must retain bytes and never enter text whitespace checks."""
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class PdfBinaryContractTests(unittest.TestCase):
    def test_published_pdf_has_explicit_binary_attributes(self):
        result = subprocess.run(
            ["git", "check-attr", "text", "diff", "merge", "--",
             "exports/ten-paces-hidden-moves_HUMAN_GAME_BLUEPRINT_20260904.pdf"],
            cwd=ROOT, capture_output=True, text=True, check=True,
        )
        values = [line.rsplit(": ", 1)[1] for line in result.stdout.splitlines()]
        self.assertEqual(["unset", "unset", "unset"], values)


if __name__ == "__main__":
    unittest.main()
