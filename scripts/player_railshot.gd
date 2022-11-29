extends RayCast

const RAIL_VFX = preload("res://scenes/vfx_railshot.tscn")
const ORGN = Vector3(0.104,-0.121,-0.4)
func _ready():
	$Area.translate(Vector3.ZERO)

func shoot():
	var areas = $Area.get_overlapping_areas()
	var receivers = []
	var gtb = global_transform.basis
	var vfx_offset = gtb.x*ORGN.x+gtb.y*ORGN.y+gtb.z*ORGN.z
	var from = global_translation
	var to = -gtb.z*200+from
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
	vfx.init(from+vfx_offset,to)
	queue_free()
