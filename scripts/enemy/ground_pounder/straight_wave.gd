extends Area

signal start

var target : Vector3 setget set_target, get_target
var unit : Vector3 = Vector3.ZERO

func _ready() -> void:
	set_target(Vector3.ZERO)
	
func _physics_process(delta: float) -> void:
	
	if get_target() != Vector3.ZERO:
		pass

func set_target(val: Vector3) -> void:
	target = val
	

func get_target() -> Vector3:
	return target


func _on_StraighWave_start(val) -> void:
	set_target(val)


func _on_StraighWave_body_entered(body: Node) -> void:
	
	if body.is_in_group("player"):
		print("player got hit")
