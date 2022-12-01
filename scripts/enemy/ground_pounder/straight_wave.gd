extends Spatial

export(float) var speed = 100
func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	translate_object_local(Vector3.FORWARD*speed*delta)
	
func _on_Area_body_entered(body: Node) -> void:
	
	if body.is_in_group('player'):
		$single_direct_hit.hit(body)

func _on_LifeSpan_timeout() -> void:
	queue_free()
