from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

DOC_PATHS = {
    "game": ROOT / "docs/01_GAME_DESIGN.md",
    "rules": ROOT / "docs/02_COMBAT_RULES.md",
    "poc": ROOT / "docs/05_COMBAT_POC_SPEC.md",
}

LEGACY_ACTIVE_SENTENCES = (
    "제한된 대회 일정 안에서 여러 무공과 최대 두 개의 심법을 수련하고, 10칸 전장의 2수 비공개 동시 선택 결투",
    "전장은 1~10번 칸이며 기본 배치는 A=4, B=6",
    "한 라운드는 행동 타이밍 10개이며 2타이밍씩 묶어 총 5번 선택한다",
    "각 묶음에서 AI와 플레이어는 행동 두 개를 비공개로 잠근 뒤 동시에 공개한다",
    "## 2. 라운드와 2수 동시 선택",
    "2타이밍을 한 묶음으로 하여 라운드마다 총 5번 행동을 선택한다",
    "행동력은 타이밍 수와 다르다",
    "AI는 각 2수 묶음 시작 시 공개 정보로 두 행동을 잠근다",
    "| 초기 배치 | A=4번 칸, B=6번 칸 |",
    "| 행동력 | 6, 10타이밍 종료 시 전부 회복 |",
    "- 2수 비공개 잠금과 AI 공정성이 유지된다.",
)


def load_json(relative: str) -> dict:
    return json.loads((ROOT / relative).read_text(encoding="utf-8"))


def read_docs() -> dict[str, str]:
    result: dict[str, str] = {}
    for key, path in DOC_PATHS.items():
        assert path.is_file(), path.relative_to(ROOT)
        result[key] = path.read_text(encoding="utf-8")
    return result


def assert_no_legacy_active_sentences(docs: dict[str, str]) -> None:
    failures: list[str] = []
    for key, text in docs.items():
        for sentence in LEGACY_ACTIVE_SENTENCES:
            if sentence in text:
                failures.append(f"{DOC_PATHS[key].relative_to(ROOT)}: {sentence}")
    assert not failures, "legacy combat rules returned to canonical docs:\n" + "\n".join(failures)


def assert_current_contract(docs: dict[str, str]) -> None:
    board = load_json("data/combat/combat_board_poc.json")
    timing = load_json("data/combat/combat_action_timing_preview.json")
    hud = load_json("data/combat/combat_hud_preview.json")
    resolution = load_json("data/combat/combat_resolution_preview.json")
    card_catalog = load_json("data/cards/basic_cards.json")

    game = docs["game"]
    rules = docs["rules"]
    poc = docs["poc"]
    combined = "\n".join(docs.values())

    sequence = timing["timing_sequence"]
    sequence_text = " → ".join(f"{value}수" for value in sequence)
    assert sequence == [3, 3, 4]
    assert sequence_text in game
    assert sequence_text in rules
    assert sequence_text in poc

    assert f"플레이어 {board['player_start_tile']}번" in game
    assert f"상대 {board['enemy_start_tile']}번" in game
    assert f"플레이어 기본 시작 위치는 {board['player_start_tile']}번" in rules
    assert f"상대 기본 시작 위치는 {board['enemy_start_tile']}번" in rules
    assert f"플레이어 시작 | {board['player_start_tile']}번" in poc
    assert f"상대 시작 | {board['enemy_start_tile']}번" in poc

    order_label = resolution["resolution_order_label"]
    assert order_label in game
    assert order_label in rules
    assert order_label in poc

    assert board["tile_count"] == resolution["tile_count"] == timing["total_timings"] == 10
    assert "기초 행동 8종" in game
    assert "기초 행동 8종" in rules
    assert "기초 행동 8종" in poc

    cards = card_catalog["cards"]
    assert len(cards) == 8
    for card in cards:
        card_id = card["id"]
        card_name = card["name"]
        assert card_name in rules, card_name
        assert card_id in poc, card_id

    by_id = {card["id"]: card for card in cards}
    heavy = by_id["basic_heavy_attack"]
    footwork = by_id["basic_footwork"]
    guard = by_id["basic_guard"]
    evade = by_id["basic_evade"]
    stance = by_id["basic_stance"]

    assert heavy["action_slots"] == 2
    assert heavy["range_text"] == "2"
    assert heavy["stamina_cost"] == 1
    assert heavy["internal_cost"] == 1
    for token in ("강공", "슬롯 | 2", "기력 1·내력 1", "거리 1 또는 2"):
        assert token in rules, token

    assert footwork["move_range"] == 2
    assert footwork["internal_cost"] == 1
    assert "보법" in rules and "좌·우 1칸 또는 2칸" in rules

    response = board["response_rules"]
    assert response["guard_block"] == resolution["guard_block"] == 4
    assert response["stance_guard_multiplier"] == resolution["stance_response_defense_multiplier"] == 1.5
    assert "방어도 4" in rules
    assert "방어도 6" in rules
    assert "같은 수 공격 완전 회피" in rules
    assert "현재 행동 묶음의 모든 공격을 완전히 회피" in rules
    assert "태세+막기" in rules and "태세+회피" in rules
    assert "50%" in guard["effect_text"]
    assert "완전히 회피" in evade["effect_text"]
    assert "대응" in stance["effect_text"]

    for side in ("player", "enemy"):
        for resource in ("health", "stamina", "internal"):
            current, maximum = hud[side][resource]
            assert current == maximum
    assert "체력·기력·내력은 전투 시작 시 최대치" in game
    assert "최대치−시작 패널티" in poc
    assert "start_penalties" in rules

    assert board["resolution_engine"]["interruption_enabled"] is False
    assert "STEP 11" in game
    assert "STEP 11" in rules
    assert "STEP 11" in poc
    assert "고정 행동 계획" in rules
    assert "고정 행동 계획" in poc
    assert "정식 AI가 아니다" in rules

    assert "HOLD" in combined
    for token in ("2수 비공개", "행동력", "합 수치 비교"):
        assert token in combined, token


def main() -> None:
    docs = read_docs()
    assert_no_legacy_active_sentences(docs)
    assert_current_contract(docs)
    print("canonical combat docs 01/02/05 vs runtime contract: PASS")


if __name__ == "__main__":
    main()
