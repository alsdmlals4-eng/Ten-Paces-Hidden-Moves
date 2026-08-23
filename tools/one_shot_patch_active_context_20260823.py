from __future__ import annotations

from pathlib import Path


PATH = Path("[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md")


def replace_once(text: str, old: str, new: str, label: str) -> str:
    count = text.count(old)
    if count != 1:
        raise SystemExit(f"{label}: expected exactly 1 match, found {count}")
    return text.replace(old, new, 1)


def main() -> None:
    text = PATH.read_text(encoding="utf-8")

    before_current, current_and_after = text.split("## 현재 기준", 1)
    current, after_current = current_and_after.split("## 관측 증거 스냅샷", 1)

    current = replace_once(
        current,
        "product_stage: VERTICAL_SLICE_VISUAL_UX_REQUIREMENT_COMPLETE_HANDOFF_READY",
        "product_stage: FIRST_FIVE_DUEL_PHASE_I_VI_IMPLEMENTED",
        "current product stage",
    )
    current = replace_once(
        current,
        "performance_validation: BASELINE_CAPTURED_RELEASE_NOT_RUN\nproduct_implementation_authorized: false",
        "performance_validation: BASELINE_CAPTURED_RELEASE_NOT_RUN\nphase_i_vi_implementation: AUTHORIZED_AND_MERGED\nfuture_product_mutation_authorized: false",
        "implementation authorization split",
    )
    current = replace_once(
        current,
        "플랫폼 Adapter 구현 Gate는 여전히 제품 구현 경계로 유효하다. 사용자는 2026-08-20 `TEN-DEC-20260820-VERTICAL-SLICE-PLANNING-COMPLETE-01` 기준 첫 5전 Vertical Slice 텍스트 기획을 완료 승인했고, 이어 `TEN-DEC-20260820-VISUAL-UX-SYSTEM-01`로 Visual/UX Requirement & Reference Review까지 완료 승인했다. 그러나 어느 승인도 제품 구현 요청 또는 새 이미지 생성 요청과 동일하지 않으므로 `product_implementation_authorized: false`, `planning_visual_generation: USER_EXPLICIT_REQUEST_REQUIRED`를 유지한다. 현재 자동 다음 작업은 없으며 **이미지 자산 제작 또는 제품 구현의 사용자 명시 요청을 대기**한다. 제품 mutation은 별도 구현 요청과 fresh Entry Gate 재검증 뒤에만 허용한다.",
        "플랫폼 Adapter 구현 Gate는 향후 플랫폼 확장 경계로 계속 유효하다. 2026-08-20 `TEN-DEC-20260820-VERTICAL-SLICE-PLANNING-COMPLETE-01`과 `TEN-DEC-20260820-VISUAL-UX-SYSTEM-01` 자체는 제품 구현 권한이 아니었지만, 후속 `TEN-DEC-20260820-PC-FIRST-VERTICAL-SLICE-IMPLEMENTATION-GATE-01`이 첫 5전 PC-first Vertical Slice Phase I–VI 구현을 명시적으로 허용했고 해당 범위는 현재 `main`에 병합됐다. 따라서 현재 상태는 `phase_i_vi_implementation: AUTHORIZED_AND_MERGED`이며, **추가 제품 mutation**만 `future_product_mutation_authorized: false`로 새 명시 요청 + fresh Gate를 요구한다. 새 이미지 생성도 계속 `planning_visual_generation: USER_EXPLICIT_REQUEST_REQUIRED`다.",
        "current implementation explanation",
    )

    after_current = replace_once(
        after_current,
        "planning_pr_2026_08_20_base: 0e9955afe791c43255176a4e89d89cf58be9b76a\n```",
        "planning_pr_2026_08_20_base: 0e9955afe791c43255176a4e89d89cf58be9b76a\nhistorical_pre_phase_i_vi_product_stage: VERTICAL_SLICE_VISUAL_UX_REQUIREMENT_COMPLETE_HANDOFF_READY\nhistorical_pre_phase_i_vi_product_implementation_authorized: false\nphase_i_vi_completion_pr: 183\nphase_i_vi_completion_merge_commit: dfe25dec47f02229ecc5c92cdad7b6e1929525c8\nauthority_bootstrap_pr: 186\nauthority_bootstrap_merge_commit: 43a6e625c57c6f3e50b562e494fec074be553457\n```",
        "historical Phase I-VI evidence",
    )
    after_current = replace_once(
        after_current,
        "- 구현 Handoff: `docs/16_VERTICAL_SLICE_IMPLEMENTATION_HANDOFF_PLAN.md`.",
        "- 구현 Gate: `TEN-DEC-20260820-PC-FIRST-VERTICAL-SLICE-IMPLEMENTATION-GATE-01`, `docs/planning-data/current_vertical_slice_implementation_gate_20260820.json`.\n- Phase I–VI 상태: `AUTHORIZED_AND_MERGED`; exact PR/SHA는 위 관측 증거 스냅샷에서만 역사 증거로 보존한다.\n- 구현 Handoff: `docs/16_VERTICAL_SLICE_IMPLEMENTATION_HANDOFF_PLAN.md`.",
        "current authority implementation gate",
    )
    after_current = replace_once(
        after_current,
        "위 App Flow·상세 계약·Visual/UX 요구사항은 계획 권위다. 사용자 `기획완료`와 후속 Visual/UX 승인은 다음 제작 단계의 기준선을 닫지만 그 자체로 제품 mutation이나 이미지 생성을 허가하지 않는다. PR #65 앱 흐름 기반은 역사·호환 근거이고 현재 구현 권위는 상단 YAML의 `TEN_MANUAL_PRODUCT_VALIDATION_MERGED_PR92`다.",
        "위 App Flow·상세 계약·Visual/UX 요구사항은 계획 권위다. 사용자 `기획완료`와 후속 Visual/UX 승인 자체는 제품 mutation 권한이 아니었고, 이후 `TEN-DEC-20260820-PC-FIRST-VERTICAL-SLICE-IMPLEMENTATION-GATE-01`이 첫 5전 Phase I–VI bounded implementation을 별도로 승인했다. PR #65와 `TEN_MANUAL_PRODUCT_VALIDATION_MERGED_PR92`는 선행 런타임/자동검증 계보로 보존하고, 현재 전체 Phase I–VI 구현 상태는 상단 `phase_i_vi_implementation: AUTHORIZED_AND_MERGED`가 라우팅한다. 새 이미지 또는 추가 제품 mutation은 다시 명시적 요청과 fresh Gate가 필요하다.",
        "planning-to-implementation transition explanation",
    )

    after_current = replace_once(
        after_current,
        "## 현재 Entry Gate\n\n`docs/planning-data/current_entry_gate_20260808.json`의 현재 의미는 다음과 같다.\n\n```yaml\nlocal_windows_core:",
        "## 역사 Entry Gate · 2026-08-08\n\n`docs/planning-data/current_entry_gate_20260808.json`은 Phase I–VI 구현 승인 이전의 플랫폼/제품 pre-implementation Gate다. 후속 `docs/planning-data/current_vertical_slice_implementation_gate_20260820.json`이 첫 5전 Phase I–VI 범위의 current implementation authority를 소유하므로, 이 8월 8일 Gate를 현재 구현 미승인 근거로 재사용하지 않는다. Android/device/Human readiness의 역사 evidence ceiling은 계속 보존한다.\n\n```yaml\nstatus: SUPERSEDED_FOR_PHASE_I_VI_IMPLEMENTATION\nlocal_windows_core:",
        "historical entry gate heading",
    )
    after_current = replace_once(
        after_current,
        "이 Entry Gate는 제품/플랫폼 구현 경계다. 첫 5전 Vertical Slice 텍스트 기획과 Visual/UX Requirement Review는 완료됐지만 제품 구현 권한은 아니다. 위 `REVIEW_VISUAL_UX...`는 허용 가능한 비제품 작업을 열어 둔 기존 Entry Gate 항목이며 현재 사용자-directed Visual review 자체는 이미 완료 상태다. 새 이미지 생성은 사용자 명시 요청이 필요하고, 제품 mutation은 사용자의 별도 구현 요청과 fresh Gate 확인 뒤에만 허용한다. Android 완료, 실제 기기 완료, 사람 검증 완료를 아직 주장하면 안 된다.",
        "이 2026-08-08 Entry Gate는 당시 제품/플랫폼 구현 경계를 기록한 역사 증거다. 이후 2026-08-20 PC-first Vertical Slice 구현 Gate가 Phase I–VI를 별도로 승인했고 해당 bounded 구현은 병합되었다. 따라서 여기의 `product_implementation_authorized: false`는 **당시 pre-implementation 상태**로만 읽는다. 새 이미지 생성과 향후 추가 제품 mutation은 여전히 별도 명시 요청/fresh Gate가 필요하며, Android 실제 기기·Windows visible Human·사람 검증은 실제 실행 전 PASS로 승격하지 않는다.",
        "historical entry gate explanation",
    )
    after_current = replace_once(
        after_current,
        "3. exact Project Notion Home·Work·Flow·Core System 재조회\n4. current_user_planning_status, current_entry_gate, current_operating_state 재조회\n5. live context 의미 상태와 fresh truth 차이 교정",
        "3. exact Project Notion Home·Work·Flow·Core System 재조회\n4. current_user_planning_status, current_vertical_slice_implementation_gate_20260820, current_operating_state 재조회; 플랫폼/device 재인가 작업일 때만 current_entry_gate_20260808을 역사 비교 근거로 추가 확인\n5. live context 의미 상태와 fresh truth 차이 교정",
        "resume gate order",
    )
    after_current = replace_once(
        after_current,
        "5. `docs/planning-data/current_user_planning_status.json`.\n6. `docs/planning-data/current_operating_state.json`.\n7. `docs/planning-data/current_entry_gate_20260808.json`.\n8. exact Project Notion의 `Project Home`, `02 · 비주얼 바이블`, `03 · UI · 전투 Flow Map`, `04 · 에셋 라이브러리`, `09 · 세계관 · 강호 비무행 · Vertical Slice`, `10 · 상대 15명 · 강호행로 8노드 · 텍스트 UX`, `11 · 상대 무공 배정 · Route 예산 · 비전투 Wire`, `12 · Vertical Slice · 기획 완료 기준선`, `13 · 기획 완료 · Visual/구현 Handoff`와 현재 Decision 페이지.\n9. `docs/16_VERTICAL_SLICE_IMPLEMENTATION_HANDOFF_PLAN.md`와 `docs/17_VERTICAL_SLICE_VISUAL_UX_REQUIREMENT_SPEC.md`.\n10. 질문별 분야 책임 원본과 실제 코드·테스트·GitHub PR metadata.",
        "5. `docs/planning-data/current_user_planning_status.json`.\n6. `docs/planning-data/current_operating_state.json`.\n7. `docs/planning-data/current_vertical_slice_implementation_gate_20260820.json`.\n8. `docs/planning-data/current_entry_gate_20260808.json` — 플랫폼/device 과거 pre-implementation Gate 비교가 실제로 필요할 때만 역사 근거로 읽는다.\n9. exact Project Notion의 `Project Home`, `02 · 비주얼 바이블`, `03 · UI · 전투 Flow Map`, `04 · 에셋 라이브러리`, `09 · 세계관 · 강호 비무행 · Vertical Slice`, `10 · 상대 15명 · 강호행로 8노드 · 텍스트 UX`, `11 · 상대 무공 배정 · Route 예산 · 비전투 Wire`, `12 · Vertical Slice · 기획 완료 기준선`, `13 · 기획 완료 · Visual/구현 Handoff`와 현재 Decision 페이지.\n10. `docs/16_VERTICAL_SLICE_IMPLEMENTATION_HANDOFF_PLAN.md`와 `docs/17_VERTICAL_SLICE_VISUAL_UX_REQUIREMENT_SPEC.md`.\n11. 질문별 분야 책임 원본과 실제 코드·테스트·GitHub PR metadata.",
        "cold start read order",
    )
    after_current = replace_once(
        after_current,
        "- 첫 5전 Vertical Slice 텍스트 기획과 Visual/UX Requirement는 완료됐지만 제품 구현은 별도 요청과 fresh Gate 전 `NOT_AUTHORIZED`다.",
        "- 첫 5전 PC-first Vertical Slice Phase I–VI는 승인 범위가 구현·병합됐다. 다만 Windows visible Human usability, Android 실기기, Human 재미·가독성·몰입, 최종 Visual/VFX/Audio는 계속 `NOT_RUN`이며 완료로 승격하지 않는다.",
        "current risk implementation state",
    )
    after_current = replace_once(
        after_current,
        "- Android export preset 및 제품 Adapter 구현은 current Entry Gate가 허용하기 전 완료로 승격하지 않는다.",
        "- Android export preset 및 제품 Adapter 구현은 별도의 fresh platform Entry Gate가 허용하고 실제 검증하기 전 완료로 승격하지 않는다.",
        "current risk platform gate",
    )
    after_current = replace_once(
        after_current,
        "- `product_implementation_authorized: false`를 유지한다.",
        "- `future_product_mutation_authorized: false`를 유지한다. 이는 이미 병합된 Phase I–VI를 부정하지 않고 **새 추가 mutation**만 차단한다.",
        "current risk future mutation",
    )

    new_text = before_current + "## 현재 기준" + current + "## 관측 증거 스냅샷" + after_current
    PATH.write_text(new_text, encoding="utf-8")


if __name__ == "__main__":
    main()
