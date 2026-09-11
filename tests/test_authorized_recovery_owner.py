"""Recovery stays in the higher-authority owner, not a generated file."""
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]

class RecoveryOwnerTests(unittest.TestCase):
    def test_bounded_recovery_and_protection(self):
        text = (ROOT / 'AGENTS.md').read_text(encoding='utf-8')
        for token in ['RECOVERY_ONLY', '반복 승인을 요청하지 않는다', '같은 검사와 영향 회귀',
                      '일반 실행은 재개하지 않는다', '승인 조작', '생성 라우터는 채택한 Base 출력']:
            self.assertIn(token, text)

if __name__ == '__main__':
    unittest.main()
