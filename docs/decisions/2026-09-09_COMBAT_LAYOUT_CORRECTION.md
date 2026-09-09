# 전투 화면 배치와 실제 렌더 경계 교정

```yaml
decision_id: TEN-DEC-20260909-COMBAT-LAYOUT-CORRECTION-01
status: APPROVED_FOR_SCOPED_BUILD
authority: CURRENT_USER_CONTINUOUS_BLUEPRINT_IMPLEMENTATION_AND_CORRECTION
implementation_base: 544fcbbaff0448edf265e381c70ad3d48fd61b7b
protected_baseline: 477697842bf14d95e670f01b0fe815e384b53658
stage: RUNTIME_VERIFIED_BOUNDED_LAYOUT
CODEX_GODOT_PRODUCT_IMPLEMENTATION_HANDOFF: TASKS_1_3_SOURCE_COMMITTED_DELIVERY_PENDING
```

## 문제와 책임 원본

PR335 실제 화면에는 해결 중 하단의 큰 빈 영역, 숨긴 논리 칸에 묶인 작은 전투원, 현재 행동 카드와 효과·문구 중첩이 남았다. `2026-09-02_SCREEN_PARTITION_AND_DISTANT_FRONTAL_DUEL_DECISION.md`의 무대 전용 배경·공유 바닥·인물 높이 상한과 `2026-09-04_THREE_BRANCH_FOUR_CHOICE_JIANGHU_AND_HUMAN_BLUEPRINT_DECISION.md`의 단일 실행·계획 숨김·이번 수 비교를 복원한다. 현재 잘못된 배치를 승인 정본으로 간주하지 않는다.

## 범위 확정과 독립 검토

현재 사용자의 연속 구현·부족한 상세 기본값 보완 승인 안에서 아래46%/실제 렌더 경계·영역·resize 기술 기본값을 controller가 확정한다. 코어/자산 최종 잠금/Human 승인을 새로 선언하지 않는다. 검토 원본 SHA0626f2956be878d16837cfabcf04d388b774a8fc8962f0055eefb0b119e47a61와 동기화 계획 SHA7c32dbc828bec054038c8d2526b8af70b9eed02d35e599871df42417c0a02e2c에 별도 검토자가 APPROVED_FOR_CONTROLLER_BUILD_DISPATCH했다. 최초 L1–5 및 추가 R1 실패 이력을 보존한다. R1 교정은 최종 성공 active Rect2+valid,0.01픽셀 tolerance로 실제 변화만 판정하여 super의 일시 준비 rect 때문에 이동을 중단하지 않는 것이다.

## 채택할 제한된 교정

- 준비 상태는 기존 상단 상태/중단 결투/하단 계획을 유지한다. 실행 시 계획을 닫고 결투 무대를 HUD 아래부터 화면 끝까지 사용하며 모든 timing snapshot이 같은 배치를 유지한다.
- 배경·깃발·틴트는 실제 결투 무대만 채운다. Title의 전체 화면 배경 소비처는 변경하지 않는다.
- 캐릭터 렌더러가 기존 원본의 알파 영역과 실제 draw 변환을 한 번 읽어 캐시한다. 배치와 검증은 Control 크기가 아니라 실제 그려지는 영역을 사용한다. 같은 수식으로 그리기와 측정을 연결하고 매 프레임 image read를 추가하지 않는다.
- 인물의 idle 실제 높이는 무대의46%를 기본값으로 한다. 기존 최대 모션 배율1.12에서51.52%이므로 승인된52% 상한을 지킨다. 조정 상한은 `min(50%,52%/현재모션최대배율)`이다. 이는 사용자에게 최종 시각 승인을 받았다는 뜻이 아닌 되돌릴 수 있는 구현 기본값이다.
- 배치·이동 도중·이동 끝은 동일한 정면 발 위치를 사용한다. 초기 거리2의42% 이상 간격만 보호하며 이후 거리0/1의 기존 간격을 바꾸지 않는다. 실제 무대 크기가 바뀔 때만 진행 중 MOVE tween을 종료하고 새 발 위치에 정렬한다. 판정·시간·다른 모션은 바꾸지 않는다.
- 실행 중 이번 수 비교, 결과 문구, VFX 영역을 분리한다. 준비 중에는 실행 전용 영역을 비우고 숨긴다. 양수 공간을 위조하거나 필요한 문구를 잘라내지 않는다. VFX는 기존 최대 확대까지 영역 안에 맞추며 배치 실패를 두 표시 호출부가 실제로 존중한다.
- 음소거·모션 감소·skip·현재 수만 공개·3/3/4·AI·무공 수치·보상·10전/36행로·저장 schema1은 보존한다. 새 효과/음원/이미지/씬/노드/라이브러리나 전투 의미를 추가하지 않는다.

구체적 수식·구현 경로·회귀와 전달 순서는 `docs/operations/2026-09-09_COMBAT_LAYOUT_IMPLEMENTATION_PLAN.md`가 소유한다. 최초 구현은 10개 경로이며, 아래 PR337의 실제 CI 실패 교정으로 기존 검사기 1개를 추가해 현재 범위는 11개다. 제품 경로는 기존 board 2개와 character renderer 1개뿐이다. 별도 ordered-combat-v2 명세는 이 화면 교정의 의존성이나 승인 대상이 아니다.

