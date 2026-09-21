extends RefCounted
## Text projection of authored operations, never a second combat resolver.
const RESOURCES := {"internal":"내력", "stamina":"기력", "defense":"방어도", "health":"체력"}
const STATUSES := {"evade":"같은 수 공격 회피", "fortitude":"강건", "prepared":"준비", "taiji_stance":"태극 자세"}
static func describe(card: Dictionary) -> String:
    var lines := PackedStringArray()
    for step in card.get("effect_steps", []):
        var text := ""
        match str(step.get("op", "")):
            "ATTACK", "INDEPENDENT_ATTACK":
                text = "위력 %d 공격 (거리 %d~%d)" % [step.get("power",0),step.get("min_range",0),step.get("max_range",0)]
            "GAIN_RESOURCE":
                text = "%s +%d" % [RESOURCES.get(step.get("resource"),step.get("resource")),step.get("amount",0)]
            "GAIN_STATUS":
                text = "%s %d" % [STATUSES.get(step.get("status"),step.get("status")),step.get("amount",1)]
            "CONSUME_STATUS":
                text = "%s 소비%s" % [STATUSES.get(step.get("status"),step.get("status")), " (있을 때만)" if step.get("optional",false) else ""]
            "SPECIAL_CLASH":
                text = "특수 합 위력 %d + %s × %s" % [step.get("power",0),step.get("stat","능력"),str(step.get("coefficient",0))]
            "MOVE_TOWARD", "MOVE_AWAY":
                text = "%d칸 %s" % [step.get("tiles",0),"접근" if step.op == "MOVE_TOWARD" else "후퇴"]
            "RECHECK_RANGE": text = "거리 %d~%d에서 후속 실행" % [step.get("min",0),step.get("max",0)]
            "REQUIRE_ACTUAL_HP_HITS": text = "실제 체력 피해 %d회 성공해야 이후 공격" % step.get("count",0)
            "REQUIRE_EVADE_SUCCESS": text = "실제 회피 성공 시에만 이후 효과"
            "BREAK_DEFENSE": text = "상대 방어도 %d 감소" % step.get("amount",0)
            "GAIN_MOMENTUM_ON_COMPLETE": text = "완료 시 절초 기세 +%d" % step.get("amount",0)
            _: text = str(step.get("op", ""))
        match str(step.get("condition", "")):
            "LOW_RESOURCE": text += " (기력 또는 내력이 최대의 절반 이하일 때)"
            "EXACT_MAX_RANGE": text += " (최대 사거리일 때)"
            "STATUS_CONSUMED": text += " (준비를 소비했을 때)"
        lines.append(text)
    return " → ".join(lines)
