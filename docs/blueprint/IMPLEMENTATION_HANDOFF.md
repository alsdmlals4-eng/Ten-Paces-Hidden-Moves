# 최종 승인 후 구현 인수 계약

상태: `USER_APPROVED / CODEX_IMPLEMENTATION_VALIDATING`.
2026-09-11 사용자의 최종 확정과 `맞아 진행해`에 따라 아래 계약을 실제 구현했다.
현재 실행 증거는 docs/operations/2026-09-11_VARIABLE_ROSTER_IMPLEMENTATION.md를 따른다.
이하 승인 전 문구는 원래 계약의 조건 설명이며 이미 기록된 사용자 확정을 취소하지 않는다.
2026-09-11 사용자는 이전 권장안의 기획·자산 후보·검증 준비 작업을 계속하도록 승인했고,
다른 프로젝트 Blueprint 참고를 요구에서 제외했다. 게임의 새 기획 적용과 신규 원화 final lock은 최종 검토 뒤다.
기준 main `885c91ee934a6f096c79c7d0cfb5f31db4de7f5c`, 문서 분기 시작 `6d84832dedeba4c66097bdfd061891a8fdffc108`.
구현자는 이 SHA를 영구 pin으로 사용하지 않고 승인된 최종 commit과 main을 다시 읽는다.

## 원본·consumer·수정 순서

| 책임 | 실제 기존 파일 | 승인 후 변경 | 완료 증거 |
|---|---|---|---|
| 기획 원본 | docs/blueprint/OPPONENT_BUDGET.json / OPPONENT_PRESENTATION.json | 인물별 가변 무공·네 단계 별호. 단계 계산은 tools/build_opponent_stage_blueprint.py | 16명160행, 비용/성수/기술 해금·반례 검사 |
| 후보 정의 | data/run/vertical_slice_opponents.json | 기존15명 ID 유지, 백무진 추가, 각 인물의 대표·연계 무공·성장·원화 locator | 모든 ID resolve, 원래 대표 무공 유지 |
| 생성·조회 | src/run/vertical_slice_opponent_catalog.gd | 새 여정용 가중 추첨/확정 roster 조회 추가. 기존 CAMPAIGN_ORDER는 v1 경로 유지 | 동일 버전·시드 결과 일치, 반복 인물도 만남ID 분리 |
| 회차 상태 | src/run/vertical_slice_run_state.gd | 새 여정 생성 시10건 확정, 현재 stage로 조회, snapshot/보상 대조 변경 | 이어하기·재도전·정탐에서 재추첨0 |
| 화면 | src/run/vertical_slice_shell.gd | 대표1권을 만남의 배열로 연결. 브리핑·현재 상대 표시는 같은 만남 | 2/3/4/5권 표시와 실제 바인딩 일치 |
| 전투 바인딩 | src/run/vertical_slice_combat_bridge.gd | 기존 복수 배열 인터페이스 재사용, 최종능력·성수·제약 적용 순서 통일 | 보너스 중복 가산0, 제약 전후 실제 정의 대조 |
| 전투 저장 | src/run/combat_checkpoint_codec.gd | size=1·signature seed 대조를 v1/v2 구분, v2는 만남과 무공 집합·성수 일치 검사 | 임의 무공 삽입/성수 변경/빈 배열/중복 거부 |
| 회차 저장 | src/run/run_checkpoint_codec.gd | v1 엄격 경로 보존, v2 schema/ruleset/roster cross-validation | 구형 fixture 완주, 잘못된 identity 원본 보존 거부 |
| 효과·AI | src/combat/martial_manual_registry.gd / combat_resolution_engine.gd | 현재 적 사용 가능 정의·차단 위치를 먼저 검증하고 관찰 전용 권한을 보호하며 복수 편성 허용 | 적 관찰0, 미확정 계획 변형에도 AI 공개 입력 같으면 결과 같음 |
| 전투 인물 | src/combat/combat_character_placeholder.gd | 승인 모션 보호; 새 도감 원화를 전투 프레임으로 대체하지 않음 | 기존 캐릭터·동작 bytes 불변 |

추가 모듈이 필요하면 기존 catalog의 생성 함수로 먼저 구현한다. 저장·화면·전투별 생성기를
새로 만들지 않는다. 기획 생성 Python을 게임 runtime의 실행 의존성으로 들이지 않는다.

