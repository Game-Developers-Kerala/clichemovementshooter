tool
extends Area
class_name pickup

var origin = Vector3.ZERO

# Type of the pickup, Add new items at the end
# DONOT INSERT NEW ITEMS BETWEEN EXISTING ITEMS,
# DONOT DELETE EXISTING ITEMS, EVEN IF UNUSED!
enum types {none,health_small,health_medium,health_large,health_super
			weapon_rail,weapon_missilepack
			powerup_spikecage}

const PICKUP_INFO = {
				"none":{},
				"health_small":{"health":3,"health_overload":true},
				"health_medium":{"health":20},
				"health_large":{"health":50},
				"health_super":{"health":200,"health_overload":true},
				"weapon_rail":{"weapon_rail":true},
				"weapon_missilepack":{"weapon_missilepack":true},
				"powerup_spikecage":{"powerup_spikecage":true},
				}

export(types) var type = types.none
export var model_node :NodePath
var pickup_model :Node = null
var pickup_ready :bool = true


export(bool) var respawning = false
export(float) var respawn_interval = 20
export(bool) var despawning = false
export(float) var lifespan = 10

export(bool) var anim_rotate = false
export(float) var rotation_speed = 0.5
export(bool) var anim_bob = false
export(float) var bob_speed = 3.0
export(float) var bob_amplitude = 0.1
export(NodePath) var glow


func _ready():
	if model_node:
		pickup_model = get_node(model_node)
	origin = global_translation
	set_process(false)
	if anim_bob or anim_rotate:
		set_process(true)

func get_pickup_info()->Dictionary:
	return PICKUP_INFO[types.keys()[type]]

func on_pickup():
	if respawning:
		respawner_pickedup()
		return
	queue_free()

func respawner_pickedup():
	pickup_ready = false
	if glow:
		get_node(glow).hide()
	$CollisionShape.disabled = true
	if pickup_model:
		pickup_model.hide()
	$Timer.start(respawn_interval)

func respawn():
	pickup_ready = true
	if glow:
		get_node(glow).show()
	$CollisionShape.disabled = false
	yield(get_tree(),"idle_frame")
	translate(Vector3.ZERO)
	force_update_transform()
	if pickup_model:
		pickup_model.show()

func despawn():
	queue_free()

func _on_Timer_timeout():
	if despawning:
		despawn()
	if respawning:
		respawn()

func _process(delta):
	if Engine.editor_hint:
		return
	if !anim_rotate and !anim_bob:
		set_process(false)
		return
	if anim_rotate:
		rotate_y(PI*delta*rotation_speed)
	if anim_bob:
		global_translation.y = origin.y + sin(game.time*bob_speed)*bob_amplitude


func _on_VisibilityNotifier_camera_entered(camera):
	set_process(true)
	show()

func _on_VisibilityNotifier_camera_exited(camera):
	set_process(false)
	hide()
