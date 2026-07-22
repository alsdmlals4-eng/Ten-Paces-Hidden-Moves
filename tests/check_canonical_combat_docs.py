from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

DOC_PATHS = {
    "game": ROOT / "docs/01_GAME_DESIGN.md",
    "rules": ROOT / "docs/02_COMBAT_RULES.md",
    "roadmap": ROOT / "docs/04_ROADMAP.md",
    "poc": ROOT / "docs/05_COMBAT_POC_SPEC.md",
    "ui": ROOT / "docs/07_COMBAT_UI_SPEC.md",
    "qa": ROOT / "docs/08_TEST_CHECKLIST.md",
    "architecture": ROOT / "docs/09_COMBAT_SYSTEM_ARCHITECTURE.md",
    "presentation": ROOT / "docs/10_COMBAT_PRESENTATION_PLAN.md",
}

SCRIPT_PATHS = {
    "engine": ROOT / "src/combat/combat_resolution_engine.gd",
    "board": ROOT / "src/combat/combat_board_preview.gd",
    "timing": ROOT / "src/ui/action_timing_panel.gd",
    "progress": ROOT / "src/ui/combat_progress_button.gd",
    "log": ROOT / "src/ui/combat_log_panel.gd",
    "round_hud": ROOT / "src/ui/round_hud_panel.gd",
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
    "ActionPair",
    "PairLockCoordinator",
    "ClashResolver",
)


def load_json(relative: str) -> dict:
    return json.loads((ROOT / relative).read_text(encoding="utf-8"))


def read_files(paths: dict[str, Path]) -> dict[str, str]:
    result: dict[str, str] = {}
    for key, path in paths.items():
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


def assert_core_rule_contract(docs: dict[str, str]) -> None:
    board = load_json("data/combat/combat_board_poc.json")
    timing = load_json("data/combat/combat_action_timing_preview.json")
    hud = load_json("data/combat/combat_hud_preview.json")
    resolution = load_json("data/combat/combat_resolution_preview.json")
    card_catalog = load_json("data/cards/basic_cards.json")

    game = docs["game"]
    rules = docs["rules"]
    roadmap = docs["roadmap"]
    poc = docs["poc"]
    ui = docs["ui"]
    qa = docs["qa"]
    architecture = docs["architecture"]
    presentation = docs["presentation"]
    combined = "\n".join(docs.values())

    sequence = timing["timing_sequence"]
    sequence_text = " → ".join(f"{value}수" for value in sequence)
    assert sequence == [3, 3, 4]
    for key in ("game", "rules", "roadmap", "poc", "ui", "qa", "presentation"):
        assert sequence_text in docs[key], key

    assert f"플레이어 {board['player_start_tile']}번" in game
    assert f"상대 {board['enemy_start_tile']}번" in game
    assert f"플레이어 기본 시작 위치는 {board['player_start_tile']}번" in rules
    assert f"상대 기본 시작 위치는 {board['enemy_start_tile']}번" in rules
    assert f"플레이어 시작 | {board['player_start_tile']}번" in poc
    assert f"상대 시작 | {board['enemy_start_tile']}번" in poc
    assert f"플레이어 {board['player_start_tile']}번·상대 {board['enemy_start_tile']}번" in ui

    order_label = resolution["resolution_order_label"]
    for key in ("game", "rules", "poc", "ui", "qa", "architecture", "presentation"):
        assert order_label in docs[key], key

    assert board["tile_count"] == resolution["tile_count"] == timing["total_timings"] == 10
    for key in ("game", "rules", "poc", "ui", "qa", "presentation"):
        assert "기초 행동 8종" in docs[key], key

    cards = card_catalog["cards"]
    assert len(cards) == 8
    for card in cards:
        card_id = card["id"]
        card_name = card["name"]
        assert card_name in rules, card_name
        assert card_id in poc, card_id
        assert card_name in ui, card_name
        assert card_name in qa, card_name

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
    assert "좌·우 1칸 또는 2칸" in rules

    response = board["response_rules"]
    assert response["guard_block"] == resolution["guard_block"] == 4
    assert response["stance_guard_multiplier"] == resolution["stance_response_defense_multiplier"] == 1.5
    for token in ("방어도 4", "방어도 6", "같은 수 공격 완전 회피", "태세+막기", "태세+회피"):
        assert token in rules, token
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
    for key in ("game", "rules", "roadmap", "poc", "ui", "qa", "architecture", "presentation"):
        assert "STEP 11" in docs[key], key
    assert "고정 행동 계획" in rules
    assert "고정 행동 계획" in poc
    assert "정식 AI가 아니다" in rules

    assert "HOLD" in combined
    for token in ("2수 비공개", "행동력", "합 수치 비교"):
        assert token in combined, token


