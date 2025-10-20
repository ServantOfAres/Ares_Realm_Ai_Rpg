extends Control

@onready var story_btn: Button = $CenterContainer/VBoxContainer/Buttons/StoryButton
@onready var companion_btn: Button = $CenterContainer/VBoxContainer/Buttons/CompanionButton

func _ready() -> void:
	if story_btn == null or companion_btn == null:
		push_warning("MainMenu: buttons not found, check node paths.")
		return
	story_btn.pressed.connect(_on_story)
	companion_btn.pressed.connect(_on_companion)

func _on_story() -> void:
	get_tree().change_scene_to_file("res://scenes/CharacterCreation.tscn")

func _on_companion() -> void:
	get_tree().change_scene_to_file("res://companion/GUI/CompanionProfileSelect.tscn")
