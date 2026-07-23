from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DESIGN_REGISTRY_PATH = ROOT / "[기획서]/DESIGN_DOCUMENT_REGISTRY.json"

ACTIVE_TEXT_PATHS = {
    "readme": ROOT / "README.md",
    "legacy_context": ROOT / "docs/ACTIVE_CONTEXT.md",
    "game": ROOT / "docs/01_GAME_DESIGN.md",
    "rules": ROOT / "docs/02_COMBAT_RULES.md",
    "content": ROOT / "docs/03_CONTENT_CATALOG.md",
    "roadmap": ROOT / "docs/04_ROADMAP.md",
    "poc": ROOT / "docs/05_COMBAT_POC_SPEC.md",
    "mastery": ROOT / "docs/06_STARTING_FACTION_MASTERY_DATA.md",
    "ui": ROOT / "docs/07_COMBAT_UI_SPEC.md",
    "qa": ROOT / "docs/08_TEST_CHECKLIST.md",
    "architecture": ROOT / "docs/09_COMBAT_SYSTEM_ARCHITECTURE.md",
    "presentation": ROOT / "docs/10_COMBAT_PRESENTATION_PLAN.md",
    "learning": ROOT / "docs/11_BASE_ADOPTION_AND_LEARNING_LOG.md",
    "hub_context": ROOT / "[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md",
    "design_skill": ROOT / "skills/game-design/ten-paces-game-design/SKILL.md",
    "engineering_skill": ROOT / "skills/engineering/combat-implementation-handoff/SKILL.md",
    "ux_skill": ROOT / "skills/ux-ui-accessibility/combat-ux-and-accessibility/SKILL.md",
    "qa_skill": ROOT / "skills/qa/ten-paces-verification/SKILL.md",
}

RUNTIME_PATHS = {
    "engine": ROOT / "src/combat/combat_resolution_engine.gd",
    "board": ROOT / "src/combat/combat_board_preview.gd",
    "timing": ROOT / "src/ui/action_timing_panel.gd",
    "progress": ROOT / "src/ui/combat_progress_button.gd",
    "log": ROOT / "src/ui/combat_log_panel.gd",
    "round_hud": ROOT / "src/ui/round_hud_panel.gd",
    "board_verifier": ROOT / "tests/verify_combat_board.gd",
    "response_verifier": ROOT / "tests/verify_response_rules.gd",
    "reference_svg": ROOT / "assets/reference/step_02_character_scale_and_tile_placement.svg",
    "workflow": ROOT / ".github/workflows/card-component-contract.yml",
}

EXPECTED_PLAYER_TILE = 4
EXPECTED_ENEMY_TILE = 7
EXPECTED_DISTANCE = 3
EXPECTED_CARD_IDS = [
    "basic_move",
    "basic_footwork",
    "basic_guard",
    "basic_evade",
    "basic_quick_attack",
    "basic_heavy_attack",
    "basic_meditate",
    "basic_stance",
]

STALE_START_TOKENS = (
    "플레이어 3번·상대 8번",
    "플레이어 3번 / 상대 8번",
    "플레이어 3번, 상대 8번",
    "플레이어는 3번, 상대는 8번",
    "플레이어 기본 시작 위치는 3번",
    "상대 기본 시작 위치는 8번",
    '"player_start_tile": 3',
    '"enemy_start_tile": 8',
    "var _player_tile := 3",
    "var _enemy_tile := 8",
    "EXPECTED_PLAYER_TILE := 3",
    "EXPECTED_ENEMY_TILE := 8",
)

STALE_ACTIVE_RULE_SENTENCES = (
    "한 라운드는 행동 타이밍 10개이며 2타이밍씩 묶어 총 5번 선택한다",
    "각 묶음에서 AI와 플레이어는 행동 두 개를 비공개로 잠근 뒤 동시에 공개한다",
    "행동력은 타이밍 수와 다르다",
    "체력·행동력·기력·내공",
    "선택 묶음 | 두 행동 잠금",
    "ActionPair",
    "PairLockCoordinator",
    "ClashResolver",
    "기초 행동 7종",
)


def load_json(relative: str) -> dict:
    return json.loads((ROOT / relative).read_text(encoding="utf-8"))


def read_files(paths: dict[str, Path]) -> dict[str, str]:
    result: dict[str, str] = {}
    for key, path in paths.items():
        assert path.is_file(), path.relative_to(ROOT)
        result[key] = path.read_text(encoding="utf-8")
    return result


