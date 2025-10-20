extends Node

func _ready():
    print("AI test starting...")
    if not Engine.has_singleton("AIAdapter"):
        print("No AIAdapter autoload found")
        return
    var adapter = get_node_or_null("/root/AIAdapter")
    print("Adapter API base:", adapter.api_base)
    var avail = adapter.is_available()
    print("Is available:", avail)
    if avail:
        var t = adapter.request_text("Say hello from LM Studio")
        print("Text response:", t)
        var img = adapter.request_image("A friendly portrait, simple style")
        print("Image path:", img)
    else:
        print("Adapter not reachable; check LM Studio at", adapter.api_base)
