extends Control

@onready var xp_bar: ProgressBar = $BGPanel/VBoxContainer/XPProgress
@onready var stats_label: Label = $BGPanel/VBoxContainer/StatsLabel
@onready var traits_label: Label = $BGPanel/VBoxContainer/TraitsLabel
@onready var story_log: RichTextLabel = $BGPanel/VBoxContainer/StoryLog
@onready var next_btn: Button = $BGPanel/VBoxContainer/ButtonRow/NextEventBtn
@onready var back_btn: Button = $BGPanel/VBoxContainer/ButtonRow/BackBtn

var story_events: Array = [
	"You wake up in a quiet village. The air smells of pine and rain.",
	"A merchant greets you warmly and offers a simple quest.",
	"You face your first challenge: a bandit on the road!",
	"After the battle, you gain experience and confidence.",
    "The day fades to dusk as new adventures await..."
]
var current_event: int = 0

func _ready() -> void:
	if back_btn:
		back_btn.pressed.connect(_on_back_pressed)
	if next_btn:
		next_btn.pressed.connect(_on_next_event)
	_update_ui()

func _update_ui() -> void:
	# Safely pull data from managers
	if not Engine.is_editor_hint():
		var effective: Dictionary = GameManager.get_effective_stats()
		var traits_text: String = GameManager.traits.owned_as_readable()
		stats_label.text = "Stats: %s" % _format_stats(effective)
		traits_label.text = "Traits: %s" % traits_text
		xp_bar.max_value = GameManager.xp_per_level
		xp_bar.value = int(GameManager.get_current_xp())
	_update_story_log()

func _update_story_log() -> void:
	var visible_text := ""
	for i in range(current_event + 1):
		visible_text += "[color=white]%s[/color]\n\n" % story_events[i]
	story_log.text = visible_text

func _on_next_event() -> void:
	if current_event < story_events.size() - 1:
		current_event += 1
		GameManager.add_xp(10)
		_update_ui()
	else:
		story_log.text += "[b][color=gold]The End.[/color][/b]"

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _format_stats(d: Dictionary) -> String:
	var parts: Array = []
	var keys = ["strength","agility","intelligence","charisma","endurance"]
	for raw_k in keys:
		if raw_k == null:
			continue
		var k := str(raw_k)
		parts.append("%s:%d" % [k.substr(0,3), int(d.get(k,0))])
	return String(" ").join(parts)