## 조사·대안·구현 가능성

CURRENT_SOURCE_RELEVANCE_CHECK: REUSED_CURRENT_WITH_OFFICIAL_REFRESH. 9월1일 정면결투10사례와9월9일 피드백10사례의 같은 공간/현재행동 판단 차원을 재사용한다. 새 deck·전체미래예측·타사그림 복제는 AVOID, 계획/실행 분리와 확정된 이번 수의 명확한 표시는 ADAPT다. 원본 교체, z-index만 변경, 신규 layout framework는 실제 결함을 해결하지 못하거나 범위를 불필요하게 넓혀 제외한다.

Godot의 [CanvasItem 변환](https://docs.godotengine.org/en/stable/classes/class_canvasitem.html), [Tween 취소/수명](https://docs.godotengine.org/en/stable/classes/class_tween.html), [Image의 알파 사용 영역](https://docs.godotengine.org/en/stable/classes/class_image.html)을2026-09-09 직접 재확인했다. 겉 node rect와 실제 draw 변환은 다르며, 사용 영역은 nonzero alpha 기준이다. 기존 이미지 load에서 이를 캐시하고 기존 callback에서 네 모서리/Rect2 연산만 한다. 움직이는 동일 property를 겹쳐 구동하지 않는다. 문서는 API 근거이지 현재 프로젝트의 렌더 성공 증거가 아니다.

FEASIBLE: 실제 소비처와 stage rect/texture/anchor API가 존재한다. 최초 초안의 visible-size/발위치/준비공간/효과재표시/초기간격 오류5개와 배경 정본 충돌을 교정했다. 후속 실제 구현과 검증은 실행 기록이 소유한다. source eda26a97f25a931ac02ba739d5c4921720512d41에서 전체499검사와720/800/1080 native 화면, 긴 한글·도겸·모션·resize·skip을 확인했으나, 자연스러운 글자 배치·인물 접지/중첩·최종 아틀라스 품질 승인은 포함하지 않는다. 별도5회 전체 소스 검토와 캡처 검토의 실제 한계를 보존한다.

Base current remote는 이번 재조회에서도 `2fbb934d987b297f1fc967f0e117f303c8aa1861`이다. 프로젝트의 채택9.4.4/19355 pin을 교체하지 않으며 프로젝트의5회 전체 범위 검토를 유지한다.

## 검증과 복구

prospective behavioral RED → 최소 GREEN → 별도 검토자 → 실제 native 캡처 → 전체 검사 → exact-head CI → 정상 병합 → main readback을 따른다. syntax/import 실패는 행동 RED로 세지 않는다. 기존 approved 이미지/PDF bytes와 미수정 consumer를 함께 검증한다. 새 캡처는 producer 전에 source-absent receipt를 만들고 현재 source와 정확한 engine/session에 묶는다.

실패는 실제 영역·상태·출력으로 기록한다. 필요한 텍스트 숨김, 폰트 축소, 이미지 crop, 모션 배율 변경, 검증 완화로 통과시키지 않는다. rollback은 이번 배치 commit의 정상 revert이며 저장 migration이 없다. 전체 Blueprint, 사람 가독성/선호, 청음, Android/접근성 사용자/출시/권리 PASS는 별도다.

## PR337 exact-CI oracle correction — additional test-only scope

Exact head6433e1f44fa119535360b3ba1c09709713e9ba9d의 Full Validation34313348268에서 `tests/verify_combat_board.gd:479–489`의 comparable-scale assertion1개가 실제실패했다. 이이전검사는 Control.size를실제인물높이로취급하지만 본Decision의alpha-normalized draw는두원본의알파여백이달라서node높이가달라지는것이정상이다. Controller와별도검토자가actualsource/CI원문을대조했다. 추가경로는이test1개뿐이며제품3경로/수치/이미지는그대로다. 같은SIZE_TOLERANCE0.01과52%상한을유지하고, 원본Image의get_used_rect와실제draw/global변환으로독립측정한idle ink를비교한다. 현재모션ink와idle×기존peak의상한을보호하고, 실제enemy.scale.y를0.8로잠시변경하는negative가불일치를검출한뒤즉시복원해야한다. 기존anchor/HUD/domain판정은그대로유지한다. 이는검증완화가아니라승인된책임단위로오래된oracle을교정하는것이며 CI실패는보존한다.

## Task1 evidence-backed scope refinement — retained history

Actual untouched inline verifier reported six overlaps at720/800/1080, all on hidden previous-bundle TimingSlot02/03 (visible=false). Current src/ui/action_timing_panel.gd115–131 explicitly makes only current bundle slots visible. Controller independently read the real diagnostic and source, authorizing only the additional inline verifier path above: verify actual visibility equals current-index membership and exact positive count, then assert non-overlap on every visible slot. Existing timing panel/CTA/card checks remain unchanged. Never move hidden geometry or hide current slots to manufacture PASS. Three product paths, game behavior, fonts, assets and other scope remain unchanged. The old9-path plan hash remains independent-review history; actual tests and final full-scope review must cover this explicit10-path refinement.
