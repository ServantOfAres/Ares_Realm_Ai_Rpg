extends Control

@onready var name_input: LineEdit = $MarginContainer/VBoxContainer/NameRow/NameInput
@onready var age_slider: HSlider = $MarginContainer/VBoxContainer/AgeRow/AgeSlider
@onready var gender_opt: OptionButton = $MarginContainer/VBoxContainer/GenderRow/GenderOpt
@onready var temp_opt: OptionButton = $MarginContainer/VBoxContainer/TempRow/TempOpt
@onready var visual_text: TextEdit = $MarginContainer/VBoxContainer/VisualText
@onready var random_btn: Button = $MarginContainer/VBoxContainer/Buttons/RandomizeBtn
@onready var confirm_btn: Button = $MarginContainer/VBoxContainer/Buttons/ConfirmBtn
@onready var prompt_preview: Label = $MarginContainer/VBoxContainer/PromptPreview

func _ready() -> void:
    for g in ["Female","Male","Non-binary"]:
        gender_opt.add_item(g)
    for t in ["Playful and supportive","Curious and adventurous","Calm and thoughtful","Bold and sassy"]:
        temp_opt.add_item(t)
    random_btn.pressed.connect(_on_randomize)
    confirm_btn.pressed.connect(_on_confirm)
    _on_randomize()

func _on_randomize() -> void:
    CompanionManager.randomize_personality()
    _sync_from_core()

func _sync_from_core() -> void:
    var p = CompanionManager.personality
    name_input.text = p.name
    age_slider.value = p.age
    var gi := max(0, ["Female","Male","Non-binary"].find(p.gender))
    gender_opt.select(gi)
    var ti := max(0, ["Playful and supportive","Curious and adventurous","Calm and thoughtful","Bold and sassy"].find(p.temperament))
    temp_opt.select(ti)
    visual_text.text = p.visual_description
    prompt_preview.text = "Portrait prompt: " + CompanionManager.build_portrait_prompt()

func _on_confirm() -> void:
    var p = PersonalityCore.new()
    p.name = name_input.text
    p.age = int(age_slider.value)
    p.gender = gender_opt.get_item_text(gender_opt.selected)
    p.temperament = temp_opt.get_item_text(temp_opt.selected)
    p.visual_description = visual_text.text
    CompanionManager.set_personality(p)
    prompt_preview.text = "Portrait prompt: " + CompanionManager.build_portrait_prompt()
    get_tree().change_scene_to_file("res://companion/GUI/CompanionUI.tscn")

