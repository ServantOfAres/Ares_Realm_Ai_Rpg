extends Control

# Simple test UI script to toggle traits and observe traits_changed signal

onready var status_label: Label = $VBox/Status
onready var toggle_btn: Button = $VBox/ToggleBtn
onready var random_btn: Button = $VBox/RandomBtn

func _ready():
	if GameManager and GameManager.traits:
		GameManager.traits.connect("traits_changed", Callable(self, "_on_traits_changed"))
	else:
		status_label.text = "GameManager.traits not available"

	toggle_btn.pressed.connect(_on_toggle_pressed)
	random_btn.pressed.connect(_on_random_pressed)
	_update_status()

func _on_toggle_pressed():
	# Toggle a specific trait for testing
	var id = "quick_learner"
	if GameManager.traits.owned.has(id):
		GameManager.traits.remove(id)
		status_label.text = "Removed %s" % id
	else:
		GameManager.traits.add(id)
		status_label.text = "Added %s" % id

func _on_random_pressed():
	GameManager.grant_random_traits(1)
	status_label.text = "Granted random trait"

func _on_traits_changed(current: Dictionary) -> void:
	_update_status()

func _update_status():
	if not GameManager or not GameManager.traits:
		status_label.text = "GameManager.traits not available"
		return
	status_label.text = "Owned: %s" % GameManager.traits.owned_as_readable()
