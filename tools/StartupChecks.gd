extends Node

# Lightweight development-time startup checks.
# Add this script as an autoload (Project Settings -> Autoload) named "StartupChecks" for extra diagnostics.

func _ready() -> void:
	var msgs := []
	msgs.append("Startup checks run at %s" % [OS.get_datetime().to_string()])

	# Check common autoloads
	var expected := ["GameManager", "StoryManager", "UIManager", "CompanionManager", "AIAdapter"]
	for name in expected:
		if not Engine.has_singleton(name):
			msgs.append("MISSING autoload singleton: %s" % name)

	# Check CompanionManager basics
	if Engine.has_singleton("CompanionManager"):
		var cm = get_node_or_null("/root/CompanionManager")
		if cm == null:
			msgs.append("CompanionManager singleton present but node not found at /root/CompanionManager")
		else:
			if not cm.personality:
				msgs.append("CompanionManager: personality is null")
			if not cm.memory:
				msgs.append("CompanionManager: memory is null")

	# Scan traits DB for null keys or malformed entries
	if Engine.has_singleton("GameManager") and GameManager and GameManager.traits:
		for raw_k in GameManager.traits._db.keys():
			if raw_k == null:
				msgs.append("TraitsSystem: null key in _db")
				continue
			var k_str := str(raw_k)
			var entry = GameManager.traits._db.get(k_str, {})
			if typeof(entry) != TYPE_DICTIONARY:
				msgs.append("TraitsSystem: non-dict entry for key: %s" % k_str)

	# Write results to user://startup_check.txt (overwrites)
	var path := "user://startup_check.txt"
	var f := FileAccess.open(path, FileAccess.WRITE)
	for m in msgs:
		f.store_line(m)
	f.close()

	# Also print to console for immediate feedback
	for m in msgs:
		print(m)
