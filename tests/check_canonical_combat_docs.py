from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REGISTRY = ROOT / "[기획서]/DESIGN_DOCUMENT_REGISTRY.json"

DOCS = {
    "readme": "README.md",
    "legacy": "docs/ACTIVE_CONTEXT.md",
    "game": "docs/01_GAME_DESIGN.md",
    "rules": "docs/02_COMBAT_RULES.md",
    "content": "docs/03_CONTENT_CATALOG.md",
    "roadmap": "docs/04_ROADMAP.md",
    "poc": "docs/05_COMBAT_POC_SPEC.md",
    "mastery": "docs/06_STARTING_FACTION_MASTERY_DATA.md",
    "ui": "docs/07_COMBAT_UI_SPEC.md",
    "qa": "docs/08_TEST_CHECKLIST.md",
    "architecture": "docs/09_COMBAT_SYSTEM_ARCHITECTURE.md",
    "presentation": "docs/10_COMBAT_PRESENTATION_PLAN.md",
    "learning": "docs/11_BASE_ADOPTION_AND_LEARNING_LOG.md",
    "hub": "[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md",
}

RUNTIME = {
    "engine": "src/combat/combat_resolution_engine.gd",
    "ai": "src/combat/combat_ai_planner.gd",
    "board": "src/combat/combat_board_preview.gd",
    "board_test": "tests/verify_combat_board.gd",
    "response_test": "tests/verify_response_rules.gd",
    "rival_test": "tests/verify_ai_rival_tendency.gd",
    "pr_workflow": ".github/workflows/documentation-governance.yml",
    "full_workflow": ".github/workflows/full-validation.yml",
}

BASIC_IDS = [
    "basic_move", "basic_footwork", "basic_guard", "basic_evade",
    "basic_quick_attack", "basic_heavy_attack", "basic_meditate", "basic_stance",
]
ULTIMATE_IDS = [
    "ultimate_ten_paces_wave", "ultimate_cleave_peak", "ultimate_void_sword_qi",
]

STALE = (
    "플레이어 3번·상대 8번",
    "플레이어 3번 / 상대 8번",
    '"player_start_tile": 3',
    '"enemy_start_tile": 8',
    "var _player_tile := 3",
    "var _enemy_tile := 8",
    "EXPECTED_PLAYER_TILE := 3",
    "EXPECTED_ENEMY_TILE := 8",
    "2타이밍씩 묶어 총 5번",
    "행동 두 개를 비공개로 잠근 뒤 동시에 공개",
    "ActionPair",
    "PairLockCoordinator",
    "기초 행동 7종",
    "한 칸에 한 전투원",
    "같은 칸 중첩 없음",
    "공동 목적지면 둘 다 제자리",
    "현재 상대는 고정 검증 계획",
    "피격 중단은 아직 구현되지 않았다",
    "같은 단계 공격 동시 피해",
    "Base 공유 Skill 13개",
)


def text(relative: str) -> str:
    path = ROOT / relative
    assert path.is_file(), f"missing file: {relative}"
    return path.read_text(encoding="utf-8", errors="replace")


def data(relative: str) -> dict:
    return json.loads(text(relative))


def all_tokens(value: str, tokens: tuple[str, ...], label: str) -> None:
    missing = [token for token in tokens if token not in value]
    assert not missing, f"{label}: missing {missing}"


def any_token(value: str, tokens: tuple[str, ...], label: str) -> None:
    assert any(token in value for token in tokens), f"{label}: none of {tokens}"


