extends Spatial
class_name projectile

export(bool) var shot_by_player = false
export(float) var speed = 25
export(float) var lifespan = 5
export(bool) var detect_npc = true
export(bool) var detect_wall = true
export(bool) var detect_player = false
export(bool) var detect_custom = false
export(NodePath) var explosion
export(NodePath) var explosion_vfx
export(NodePath) var direct_hit
export(NodePath) var trail

func _ready():
	$Timer.start(lifespan)
	if trail:
		get_node(trail).start()
	ready_extend()

func ready_extend():
	pass

func _physics_process(delta):
	phys_process_extend(delta)

func phys_process_extend(delta):
	translate_object_local(Vector3.FORWARD*speed*delta) #move forwad

func _process(delta):
	process_extend(delta)

func process_extend(delta):
	pass

func explode():
	var explosion_node = get_node(explosion)
	remove_child(explosion_node)
	get_tree().current_scene.add_child(explosion_node)
	explosion_node.global_translation = global_translation
	explosion_node.explode()

func explode_vfx(normal_vec:Vector3=Vector3.ZERO):
	var explosion_node = get_node(explosion_vfx)
	remove_child(explosion_node)
	get_tree().current_scene.add_child(explosion_node)
	explosion_node.global_translation = global_translation
	explosion_node.explode(normal_vec)

func stop_trail():
	var trail_node = get_node(trail)
	remove_child(trail_node)
	get_tree().current_scene.add_child(trail_node)
	trail_node.global_transform = global_transform
	trail_node.stop()

func _on_Timer_timeout():
	if trail:
		stop_trail()
	queue_free()
