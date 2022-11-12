extends Spatial

const SPEED = 30
const LIFESPAN = 5
var time := 0.0
var direct_hit_receiver :Node = null
var receivers = []

var exp_fac = 0.0
const SIZE_START = 0.5
const SIZE_DIFF = 2.0
const EXPLOSION_SPEED = 10
onready var mat = $Explosion.get_active_material(0)

func _ready():
	set_process(false)
	$Timer.start(LIFESPAN)
	$Explosion.hide()
	$Explosion/Area/CollisionShape.disabled = true

func _physics_process(delta):
	translate_object_local(Vector3.FORWARD*SPEED*delta) #move forwad
	if $RayCast.is_colliding(): #check rocket is hiting something
		if $RayCast.get_collider().get_collision_layer_bit(cmn.colliders.enemy):
			print("enemy hurt by direct hit")
			receivers.push_front($RayCast.get_collider())
		explode()
		set_physics_process(false)

func _process(delta):
	exp_fac = lerp(exp_fac,1,delta*EXPLOSION_SPEED)
	mat.set_shader_param("opacity",1-exp_fac)
	var exp_size = SIZE_START+exp_fac*SIZE_DIFF
	$Explosion.scale = Vector3.ONE*exp_size
	if exp_fac > 0.98:
		queue_free()
	
func hit():
	pass

func explode():
	$Body.queue_free()
	set_process(true)
	$Explosion.show()
	$Explosion/Area/CollisionShape.disabled = false
	$Explosion/Area.translate(Vector3.ZERO)
	exp_fac = 0.0



func _on_Timer_timeout():
	if is_processing():
		return
	queue_free()


func _on_Area_body_entered(body):
	if body.get_collision_layer_bit(cmn.colliders.player):
		for node in receivers:
			if body == node:
				return
		receivers.push_front(body)
		var push_dict = {origin = $Explosion.global_translation, force = 30.0}
		body.get_pushed(push_dict)
		print("player in explosion:",OS.get_ticks_msec())
	if body.get_collision_layer_bit(cmn.colliders.enemy):
		for node in receivers:
			if body == node:
				return
		receivers.push_front(body)
		print("enemy hurt by explosion:",OS.get_ticks_msec())