def assert_no_stale_active_contract(active: dict[str, str], runtime: dict[str, str]) -> None:
    failures: list[str] = []
    for key, text in {**active, **runtime}.items():
        for token in STALE_START_TOKENS:
            if token in text:
                failures.append(f"{key}: stale start token: {token}")
    for key, text in active.items():
        for sentence in STALE_ACTIVE_RULE_SENTENCES:
            if sentence in text:
                failures.append(f"{key}: stale active rule: {sentence}")
    assert not failures, "active combat references are stale:\n" + "\n".join(failures)


def assert_start_position_contract(active: dict[str, str], runtime: dict[str, str]) -> None:
    board = load_json("data/combat/combat_board_poc.json")
    assert board["schema_version"] >= 13
    assert board["tile_count"] == 10
    assert board["player_start_tile"] == EXPECTED_PLAYER_TILE
    assert board["enemy_start_tile"] == EXPECTED_ENEMY_TILE
    assert board["enemy_start_tile"] - board["player_start_tile"] == EXPECTED_DISTANCE

    required_active_tokens = {
        "readme": ("플레이어 4번·상대 7번 시작",),
        "game": ("기본 시작 위치는 플레이어 4번, 상대 7번", "시작 거리는 3칸"),
        "rules": ("플레이어 기본 시작 위치는 4번", "상대 기본 시작 위치는 7번", "시작 거리는 3칸"),
        "content": ("`[강호낭인]`, 4번 칸 시작", "공개 상태 최소 AI 상대, 7번 칸 시작"),
        "roadmap": ("P0-3 — 시작 위치 4/7 전파·활성 원본 정리",),
        "poc": ("플레이어 시작 | 4번", "상대 시작 | 7번", "시작 거리 | 3칸"),
        "ui": ("플레이어 4번·상대 7번 시작", "시작 거리는 3칸"),
        "qa": ("플레이어는 4번, 상대는 7번", "시작 거리는 정확히 3칸"),
        "architecture": ("player.tile = 4", "enemy.tile = 7", "시작 위치 계약 소비자"),
        "presentation": ("플레이어 4번·상대 7번", "시작 거리 3"),
        "learning": ("전장 10칸, 플레이어 4번·상대 7번 시작",),
        "hub_context": ("플레이어 4번·상대 7번 시작", "P0-3 시작 위치·활성 원본 정리"),
        "design_skill": ("플레이어 4번·상대 7번 시작", "시작 거리 3"),
        "engineering_skill": ("플레이어 4번·상대 7번", "시작 위치 변경 계약"),
        "ux_skill": ("플레이어 4번·상대 7번 시작", "시작 화면 판독 계약"),
        "qa_skill": ("플레이어 4번·상대 7번", "정본 최신성 차단"),
    }
    for key, tokens in required_active_tokens.items():
        for token in tokens:
            assert token in active[key], f"{key}: missing {token}"

    board_script = runtime["board"]
    for token in (
        "var _player_tile := 4",
        "var _enemy_tile := 7",
        'contract.get("player_start_tile", 4)',
        'contract.get("enemy_start_tile", 7)',
    ):
        assert token in board_script, token

    board_verifier = runtime["board_verifier"]
    for token in (
        "EXPECTED_PLAYER_TILE := 4",
        "EXPECTED_ENEMY_TILE := 7",
        "from 4 to 5",
        "from 7 to 6",
        "from tile 4 to tile 6",
    ):
        assert token in board_verifier, token

    response_verifier = runtime["response_verifier"]
    for token in (
        "PLAYER_START_TILE := 4",
        "ENEMY_START_TILE := 7",
        "RESPONSE_RULES_10_6_START_4_7_VERIFY_OK",
    ):
        assert token in response_verifier, token

    svg = runtime["reference_svg"]
    for token in ("플레이어 4번 / 상대 7번", "플레이어 · 4번 칸", "상대 · 7번 칸"):
        assert token in svg, token


