from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OLD_IDENTITIES = {
    "3f2c4a624d302b704c1b5322eb5c9f34ad55abb9": "7dd1a4f80388bc5faca767ff74a3eb32dc9d0ac8",
    "ff117d24d5bdb121314e109a6aa9b4f552e0fdc1": "da33a350d61b8adc52df97fccc7001708a933370",
    "87a0b54c2847ce4b685879209205957c170cc1cd": "0b7c94f38d959efc0fc9442274c60b2e268a3c97",
    "dd705d7f48a7919187bc0507610ba5fc5b43a658": "7dd1a4f80388bc5faca767ff74a3eb32dc9d0ac8",
    "0c6cdd128bf1f5782e96b3a6240c9585f8d1ef6d": "da33a350d61b8adc52df97fccc7001708a933370",
    "ac9466edc2d93b59f274c9ac55ca719eba2809e3": "0b7c94f38d959efc0fc9442274c60b2e268a3c97",
}

changed: list[str] = []
for path in sorted((ROOT / "tests").rglob("*.py")):
    text = path.read_text(encoding="utf-8")
    if "PROJECT_BASE_ADAPTER.json" not in text and "base_release" not in text:
        continue
    updated = text
    for old, new in OLD_IDENTITIES.items():
        updated = updated.replace(old, new)
    updated = updated.replace('"9.4.1"', '"9.4.3"').replace("'9.4.1'", "'9.4.3'")
    updated = updated.replace('"9.4.2"', '"9.4.3"').replace("'9.4.2'", "'9.4.3'")
    if "planning_first_governance" in text or "v942_planning_first" in path.name:
        updated = updated.replace("base-v9.4.2.lock.json", "base-v9.4.3.lock.json")
    if updated != text:
        path.write_text(updated, encoding="utf-8")
        changed.append(path.relative_to(ROOT).as_posix())

if not changed:
    raise SystemExit("no current Base adapter consumers were updated")
print("updated consumers:")
for item in changed:
    print(f"- {item}")
