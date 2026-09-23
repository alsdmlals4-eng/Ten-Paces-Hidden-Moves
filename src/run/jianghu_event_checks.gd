extends RefCounted
## Version-two event checks. Presentation reads these results; it never rolls.

const STAT_NAMES := {"external":"외공", "constitution":"근골", "agility":"신법", "internal_power":"내공", "insight":"심안"}
const PLAYER_SOURCE := "res://data/combat/combat_hud_preview.json"
var catalog: Dictionary

func _init(source: Dictionary) -> void:
    catalog = source

func player_stats() -> Dictionary:
    # Same current owner as TopCombatHud/CombatResolutionEngine. Permanent growth
    # is a separate, unmerged contract and is not fabricated in event UI.
    var source: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(PLAYER_SOURCE))
    return source.player.stats.duplicate(true)

func success_chance(choice: Dictionary, stats: Dictionary) -> int:
    if not choice.has("check"): return 100
    var rule: Dictionary = catalog.chance_rule
    var check: Dictionary = choice.check
    return clampi(int(rule.base) + (int(stats.get(check.stat, 0)) - int(check.difficulty)) * int(rule.per_stat), int(rule.minimum), int(rule.maximum))

func _roll(seed_value: int, duel: int, step: int, event_id: String, choice_id: String, purpose: String) -> int:
    # Distinct domain keys keep success and rare reward independent and stable
    # across process restarts without consuming UI-dependent RNG state.
    var key := "event-v2:%d:%d:%d:%s:%s:%s" % [seed_value, duel, step, event_id, choice_id, purpose]
    return int(key.sha256_text().substr(0, 7).hex_to_int()) % 100

func effect_text(effect: Dictionary) -> String:
    var parts: Array[String] = []
    if int(effect.get("training",0)) > 0: parts.append("자유 수련 +%d" % int(effect.training))
    if int(effect.get("health_cost",0)) > 0: parts.append("체력 -%d" % int(effect.health_cost))
    var stamina := int(effect.get("stamina",0))
    if stamina != 0: parts.append("기력 %s%d" % ["+" if stamina > 0 else "", stamina])
    return " · ".join(parts) if not parts.is_empty() else "보상·손실 없음"

func _item_name(id: String) -> String:
    for item in catalog.giyun:
        if item.id == id: return item.name
    return ""

func options(event: Dictionary, owned: Array, health: int, stats: Dictionary) -> Array:
    var result: Array = []
    for choice in event.choices:
        var tested: bool = choice.has("check")
        var chance := success_chance(choice, stats)
        var text := "안전 선택 · 판정 없음 · " + effect_text(choice.success)
        if tested:
            text = "%s %d · 난도 %d · 성공 %d%%\n성공: %s / 실패: %s" % [STAT_NAMES[choice.check.stat], int(stats.get(choice.check.stat,0)), choice.check.difficulty, chance, effect_text(choice.success), effect_text(choice.failure)]
        if choice.has("rare_bonus"):
            var bonus: Dictionary = choice.rare_bonus
            text += "\n성공 후 추가 %d%%: %s · 전체 확률 %s%%" % [bonus.chance, _item_name(bonus.giyun_id), str(float(chance) * float(bonus.chance) / 100.0)]
            if bonus.giyun_id in owned: text += " · 이미 보유: 당첨 시 수련 +%d" % int(catalog.chance_rule.duplicate_training)
        var cost := maxi(int(choice.success.get("health_cost",0)), int(choice.failure.get("health_cost",0)))
        var disabled := cost > 0 and health <= cost
        if disabled: text += "\n선택 불가: 실패 비용을 내고도 체력이 남아야 합니다."
        result.append({"id":"event."+choice.id, "label":choice.label, "effect":text, "disabled":disabled})
    return result

func resolve(event: Dictionary, choice_id: String, owned: Array, stats: Dictionary, seed_value: int, duel: int, step: int) -> Dictionary:
    var choice: Dictionary = {}
    for candidate in event.choices:
        if candidate.id == choice_id: choice = candidate
    if choice.is_empty(): return {}
    var tested: bool = choice.has("check")
    var chance := success_chance(choice, stats)
    var roll := _roll(seed_value,duel,step,event.id,choice_id,"success") if tested else -1
    var success := not tested or roll < chance
    var effect: Dictionary = choice.success if success else choice.failure
    var result := {"choice":choice_id, "choice_label":choice.label, "event_id":event.id,
        "training":int(effect.get("training",0)), "health_cost":int(effect.get("health_cost",0)),
        "stamina":int(effect.get("stamina",0)), "giyun_id":"", "success":success,
        "tested":tested, "chance":chance, "roll":roll, "rare_roll":-1, "rare_awarded":false,
        "duplicate_training":0, "stat":str(choice.get("check",{}).get("stat","")),
        "stat_value":int(stats.get(choice.get("check",{}).get("stat",""),0))}
    if success and choice.has("rare_bonus"):
        var bonus: Dictionary = choice.rare_bonus
        result.rare_roll = _roll(seed_value,duel,step,event.id,choice_id,"rare")
        result.rare_awarded = int(result.rare_roll) < int(bonus.chance)
        if result.rare_awarded:
            if bonus.giyun_id in owned:
                result.duplicate_training = int(catalog.chance_rule.duplicate_training)
                result.training += result.duplicate_training
            else: result.giyun_id = bonus.giyun_id
    return result

func outcome_text(outcome: Dictionary) -> String:
    var result := ("성공" if outcome.success else "실패") if outcome.tested else "안전하게 떠남"
    if outcome.tested: result += " · %s %d · 성공률 %d%%" % [STAT_NAMES[outcome.stat], outcome.stat_value, outcome.chance]
    result += "\n" + effect_text(outcome)
    if outcome.has("actual_stamina") and outcome.actual_stamina != outcome.stamina:
        result += " · 기력 실제 변화 %s%d (자원 상한·하한 적용)" % ["+" if outcome.actual_stamina >= 0 else "", outcome.actual_stamina]
    if not outcome.giyun_id.is_empty(): result += "\n희귀 기연 획득: " + _item_name(outcome.giyun_id)
    elif outcome.duplicate_training > 0: result += "\n희귀 보상 당첨 · 이미 보유한 기연 → 추가 수련 +%d 포함" % outcome.duplicate_training
    elif outcome.rare_roll >= 0: result += "\n추가 기연 없음 · 일반 성공 보상만 적용"
    return result