def assert_core_rules(active: dict[str, str]) -> None:
    board = load_json("data/combat/combat_board_poc.json")
    timing = load_json("data/combat/combat_action_timing_preview.json")
    hud = load_json("data/combat/combat_hud_preview.json")
    resolution = load_json("data/combat/combat_resolution_preview.json")
    card_catalog = load_json("data/cards/basic_cards.json")

    assert timing["timing_sequence"] == [3, 3, 4]
    assert timing["total_timings"] == 10
    assert board["tile_count"] == resolution["tile_count"] == 10
    sequence_text = "3수 → 3수 → 4수"
    order_text = resolution["resolution_order_label"]

    for key in ("readme", "game", "rules", "roadmap", "poc", "ui", "qa", "presentation", "hub_context"):
        assert sequence_text in active[key], key
    for key in ("game", "rules", "poc", "ui", "qa", "architecture", "presentation", "hub_context"):
        assert order_text in active[key], key

    cards = card_catalog["cards"]
    assert [card["id"] for card in cards] == EXPECTED_CARD_IDS
    assert len(cards) == 8
    for key in ("readme", "game", "rules", "content", "poc", "ui", "qa", "presentation", "hub_context"):
        assert "기초 행동 8종" in active[key], key

    by_id = {card["id"]: card for card in cards}
    assert by_id["basic_move"]["move_range"] == 1
    assert by_id["basic_footwork"]["move_range"] == 2
    assert by_id["basic_footwork"]["internal_cost"] == 1
    assert by_id["basic_heavy_attack"]["action_slots"] == 2
    assert by_id["basic_heavy_attack"]["range_text"] == "2"
    assert by_id["basic_heavy_attack"]["stamina_cost"] == 1
    assert by_id["basic_heavy_attack"]["internal_cost"] == 1

    response = board["response_rules"]
    assert response["guard_block"] == resolution["guard_block"] == 4
    assert response["stance_guard_multiplier"] == resolution["stance_response_defense_multiplier"] == 1.5
    for token in ("태세+막기", "태세+회피", "방어도 6"):
        assert token in active["rules"], token

    for side in ("player", "enemy"):
        for resource in ("health", "stamina", "internal"):
            current, maximum = hud[side][resource]
            assert current == maximum

    assert board["resolution_engine"]["interruption_enabled"] is True
    assert board["ultimate_skills"]["activation_momentum"] == 5
    assert board["engagement"]["same_tile_allowed"] is True
    for key in ("game", "rules", "roadmap", "poc", "ui", "qa", "architecture", "presentation", "hub_context"):
        assert "Issue #11" in active[key], key
    assert "공개 상태 최소 AI" in active["rules"]
    assert "공개 상태 최소 AI" in active["poc"]
    assert "플레이어의 미확정 슬롯·대상·절초 예약은 읽지 않는다" in active["rules"]


def assert_scope_and_document_lifecycle(active: dict[str, str]) -> None:
    content = active["content"]
    mastery = active["mastery"]
    legacy_context = active["legacy_context"]

    for token in ("CURRENT_T0", "PLANNED_T1", "HYPOTHESIS_T2_PLUS"):
        assert token in content, token
    for token in ("T1 이후 가설 원본", "현재 T0에는 세력 선택", "공용 절초 3종"):
        assert token in mastery, token
    assert "DEPRECATED_ENTRYPOINT" in legacy_context
    assert "독립적으로 보관하지 않는다" in legacy_context
    assert "## 제품 계약" not in legacy_context
    assert "## 현재 상태" not in legacy_context

    referenced_legacy_entrypoint: list[str] = []
    for path in ROOT.rglob("*.md"):
        if path == ACTIVE_TEXT_PATHS["legacy_context"]:
            continue
        if any(part in {".git", ".godot", "[백업]", "[보류]"} for part in path.parts):
            continue
        text = path.read_text(encoding="utf-8", errors="replace")
        if "docs/ACTIVE_CONTEXT.md" in text:
            referenced_legacy_entrypoint.append(str(path.relative_to(ROOT)))
    assert not referenced_legacy_entrypoint, (
        "active Markdown still references deprecated docs/ACTIVE_CONTEXT.md: "
        + ", ".join(referenced_legacy_entrypoint)
    )


def assert_design_registry_matches_documents() -> None:
    registry = json.loads(DESIGN_REGISTRY_PATH.read_text(encoding="utf-8"))
    documents = registry.get("documents", [])
    assert len(documents) == 11
    seen_paths: set[Path] = set()
    for entry in documents:
        assert entry.get("status") == "ACTIVE"
        assert entry.get("publication_policy") == "source_only"
        source_path = (DESIGN_REGISTRY_PATH.parent / str(entry["source_path"])).resolve()
        assert source_path.is_file(), source_path
        assert source_path not in seen_paths, source_path
        seen_paths.add(source_path)
        text = source_path.read_text(encoding="utf-8")
        assert text.startswith(f"# {entry['title']}\n"), f"registry title drift: {source_path.relative_to(ROOT)}"
        for section in entry.get("required_sections", []):
            assert section in text, f"{source_path.relative_to(ROOT)} missing registry section: {section}"


