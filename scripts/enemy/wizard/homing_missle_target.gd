extends Area

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func _on_Die_timeout() -> void:
	
	queue_free()
