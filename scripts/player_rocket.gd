extends Spatial

const SPEED = 30
const LIFESPAN = 5
var time := 0.0
var direct_hit_receiver :Node = null
var receivers = []


const EXPLOSION = preload("res://scenes/explosion.tscn")
const VFX_EXPLOSION = preload("res://scenes/vfx_explosion.tscn")

func _ready():
	$Timer.start(LIFESPAN)


func _physics_process(delta):
	translate_object_local(Vector3.FORWARD*SPEED*delta) #move forwad
	if $RayCast.is_colliding(): #check if rocket is hiting something
		if $RayCast.get_collider().get_collision_layer_bit(cmn.colliders.enemy_hurtbox):
			print("enemy hurt by direct hit")
		explode()

func explode():
	var explosion = EXPLOSION.instance()
	get_tree().current_scene.add_child(explosion)
	explosion.global_translation = global_translation
	var vfx_explosion = VFX_EXPLOSION.instance()
	get_tree().current_scene.add_child(vfx_explosion)
	vfx_explosion.global_translation = global_translation
	queue_free()

func _on_Timer_timeout():
	queue_free()
