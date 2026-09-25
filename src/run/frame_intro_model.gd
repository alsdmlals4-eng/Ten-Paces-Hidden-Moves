extends RefCounted
## Intro-only rules and immutable event receipts. UI never rolls or grants rewards.
const CODEC := preload("res://src/run/run_checkpoint_codec.gd")
const DATA_PATH := "res://data/run/frame_intro.json"
var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH))
var rules = preload("res://src/run/giyun_rules.gd").new()

func initial() -> Dictionary:
    return {"version": 1, "onboarding": {"tutorial_step": 0, "practice_complete": false,
        "journey_entered": false, "journey_receipt": {}, "completed": false}}

func options() -> Array:
    var result: Array = rules.event_options(data.event, [], 30, rules.player_stats())
    for item in result: item.id = str(item.id).trim_prefix("event.")
    return result

func resolve(seed_value: int, choice: String) -> Dictionary:
    return rules.resolve_event(data.event, choice, [], rules.player_stats(), seed_value, 0, 0)

func valid(snapshot: Dictionary) -> bool:
    var frame = snapshot.get("frame")
    if typeof(frame) != TYPE_DICTIONARY or frame.size() != 2 or not CODEC.integer(frame.get("version"), 1, 1): return false
    var onboarding = frame.get("onboarding")
    if typeof(onboarding) != TYPE_DICTIONARY or onboarding.size() != 5: return false
    if not CODEC.integer(onboarding.get("tutorial_step"), 0, 3): return false
    for key in ["practice_complete", "journey_entered", "completed"]:
        if typeof(onboarding.get(key)) != TYPE_BOOL: return false
    if typeof(onboarding.get("journey_receipt")) != TYPE_DICTIONARY: return false
    var receipt: Dictionary = onboarding.journey_receipt
    if not receipt.is_empty():
        if not onboarding.journey_entered or not CODEC.integer(snapshot.get("run_seed")): return false
        if typeof(receipt.get("choice")) != TYPE_STRING or receipt != resolve(int(snapshot.run_seed), receipt.choice): return false
    if onboarding.practice_complete and onboarding.tutorial_step != 3: return false
    if onboarding.journey_entered and not onboarding.practice_complete: return false
    if onboarding.completed and receipt.is_empty(): return false
    var history = snapshot.get("flow_history")
    if typeof(history) != TYPE_ARRAY: return false
    var required := ["MAIN", "PROLOGUE", "SETUP", "TUTORIAL", "FIRST_JOURNEY", "BRIEFING"]
    var required_count := required.find(str(snapshot.get("current_screen"))) + 1 if not onboarding.completed else required.size()
    if required_count < 2 or history.slice(0, required_count) != required.slice(0, required_count): return false
    match snapshot.get("current_screen"):
        "PROLOGUE", "SETUP":
            return onboarding == initial().onboarding and snapshot.get("completed_duels") == 0
        "TUTORIAL":
            return not onboarding.journey_entered and not onboarding.completed and snapshot.get("completed_duels") == 0
        "FIRST_JOURNEY":
            return onboarding.practice_complete and not onboarding.completed and snapshot.get("completed_duels") == 0
        "INTRO", "MAIN": return false
        _: return onboarding.completed
