extends HBoxContainer

@export var role: String = "user" # "user" or "ai"
@onready var text_label: Label = $Label

func set_text(t: String) -> void:
    text_label.text = t
    _apply_style()

func _apply_style() -> void:
    alignment = role == "ai" ? BoxContainer.ALIGNMENT_BEGIN : BoxContainer.ALIGNMENT_END

