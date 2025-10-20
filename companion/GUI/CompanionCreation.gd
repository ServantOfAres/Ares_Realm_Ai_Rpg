extends Control

@onready var name_input: LineEdit = $Margin/Root/Grid/NameInput
@onready var age_input: SpinBox = $Margin/Root/Grid/AgeInput
@onready var gender_select: OptionButton = $Margin/Root/Grid/GenderSelect
@onready var temper_input: TextEdit = $Margin/Root/Grid/TemperInput
@onready var visual_input: TextEdit = $Margin/Root/Grid/VisualInput
@onready var memory_input: LineEdit = $Margin/Root/Grid/MemoryInput
@onready var backstory_input: TextEdit = $Margin/Root/Grid/BackstoryInput

@onready var generate_btn: Button = $Margin/Root/Buttons/GenerateBtn
@onready var confirm_btn: Button = $Margin/Root/Buttons/ConfirmBtn
@onready var cancel_btn: Button = $Margin/Root/Buttons/CancelBtn

# Temporary feedback label
var generating: bool = false

func _ready() -> void:
	# Populate gender options if not already
	if gender_select.item_count == 0:
		gender_select.add_item("Female")
		gender_select.add_item("Male")
		gender_select.add_item("Non-binary")
		gender_select.add_item("Other / Undefined")

	generate_btn.pressed.connect(_on_generate_pressed)
	confirm_btn.pressed.connect(_on_confirm_pressed)
	cancel_btn.pressed.connect(_on_cancel_pressed)

func _on_generate_pressed() -> void:
	if generating:
		return
	generating = true
	generate_btn.text = "Generating..."
	await get_tree().create_timer(0.2).timeout  # small delay for UX

	# Use CompanionManager's random generator to fill in base values
	# If AIAdapter autoload exists or can be created, ask it for a character.
	var adapter: AIAdapter = null
	if Engine.has_singleton("AIAdapter"):
		adapter = get_node_or_null("/root/AIAdapter") if get_node_or_null("/root/AIAdapter") else AIAdapter.new()
	else:
		adapter = AIAdapter.new()
		get_tree().root.add_child(adapter)

	var did_fill := false
	if adapter and adapter.is_available():
		# Build a rich prompt containing game context and expected JSON schema.
		var game_ctx := {
			"level": GameManager.get_level(),
			"xp": GameManager.get_current_xp(),
			"stats": GameManager.get_effective_stats(),
		}
		var prompt := "Generate a companion character for a game. Respond ONLY with valid JSON (no extra text). Schema: {name:string, age:int, gender:string, temperament:string, visual_description:string, memory: [strings], backstory:string, portrait_prompt:string}. Game context: %s. Produce realistic, concise fields." % JSON.print(game_ctx)
		var raw := adapter.request_character(prompt)
		if raw and raw.strip_edges() != "":
			# Try to parse JSON from the response (best-effort: find first '{'..')')
			var start := raw.find("{")
			var obj: Dictionary = {}
			if start >= 0:
				var substr := raw.substr(start, raw.length() - start)
				var parsed := JSON.parse(substr)
				if parsed.error == OK and typeof(parsed.result) == TYPE_DICTIONARY:
					obj = parsed.result
			# Fill fields if we got a dictionary
			if obj.size() > 0:
				name_input.text = str(obj.get("name", ""))
				age_input.value = int(obj.get("age", 18))
				var gender := str(obj.get("gender", "Other / Undefined"))
				var gi := ["Female","Male","Non-binary","Other / Undefined"].find(gender)
				if gi == -1:
					gi = 3
				gender_select.select(gi)
				temper_input.text = str(obj.get("temperament", ""))
				visual_input.text = str(obj.get("visual_description", ""))
				memory_input.text = String.join([str(x) for x in obj.get("memory", [])], ", ") if obj.has("memory") else ""
				backstory_input.text = str(obj.get("backstory", ""))

				# Save portrait prompt and optionally request image
				var portrait_prompt := str(obj.get("portrait_prompt", CompanionManager.build_portrait_prompt()))
				var prompt_path := "user://companions/portraits/%s_prompt.txt" % CompanionManager.current_profile_name
				DirAccess.make_dir_recursive_absolute("user://companions/portraits/")
				var pf := FileAccess.open(prompt_path, FileAccess.WRITE)
				if pf:
					pf.store_string(portrait_prompt)
					pf.close()

				# Try to request an image and save it; if it fails, create placeholder
				var img_path := adapter.request_image(portrait_prompt)
				if img_path == "":
					var save_path := "user://companions/portraits/%s.png" % CompanionManager.current_profile_name
					var img := Image.new()
					img.create(512, 512, false, Image.FORMAT_RGBA8)
					img.fill(Color(0.15, 0.18, 0.22, 1.0))
					img.save_png(save_path)
					img_path = save_path

				CompanionManager.portrait_image_path = img_path
				CompanionManager.set_personality(CompanionManager.personality)
				CompanionManager.save_profile()

				did_fill = true

	if not did_fill:
		# fallback to randomize
		CompanionManager.randomize_personality()
		var p = CompanionManager.personality
		name_input.text = p.name
		age_input.value = p.age
		var idx := ["Female","Male","Non-binary","Other / Undefined"].find(p.gender)
		if idx != -1:
			gender_select.select(idx)
		else:
			gender_select.select(0)
		temper_input.text = p.temperament + "\nDriven by curiosity and empathy."
		visual_input.text = p.visual_description + ", usually wearing something distinctive."
		memory_input.text = "starlight, first meeting, promise"
		backstory_input.text = "They grew up near the ocean, fascinated by human stories and forgotten places."

	generating = false
	generate_btn.text = "AI Generate"

func _on_confirm_pressed() -> void:
	var name: String = name_input.text.strip_edges()
	if name == "":
		push_warning("Please enter a name.")
		return

	var p = CompanionManager.personality
	p.name = name
	p.age = int(age_input.value)
	p.gender = gender_select.get_item_text(gender_select.selected)
	p.temperament = temper_input.text.strip_edges()
	p.visual_description = visual_input.text.strip_edges()

	if CompanionManager.memory:
		CompanionManager.memory.record_event("core_memory", memory_input.text.strip_edges())
		CompanionManager.memory.record_event("origin_story", backstory_input.text.strip_edges())

	CompanionManager.set_personality(p)
	CompanionManager.save_profile()

	print("Companion created:", CompanionManager.current_profile_name)
	get_tree().change_scene_to_file("res://companion/GUI/CompanionMain.tscn")

func _on_cancel_pressed() -> void:
	get_tree().change_scene_to_file("res://companion/GUI/CompanionProfileSelect.tscn")
