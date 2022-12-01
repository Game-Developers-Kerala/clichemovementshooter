extends Spatial

export(float) var speed = 100
func _ready() -> void:
	pass

func _process(delta: float) -> void:
	translate_object_local(Vector3.FORWARD*speed*delta)
	
	if $RayCast.is_colliding():
		queue_free()
	
func _on_Timer_timeout() -> void:
	queue_free()


func _on_Area_body_entered(body: Node) -> void:
	
	if body.is_in_group('player'):
		print("hited someone"+ str(body))
		$single_direct_hit.hit(body)
	queue_free()
