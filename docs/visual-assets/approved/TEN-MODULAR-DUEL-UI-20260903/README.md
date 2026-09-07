# TEN-MODULAR-DUEL-UI-20260903 · final-locked modular frames

The four PNGs in this folder are the canonical approved source copies of the UI modules final-locked by the user with `확정` on 2026-09-03. Their byte-identical runtime destinations are in `res://assets/ui/duel/`; no rejected candidate or character pose sheet was promoted.

| asset | canonical source | runtime destination | SHA-256 | dimensions / RGBA corners | dynamic consumer |
| --- | --- | --- | --- | --- | --- |
| Status HUD | `status_hud_frame_01_v1.png` | `res://assets/ui/duel/status_hud_frame_01_v1.png` | `f2a428e9717b9fa3661ab8ede92df8a7398bb597254e56c1b23b85bd414d1226` | `2172×724`, `0,0,0,0` | `CombatantStatusPanel` |
| Current action slot | `current_action_slot_frame_01_v1.png` | `res://assets/ui/duel/current_action_slot_frame_01_v1.png` | `1df3a70457d45e82716910452a9744f0a0cc8807c3fc6e5d03671131b72e81d6` | `1817×866`, `0,0,0,0` | `ActionTimingSlot` |
| Technique detail | `technique_detail_frame_01_v1.png` | `res://assets/ui/duel/technique_detail_frame_01_v1.png` | `37324331c8aeb6dfce499a61b3b4e4ddc784b608dfd477bc510f34ca4d836f09` | `1049×1499`, `0,0,0,0` | `ActionDetailPanel` |
| Observation reveal | `observation_reveal_frame_01_v1.png` | `res://assets/ui/duel/observation_reveal_frame_01_v1.png` | `b6b71742da3621449dd8ac9aeaf0827af3f199dcb0ac578435e4a87120d1d2ea` | `1156×1361`, `0,0,0,0` | `ObservationRevealPanel` |

Each source was generated with OpenAI built-in image generation and had its exact bytes, `Format32bppArgb` pixel format, RGBA alpha range `0–255`, and transparent corners read back before promotion. The images contain no gameplay values, names, observation result, target, damage, direction, or private plan; Godot renders those public values dynamically. User references informed only broad warm ink-and-gold functional direction. Release rights remain conditional on the project asset-rights review; source registration is not a human UX, Android, accessibility, or release PASS.