def verify_structured_contract() -> None:
    board = data("data/combat/combat_board_poc.json")
    timing = data("data/combat/combat_action_timing_preview.json")
    hud = data("data/combat/combat_hud_preview.json")
    resolution = data("data/combat/combat_resolution_preview.json")
    tendency = data("data/combat/combat_rival_tendency_poc.json")
    basics = data("data/cards/basic_cards.json")
    ultimates = data("data/cards/ultimate_cards.json")

    assert (board["schema_version"], board["tile_count"]) == (17, 10)
    assert (board["player_start_tile"], board["enemy_start_tile"]) == (4, 7)
    assert timing["timing_sequence"] == [3, 3, 4]
    assert timing["total_timings"] == 10
    assert resolution["resolution_order"] == ["response", "quick_attack", "move", "general"]

    engagement = board["engagement"]
    assert engagement == {
        "same_tile_allowed": True,
        "max_combatants_per_tile": 2,
        "distance": 0,
        "label": "밀착",
        "range_one_or_more_automatic": True,
        "stationary_opponent_entry_allowed": True,
        "shared_empty_destination_allowed": True,
        "swap_and_pass_forbidden": True,
    }

    assert resolution["enemy_plan_source"] == "public_state_ai"
    assert resolution["enemy_bundles"] == {}
    assert resolution["clash_same_timing_attacks"] is True
    assert resolution["clash_damage_uses_defense"] is True
    assert resolution["guard_resolution_order"] == ["subtract_guard_block", "halve_if_same_timing"]
    assert resolution["damage_interrupts_current_timing_actions"] is True
    assert resolution["fortitude_quick_phase_one_slot_only"] is True

    assert tendency["schema_version"] == 1
    assert tendency["active_rival_id"] == "rival_t0_midrange_pressure"
    assert tendency["max_candidates"] == 3
    assert float(tendency["score_window"]) == 2.0
    assert [profile["id"] for profile in tendency["profiles"]] == ["rival_t0_midrange_pressure"]

    assert board["response_rules"]["guard_block"] == resolution["guard_block"] == 4
    assert board["response_rules"]["stance_guard_multiplier"] == 1.5
    assert board["ultimate_skills"]["activation_momentum"] == ultimates["momentum_cost"] == 5
    assert board["resolution_engine"]["interruption_enabled"] is True
    assert board["resolution_engine"]["fortitude_enabled"] is True

    basic_cards = basics["cards"]
    assert [card["id"] for card in basic_cards] == BASIC_IDS
    by_basic = {card["id"]: card for card in basic_cards}
    assert by_basic["basic_footwork"]["move_range"] == 2
    assert by_basic["basic_heavy_attack"]["action_slots"] == 2
    assert "방어도 차감 뒤" in by_basic["basic_guard"]["effect_text"]

    ultimate_cards = ultimates["cards"]
    assert [card["id"] for card in ultimate_cards] == ULTIMATE_IDS
    by_ultimate = {card["id"]: card for card in ultimate_cards}
    assert [by_ultimate[card_id]["action_slots"] for card_id in ULTIMATE_IDS] == [1, 2, 3]
    assert "필중" in by_ultimate["ultimate_void_sword_qi"]["tags"]

    for side in ("player", "enemy"):
        assert hud[side]["health"] == [30, 30]
        assert hud[side]["stamina"] == [5, 5]
        assert hud[side]["internal"] == [4, 4]
        assert hud[side]["momentum"] == [0, 5]
        assert hud[side]["attack_power"] == 8


