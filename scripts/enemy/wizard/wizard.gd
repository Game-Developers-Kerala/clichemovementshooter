extends KinematicBody

export(int) var max_health = 100
var health :int = max_health

onready var player = get_tree().get_nodes_in_group("player")[0]

onready var model = $model
onready var anim = $model/AnimationPlayer
onready var staff_tip = $model/Armature/Skeleton/staff/staff_tip

const CENTER_OF_MASS = Vector3(0,1.5,0)
export var atk_cool_time :float = 12
var nav := false

var random = RandomNumberGenerator.new()

var navdir := Vector3.ZERO
var speed := 4

enum states {idle,repositioning,attack_wind,attack_fire,stunned,dead}
var state = states.idle

var state_times = {
					"attack_wind":0.8,"attack_fire":0.8,"stunned":1.5,"dead":2.0}

const FIREBALL = preload("res://scenes/enemy/wizard/wizard_projectile_homing.tscn")

func get_eye_pos()->Vector3:
	return global_translation + CENTER_OF_MASS

func get_player_pos()->Vector3:
	return player.global_translation + player.CENTER_OF_MASS

func _ready():
	random.randomize()
	yield(get_tree().create_timer(random.randf_range(0,$blink_timer.wait_time)),"timeout")
	$blink_timer.start()

func _physics_process(delta):
	if $NavigationAgent.is_navigation_finished() or !nav:
		return
	navdir = global_transform.origin.direction_to($NavigationAgent.get_next_location())
	var velocity = move_and_slide(navdir*speed,Vector3.UP)
	move_and_slide(velocity,Vector3.UP)

func _process(delta):
	if state == states.stunned or state == states.dead:
		return
	if nav:
		face_heading(delta)
	else:
		face_player()

func face_player():
	look_at(get_player_pos(),Vector3.UP)
	rotation.x = 0

func face_heading(delta):
	var lerp_rate = 2
	var dir = navdir
	var angleside = 1-2*int(dir.cross(-global_transform.basis.z).y<0)
	var theta = dir.dot(-global_transform.basis.z.normalized())
	var angle = acos(theta)*angleside
	if abs(angle)<deg2rad(3):
		return
	rotation.y = lerp_angle(rotation.y,rotation.y-angle,delta*lerp_rate)

func _on_blink_timer_timeout():
	match state:
		states.idle:
			if is_player_attackable():
				change_state(states.attack_wind)
			else:
				change_state(states.repositioning)
		states.repositioning:
			if is_player_attackable():
				change_state(states.attack_wind)

func is_player_attackable():
	if !$cooldown_timer.is_stopped():
		return false
	$ray_sight.look_at_from_position(get_eye_pos(),get_player_pos(),Vector3.UP)
	$ray_sight.force_raycast_update()
	if $ray_sight.is_colliding():
		if $ray_sight.get_collider() == player:
			return true
	return false

func change_state(to_state:int,args:={}):
	nav = false
	match to_state:
		states.idle:
			anim.play("idle")
			pass
		states.repositioning:
			var vantageholder = get_tree().get_nodes_in_group("vantage_points")[0]
			if vantageholder:
				var new_nav_point = vantageholder.get_random_sniper_vantage_position()
				$NavigationAgent.set_target_location(new_nav_point)
				nav = true
				anim.play("run")
			pass
		states.attack_wind:
			anim.play("attack_windup")
		states.attack_fire:
			$cooldown_timer.start(atk_cool_time)
			anim.play("attack_fire")
			shoot_fireball()
		states.stunned:
			anim.play("hit")
			pass
		states.dead:
			$CollisionShape.disabled = true
			anim.play("dead")
			game.emit_signal("enemy_killed")
			pass
	state = to_state
	if state_times.has(states.keys()[state]):
		$state_timer.start(state_times[states.keys()[state]])

func get_hit(dict):
	if state == states.dead:
		print("dead")
		return
	print(dict)
	health = max(health-dict["dmg"],0)
	if !health:
		change_state(states.dead)
		return
	if dict["dmg"] > 15:
		change_state(states.stunned)

func _on_NavigationAgent_navigation_finished():
	change_state(states.idle)


func _on_state_timer_timeout():
	match state:
		states.attack_wind:
			change_state(states.attack_fire)
		states.attack_fire:
			change_state(states.idle)
		states.stunned:
			change_state(states.idle)
		states.dead:
			queue_free()

func shoot_fireball():
	var inst = FIREBALL.instance()
	inst.target = player
	inst.look_dir = -global_transform.basis.z
	get_tree().current_scene.add_child(inst)
	inst.global_translation = staff_tip.global_translation
	
