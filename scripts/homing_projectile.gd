extends Area

export(float) var speed = 25
export(float) var lifespan = 10
export(float) var steering = 0.4
export(float) var launch_time = 0.1
export(bool) var detect_npc = true
export(bool) var detect_wall = true
export(bool) var detect_player = false
export(NodePath) var explosion

var target:Spatial
onready var target_pos :Vector3 = -global_transform.basis.z
var look_dir :Vector3

var launched = false

func _ready():
	look_at(global_translation+look_dir,Vector3.UP)
	$JustLaunched.start(launch_time)
	if detect_wall:
		set_collision_mask_bit(cmn.colliders.level,true)
	if detect_npc:
		set_collision_mask_bit(cmn.colliders.enemy,true)
	if detect_player:
		set_collision_mask_bit(cmn.colliders.player,true)
	$Timer.start(lifespan)

func _process(delta):
	if launched and is_instance_valid(target):
		var looking_at = global_translation - global_transform.basis.z
		target_pos = target.global_translation+Vector3.UP
		look_dir = lerp(looking_at,target_pos,delta*steering)
		look_at(target_pos,Vector3.UP)
	translate_object_local(Vector3.FORWARD*speed*delta)
	
func _on_Timer_timeout():
	terminate()


func _on_homing_projectile_body_entered(body):
	terminate()

func terminate():
	if explosion:
		explode()
	queue_free()

func explode():
	var explosion_node = get_node(explosion)
	remove_child(explosion_node)
	get_tree().current_scene.add_child(explosion_node)
	explosion_node.global_translation = global_translation
	explosion_node.explode()

func _on_JustLaunched_timeout():
	launched = true
