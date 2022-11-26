extends Area

var unit : Vector3 = Vector3(8,0,8)


func _ready() -> void:
	translate(Vector3.ONE)
	force_update_transform()


func _physics_process(delta: float) -> void:
	
	if scale < Vector3(14,0,14):
		scale += unit * delta
	else :
		queue_free()
		
func _on_CircularWave_body_entered(body: Node) -> void:
	disconnect("body_entered",self,"_on_CircularWave_body_entered")
	if body.is_in_group("player"):
		print(self.name,"player caught in WAVE!!!")
		$single_direct_hit.hit(body)
