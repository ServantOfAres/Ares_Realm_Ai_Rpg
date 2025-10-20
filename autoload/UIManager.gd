extends Node

var _last_profile: Dictionary = {}

func _ready() -> void:
    if GameManager and GameManager.has_signal("profile_updated"):
        GameManager.profile_updated.connect(Callable(self, "on_profile_changed"))

func on_profile_changed(profile: Dictionary) -> void:
    _last_profile = profile
    var hud = _find_hud()
    if hud:
        hud.update_from_profile(profile)

func get_cached_profile() -> Dictionary:
    return _last_profile.duplicate(true)

func _find_hud() -> Node:
    if get_tree() == null:
        return null
    var current = get_tree().current_scene
    if current == null:
        return null
    var stack: Array = [current]
    while stack.size() > 0:
        var n: Node = stack.pop_back()
        if n.has_method("update_from_profile"):
            return n
        for c in n.get_children():
            stack.append(c)
    return null

