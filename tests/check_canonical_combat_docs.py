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
    "ai": ROOT / "src/combat/combat_ai_planner.gd",
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
EXPECTED_ULTIMATE_IDS = [
    "ultimate_ten_paces_wave",
    "ultimate_cleave_peak",
    "ultimate_void_sword_qi",
]

STALE_START_TOKENS = (
    "플레이어 3번·상대 8번",
    "플레이어 3번 / 상대 8번",
    "플레이어 3번, 상대 8번",
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


def assert_tokens(text: str, tokens: tuple[str, ...], label: str) -> None:
    for token in tokens:
        assert token in text, f"{label}: missing {token}"


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
    assert board["schema_version"] == 16
    assert board["tile_count"] == 10
    assert board["player_start_tile"] == EXPECTED_PLAYER_TILE
    assert board["enemy_start_tile"] == EXPECTED_ENEMY_TILE
    assert board["enemy_start_tile"] - board["player_start_tile"] == EXPECTED_DISTANCE

    required_active_tokens = {
        "readme": ("플레이어 4번·상대 7번 시작", "시작 거리 3"),
        "game": ("플레이어 4번·상대 7번", "시작 거리 3"),
        "rules": ("`[강호낭인]`은 4번", "상대는 7번", "시작 거리는 3"),
        "content": ("4번 시작", "7번 시작", "시작 거리는 3"),
        "roadmap": ("10칸·4/7·거리 3",),
        "poc": ("플레이어 4번·상대 7번", "시작 거리 3"),
        "ui": ("4/7", "거리 3"),
        "qa": ("플레이어는 4번, 상대는 7번", "시작 거리는 정확히 3"),
        "architecture": ("초기 타일은 4/7",),
        "presentation": ("4/7·거리 3",),
        "learning": ("10칸·4/7",),
        "hub_context": ("10칸·4/7·거리 3",),
    }
    for key, tokens in required_active_tokens.items():
        assert_tokens(active[key], tokens, key)

    assert_tokens(
        runtime["board"],
        (
            "var _player_tile := 4",
            "var _enemy_tile := 7",
            'contract.get("player_start_tile", 4)',
            'contract.get("enemy_start_tile", 7)',
        ),
        "board runtime",
    )
    assert_tokens(
        runtime["board_verifier"],
        (
            "EXPECTED_PLAYER_TILE := 4",
            "EXPECTED_ENEMY_TILE := 7",
            "from 4 to 5",
            "from 7 to 6",
            "from tile 4 to tile 6",
        ),
        "board verifier",
    )
    assert_tokens(
        runtime["response_verifier"],
        (
            "PLAYER_START_TILE := 4",
            "ENEMY_START_TILE := 7",
            "RESPONSE_RULES_10_6_START_4_7_VERIFY_OK",
        ),
        "response verifier",
    )
    assert_tokens(
        runtime["reference_svg"],
        ("플레이어 4번 / 상대 7번", "플레이어 · 4번 칸", "상대 · 7번 칸"),
        "reference SVG",
    )


def assert_structured_current_rules() -> None:
    board = load_json("data/combat/combat_board_poc.json")
    timing = load_json("data/combat/combat_action_timing_preview.json")
    hud = load_json("data/combat/combat_hud_preview.json")
    resolution = load_json("data/combat/combat_resolution_preview.json")
    basic = load_json("data/cards/basic_cards.json")
    ultimates = load_json("data/cards/ultimate_cards.json")

    assert timing["timing_sequence"] == [3, 3, 4]
    assert timing["total_timings"] == 10
    assert board["tile_count"] == resolution["tile_count"] == 10

    engagement = board["engagement"]
    assert engagement["same_tile_allowed"] is True
    assert engagement["max_combatants_per_tile"] == 2
    assert engagement["same_tile_distance"] == 0
    assert engagement["allow_enter_stationary_opponent_tile"] is True
    assert engagement["allow_same_empty_destination"] is True
    assert engagement["disallow_swap"] is True
    assert engagement["disallow_pass_through"] is True

    assert resolution["enemy_plan_source"] == "public_state_ai"
    assert resolution["enemy_bundles"] == {}
    assert resolution["clash_same_timing_attacks"] is True
    assert resolution["clash_tie_damage"] == 0
    assert resolution["sure_hit_ignores_evade_only"] is True
    assert resolution["guard_resolution_order"] == [
        "subtract_guard_block",
        "same_timing_halve_remaining",
    ]
    assert resolution["interruption_only_same_timing_not_future"] is True
    assert resolution["fortitude_next_attack_only"] is True

    cards = basic["cards"]
    assert [card["id"] for card in cards] == EXPECTED_CARD_IDS
    assert len(cards) == 8
    by_id = {card["id"]: card for card in cards}
    assert by_id["basic_move"]["move_range"] == 1
    assert by_id["basic_footwork"]["move_range"] == 2
    assert by_id["basic_footwork"]["internal_cost"] == 1
    assert by_id["basic_heavy_attack"]["action_slots"] == 2
    assert by_id["basic_heavy_attack"]["range"] == 2
    assert by_id["basic_heavy_attack"]["stamina_cost"] == 1
    assert by_id["basic_heavy_attack"]["internal_cost"] == 1
    assert "방어도 차감 뒤 남은 피해를 50%" in by_id["basic_guard"]["effect_text"]

    ultimate_cards = ultimates["cards"]
    assert [card["id"] for card in ultimate_cards] == EXPECTED_ULTIMATE_IDS
    ultimate_by_id = {card["id"]: card for card in ultimate_cards}
    assert ultimate_by_id["ultimate_ten_paces_wave"]["action_slots"] == 1
    assert ultimate_by_id["ultimate_cleave_peak"]["action_slots"] == 2
    assert ultimate_by_id["ultimate_void_sword_qi"]["action_slots"] == 3
    assert "필중" in ultimate_by_id["ultimate_void_sword_qi"]["tags"]

    for side in ("player", "enemy"):
        assert hud[side]["health"] == [30, 30]
        assert hud[side]["attack_power"] == 8
        assert hud[side]["stamina"] == [5, 5]
        assert hud[side]["internal"] == [4, 4]
        assert hud[side]["momentum"] == [0, 5]

    assert board["response_rules"]["guard_block"] == resolution["guard_block"] == 4
    assert board["response_rules"]["stance_guard_multiplier"] == 1.5
    assert board["ultimate_skills"]["activation_momentum"] == 5
    assert board["resolution_engine"]["interruption_enabled"] is True


def assert_current_rules_in_documents(active: dict[str, str]) -> None:
    sequence_text = "3수 → 3수 → 4수"
    for key in (
        "readme",
        "game",
        "rules",
        "roadmap",
        "poc",
        "ui",
        "qa",
        "presentation",
        "hub_context",
    ):
        assert sequence_text in active[key], key

    for key in ("readme", "game", "rules", "content", "poc", "ui", "qa", "hub_context"):
        assert "기초 행동 8종" in active[key], key
        assert "절초 3종" in active[key], key

    for key in ("readme", "game", "rules", "poc", "ui", "qa", "architecture", "presentation", "hub_context"):
        assert "합" in active[key], key

    for key in ("readme", "game", "rules", "poc", "architecture", "hub_context"):
        assert "공개 상태" in active[key] and "AI" in active[key], key

    assert_tokens(
        active["rules"],
        (
            "같은 타일의 거리는 0",
            "방어도 차감",
            "[필중]",
            "같은 수에서 아직 실행하지 않은 행동",
            "CombatAiPlanner",
            "결전 다시 시작",
        ),
        "rules",
    )
    assert_tokens(
        active["qa"],
        (
            "BOARD-002 밀착·공동 목적지",
            "CLASH-001 기본 합",
            "AI-001 공개 정보 입력",
            "RESTART-001 완전 초기화",
            "STEP 14 사람 플레이",
        ),
        "qa",
    )
    for key in ("poc", "ui", "qa", "presentation", "hub_context"):
        assert "NOT_RUN" in active[key] or "HUMAN_NOT_RUN" in active[key], key


def assert_scope_and_document_lifecycle(active: dict[str, str]) -> None:
    for token in ("CURRENT_T0", "PLANNED_T1", "HYPOTHESIS_T2_PLUS", "HOLD"):
        assert token in active["content"], token
    for token in (
        "T1 이후 가설 원본",
        "현재 T0에는 세력 선택",
        "공용 절초 3종",
        "프로젝트 코어가 사용자 승인",
    ):
        assert token in active["mastery"], token

    legacy_context = active["legacy_context"]
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
        assert text.startswith(f"# {entry['title']}\n"), (
            f"registry title drift: {source_path.relative_to(ROOT)}"
        )
        for section in entry.get("required_sections", []):
            assert section in text, (
                f"{source_path.relative_to(ROOT)} missing registry section: {section}"
            )


def assert_ui_and_runtime_boundaries(active: dict[str, str], runtime: dict[str, str]) -> None:
    progress_data = load_json("data/combat/combat_progress_preview.json")
    for value in (
        progress_data["caption"],
        progress_data["ready_text"],
        progress_data["disabled_text"],
        progress_data["requested_text"],
    ):
        assert value in active["ui"], value

    assert '_round_label.text = "제 %d 라운드" % round_number' in runtime["round_hud"]
    assert "제 1 라운드" in active["ui"]
    assert "행동 묶음 1/3" in active["ui"]
    assert "focus_mode = Control.FOCUS_ALL" in runtime["progress"]
    assert "focus_mode = Control.FOCUS_NONE" in runtime["log"]
    assert "`Enter`/`ui_accept`" in active["ui"]
    assert "명시적 포커스" in active["presentation"]
    assert "HUMAN_NOT_RUN" in active["ui"]

    resolve_index = runtime["board"].index("resolution_engine.resolve_bundle")
    advance_index = runtime["board"].index("action_timing_panel.advance_after_resolution")
    assert resolve_index < advance_index
    assert '"timing_results"' in runtime["engine"]
    assert '"presentation_events"' in runtime["engine"]
    assert "await _apply_timing_snapshot" in runtime["board"]
    assert "committed → resolving → presenting_result → next_bundle_ready" in active["ui"]
    assert "planning\n→ committed\n→ resolving\n→ presenting_result\n→ next_bundle_ready" in active["presentation"]


def assert_architecture_matches_runtime(active: dict[str, str], runtime: dict[str, str]) -> None:
    architecture = active["architecture"]
    engine = runtime["engine"]
    timing = runtime["timing"]

    for token in ("round_number", "bundle_index", "player", "enemy", "ai_decision_seed"):
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
        "timing_results",
        "presentation_events",
    ):
        assert f'"{token}"' in engine, token
        assert token in architecture, token

    assert "class_name CombatAiPlanner" in runtime["ai"]
    assert "build_bundle_actions" in runtime["ai"]
    assert "restart_combat()" in runtime["board"]
    assert "restart_combat()" in architecture
    assert "회차 저장·불러오기" in architecture
    assert "T0에는 다음이 없다" in architecture


