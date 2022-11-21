extends Area

onready var hit_receiver = get_parent()

func _ready() -> void:
	
	print(hit_receiver)