def verify_documents() -> None:
    docs = {key: text(path) for key, path in DOCS.items()}
    runtime = {key: text(path) for key, path in RUNTIME.items()}

    failures = [
        f"{label}: {token}"
        for label, value in {**docs, **runtime}.items()
        for token in STALE
        if token in value
    ]
    assert not failures, "stale active references:\n" + "\n".join(failures)

    sequence_forms = ("3수 → 3수 → 4수", "3/3/4", "[3,3,4]", "[3, 3, 4]")
    for key in ("readme", "game", "rules", "roadmap", "poc", "ui", "qa", "architecture", "hub"):
        any_token(docs[key], sequence_forms, f"{key} timing sequence")

    for key in ("readme", "game", "rules", "poc", "hub"):
        all_tokens(docs[key], ("4", "7", "합", "공개 상태", "AI"), key)

    all_tokens(docs["rules"], ("abs(4 - 7) = 3", "같은 타일의 거리는 0", "방어도 차감", "필중", "CombatAiPlanner", "결전 다시 시작"), "rules")
    all_tokens(docs["poc"], ("STEP 14", "NOT_RUN", "공개 상태"), "poc")
    all_tokens(docs["qa"], ("BOARD-002", "CLASH-001", "AI-001", "RESTART-001", "STEP 14 사람 플레이"), "qa")
    all_tokens(docs["content"], ("CURRENT_T0", "PLANNED_T1", "HYPOTHESIS_T2_PLUS", "HOLD"), "content")
    all_tokens(docs["mastery"], ("T1 이후 가설 원본", "현재 T0에는 세력 선택", "공용 절초 3종", "프로젝트 코어가 사용자 승인"), "mastery")

    all_tokens(docs["legacy"], ("DEPRECATED_ENTRYPOINT", "독립적으로 보관하지 않는다"), "legacy")
    assert "## 제품 계약" not in docs["legacy"]
    assert "## 현재 상태" not in docs["legacy"]

    all_tokens(runtime["board"], ("var _player_tile := 4", "var _enemy_tile := 7", "resolution_engine.resolve_bundle", "await _apply_timing_snapshot"), "board")
    all_tokens(runtime["board_test"], ("EXPECTED_PLAYER_TILE := 4", "EXPECTED_ENEMY_TILE := 7"), "board test")
    all_tokens(runtime["response_test"], ("PLAYER_START_TILE := 4", "ENEMY_START_TILE := 7"), "response test")
    all_tokens(runtime["ai"], ("class_name CombatAiPlanner", "get_last_trace", "public_snapshot", "candidate_ids", "ai_decision_seed"), "AI")
    all_tokens(runtime["rival_test"], ("AI_RIVAL_TENDENCY_VERIFY_OK", "TRACE_KEYS", "SNAPSHOT_KEYS"), "rival test")
    all_tokens(runtime["engine"], ('"timing_results"', '"presentation_events"', "_build_presentation_events"), "engine")

    all_tokens(runtime["pr_workflow"], ("name: PR Validation", "Classify changed paths", "python tests/check_rival_tendency_contract.py", "cancel-in-progress: true"), "PR workflow")
    all_tokens(runtime["full_workflow"], ("name: Full Validation", "ubuntu-latest", "windows-latest", "tests/verify_ai_rival_tendency.gd", "cancel-in-progress: true"), "full workflow")


def verify_registry() -> None:
    registry = json.loads(REGISTRY.read_text(encoding="utf-8"))
    documents = registry.get("documents", [])
    assert len(documents) == 11
    seen: set[Path] = set()
    for entry in documents:
        assert entry.get("status") == "ACTIVE"
        assert entry.get("publication_policy") == "source_only"
        source = (REGISTRY.parent / str(entry["source_path"])).resolve()
        assert source.is_file() and source not in seen
        seen.add(source)
        source_text = source.read_text(encoding="utf-8")
        assert source_text.startswith(f"# {entry['title']}\n")
        for section in entry.get("required_sections", []):
            assert section in source_text, f"{source.relative_to(ROOT)} missing {section}"
    bad_refs: list[str] = []
    for path in ROOT.rglob("*.md"):
        if path == ROOT / DOCS["legacy"]:
            continue
        if any(part in {".git", ".godot", "[백업]", "[보류]"} for part in path.parts):
            continue
        if "docs/ACTIVE_CONTEXT.md" in path.read_text(encoding="utf-8", errors="replace"):
            bad_refs.append(str(path.relative_to(ROOT)))
    assert not bad_refs, "deprecated ACTIVE_CONTEXT references: " + ", ".join(bad_refs)


def main() -> None:
    verify_structured_contract()
    verify_documents()
    verify_registry()
    print("canonical combat impact map: PASS")


if __name__ == "__main__":
    main()
