extends Node

# --- External script references ---
const CharacterStats = preload("res://scripts/CharacterStats.gd")
const TraitsSystem   = preload("res://scripts/TraitsSystem.gd")

# --- Signals ---
signal profile_updated(profile: Dictionary)

# --- Core systems ---
var stats: CharacterStats = CharacterStats.new()
var traits: TraitsSystem  = TraitsSystem.new()

# --- XP / Level Settings ---
var xp_per_level: int     = 100
var start_points: int     = 10
var per_stat_cap: int     = 10

# --- Internal state ---
var _profile: Dictionary = {
	"level": 1,
	"xp": 0,
	"stats": {},
	"traits": {}
}

# --------------------------------------------------------------------
#  Lifecycle
# --------------------------------------------------------------------
func _ready() -> void:
	print("GameManager ready")
	_emit_profile()

# --------------------------------------------------------------------
#  Profile Management
# --------------------------------------------------------------------
func new_profile() -> void:
	stats.reset()
	traits.reset()
	_profile = {
		"level": 1,
		"xp": 0,
		"stats": stats.as_dict(),
		"traits": traits.owned
	}
	_emit_profile()

func _emit_profile() -> void:
	_profile["stats"]  = stats.as_dict()
	_profile["traits"] = traits.owned
	emit_signal("profile_updated", _profile)

# --------------------------------------------------------------------
#  Level / XP Helpers
# --------------------------------------------------------------------
func add_xp(amount: int) -> void:
	_profile["xp"] += amount
	while _profile["xp"] >= xp_per_level:
		_profile["xp"] -= xp_per_level
		_profile["level"] += 1
		print("Level Up! → %d" % _profile["level"])
	_emit_profile()

func get_level() -> int:
	return int(_profile.get("level", 1))

# --------------------------------------------------------------------
#  XP / Progress Accessors
# --------------------------------------------------------------------
func get_current_xp() -> int:
	return int(_profile.get("xp", 0))

func get_xp_for_next_level() -> int:
	return xp_per_level

func get_xp_progress() -> float:
	var current_xp: int = get_current_xp()
	return float(current_xp) / float(xp_per_level)

# --------------------------------------------------------------------
#  Stats & Traits Accessors
# --------------------------------------------------------------------
func get_effective_stats() -> Dictionary:
	var copy: CharacterStats = stats.clone()
	traits.apply_modifiers(copy)
	return copy.as_dict()

func grant_random_traits(count: int = 1, allow_negative: bool = true, allow_positive: bool = true) -> void:
	var level: int = get_level()
	var picked: Array[String] = traits.pick_random(level, count, allow_negative, allow_positive)
	for id: String in picked:
		traits.add(id)
	_emit_profile()

# --------------------------------------------------------------------
#  Debug / Dev Helpers
# --------------------------------------------------------------------
func debug_print_profile() -> void:
	print("---- PROFILE ----")
	print("Level:", _profile["level"])
	print("XP:", _profile["xp"])
	print("Stats:", _profile["stats"])
	print("Traits:", traits.owned_as_readable())
