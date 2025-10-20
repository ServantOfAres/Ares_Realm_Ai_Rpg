extends Resource
class_name TraitsSystem
signal traits_changed(current: Dictionary)

# === Trait Database ===
var _db: Dictionary = {
	"quick_learner": {
		"name": "Quick Learner",
		"type": "positive",
		"requires_level": 1,
		"conflicts": ["slow_learner"],
		"modifiers": {"intelligence": 2}
	},
	"charmer": {
		"name": "Charmer",
		"type": "positive",
		"requires_level": 1,
		"conflicts": ["socially_awkward"],
		"modifiers": {"charisma": 2}
	},
	"tenacious": {
		"name": "Tenacious",
		"type": "positive",
		"requires_level": 3,
		"conflicts": [],
		"modifiers": {"endurance": 2}
	},
	"slow_learner": {
		"name": "Slow Learner",
		"type": "negative",
		"requires_level": 1,
		"conflicts": ["quick_learner"],
		"modifiers": {"intelligence": -1}
	},
	"socially_awkward": {
		"name": "Socially Awkward",
		"type": "negative",
		"requires_level": 1,
		"conflicts": ["charmer"],
		"modifiers": {"charisma": -1}
	},
	"fragile": {
		"name": "Fragile",
		"type": "negative",
		"requires_level": 2,
		"conflicts": ["tenacious"],
		"modifiers": {"endurance": -2}
	},
}

var owned: Dictionary = {}

# === Core Methods ===
func reset() -> void:
	owned.clear()
	emit_signal("traits_changed", owned)

# === Trait Queries ===
func get_all(level: int, include_negative: bool = true, include_positive: bool = true) -> Dictionary:
	var out: Dictionary = {}
	for id in _db.keys():
		if id == null:
			continue
		var t: Dictionary = _db.get(id, {})
		if level < int(t.get("requires_level", 1)):
			continue
		var t_type := t.get("type", "neutral")
		if (t_type == "positive" and not include_positive) or (t_type == "negative" and not include_negative):
			continue
		out[str(id)] = t
	return out

func is_conflicting(id: String) -> bool:
	if not _db.has(id):
		return false
	var conflicts_any: Array = _db.get(id, {}).get("conflicts", [])
	for c in conflicts_any:
		if c == null:
			continue
		if owned.has(str(c)):
			return true
	return false

# === Trait Management ===
func add(id: String) -> bool:
	if not _db.has(id):
		push_warning("Unknown trait: %s" % id)
		return false
	if owned.has(id):
		return false
	if is_conflicting(id):
		return false
	owned[id] = true
	emit_signal("traits_changed", owned)
	return true

func remove(id: String) -> void:
	owned.erase(id)
	emit_signal("traits_changed", owned)

# === Stat Modifiers ===
func apply_modifiers(stats: CharacterStats, max_value: int = 100) -> void:
	for id in owned.keys():
		if id == null:
			continue
		var t: Dictionary = _db.get(id, {})
		var mods: Dictionary = t.get("modifiers", {})
		for key in mods.keys():
			if key == null:
				continue
			# Safe for both 2- or 3-parameter add_stat() definitions
			if stats.has_method("add_stat"):
				var arg_count: int = stats.get_method_argument_count("add_stat")
				if arg_count == 3:
					stats.add_stat(str(key), int(mods[key]), max_value)
				else:
					stats.add_stat(str(key), int(mods[key]))

# === Random Trait Generation ===
func available_for_random(level: int, include_negative: bool = true, include_positive: bool = true) -> Array:
	var pool: Array[String] = []
	var all: Dictionary = get_all(level, include_negative, include_positive)
	for raw_id in all.keys():
		if raw_id == null:
			continue
		var id: String = str(raw_id)
		if not is_conflicting(id) and not owned.has(id):
			pool.append(id)
	return pool

func pick_random(level: int, count: int, include_negative: bool = true, include_positive: bool = true) -> Array:
	var chosen: Array[String] = []
	var pool: Array[String] = available_for_random(level, include_negative, include_positive)
	while count > 0 and pool.size() > 0:
		var idx: int = randi() % pool.size()
		var id: String = pool[idx]
		chosen.append(id)
		pool.erase(id)
		count -= 1
	return chosen

# === Tooltip / Display Helpers ===
func get_trait_description(id: String) -> String:
	if not _db.has(id):
		return "Unknown trait."
	var t: Dictionary = _db[id]
	var mods: Dictionary = t.get("modifiers", {})
	var mod_texts: Array = []
	for raw_k in mods.keys():
		if raw_k == null:
			continue
		var k_str := str(raw_k)
		mod_texts.append("%s %+d" % [k_str.capitalize(), int(mods[raw_k])])
	var mod_line: String = String(", ").join(mod_texts)
	var type_text: String = String(t.get("type", "neutral")).capitalize()
	var level_req: int = t.get("requires_level", 1)
	var color: String = "lightgreen" if type_text == "Positive" else "crimson"
	return "[color=%s][b]%s[/b][/color]\nType: %s\nRequires Level: %d\nEffects: %s" % [
		color,
		t.get("name", id),
		type_text,
		level_req,
		mod_line
	]

func owned_as_readable() -> String:
	var names: Array = []
	for id in owned.keys():
		if id == null:
			continue
		var entry = _db.get(id, {})
		names.append(str(entry.get("name", id)))
	names.sort()
	return String(", ").join(names) if names.size() > 0 else "None"

func get_trait_name(id: String) -> String:
	return _db.get(id, {}).get("name", id)

func get_trait_type(id: String) -> String:
	return _db.get(id, {}).get("type", "?")
