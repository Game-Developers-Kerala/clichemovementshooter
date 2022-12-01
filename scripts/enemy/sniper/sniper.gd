extends KinematicBody

export(float) var speed = 3
export(int) var max_health = 150
var health :int = max_health
export(float) var atk_cool_time = 7
export(float) var atk_dmg = 20
export(float) var atk_push_force = 75


onready var player = get_tree().get_nodes_in_group("player")[0]

onready var model = $model
onready var anim = $model/AnimationPlayer
onready var wand_tip = $model/Armature/Skeleton2/right_hand/wand/wand_tip
const CENTER_OF_MASS = Vector3(0,2,0)

var random = RandomNumberGenerator.new()
enum states {idle,repositioning,shot_warm,shot_wind,shot_fire,stunned,dead}
var state:int = states.idle

var state_times = {
					"shot_warm":4.0,"shot_wind":0.5,"shot_fire":0.5,
					"stunned":1.5,"dead":2.0
					}
#var next_state = states.idle

#var velocity:=Vector3.ZERO
var navdir := Vector3.ZERO
var nav = false

func get_eye_pos()->Vector3:
	return global_translation + CENTER_OF_MASS

func get_player_pos()->Vector3:
	return player.global_translation + player.CENTER_OF_MASS

func _ready():
	$ray_aim/ray_vfx_holder/shot.hide()
	$ray_aim/ray_vfx_holder/warn.hide()
	random.randomize()
	yield(get_tree().create_timer(random.randf_range(0,$blink_timer.wait_time)),"timeout")
	$blink_timer.start()
	pass

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
		if $ray_aim.enabled:
			var from = wand_tip.global_translation
			$ray_aim.look_at_from_position(from,get_player_pos(),Vector3.UP)
			var ray_length = 200.0
			if $ray_aim.is_colliding():
				var point = $ray_aim.get_collision_point()
				ray_length = ($ray_aim.global_translation-point).length()
				$ray_aim/ray_vfx_holder.scale.z = ray_length

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
				change_state(states.shot_warm)
			else:
				change_state(states.repositioning)
		states.repositioning:
			if is_player_attackable():
				change_state(states.shot_warm)

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
			$ray_aim/ray_vfx_holder/warn.hide()
			$ray_aim.enabled=false
			anim.play("idle")
			pass
		states.repositioning:
			$ray_aim/ray_vfx_holder/warn.hide()
			$ray_aim.enabled=false
			var vantageholder = get_tree().get_nodes_in_group("vantage_points")[0]
			if vantageholder:
				var new_nav_point = vantageholder.get_random_sniper_vantage_position()
				$NavigationAgent.set_target_location(new_nav_point)
				nav = true
				anim.play("run")
			pass
		states.shot_warm:
			$ray_aim.enabled=true
			$ray_aim/ray_vfx_holder/warn.show()
			anim.play("shot_warmup")
			pass
		states.shot_wind:
			anim.play("shot_windup")
			pass
		states.shot_fire:
			$ray_aim/ray_vfx_holder/warn.hide()
			$ray_aim/ray_vfx_holder/shot.show_fx()
			$cooldown_timer.start(atk_cool_time)
			anim.play("shot_fire")
			if $ray_aim.is_colliding():
				if $ray_aim.get_collider()==player:
					damage_player()
			$ray_aim.enabled = false
			pass
		states.stunned:
			$ray_aim/ray_vfx_holder/warn.hide()
			$ray_aim.enabled = false
			if is_in_shooting_state():
				anim.play("hit_while_shooting")
			else:
				anim.play("hit_norm")
			pass
		states.dead:
			$ray_aim/ray_vfx_holder/warn.hide()
			$ray_aim.enabled = false
			$CollisionShape.disabled = true
			anim.play("dead")
			game.emit_signal("enemy_killed")
			pass
	state = to_state
	if state_times.has(states.keys()[state]):
		$state_timer.start(state_times[states.keys()[state]])

func _on_state_timer_timeout():
	match state:
		states.shot_warm:
			change_state(states.shot_wind)
		states.shot_wind:
			change_state(states.shot_fire)
		states.shot_fire:
			change_state(states.idle)
		states.stunned:
			change_state(states.idle)
		states.dead:
			queue_free()

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

func is_in_shooting_state()->bool:
	var shooting:=false
	if state == states.shot_fire:
		shooting = true
	if state == states.shot_warm:
		shooting = true
	if state == states.shot_wind:
		shooting = true
	return shooting

func damage_player():
	var atk_dict = {dmg=atk_dmg,
					force=atk_push_force,
					push_dir=-$ray_aim.global_transform.basis.z,
					origin = $ray_aim.global_translation,
					#dir_replace = true,
					}
	player.get_hit(atk_dict)

func _on_NavigationAgent_target_reached():
	change_state(states.idle)
