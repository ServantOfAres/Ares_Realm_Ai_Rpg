extends Control

@onready var stats_label: Label = $MarginContainer/VBoxContainer/StatsLabel
@onready var randomize_btn: Button = $MarginContainer/VBoxContainer/HBoxContainer/RandomizeBtn
@onready var pos_btn: Button = $MarginContainer/VBoxContainer/HBoxContainer/PositiveTraitBtn
@onready var neg_btn: Button = $MarginContainer/VBoxContainer/HBoxContainer2/NegativeTraitBtn
@onready var pos_select: OptionButton = $MarginContainer/VBoxContainer/HBoxContainer/PositiveTraitSelect
@onready var neg_select: OptionButton = $MarginContainer/VBoxContainer/HBoxContainer2/NegativeTraitSelect
@onready var reset_btn: Button = $MarginContainer/VBoxContainer/HBoxContainer2/ResetBtn
@onready var confirm_btn: Button = $MarginContainer/VBoxContainer/ConfirmBtn
@onready var trait_list: RichTextLabel = $MarginContainer/VBoxContainer/TraitList

const MAX_POS_TRAITS := 2
const MAX_NEG_TRAITS := 2

func _ready() -> void:
	if randomize_btn: randomize_btn.pressed.connect(_on_randomize)
	if pos_btn: pos_btn.pressed.connect(_on_add_positive)
	if neg_btn: neg_btn.pressed.connect(_on_add_negative)
	if reset_btn: reset_btn.pressed.connect(_on_reset)
	if confirm_btn: confirm_btn.pressed.connect(_on_confirm)
	if trait_list:
		trait_list.meta_hover_started.connect(_on_trait_hover)
		trait_list.meta_hover_ended.connect(_on_trait_hover_end)

	GameManager.new_profile()
	_populate_trait_menus()
	_refresh()

func _populate_trait_menus() -> void:
	pos_select.clear()
	neg_select.clear()
	var all: Dictionary = GameManager.traits.get_all(GameManager.get_level(), true, true)
	for raw_id in all.keys():
		var id: String = str(raw_id)
		var t = all[id]
		var tname_raw := null
		if typeof(t) == TYPE_DICTIONARY and t.has("name"):
			tname_raw = t["name"]
		var tname := str(tname_raw) if tname_raw != null else id
		if typeof(t) == TYPE_DICTIONARY and t.has("type") and t["type"] == "positive":
			pos_select.add_item(tname)
			pos_select.set_item_metadata(pos_select.item_count - 1, id)
		elif typeof(t) == TYPE_DICTIONARY and t.has("type") and t["type"] == "negative":
			neg_select.add_item(tname)
			neg_select.set_item_metadata(neg_select.item_count - 1, id)

func _refresh() -> void:
	var profile: Dictionary = UIManager.get_cached_profile()
	var effective: Dictionary = GameManager.get_effective_stats()
	stats_label.text = "Level %d | XP %d/%d\nBase: %s\nEffective: %s" % [
		profile.get("level", 1),
		profile.get("xp", 0),
		GameManager.xp_per_level,
		_format_stats(profile.get("stats", {})),
		_format_stats(effective)
	]
	_update_trait_list()

	# Disable add buttons when max traits reached
	pos_btn.disabled = GameManager.traits.owned.size() >= MAX_POS_TRAITS
	neg_btn.disabled = GameManager.traits.owned.size() >= MAX_NEG_TRAITS

func _format_stats(d: Dictionary) -> String:
	var keys: Array = ["strength","agility","intelligence","charisma","endurance"]
	var parts: Array = []
	for raw_k in keys:
		if raw_k == null:
			continue
		var k := str(raw_k)
		parts.append("%s:%d" % [k.substr(0,3), int(d.get(k,0))])
	return String(" ").join(parts)

func _update_trait_list() -> void:
	var names: Array = []
	for id in GameManager.traits.owned.keys():
		# Avoid forcing a typed loop variable; convert to string defensively when needed.
		var id_safe = id
		if id_safe == null:
			continue
		names.append(str(id_safe))
	names.sort()

	if names.is_empty():
		trait_list.text = "[b]Traits:[/b] None selected."
		trait_list.clear()
		return

	var text := "[b]Traits:[/b]\n"
	for id in names:
		var id_s := str(id)
		var tname_raw := GameManager.traits.get_trait_name(id_s)
		var tname := str(tname_raw) if tname_raw != null else id_s
		var trait_type := GameManager.traits.get_trait_type(id_s)
		var color := "lightgreen" if trait_type == "positive" else "crimson"
		text += "[color=%s][url=%s]%s[/url][/color]\n" % [color, id_s, tname]
	trait_list.text = text

func _on_trait_hover(meta: Variant) -> void:
	if meta is String and GameManager.traits._db.has(meta):
		trait_list.tooltip_text = GameManager.traits.get_trait_description(meta)

func _on_trait_hover_end(meta: Variant) -> void:
	trait_list.tooltip_text = ""

func _on_randomize() -> void:
	GameManager.stats.randomize_starting_stats(GameManager.start_points, GameManager.per_stat_cap)
	GameManager._emit_profile()
	_refresh()

func _on_add_positive() -> void:
	if pos_select.selected == -1:
		return
	var id: String = str(pos_select.get_item_metadata(pos_select.selected))
	if GameManager.traits.owned.size() < MAX_POS_TRAITS:
		GameManager.traits.add(id)
		_refresh()

func _on_add_negative() -> void:
	if neg_select.selected == -1:
		return
	var id: String = str(neg_select.get_item_metadata(neg_select.selected))
	if GameManager.traits.owned.size() < MAX_NEG_TRAITS:
		GameManager.traits.add(id)
		_refresh()

func _on_reset() -> void:
	GameManager.new_profile()
	_populate_trait_menus()
	_refresh()

func _on_confirm() -> void:
	get_tree().change_scene_to_file("res://scenes/Game.tscn")
