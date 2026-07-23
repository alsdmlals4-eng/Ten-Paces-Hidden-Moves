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

EXPECTED_BASIC_IDS = [
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

STALE_TOKENS = (
    "플레이어 3번·상대 8번",
    "플레이어 3번 / 상대 8번",
    "플레이어 3번, 상대 8번",
    '"player_start_tile": 3',
    '"enemy_start_tile": 8',
    "var _player_tile := 3",
    "var _enemy_tile := 8",
    "EXPECTED_PLAYER_TILE := 3",
    "EXPECTED_ENEMY_TILE := 8",
    "한 라운드는 행동 타이밍 10개이며 2타이밍씩 묶어 총 5번 선택한다",
    "각 묶음에서 AI와 플레이어는 행동 두 개를 비공개로 잠근 뒤 동시에 공개한다",
    "선택 묶음 | 두 행동 잠금",
    "ActionPair",
    "PairLockCoordinator",
    "기초 행동 7종",
    "한 칸에 한 전투원",
    "같은 칸 중첩 없음",
    "공동 목적지면 둘 다 제자리",
    "현재 상대는 고정 검증 계획",
    "T0의 상대는 정식 AI가 아니다",
    "피격 중단은 아직 구현되지 않았다",
    "STEP 12 성향 기반 AI.",
    "STEP 13 종료·재시작.",
    "같은 단계 공격 동시 피해",
    "Base 공유 Skill 13개",
)


def load_json(relative: str) -> dict:
    return json.loads((ROOT / relative).read_text(encoding="utf-8"))


def read_files(paths: dict[str, Path]) -> dict[str, str]:
    result: dict[str, str] = {}
    for key, path in paths.items():
        assert path.is_file(), f"missing file: {path.relative_to(ROOT)}"
        result[key] = path.read_text(encoding="utf-8", errors="replace")
    return result


def require_all(text: str, tokens: tuple[str, ...], label: str) -> None:
    missing = [token for token in tokens if token not in text]
    assert not missing, f"{label}: missing tokens: {missing}"


def require_any(text: str, alternatives: tuple[str, ...], label: str) -> None:
    assert any(token in text for token in alternatives), (
        f"{label}: none of semantic alternatives found: {alternatives}"
    )


def assert_no_stale_contract(active: dict[str, str], runtime: dict[str, str]) -> None:
    failures: list[str] = []
    for label, text in {**active, **runtime}.items():
        for token in STALE_TOKENS:
            if token in text:
                failures.append(f"{label}: stale token: {token}")
    assert not failures, "active combat references are stale:\n" + "\n".join(failures)


def assert_structured_contract() -> None:
    board = load_json("data/combat/combat_board_poc.json")
    timing = load_json("data/combat/combat_action_timing_preview.json")
    hud = load_json("data/combat/combat_hud_preview.json")
    resolution = load_json("data/combat/combat_resolution_preview.json")
    basic = load_json("data/cards/basic_cards.json")
    ultimates = load_json("data/cards/ultimate_cards.json")

    assert board["schema_version"] == 16
    assert board["tile_count"] == 10
    assert board["player_start_tile"] == 4
    assert board["enemy_start_tile"] == 7
    assert board["enemy_start_tile"] - board["player_start_tile"] == 3

    assert timing["timing_sequence"] == [3, 3, 4]
    assert timing["total_timings"] == 10
    assert resolution["resolution_order"] == ["response", "quick_attack", "move", "general"]
    assert resolution["resolution_order_label"] == "대응 → 속공 → 이동 → 일반 공격"

    engagement = board["engagement"]
    assert engagement["same_tile_allowed"] is True
    assert engagement["max_combatants_per_tile"] == 2
    assert engagement["distance"] == 0
    assert engagement["stationary_opponent_entry_allowed"] is True
    assert engagement["shared_empty_destination_allowed"] is True
    assert engagement["swap_and_pass_forbidden"] is True

    assert resolution["same_tile_engagement"] is True
    assert resolution["same_tile_max_combatants"] == 2
    assert resolution["enemy_plan_source"] == "public_state_ai"
    assert resolution["enemy_bundles"] == {}
    assert resolution["clash_same_timing_attacks"] is True
    assert resolution["clash_damage_uses_defense"] is True
    assert resolution["guard_resolution_order"] == ["subtract_guard_block", "halve_if_same_timing"]
    assert resolution["damage_interrupts_current_timing_actions"] is True
    assert resolution["fortitude_quick_phase_one_slot_only"] is True

    assert board["response_rules"]["guard_block"] == resolution["guard_block"] == 4
    assert board["response_rules"]["stance_guard_multiplier"] == 1.5
    assert board["ultimate_skills"]["activation_momentum"] == ultimates["momentum_cost"] == 5
    assert board["resolution_engine"]["clash_same_timing_attacks"] is True
    assert board["resolution_engine"]["interruption_enabled"] is True
    assert board["resolution_engine"]["fortitude_enabled"] is True

    basic_cards = basic["cards"]
    assert [card["id"] for card in basic_cards] == EXPECTED_BASIC_IDS
    assert len(basic_cards) == 8
    by_id = {card["id"]: card for card in basic_cards}
    assert by_id["basic_move"]["move_range"] == 1
    assert by_id["basic_footwork"]["move_range"] == 2
    assert by_id["basic_footwork"]["internal_cost"] == 1
    assert by_id["basic_heavy_attack"]["action_slots"] == 2
    assert by_id["basic_heavy_attack"]["range_text"] == "2"
    assert by_id["basic_heavy_attack"]["stamina_cost"] == 1
    assert by_id["basic_heavy_attack"]["internal_cost"] == 1
    assert "방어도 차감 뒤" in by_id["basic_guard"]["effect_text"]

    ultimate_cards = ultimates["cards"]
    assert [card["id"] for card in ultimate_cards] == EXPECTED_ULTIMATE_IDS
    by_ultimate = {card["id"]: card for card in ultimate_cards}
    assert by_ultimate["ultimate_ten_paces_wave"]["action_slots"] == 1
    assert by_ultimate["ultimate_cleave_peak"]["action_slots"] == 2
    assert by_ultimate["ultimate_void_sword_qi"]["action_slots"] == 3
    assert "필중" in by_ultimate["ultimate_void_sword_qi"]["tags"]

    for side in ("player", "enemy"):
        assert hud[side]["health"] == [30, 30]
        assert hud[side]["stamina"] == [5, 5]
        assert hud[side]["internal"] == [4, 4]
        assert hud[side]["momentum"] == [0, 5]
        assert hud[side]["attack_power"] == 8


def assert_document_semantics(active: dict[str, str]) -> None:
    current_docs = (
        "readme",
        "game",
        "rules",
        "roadmap",
        "poc",
        "ui",
        "qa",
        "architecture",
        "presentation",
        "hub_context",
    )
    for key in current_docs:
        require_all(active[key], ("3수 → 3수 → 4수",), key)

    for key in ("readme", "game", "rules", "content", "poc", "ui", "qa", "hub_context"):
        require_all(active[key], ("기초 행동 8종", "절초 3종"), key)

    for key in ("readme", "game", "rules", "poc", "ui", "qa", "architecture", "presentation", "hub_context"):
        require_any(active[key], ("[합]", "`[합]`", " 합 ", "합·"), f"{key} clash")

    for key in ("readme", "game", "rules", "poc", "architecture", "hub_context"):
        require_all(active[key], ("공개 상태", "AI"), key)

    require_all(active["rules"], ("4번", "7번", "abs(4 - 7) = 3", "같은 타일의 거리는 0", "방어도 차감", "[필중]", "CombatAiPlanner", "결전 다시 시작"), "rules")
    require_all(active["poc"], ("STEP 14", "NOT_RUN", "공개 상태"), "poc")
    require_all(active["qa"], ("BOARD-002", "CLASH-001", "AI-001", "RESTART-001", "STEP 14 사람 플레이"), "qa")

    require_all(active["content"], ("CURRENT_T0", "PLANNED_T1", "HYPOTHESIS_T2_PLUS", "HOLD"), "content")
    require_all(active["mastery"], ("T1 이후 가설 원본", "현재 T0에는 세력 선택", "공용 절초 3종", "프로젝트 코어가 사용자 승인"), "mastery")

    legacy = active["legacy_context"]
    require_all(legacy, ("DEPRECATED_ENTRYPOINT", "독립적으로 보관하지 않는다"), "legacy context")
    assert "## 제품 계약" not in legacy
    assert "## 현재 상태" not in legacy


def assert_runtime_consumers(runtime: dict[str, str]) -> None:
    require_all(runtime["board"], ("var _player_tile := 4", "var _enemy_tile := 7", 'contract.get("player_start_tile", 4)', 'contract.get("enemy_start_tile", 7)', "resolution_engine.resolve_bundle", "action_timing_panel.advance_after_resolution", "await _apply_timing_snapshot"), "board runtime")
    require_all(runtime["board_verifier"], ("EXPECTED_PLAYER_TILE := 4", "EXPECTED_ENEMY_TILE := 7", "from 4 to 5", "from 7 to 6", "from tile 4 to tile 6"), "board verifier")
    require_all(runtime["response_verifier"], ("PLAYER_START_TILE := 4", "ENEMY_START_TILE := 7", "RESPONSE_RULES_10_6_START_4_7_VERIFY_OK"), "response verifier")
    require_all(runtime["reference_svg"], ("플레이어 4번 / 상대 7번", "플레이어 · 4번 칸", "상대 · 7번 칸"), "reference SVG")
    require_all(runtime["ai"], ("class_name CombatAiPlanner",), "AI planner")
    require_all(runtime["engine"], ('"timing_results"', '"presentation_events"', "_build_presentation_events", "state_before_resolution"), "resolution engine")
    require_all(runtime["progress"], ("focus_mode = Control.FOCUS_ALL",), "progress button")
    require_all(runtime["log"], ("focus_mode = Control.FOCUS_NONE",), "combat log")
    assert "scroll_to_line" not in runtime["log"]
    assert "scroll_to_paragraph" not in runtime["log"]
    require_all(runtime["round_hud"], ('_round_label.text = "제 %d 라운드" % round_number',), "round HUD")


def assert_registry_and_lifecycle() -> None:
    registry = json.loads(DESIGN_REGISTRY_PATH.read_text(encoding="utf-8"))
    documents = registry.get("documents", [])
    assert len(documents) == 11
    seen: set[Path] = set()
    for entry in documents:
        assert entry.get("status") == "ACTIVE"
        assert entry.get("publication_policy") == "source_only"
        source_path = (DESIGN_REGISTRY_PATH.parent / str(entry["source_path"])).resolve()
        assert source_path.is_file(), source_path
        assert source_path not in seen, source_path
        seen.add(source_path)
        text = source_path.read_text(encoding="utf-8")
        assert text.startswith(f"# {entry['title']}\n"), f"registry title drift: {source_path.relative_to(ROOT)}"
        for section in entry.get("required_sections", []):
            assert section in text, f"{source_path.relative_to(ROOT)} missing registry section: {section}"

    references: list[str] = []
    for path in ROOT.rglob("*.md"):
        if path == ACTIVE_TEXT_PATHS["legacy_context"]:
            continue
        if any(part in {".git", ".godot", "[백업]", "[보류]"} for part in path.parts):
            continue
        text = path.read_text(encoding="utf-8", errors="replace")
        if "docs/ACTIVE_CONTEXT.md" in text:
            references.append(str(path.relative_to(ROOT)))
    assert not references, "active Markdown references deprecated docs/ACTIVE_CONTEXT.md: " + ", ".join(references)


def assert_workflow_coverage(runtime: dict[str, str]) -> None:
    workflow = runtime["workflow"]
    for token in (
        '"docs/**"',
        '"[[]기획서[]]/**"',
        '"skills/**"',
        '"data/cards/**"',
        '"data/combat/**"',
        '"src/ui/**"',
        '"src/combat/**"',
        '"tests/check_canonical_combat_docs.py"',
        'workflow_dispatch:',
        'python tests/check_card_component_contract.py',
        'python tests/check_combat_board_contract.py',
        'python tests/check_canonical_combat_docs.py',
    ):
        assert token in workflow, f"workflow missing coverage token: {token}"


def main() -> None:
    active = read_files(ACTIVE_TEXT_PATHS)
    runtime = read_files(RUNTIME_PATHS)
    assert_no_stale_contract(active, runtime)
    assert_structured_contract()
    assert_document_semantics(active)
    assert_runtime_consumers(runtime)
    assert_registry_and_lifecycle()
    assert_workflow_coverage(runtime)
    print("canonical combat impact map: PASS")


if __name__ == "__main__":
    main()
