class_name ApprovedBlueprintArt
extends RefCounted
## Static presentation only. Never a combat sprite or animation-frame provider.
## Paths are derived from assets/blueprint/APPROVED_ART_MANIFEST.json; tests detect drift.

const PORTRAITS: Dictionary = {
    "masked_baekmujin": "res://assets/characters/portraits/masked_baekmujin_portrait_v1.png",
    "slot1_yeongyo": "res://assets/characters/portraits/slot1_yeongyo_portrait_v1.png",
    "slot1_dogyeom": "res://assets/characters/portraits/slot1_dogyeom_portrait_v1.png",
    "slot1_chaeryeong": "res://assets/characters/portraits/slot1_chaeryeong_portrait_v1.png",
    "slot2_mukjin": "res://assets/characters/portraits/slot2_mukjin_portrait_v1.png",
    "slot2_seokmu": "res://assets/characters/portraits/slot2_seokmu_portrait_v1.png",
    "slot2_danso": "res://assets/characters/portraits/slot2_danso_portrait_v1.png",
    "slot3_seolha": "res://assets/characters/portraits/slot3_seolha_portrait_v1.png",
    "slot3_uram": "res://assets/characters/portraits/slot3_uram_portrait_v1.png",
    "slot3_biyeon": "res://assets/characters/portraits/slot3_biyeon_portrait_v1.png",
    "slot4_cheongheo": "res://assets/characters/portraits/slot4_cheongheo_portrait_v1.png",
    "slot4_damwol": "res://assets/characters/portraits/slot4_damwol_portrait_v1.png",
    "slot4_jinryeo": "res://assets/characters/portraits/slot4_jinryeo_portrait_v1.png",
    "slot5_jeogu": "res://assets/characters/portraits/slot5_jeogu_portrait_v1.png",
    "slot5_pungmok": "res://assets/characters/portraits/slot5_pungmok_portrait_v1.png",
    "slot5_rajin": "res://assets/characters/portraits/slot5_rajin_portrait_v1.png"
}

const MANUALS: Dictionary = {
    "mount_hua_plum_blossom_sword": {
        "3": "res://assets/blueprint/manuals/mount_hua_plum_blossom_sword_star3_v1.png",
        "7": "res://assets/blueprint/manuals/mount_hua_plum_blossom_sword_star7_v1.png",
        "10": "res://assets/blueprint/manuals/mount_hua_plum_blossom_sword_star10_v1.png"
    },
    "shaolin_arhat_vajra_art": {
        "3": "res://assets/blueprint/manuals/shaolin_arhat_vajra_art_star3_v1.png",
        "7": "res://assets/blueprint/manuals/shaolin_arhat_vajra_art_star7_v1.png",
        "10": "res://assets/blueprint/manuals/shaolin_arhat_vajra_art_star10_v1.png"
    },
    "wudang_taiji_sword": {
        "3": "res://assets/blueprint/manuals/wudang_taiji_sword_star3_v1.png",
        "7": "res://assets/blueprint/manuals/wudang_taiji_sword_star7_v1.png",
        "10": "res://assets/blueprint/manuals/wudang_taiji_sword_star10_v1.png"
    },
    "yang_family_spear": {
        "3": "res://assets/blueprint/manuals/yang_family_spear_star3_v1.png",
        "7": "res://assets/blueprint/manuals/yang_family_spear_star7_v1.png",
        "10": "res://assets/blueprint/manuals/yang_family_spear_star10_v1.png"
    },
    "mount_hua_purple_mist_art": {
        "3": "res://assets/blueprint/manuals/mount_hua_purple_mist_art_star3_v1.png",
        "7": "res://assets/blueprint/manuals/mount_hua_purple_mist_art_star7_v1.png",
        "10": "res://assets/blueprint/manuals/mount_hua_purple_mist_art_star10_v1.png"
    },
    "xiaoyao_lingbo_footwork": {
        "3": "res://assets/blueprint/manuals/xiaoyao_lingbo_footwork_star3_v1.png",
        "7": "res://assets/blueprint/manuals/xiaoyao_lingbo_footwork_star7_v1.png",
        "10": "res://assets/blueprint/manuals/xiaoyao_lingbo_footwork_star10_v1.png"
    },
    "beggars_dragon_subduing_palm": {
        "3": "res://assets/blueprint/manuals/beggars_dragon_subduing_palm_star3_v1.png",
        "7": "res://assets/blueprint/manuals/beggars_dragon_subduing_palm_star7_v1.png",
        "10": "res://assets/blueprint/manuals/beggars_dragon_subduing_palm_star10_v1.png"
    },
    "sichuan_tang_hidden_weapons": {
        "3": "res://assets/blueprint/manuals/sichuan_tang_hidden_weapons_star3_v1.png",
        "7": "res://assets/blueprint/manuals/sichuan_tang_hidden_weapons_star7_v1.png",
        "10": "res://assets/blueprint/manuals/sichuan_tang_hidden_weapons_star10_v1.png"
    },
    "hebei_peng_five_tigers_saber": {
        "3": "res://assets/blueprint/manuals/hebei_peng_five_tigers_saber_star3_v1.png",
        "7": "res://assets/blueprint/manuals/hebei_peng_five_tigers_saber_star7_v1.png",
        "10": "res://assets/blueprint/manuals/hebei_peng_five_tigers_saber_star10_v1.png"
    },
    "nangong_boundless_sky_sword": {
        "3": "res://assets/blueprint/manuals/nangong_boundless_sky_sword_star3_v1.png",
        "7": "res://assets/blueprint/manuals/nangong_boundless_sky_sword_star7_v1.png",
        "10": "res://assets/blueprint/manuals/nangong_boundless_sky_sword_star10_v1.png"
    }
}

const CLASH_EXPLANATION: String = "res://assets/blueprint/clash_explanation_v1.png"

static func portrait_path(candidate_id: String) -> String:
    return str(PORTRAITS.get(candidate_id, ""))


static func portrait(candidate_id: String) -> Texture2D:
    return _texture(portrait_path(candidate_id))


static func manual_path(manual_id: String, mastery: int) -> String:
    if mastery < 3 or not MANUALS.has(manual_id):
        return ""
    var star := "10" if mastery >= 10 else ("7" if mastery >= 7 else "3")
    return str(MANUALS[manual_id].get(star, ""))


static func manual_illustration(manual_id: String, mastery: int) -> Texture2D:
    return _texture(manual_path(manual_id, mastery))


static func action_illustration_path(definition: Dictionary) -> String:
    # A technique keeps its authored milestone art even as current mastery grows.
    return manual_path(str(definition.get("manual_id", "")),
        int(definition.get("unlock_star", definition.get("unlock_mastery", 0))))


static func action_illustration(definition: Dictionary) -> Texture2D:
    return _texture(action_illustration_path(definition))


static func clash_explanation() -> Texture2D:
    return _texture(CLASH_EXPLANATION)


static func _texture(path: String) -> Texture2D:
    if path.is_empty():
        return null
    return load(path) as Texture2D
