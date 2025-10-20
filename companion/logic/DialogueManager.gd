extends Node
class_name DialogueManager

# Keep a short in-memory conversation history per session to preserve context.
var _history: Array = [] # entries: {role: "user"/"assistant", content: "..."}
var _history_limit: int = 12

func _push_history(role: String, content: String) -> void:
	_history.append({"role": role, "content": content})
	while _history.size() > _history_limit:
		_history.pop_front()

# Minimal, robust reply function that passes recent history to the adapter.
func reply(user_text, personality, memory) -> String:
	if user_text == null:
		return ""
	var user_msg := str(user_text)
	_push_history("user", user_msg)

	# Simple local flavoring
	var flavored := user_msg
	if user_msg.to_lower().find("music") != -1:
		if memory and memory.has_method("remember_preference"):
			memory.remember_preference("likes_music", true)
		flavored = "I remember you mentioned music - what are you into lately?"
	elif user_msg.to_lower().find("story") != -1:
		flavored = "Want to hop into story mode or just chat about it?"

	var ai_text := ""
	if Engine.has_singleton("AIAdapter"):
		var adapter = get_node_or_null("/root/AIAdapter")
		if adapter and adapter.has_method("request_text"):
			# Build a system prompt with persona + game context
			var persona := "Companion"
			if personality and typeof(personality) == TYPE_OBJECT and personality.has("name"):
				persona = str(personality.name)
			var system_msg := "You are %s, a helpful in-game companion. Keep responses in-character and concise." % persona
			var history_payload := []
			history_payload.append({"role": "system", "content": system_msg})
			# add prior history
			for h in _history:
				history_payload.append({"role": h.role, "content": h.content})
			# request text with history
			ai_text = adapter.request_text(user_msg, 512, 15, history_payload)

	if ai_text == null or ai_text == "":
		# fallback
		var name := "Companion"
		# PersonalityCore is a Resource with exported `name`. Avoid calling `has()` on objects —
		# check for a known helper method or directly access the exported property if present.
		if personality and personality.has_method("to_dict"):
			name = str(personality.name)
		var bond := 0
		if memory and memory.has_method("get_core_memory"):
			bond = int(memory.get_core_memory("emotional_bond") or 0)
		var opener := ""
		if bond >= 60:
			opener = "(warmly) "
		elif bond >= 30:
			opener = "(gently) "
		var reply_text := "%s%s: %s" % [opener, name, flavored]
		_push_history("assistant", reply_text)
		# persist memory record via CompanionManager if available
		if Engine.has_singleton("CompanionManager") and CompanionManager and CompanionManager.memory and CompanionManager.memory.has_method("record_event"):
			CompanionManager.memory.record_event("ai_msg", reply_text)
		return reply_text

	# Successful AI response
	_push_history("assistant", ai_text)
	if Engine.has_singleton("CompanionManager") and CompanionManager and CompanionManager.memory and CompanionManager.memory.has_method("record_event"):
		CompanionManager.memory.record_event("ai_msg", ai_text)
	return ai_text
