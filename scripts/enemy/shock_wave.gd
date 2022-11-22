extends Area

var unit : Vector3 = Vector3(4,0,4)


func _ready() -> void:
	
	monitoring = true


func _physics_process(delta: float) -> void:
	
	if scale < Vector3(14,0,14):
		scale += unit * delta
	else :
		queue_free()
		
		
func _on_CircularWave_body_entered(body: Node) -> void:
	
	if body.is_in_group("player"):
		print("player entered")
		$CollisionShape.set_disabled(false)
