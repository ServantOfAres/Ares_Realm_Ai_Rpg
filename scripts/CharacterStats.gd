extends Resource
class_name CharacterStats

# Lightweight stat container for player or companion

# === Core data ===
var stats: Dictionary = {
	"strength": 0,
	"agility": 0,
	"intelligence": 0,
	"charisma": 0,
	"endurance": 0
}

# === Reset all stats to zero ===
func reset() -> void:
	for raw_k in stats.keys():
		if raw_k == null:
			continue
		var k := str(raw_k)
		stats[k] = 0

# === Add or subtract from a stat ===
func add_stat(stat_name: String, value: int, max_value: int = 100) -> void:
	if not stats.has(stat_name):
		push_warning("Unknown stat: %s" % stat_name)
		return
	stats[stat_name] = clamp(stats[stat_name] + value, 0, max_value)

# === Set a stat directly ===
func set_stat(stat_name: String, value: int) -> void:
	if stats.has(stat_name):
		stats[stat_name] = max(0, value)

# === Get a stat safely ===
func get_stat(stat_name: String) -> int:
	return int(stats.get(stat_name, 0))

# === Create a deep copy of this object ===
func clone() -> CharacterStats:
	var copy := CharacterStats.new()
	copy.stats = stats.duplicate(true)
	return copy

# === Convert stats into a dictionary for saving/UI ===
func as_dict() -> Dictionary:
	return stats.duplicate(true)

# === Randomize starting stats ===
func randomize_starting_stats(total_points: int = 10, per_stat_cap: int = 10) -> void:
	reset()
	if total_points <= 0:
		return
	var keys: Array = []
	for raw_k in stats.keys():
		if raw_k == null:
			continue
		keys.append(str(raw_k))
	var remaining: int = total_points

	while remaining > 0 and keys.size() > 0:
		var raw_idx = randi() % keys.size()
		var k: String = str(keys[raw_idx])
		if stats.has(k) and stats[k] < per_stat_cap:
			stats[k] += 1
			remaining -= 1
