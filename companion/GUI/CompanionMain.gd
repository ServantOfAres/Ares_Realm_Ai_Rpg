extends Control

@onready var portrait: TextureRect = $Margin/Root/TopRow/PortraitPanel/Portrait
@onready var portrait_hint: Label = $Margin/Root/TopRow/PortraitPanel/PortraitHint

@onready var name_val: Label = $Margin/Root/TopRow/InfoPanel/NameRow/NameValue
@onready var age_val: Label = $Margin/Root/TopRow/InfoPanel/AgeRow/AgeValue
@onready var gender_val: Label = $Margin/Root/TopRow/InfoPanel/GenderRow/GenderValue
@onready var temper_val: Label = $Margin/Root/TopRow/InfoPanel/TemperRow/TemperValue
@onready var visual_val: Label = $Margin/Root/TopRow/InfoPanel/VisualRow/VisualValue
@onready var traits_val: RichTextLabel = $Margin/Root/TopRow/InfoPanel/TraitsValue

@onready var chat_log: RichTextLabel = $Margin/Root/ChatLog
@onready var input_line: LineEdit = $Margin/Root/InputRow/Input
@onready var send_btn: Button = $Margin/Root/InputRow/SendBtn
@onready var back_btn: Button = $Margin/Root/InputRow/BackBtn

func _ready() -> void:
	CompanionManager.message_sent.connect(_on_msg_sent)
	CompanionManager.companion_reply.connect(_on_reply)
	CompanionManager.portrait_updated.connect(_on_portrait_updated)

	send_btn.pressed.connect(_on_send_pressed)
	back_btn.pressed.connect(_on_back_pressed)
	input_line.text_submitted.connect(_on_text_submitted)

	# Listen for trait changes so the profile UI updates live.
	if Engine.has_singleton("GameManager") and GameManager and GameManager.traits and GameManager.traits.has_signal("traits_changed"):
		GameManager.traits.connect("traits_changed", Callable(self, "_on_traits_changed"))

	_refresh_profile()
	_refresh_portrait()

func _refresh_profile() -> void:
	name_val.text   = str(CompanionManager.get_custom_name())
	age_val.text    = str(CompanionManager.get_age())
	gender_val.text = str(CompanionManager.get_gender())
	temper_val.text = str(CompanionManager.get_personality())
	visual_val.text = str(CompanionManager.get_visual_description())

	# Display currently owned/selected traits using the TraitsSystem API.
	# Use guard checks in case GameManager.traits is missing.
	if not GameManager or not GameManager.traits:
		traits_val.text = "None"
		return

	# Prefer convenience helper if it exists
	if GameManager.traits.has_method("owned_as_readable"):
		traits_val.text = GameManager.traits.owned_as_readable()
		return

	# Fallback: build readable list from owned dictionary
	var owned_traits: Dictionary = GameManager.traits.owned
	if owned_traits.is_empty():
		traits_val.text = "None"
		return

	var names: Array = []
	for id in owned_traits.keys():
		var display_name: String = GameManager.traits.get_trait_name(id) if GameManager.traits.has_method("get_trait_name") else String(id)
		names.append(display_name)
	names.sort()
	traits_val.text = "[b]Selected:[/b] " + String(", ").join(names)


func _on_traits_changed(current: Dictionary) -> void:
	_refresh_profile()

func _refresh_portrait() -> void:
	var path: String = CompanionManager.portrait_image_path
	if path == "" or not FileAccess.file_exists(path):
		portrait.texture = null
		portrait_hint.visible = true
		return
	var img := Image.new()
	var err := img.load(path)
	if err != OK:
		portrait.texture = null
		portrait_hint.visible = true
		return
	var tex := ImageTexture.create_from_image(img)
	portrait.texture = tex
	portrait_hint.visible = false

func _on_portrait_updated(path: String) -> void:
	_refresh_portrait()

func _on_msg_sent(msg: String) -> void:
	chat_log.append_text("[b]You:[/b] %s\n" % msg)
	_scroll_chat_bottom()

func _on_reply(reply: String) -> void:
	chat_log.append_text("[color=deepskyblue][b]%s:[/b] %s[/color]\n" % [CompanionManager.get_custom_name(), reply])
	_scroll_chat_bottom()

func _on_send_pressed() -> void:
	_send_input_text()

func _on_text_submitted(text: String) -> void:
	_send_input_text()

func _send_input_text() -> void:
	var text := input_line.text.strip_edges()
	if text == "":
		return
	input_line.clear()
	CompanionManager.send_message(text)

func _scroll_chat_bottom() -> void:
	if chat_log.has_method("scroll_to_line"):
		chat_log.scroll_to_line(max(0, chat_log.get_line_count() - 1))
	else:
		chat_log.scroll_active = true

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
