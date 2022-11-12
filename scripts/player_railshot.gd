extends RayCast

const RAIL_VFX = preload("res://scenes/vfx_railshot.tscn")

func _ready():
	$Area.translate(Vector3.ZERO)

func shoot():
	var receivers = $Area.get_overlapping_bodies()
	var from = global_translation
	var to = -global_transform.basis.z*(cast_to.length())
	if is_colliding():
		to = get_collision_point()
	var length = (to-from).length()
	if receivers:
		for body in receivers:
			var bodydist = ((body.global_translation+Vector3.UP)-from).length()
			if bodydist>length:
				continue
			print(OS.get_ticks_msec(),":",body," got hit by rail")
	var vfx = RAIL_VFX.instance()
	get_tree().current_scene.add_child(vfx)
	var vfx_offset = global_transform.basis.x - global_transform.basis.y
	vfx.init(from+vfx_offset*0.25,to)

