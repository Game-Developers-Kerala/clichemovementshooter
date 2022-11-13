extends RayCast

const RAIL_VFX = preload("res://scenes/vfx_railshot.tscn")

func _ready():
	$Area.translate(Vector3.ZERO)

func shoot():
	var areas = $Area.get_overlapping_areas()
	var receivers = []
	var from = global_translation
	var to = -global_transform.basis.z*(cast_to.length())
	if is_colliding():
		to = get_collision_point()
	var length = (to-from).length()
	print("wall at:",length)
	if areas:
		for area in areas:
			if !receivers.has(area.hit_receiver):
				receivers.push_front(area.hit_receiver)
				var bodydist = (area.global_translation-from).length()
				if bodydist>length:
					print(area.hit_receiver.name," behind wall at:", bodydist)
				else:
					print(area.hit_receiver.name," hit at:",bodydist)
	var vfx = RAIL_VFX.instance()
	get_tree().current_scene.add_child(vfx)
	var vfx_offset = global_transform.basis.x - global_transform.basis.y
	vfx.init(from+vfx_offset*0.25,to)

