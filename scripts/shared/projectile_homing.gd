extends projectile

export(float) var steering = 0.4
export(float) var launch_time = 0.1


var target:Spatial
onready var target_pos :Vector3 = -global_transform.basis.z
var look_dir :Vector3

var launched = false

func ready_extend():
	set_physics_process(false)
	look_at(global_translation+look_dir,Vector3.UP)
	$JustLaunched.start(launch_time)
	if detect_wall:
		$Area.set_collision_mask_bit(cmn.colliders.level,true)
	if detect_npc:
		$Area.set_collision_mask_bit(cmn.colliders.enemy_hurtbox,true)
	if detect_player:
		$Area.set_collision_mask_bit(cmn.colliders.player,true)

func process_extend(delta):
	if launched and is_instance_valid(target):
		var looking_at = global_translation - global_transform.basis.z
		target_pos = target.global_translation+Vector3.UP
		look_dir = lerp(looking_at,target_pos,delta*steering)
		look_at(target_pos,Vector3.UP)
	translate_object_local(Vector3.FORWARD*speed*delta)

func terminate(recepient:Node=null):
	if direct_hit and is_instance_valid(recepient):
		get_node(direct_hit).hit(recepient)
	if explosion:
		explode(explosion)
	if explosion_vfx:
		explode(explosion_vfx)
	if trail:
		stop_trail()
	queue_free()

func _on_Timer_timeout():
	terminate()

func _on_Area_area_entered(area):
	$Area.disconnect("area_entered",self,"_on_Area_area_entered")
	var recepient:Node=null
	if !area.get_collision_layer_bit(cmn.colliders.level):
		recepient = area.hit_receiver
	terminate(recepient)

func _on_Area_body_entered(body):
	$Area.disconnect("body_entered",self,"_on_Area_body_entered")
	var recepient:Node=null
	if !body.get_collision_layer_bit(cmn.colliders.level):
		recepient = body
	terminate(recepient)


func _on_JustLaunched_timeout():
	launched = true