def assert_workflow_coverage(runtime: dict[str, str]) -> None:
    workflow = runtime["workflow"]
    required_paths = (
        "README.md",
        "docs/**",
        "[[]기획서[]]/**",
        "skills/**",
        "data/cards/**",
        "data/combat/**",
        "src/ui/**",
        "src/combat/**",
        "tests/check_canonical_combat_docs.py",
        "tests/verify_combat_board.gd",
        "tests/verify_response_rules.gd",
        "tests/verify_combat_layout_accessibility.gd",
        "assets/reference/step_02_character_scale_and_tile_placement.svg",
        ".github/reference-freshness.json",
        ".github/workflows/card-component-contract.yml",
        "workflow_dispatch",
    )
    missing = [path for path in required_paths if path not in workflow]
    assert not missing, (
        "Card Component Contract workflow misses consumers: " + ", ".join(missing)
    )
    for command in (
        "python tests/check_card_component_contract.py",
        "python tests/check_combat_board_contract.py",
        "python tests/check_canonical_combat_docs.py",
    ):
        assert command in workflow, command


def main() -> None:
    active = read_files(ACTIVE_TEXT_PATHS)
    runtime = read_files(RUNTIME_PATHS)
    assert_no_stale_active_contract(active, runtime)
    assert_start_position_contract(active, runtime)
    assert_structured_current_rules()
    assert_current_rules_in_documents(active)
    assert_scope_and_document_lifecycle(active)
    assert_design_registry_matches_documents()
    assert_ui_and_runtime_boundaries(active, runtime)
    assert_architecture_matches_runtime(active, runtime)
    assert_workflow_coverage(runtime)
    print("canonical combat impact map for PR #7 / Issue #13: PASS")


if __name__ == "__main__":
    main()
