extends Resource
class_name PersonalityCore

@export var name: String = "Astra"
@export_range(18, 100, 1) var age: int = 25
@export var gender: String = "Female"
@export var temperament: String = "Playful and supportive"
@export var visual_description: String = "Cheerful, short silver hair, bright blue eyes"
@export var favorite_things: Array[String] = ["adventure","music","sunsets"]
@export var dislikes: Array[String] = ["rudeness","broken promises"]
@export var core_values: Array[String] = ["loyalty","curiosity","growth"]
@export_multiline var backstory: String = "An AI companion who grows with the user through shared moments."

func describe_self() -> String:
    return "%s is a %d-year-old %s. %s Personality: %s" % [name, age, gender, visual_description, temperament]

func to_dict() -> Dictionary:
    return {
        "name": name,
        "age": age,
        "gender": gender,
        "temperament": temperament,
        "visual_description": visual_description,
        "favorite_things": favorite_things,
        "dislikes": dislikes,
        "core_values": core_values,
        "backstory": backstory
    }

static func from_dict(d: Dictionary) -> PersonalityCore:
    var p := PersonalityCore.new()
    p.name = d.get("name", p.name)
    p.age = int(d.get("age", p.age))
    p.gender = d.get("gender", p.gender)
    p.temperament = d.get("temperament", p.temperament)
    p.visual_description = d.get("visual_description", p.visual_description)
    p.favorite_things = d.get("favorite_things", p.favorite_things)
    p.dislikes = d.get("dislikes", p.dislikes)
    p.core_values = d.get("core_values", p.core_values)
    p.backstory = d.get("backstory", p.backstory)
    return p

