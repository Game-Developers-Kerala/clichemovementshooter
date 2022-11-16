extends Spatial

export(bool) var caused_by_player = false
export(float) var damage = 0.0
export(float) var force = 0.0
export(bool) var dir_replace = false

var atk_dict :Dictionary = {"caused_by_player":false, "dmg":0.0,"force":0.0,
							"push_dir":Vector3.ZERO,"dir_replace":false,"origin":Vector3.ZERO}

func _ready():
	atk_dict.dmg = damage
	atk_dict.force = force
	atk_dict.dir_replace = dir_replace
	atk_dict.caused_by_player = caused_by_player

func hit(recepient:Node=null):
	if is_instance_valid(recepient):
		atk_dict.push_dir = -global_transform.basis.z
		atk_dict.origin = global_translation
		recepient.get_hit(atk_dict)
#		print("direct hit on ",recepient.name)
	queue_free()
