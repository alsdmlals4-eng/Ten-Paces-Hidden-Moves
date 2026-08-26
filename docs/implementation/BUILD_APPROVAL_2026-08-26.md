# Dogyeom Status Portrait Runtime Binding Build Approval

- Gate: `TEN-DEC-20260826-VISUAL-CONSUMER-ASSET-PRODUCTION-01`
- Approved on: `2026-08-26 KST`
- Approval source: user approvals `6개 모두 승인`, `승인`, and continued execution instruction `작업 계속 진행해`
- Issue / PR: `#208` / `#209`
- Authority level: `SCOPED_DOGYEOM_STATUS_PORTRAIT_RUNTIME_BINDING_ONLY`

## Approved scope

This build may make only the approved `DOGYEOM_STATUS_PORTRAIT_01_v1` usable in the existing combatant status portrait slot:

1. add the approved local PNG and its manifest entry;
2. preserve the existing `STRETCH_KEEP_ASPECT_COVERED` display mode;
3. route `slot1_dogyeom` to that PNG at runtime and retain the existing generic enemy portrait for every other or missing candidate ID;
4. carry the already-selected opponent candidate ID into the combat state consumed by the status panel;
5. add focused automated Godot coverage, related regression coverage, workflow triggering, and current-state documentation.

## Protected invariants

- No combat formula, AI-information boundary, manual effect, opponent-selection rule, save schema, or platform adapter change.
- No runtime routing for candidates other than `slot1_dogyeom`.
- No claim of Windows human-readability, Android device, or battlefield-battler routing validation.
- No new image generation or visual style modification; the asset is the explicitly user-approved non-generative derivative.

## Validation ceiling

- focused and bridge Godot headless verification: required;
- project contract and affected Python tests: required;
- CI / PR checks: required;
- Windows human visual/readability: `NOT_RUN`;
- Android physical device: `NOT_RUN`;
- battlefield battler routing: `NOT_RUN`.
