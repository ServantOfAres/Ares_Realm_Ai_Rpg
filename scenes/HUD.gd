extends Control

@onready var profile_label: Label = $MarginContainer/VBoxContainer/ProfileLabel
@onready var quest_btn: Button = $MarginContainer/VBoxContainer/HBoxContainer/QuestBtn
@onready var night_btn: Button = $MarginContainer/VBoxContainer/HBoxContainer/NightBtn
@onready var bad_btn: Button = $MarginContainer/VBoxContainer/HBoxContainer/BadEventBtn

func _ready() -> void:
    quest_btn.pressed.connect(func(): StoryManager.handle_event("quest_complete"))
    night_btn.pressed.connect(func(): StoryManager.handle_event("night_survived"))
    bad_btn.pressed.connect(func(): StoryManager.handle_event("rest_without_food"))
    # GameManager emits `profile_updated` when profile changes
    if GameManager.has_signal("profile_updated"):
        GameManager.profile_updated.connect(_on_profile)
    _on_profile(UIManager.get_cached_profile())

func _on_profile(profile: Dictionary) -> void:
    update_from_profile(profile)

func update_from_profile(profile: Dictionary) -> void:
    if profile.is_empty():
        return
    var effective = GameManager.get_effective_stats()
    var lines := []
    lines.append("Level %d | XP %d/%d" % [profile.get("level",1), profile.get("xp",0), GameManager.xp_per_level])
    lines.append("Base:      %s" % _fmt_stats(profile.get("stats", {})))
    lines.append("Effective: %s" % _fmt_stats(effective))
    lines.append("Traits:    %s" % _fmt_traits(profile.get("traits", {})))
    profile_label.text = "\n".join(lines)

func _fmt_stats(d: Dictionary) -> String:
    var keys: Array = ["strength","agility","intelligence","charisma","endurance"]
    var parts: Array[String] = []
    for raw_k in keys:
        if raw_k == null:
            continue
        var k := str(raw_k)
        parts.append("%s:%d" % [k.substr(0,3), int(d.get(k,0))])
    return " ".join(parts)

func _fmt_traits(owned: Dictionary) -> String:
    var names: Array[String] = []
    for id in owned.keys():
        # TraitsSystem provides get_trait_name(id)
        names.append(GameManager.traits.get_trait_name(id))
    names.sort()
    return names.size() > 0 ? names.join(", ") : "None"

