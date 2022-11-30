extends RayCast

const RAIL_VFX = preload("res://scenes/vfx_railshot.tscn")
const RAIL_HIT = preload("res://scenes/vfx_railshot_hit.tscn")
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
		var norm = get_collision_normal()
		spawn_hit_spot_on_wall(to,norm)
	var length = (to-from).length()
#	print("wall at:",length)
	if areas:
		for area in areas:
			if !receivers.has(area.hit_receiver):
				receivers.push_front(area.hit_receiver)
				area.hit_receiver.get_hit({dmg=70.0,push_dir=Vector3.ZERO,force=0,
											origin=global_translation,caused_by_player=true,
											dir_replace=false})
				var bodydist = (area.global_translation-from).length()
				spawn_hit_spot(bodydist)
#				if bodydist>length:
#					print(area.hit_receiver.name," behind wall at:", bodydist)
#				else:
#					print(area.hit_receiver.name," hit at:",bodydist)
	var vfx = RAIL_VFX.instance()
	get_tree().current_scene.add_child(vfx)
	vfx.init(from+vfx_offset,to)
	print("receivers",receivers)
	queue_free()

func spawn_hit_spot(distance:float):
	var spot = RAIL_HIT.instance()
	get_tree().current_scene.add_child(spot)
	spot.global_translation = global_translation-global_transform.basis.z*(distance-0.25)
	spot.look_at(global_translation,Vector3.UP)
	pass

func spawn_hit_spot_on_wall(pos,norm):
	var spot = RAIL_HIT.instance()
	get_tree().current_scene.add_child(spot)
	if abs(norm.dot(Vector3.UP))>0.98:
		spot.global_translation = pos+norm*0.01
		spot.rotation.x = PI*0.5
	else:
		spot.look_at_from_position(pos+norm*0.01,pos+norm,Vector3.UP)
	