## 새 저장 스키마 상세

새 필드 외 기존 envelope의 save_id/checkpoint_id/revision/active/written_at_utc/app_version/
content_identity/run_state/combat_checkpoint/integrity_hash 의미와 엄격 크기 제한을 유지한다.

```json
{
  "schema_version": 2,
  "ruleset_id": "ten-duel-variable-roster-v2",
  "roster_version": 1,
  "roster_seed": 12345,
  "resolved_encounters": [
    {
      "encounter_id": "<save_id>:01",
      "candidate_id": "masked_baekmujin",
      "stage": 1,
      "epithet_key": "masked_baekmujin.reputation.1",
      "stats": {"external": 4, "constitution": 4, "agility": 4, "internal_power": 4, "insight": 4},
      "manuals": [{"id": "mount_hua_plum_blossom_sword", "mastery": 3}],
      "resource_caps": {"health": 30, "stamina": 5, "internal": 4},
      "source_revision": "<approved-content-revision>"
    }
  ],
  "roster_digest": "<canonical-json-sha256>"
}
```

이 JSON은 키 모양 예시이며 실행 fixture가 아니다. 실제 roster는 정확히10건, 단계1~10,
인물별 최종능력과 모든 무공은 검증된160행에서 복사한다. 예시의 균등 능력·한 권 배열을
실행 기본값으로 쓰지 않는다. 저장 digest는 정규화한10건 전체에 대해 계산한다.
번역 문구 대신 epithet_key를 저장하고 승인된 content revision으로 문자열을 resolve한다.

### 검증 불변식

- stage는1~10 정수, 각1개. encounter_id는 모두 유일하며 save_id/단계와 일치.
- roster 생성 함수에는 플레이어 현재 계획·UI 상태를 인수로 주지 않는다.
- 현재 opponent_id/성수/능력/공개계획 바인딩은 resolved_encounters[current_stage-1]과 일치.
- 무공 ID는 유일·실재, mastery는3~10 정수(bool 금지), 대표 ID는 원래 인물과 일치.
- 2~5는 이번 콘텐츠의 결과이지 엔진 장착 제한이 아니다. 저장 안전 상한은 해당 ruleset의 승인 catalog로 정한다.
- 자원 상한30/5/4, 기세·방어·회피는 원래 도메인에서 관리. 능력 합계의 성장 보너스 중복 가산 금지.
- 새 여정에서 확정한10건을 저장하기 전 전투 화면으로 넘어가지 않는다. 실패 시 재시도에서 같은 임시 roster를 사용.
- 보상 전수는 기존처럼 대표 무공3성. 보조 보유를 전수 확대 승인으로 해석하지 않는다.
- v2 미래 상대 전체는 persistence 내부에만 존재. 화면/AI에는 현재 허용 view만 제공.

## 추첨과 단계 계산

인물ID 정렬 → 전용 RNG → 100의 기본 가중치에 직전 같은 인물25%, 같은 runtime archetype50%를
곱해 정수 내림(모두 해당12) → 정수 누적구간 추첨 → 해당 단계의 기획 수치 복사. 10회 고정.
두 조건은 중첩한다. 같은 인물 반복은 허용되며 강제10명 고유가 아니다. 직전 유형·인물은
확정 roster에서만 읽고 추가 재추첨하지 않는다. 실패·이어하기는 roster를 읽으므로 RNG 호출0.
Godot RNG 알고리즘은 버전 간 불변 보장이 없으므로 seed 단독 복원 금지.

각 인물의 최종 성수·취득 권수는 OPPONENT_BUDGET의 loadouts가 소유한다. 단계별 비용 비율은
0/4/10/17/25/36/49/64/81/100%. 목표까지 남은 무공 중 현재 소비 비용/최종 비용 비율이 가장 낮고
남은 예산으로 다음 성수를 살 수 있는 무공을 올린다. 동률은 authored 배열 순서. 3성 목표는 제외.
총 예산을 초과하지 않고 이월하며10전에는 목표와 완전히 일치해야 한다. 이는 초기 튜닝 배분이고
서로 다른 비용34~76점과 취득2~5권을 전투력 등가로 합치지 않는다.

## 구형 저장 호환과 롤백