def assert_ui_runtime_contract(docs: dict[str, str], scripts: dict[str, str]) -> None:
    progress_data = load_json("data/combat/combat_progress_preview.json")
    ui = docs["ui"]
    qa = docs["qa"]
    presentation = docs["presentation"]
    progress_script = scripts["progress"]
    log_script = scripts["log"]
    board_script = scripts["board"]
    round_script = scripts["round_hud"]

    exact_strings = (
        progress_data["caption"],
        progress_data["ready_text"],
        progress_data["disabled_text"],
        progress_data["requested_text"],
    )
    for value in exact_strings:
        assert value in ui, value
        assert value in qa, value
        assert value in presentation, value

    assert '_round_label.text = "제 %d 라운드" % round_number' in round_script
    assert '_bundle_label.text = "행동 묶음  %d/%d"' in round_script
    assert "제 1 라운드" in ui
    assert "행동 묶음  1/3" in ui
    assert "라운드 1" in ui

    assert "focus_mode = Control.FOCUS_NONE" in progress_script
    assert "focus_mode = Control.FOCUS_NONE" in log_script
    assert "키보드 전체 흐름은 구현 완료가 아니다" in ui
    assert "키보드 전체 흐름은 아직 없다" in presentation
    assert "키보드 항목은 `NOT_RUN`" in qa

    assert "scroll_to_line" not in log_script
    assert "scroll_to_paragraph" not in log_script
    assert "로그 자동 스크롤 정책" in ui
    assert "새 로그 후 자동 최하단 이동" in presentation
    assert "현재 구현에는 로그 자동 스크롤 정책이 없음" in qa

    resolve_index = board_script.index("resolution_engine.resolve_bundle")
    advance_index = board_script.index("action_timing_panel.advance_after_resolution")
    assert resolve_index < advance_index
    assert "현재 판정은 신호 호출 안에서 동기적으로 완료" in ui
    assert "현재 판정은 한 신호 호출 안에서 동기적으로 끝난다" in docs["architecture"]
    assert "별도 `판정 중` 화면이 없다" in presentation
    assert "별도 `resolving` 상태 테스트" in qa


def assert_architecture_runtime_contract(docs: dict[str, str], scripts: dict[str, str]) -> None:
    architecture = docs["architecture"]
    engine = scripts["engine"]
    timing = scripts["timing"]

    initial_state_tokens = (
        '"round_number"',
        '"bundle_index"',
        '"player"',
        '"enemy"',
    )
    for token in initial_state_tokens:
        assert token in engine
        assert token.strip('"') in architecture

    placement_tokens = (
        "card_id",
        "card_name",
        "definition",
        "anchor_index",
        "span",
        "indices",
        "targeting_mode",
        "target_ready",
        "resource_ready",
        "target_tile",
        "direction",
        "origin_tile",
        "target_text",
    )
    for token in placement_tokens:
        assert f'"{token}"' in timing, token
        assert token in architecture, token

    preview_result_tokens = ("valid", "state", "invalid_anchors", "events")
    resolve_result_tokens = (
        "state",
        "logs",
        "resolved_actions",
        "round_number",
        "bundle_index",
        "bundle_start",
        "bundle_end",
        "resolution_order",
        "defenses",
    )
    for token in preview_result_tokens + resolve_result_tokens:
        assert f'"{token}"' in engine, token
        assert token in architecture, token

    assert "state_before" not in engine
    assert '"state_after"' not in engine
    assert "현재 반환하지 않는 항목" in architecture
    assert "typed domain object" in architecture
    assert "현재 별도 `BundlePlan` class는 없다" in architecture
    assert "현재 파일·class가 존재한다고 가정하지 않는다" in architecture
    assert "문자열 로그" in architecture
    assert "회차 저장·불러오기가 없다" in architecture


def assert_roadmap_and_verification_gates(docs: dict[str, str]) -> None:
    roadmap = docs["roadmap"]
    qa = docs["qa"]
    for token in (
        "P0 — 전투 정본 재정렬",
        "P1 — RESPONSE·RESOURCE PREVIEW 실제 확인",
        "STEP 11 — 피격 중단·집중·강건",
        "STEP 12 — 성향 기반 단순 AI",
        "STEP 13 — 전투 종료·재시작",
        "STEP 14 — POC 플레이테스트",
        "T1 — 최소 세로 슬라이스",
    ):
        assert token in roadmap, token

    for token in (
        "BOARD-001",
        "TIMING-001",
        "ACTION-001",
        "RESPONSE-001",
        "TARGET-001",
        "GATE-001",
        "RESOURCE-001",
        "RESOLVE-001",
        "UI-001",
        "STEP 14 POC 플레이테스트",
        "접근성 검증",
        "성능 검증",
        "T1 진입 게이트",
    ):
        assert token in qa, token


def main() -> None:
    docs = read_files(DOC_PATHS)
    scripts = read_files(SCRIPT_PATHS)
    assert_no_legacy_active_sentences(docs)
    assert_core_rule_contract(docs)
    assert_ui_runtime_contract(docs, scripts)
    assert_architecture_runtime_contract(docs, scripts)
    assert_roadmap_and_verification_gates(docs)
    print("canonical combat docs 01/02/04/05/07/08/09/10 vs runtime contract: PASS")


if __name__ == "__main__":
    main()