def assert_ui_and_runtime_boundaries(active: dict[str, str], runtime: dict[str, str]) -> None:
    progress_data = load_json("data/combat/combat_progress_preview.json")
    for value in (
        progress_data["caption"],
        progress_data["ready_text"],
        progress_data["disabled_text"],
        progress_data["requested_text"],
    ):
        assert value in active["ui"], value
        assert value in active["qa"], value
        assert value in active["presentation"], value

    assert '_round_label.text = "제 %d 라운드" % round_number' in runtime["round_hud"]
    assert "제 1 라운드" in active["ui"]
    assert "행동 묶음  1/3" in active["ui"]
    assert "라운드 1" in active["ui"]

    assert "focus_mode = Control.FOCUS_ALL" in runtime["progress"]
    assert "focus_mode = Control.FOCUS_NONE" in runtime["log"]
    assert "Enter/`ui_accept`" in active["ui"]
    assert "키보드 포커스" in active["presentation"]
    assert "카드→수 슬롯→대상 타일→진행의 키보드 흐름, 명시적 Tab 순서" in active["qa"]
    assert "실제 보조기기 사용자의 전체 사용성은 아직 `NOT_RUN`" in active["qa"]

    assert "scroll_to_line" not in runtime["log"]
    assert "scroll_to_paragraph" not in runtime["log"]
    assert "로그 자동 스크롤 정책" in active["ui"]
    assert "새 로그 후 자동 최하단 이동" in active["presentation"]
    assert "현재 구현에는 로그 자동 스크롤 정책이 없음을" in active["qa"]

    resolve_index = runtime["board"].index("resolution_engine.resolve_bundle")
    advance_index = runtime["board"].index("action_timing_panel.advance_after_resolution")
    assert resolve_index < advance_index
    assert '"timing_results"' in runtime["engine"]
    assert "await _apply_timing_snapshot" in runtime["board"]
    assert "committed → resolving → presenting_result → next_bundle_ready" in active["ui"]
    assert "표현은 `committed → resolving → presenting_result → next_bundle_ready` 상태" in active["architecture"]
    assert "현재 구현은 다음 상태를 사용한다" in active["presentation"]
    assert "입력 잠금과 `resolving`/`presenting_result` 상태를 자동 테스트" in active["qa"]


def assert_architecture_matches_runtime(active: dict[str, str], runtime: dict[str, str]) -> None:
    architecture = active["architecture"]
    engine = runtime["engine"]
    timing = runtime["timing"]

    for token in ("round_number", "bundle_index", "player", "enemy"):
        assert f'"{token}"' in engine
        assert token in architecture

    for token in (
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
    ):
        assert f'"{token}"' in timing, token
        assert token in architecture, token

    for token in (
        "valid",
        "state",
        "invalid_anchors",
        "events",
        "logs",
        "resolved_actions",
        "bundle_start",
        "bundle_end",
        "resolution_order",
        "defenses",
    ):
        assert f'"{token}"' in engine, token
        assert token in architecture, token

    assert "state_before_resolution" in engine
    assert '"presentation_events"' in engine
    assert "_build_presentation_events" in engine
    assert "현재 반환하지 않는 항목" in architecture
    assert "현재 별도 `BundlePlan` class는 없다" in architecture
    assert "현재 파일·class가 존재한다고 가정하지 않는다" in architecture
    assert "회차 저장·불러오기가 없다" in architecture


def assert_workflow_coverage(runtime: dict[str, str]) -> None:
    workflow = runtime["workflow"]
    required_paths = (
        "README.md",
        "docs/ACTIVE_CONTEXT.md",
        "docs/03_CONTENT_CATALOG.md",
        "docs/06_STARTING_FACTION_MASTERY_DATA.md",
        "docs/11_BASE_ADOPTION_AND_LEARNING_LOG.md",
        "[기획서]/DESIGN_DOCUMENT_REGISTRY.json",
        "skills/game-design/ten-paces-game-design/SKILL.md",
        "skills/engineering/combat-implementation-handoff/SKILL.md",
        "skills/ux-ui-accessibility/combat-ux-and-accessibility/SKILL.md",
        "skills/qa/ten-paces-verification/SKILL.md",
        "data/combat/**",
        "src/combat/**",
        "tests/check_canonical_combat_docs.py",
        "tests/verify_combat_board.gd",
        "tests/verify_response_rules.gd",
        "tests/verify_combat_layout_accessibility.gd",
        "assets/reference/step_02_character_scale_and_tile_placement.svg",
        ".github/reference-freshness.json",
    )
    missing = [path for path in required_paths if path not in workflow]
    assert not missing, "Card Component Contract workflow misses consumers: " + ", ".join(missing)


def main() -> None:
    active = read_files(ACTIVE_TEXT_PATHS)
    runtime = read_files(RUNTIME_PATHS)
    assert_no_stale_active_contract(active, runtime)
    assert_start_position_contract(active, runtime)
    assert_core_rules(active)
    assert_scope_and_document_lifecycle(active)
    assert_design_registry_matches_documents()
    assert_ui_and_runtime_boundaries(active, runtime)
    assert_architecture_matches_runtime(active, runtime)
    assert_workflow_coverage(runtime)
    print("canonical combat impact map including tile 4 and 7 consumers: PASS")


if __name__ == "__main__":
    main()