v1의 현재 엄격 codec/catalog/ruleset을 승인 구현 시작 시 고정된 호환 provider로 보존한다.
신형 카탈로그를 기존 identity 함수에 그대로 섞지 않는다. 버전 dispatcher는 v1 검증을 먼저
그대로 통과시킨 뒤 v1 경로에서만 계속 플레이하게 한다. 새 여정만 v2를 생성한다.
v1의 진행 상대·성수·제약·자원·공개계획·보상 ledger를 신형으로 묵시 변환하지 않는다.

기존 user save 파일은 해시/bytes가 같은 백업을 보존한다. v2 파일과 활성 포인터를 분리하며
쓰기→flush/close→재읽기 검증→포인터 전환 순서. 실패하면 원본을 유지하고 재시도 UI.
임의 파일 경로를 save payload에서 실행하거나 trust하지 않는다. corrupt/unknown/version mismatch는
명확한 상태로 거부하고 bytes를 남긴다. 롤백 빌드로 v2를 열어 v1으로 덮어쓰지 않는다.

## 첫 구현 작업의 RED 회귀 목록

1. 16×10 모든 행에서 기술/강화 unlock_star, 성수·능력 단조성, 최종 목표와 실제 비용 일치.
2. 같은 engine/version/seed는 같은10건. 10,000개 시드의 각 인물·유형·연속 반복 분포를 보고.
3. roster 확정 후 저장 실패→재시도·재실행·재도전·정탐에서10건 byte-normalized hash 불변.
4. v1 준비/COMMITTED/RESOLVED/승리보상/행로/패배 fixture 읽기·이어하기·완주. COMMITTED 한 번 해결,
   RESOLVED 재실행0·보상 중복0·36행로·최종10전 뒤 행로 없음.
5. v2 2/3/4/5권 바인딩: shell→bridge→실제 카드 정의→codec 복원 같음.
6. 천기암기록5성 등 observation 효과 포함 카드: registry의 실제 enemy filter 처리와 최종 실행을 검사.
   현재 구현이 해당 카드를 전부 막으면 그 동작부터 보존한다. 공격만 남기는 새로운 정의는 별도 검토.
7. 적 observation point·reveal·미확정 플레이어 계획·숨은 배치·UI 의도 접근0. 같은 공개 상태에서
   플레이어 미확정 계획만 바꿔 AI 후보/결과가 달라지면 실패.
8. 제약이 복수 무공 전체에 적용되되 대표 보상은 그대로. stat 보너스 이중 가산0.
9. 도감16명·브리핑·현재 전투 인물ID·이름·별호 일치. 모든 화면 해상도·입력·모션 감소에서 확인.

예정 테스트 파일은 기존 tests의 해당 회귀 파일을 확장하거나 역할별 새 파일로 작성한다.
이번 Python 기획 테스트는 4~9번 Godot 통합 실행을 대신하지 않는다.

## 자산과 제작 경계

docs/blueprint/ASSET_READINESS.json은 원화 후보 hash/용도/목표 consumer를 소유한다.
승인 뒤에만 assets/characters/portraits/<candidate_id>_portrait_v1.png로 복사하고 manifest를 연결한다.
도감·브리핑은 KEEP_ASPECT_CENTERED, 원화 일반/호버/선택/비활성은 동일 그림+UI 표현을 사용한다.
캐릭터 frame animation을 정적 도감 원화로 자동 변환하지 않는다. 최종 자산 승인은
신규 그림의 provenance/출시 약관 검증이나 모든 무기 모션을 승인한 것으로 확대하지 않는다.

이번 패키지로 모든 전투 모션 자산이 ASSET_READY가 되는 것은 아니다. 첫 구현의 저장·편성·도감
연결에는 기존 승인 모션과 새 승인 도감 그림을 쓰고, 무기군 고유 모션은 명시된 상태표에 따라 후속 제작한다.

## 근거와 한계

2026-09-11 Godot 공식 [Saving games](https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html)
의 저장 대상 분리와 JSON 한계, [RandomNumberGenerator](https://docs.godotengine.org/en/stable/classes/class_randomnumbergenerator.html)
의 seed/state 및 버전 한계를 참고했다. stable 문서는 exact 4.7.1 runtime 검증이 아니다.
TextureRect 공식 페이지는 이번 조회 오류로 출처 PASS로 세지 않았으며, 프로젝트 실제 사용 코드를 대조했다.
기능을 새로 늘리기보다 기존 단일 engine/bridge·엄격 codec·도메인 owner를 재사용한다.
