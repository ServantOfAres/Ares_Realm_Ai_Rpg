extends Node

signal message_sent(msg: String)
signal companion_reply(reply: String)
signal portrait_updated(path: String)
signal companion_loaded(name: String)
signal profile_list_changed()

var personality: PersonalityCore
var memory: MemorySystem
var dialogue: DialogueManager

var portrait_image_path: String = ""
var profiles_dir := "user://companions/"
var current_profile_name: String = ""
var current_profile: Dictionary = {}

func _ready() -> void:
	dialogue = DialogueManager.new()
	DirAccess.make_dir_recursive_absolute(profiles_dir)
	_load_last_profile_or_default()

func get_custom_name() -> String:
	# PersonalityCore exports `name`. Return a plain string and guard missing personality.
	if personality == null:
		return ""
	# Access exported property directly (safe) — avoids using StringName() on possibly-null data.
	return str(personality.name)

func get_age() -> int:
	return int(personality.age) if personality else 0

func get_gender() -> String:
	return personality.gender if personality else ""

func get_personality() -> String:
	return personality.temperament if personality else ""

func get_visual_description() -> String:
	return personality.visual_description if personality else ""

func get_profile_dict() -> Dictionary:
	if personality and personality.has_method("to_dict"):
		var d: Dictionary = personality.to_dict()
		d["visual_description"] = get_visual_description()
		return d
	# Fall back to safe accessors — get_name() did not exist and could produce wrong/empty summaries.
	return {
		"name": str(get_custom_name()),
		"age": get_age(),
		"gender": get_gender(),
		"temperament": get_personality(),
		"visual_description": get_visual_description(),
	}

func _sync_current_profile() -> void:
	current_profile = get_profile_dict()

func _load_last_profile_or_default() -> void:
	var last_path = "user://last_profile.txt"
	if FileAccess.file_exists(last_path):
		var file = FileAccess.open(last_path, FileAccess.READ)
		current_profile_name = file.get_as_text().strip_edges()
		file.close()
	if current_profile_name != "":
		load_profile(current_profile_name)
	else:
		_create_new_profile("Default")

func _save_last_used(name: String) -> void:
	var file = FileAccess.open("user://last_profile.txt", FileAccess.WRITE)
	file.store_string(name)
	file.close()

func _create_new_profile(name: String) -> void:
	personality = PersonalityCore.new()
	memory = MemorySystem.new()
	memory.record_event("init", "Created new profile.")
	current_profile_name = name
	_sync_current_profile()
	save_profile()
	emit_signal("profile_list_changed")

func set_personality(new_core: PersonalityCore) -> void:
	personality = new_core
	memory.record_event("personality_init", personality.describe_self())
	_sync_current_profile()
	save_profile()

func randomize_personality() -> void:
	var p := PersonalityCore.new()
	p.name = ["Astra","Nova","Rhea","Kai","Orion"].pick_random()
	p.age = randi_range(18, 100)
	p.gender = ["Female","Male","Non-binary"].pick_random()
	p.temperament = ["Playful and supportive","Curious and adventurous","Calm and thoughtful","Bold and sassy"].pick_random()
	p.visual_description = [
		"short silver hair, bright blue eyes",
		"curly dark hair, green eyes, gentle smile",
		"long auburn hair, freckles, warm gaze",
		"undercut, amber eyes, confident posture"
	].pick_random()
	set_personality(p)

func send_message(user_msg: String) -> void:
	if user_msg.strip_edges() == "":
		return
	print("CompanionManager: user_msg ->", user_msg)
	emit_signal("message_sent", user_msg)
	if memory and memory.has_method("record_event"):
		memory.record_event("user_msg", user_msg)
	var reply_text := ""
	if dialogue and dialogue.has_method("reply"):
		reply_text = dialogue.reply(user_msg, personality, memory)
	else:
		reply_text = "(no dialogue manager available)"
	if memory and memory.has_method("record_event"):
		memory.record_event("ai_msg", reply_text)
	print("CompanionManager: ai_reply ->", reply_text)
	emit_signal("companion_reply", reply_text)
	save_profile()

func get_profiles_list() -> Array[String]:
	var da = DirAccess.open(profiles_dir)
	if da == null:
		return []
	var files: Array[String] = []
	for f in da.get_files():
		if f.ends_with(".cfg"):
			files.append(f.get_basename())
	files.sort()
	return files

func load_profile(profile_name: String) -> void:
	var path = profiles_dir + profile_name + ".cfg"
	if not FileAccess.file_exists(path):
		_create_new_profile(profile_name)
		return
	var cfg = ConfigFile.new()
	var err = cfg.load(path)
	if err != OK:
		push_warning("Error loading %s" % path)
		return
	personality = PersonalityCore.from_dict(cfg.get_value("companion","personality", {}))
	memory = MemorySystem.from_dict(cfg.get_value("companion","memory", {}))
	portrait_image_path = cfg.get_value("companion","portrait","")
	current_profile_name = profile_name
	_sync_current_profile()
	_save_last_used(current_profile_name)
	emit_signal("portrait_updated", portrait_image_path)
	emit_signal("companion_loaded", current_profile_name)
	print("Loaded companion: %s" % profile_name)

func save_profile() -> void:
	if current_profile_name == "":
		current_profile_name = "Default"
	var cfg = ConfigFile.new()
	cfg.set_value("companion","personality", personality.to_dict())
	cfg.set_value("companion","memory", memory.to_dict())
	cfg.set_value("companion","portrait", portrait_image_path)
	cfg.save(profiles_dir + current_profile_name + ".cfg")
	_sync_current_profile()
	_save_last_used(current_profile_name)
	print("Saved companion profile: %s" % current_profile_name)

func delete_profile(name: String) -> void:
	var path = profiles_dir + name + ".cfg"
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
		if name == current_profile_name:
			_create_new_profile("Default")
	emit_signal("profile_list_changed")

func apply_external_update(d: Dictionary) -> void:
	if d.has("personality"):
		personality = PersonalityCore.from_dict(d["personality"])
	if d.has("memory"):
		memory = MemorySystem.from_dict(d["memory"])
	if d.has("portrait_image_path"):
		portrait_image_path = String(d["portrait_image_path"])
		emit_signal("portrait_updated", portrait_image_path)
	_sync_current_profile()
	save_profile()

func build_portrait_prompt() -> String:
	return "%s, %d years old, %s, portrait, highly detailed, cinematic lighting, neutral background" % [
		personality.gender, personality.age, personality.visual_description
	]
