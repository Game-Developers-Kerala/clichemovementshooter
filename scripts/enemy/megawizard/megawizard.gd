extends KinematicBody

export(float) var speed = 2
export(int) var max_health = 1000
var health :int = max_health
export(float) var guns_cool_time = 5
export(float) var guns_shots_count = 5
export(float) var guns_shots_interval = 0.1
export(float) var mines_cool_time = 10



onready var player = get_tree().get_nodes_in_group("player")[0]

onready var model = $model
onready var anim = $model/AnimationPlayer
onready var muzzle_left = $model/Armature/Skeleton/body/bonecorrection/Guns/muzzle_left
onready var muzzle_right = $model/Armature/Skeleton/body/bonecorrection/Guns/muzzle_right
const CENTER_OF_MASS = Vector3(0,6.5,0)

var random = RandomNumberGenerator.new()
enum states {idle,repositioning,cast_start,casting,cast_end,stunned,dead}
var state:int = states.idle
var gun_shooting := false
var gun_barrage_shots := 0
enum gun_cooling_states {none,barrage_ongoing,barrage_over}
var gun_cooling_state = gun_cooling_states.none

var state_times = {
					"cast_start":1.5,"casting":4,"cast_end":1.65,
					"stunned":2,"dead":2.0
					}

var navdir := Vector3.ZERO
var nav = false

const MINEPROBE = preload("res://scenes/shared/magic_mine_probe.tscn")
const BULLET = preload("res://scenes/enemy/megawizard/megawizard_gun_projectile.tscn")


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
			change_state(states.repositioning)
		states.repositioning:
			if is_player_attackable():
				start_gun_barrage()
			elif $mines_cooldown.is_stopped():
				change_state(states.cast_start)

func is_player_attackable():
	if is_in_casting_state() or !is_gun_ready():
		return false
	$ray_sight.look_at_from_position(get_eye_pos(),get_player_pos(),Vector3.UP)
	$ray_sight.force_raycast_update()
	if $ray_sight.is_colliding():
		if $ray_sight.get_collider() == player:
			return true
	return false

func change_state(to_state:int,args:={}):
	nav = false
	$Castfx.hide()
	match to_state:
		states.idle:
			anim.play("idle")
			pass
		states.repositioning:
			var vantageholder = get_tree().get_nodes_in_group("vantage_points")[0]
			if vantageholder:
				var new_nav_point = vantageholder.get_random_megawizard_vantage_position()
				$NavigationAgent.set_target_location(new_nav_point)
				nav = true
				anim.play("walk")
			pass
		states.cast_start:
			anim.play("cast_start")
		states.casting:
			$Castfx.show()
			$mines_cooldown.start(mines_cool_time)
			var probe = MINEPROBE.instance()
			get_tree().current_scene.add_child(probe)
			anim.play("casting")
		states.cast_end:
			anim.play("cast_over")
			anim.queue("idle")
		states.stunned:
			anim.play("hit")
			anim.queue("idle")
			pass
		states.dead:
			$CollisionShape.disabled = true
			$CollisionShape2.disabled = true
			$CollisionShape3.disabled = true
			anim.play("dead")
			game.emit_signal("enemy_killed")
			pass
	state = to_state
	if state_times.has(states.keys()[state]):
		$state_timer.start(state_times[states.keys()[state]])

func _on_state_timer_timeout():
	match state:
		states.cast_start:
			change_state(states.casting)
		states.casting:
			change_state(states.cast_end)
		states.cast_end:
			change_state(states.idle)
		states.stunned:
			change_state(states.idle)
		states.dead:
			queue_free()

func get_hit(dict):
	if state == states.dead:
#		print("dead")
		return
#	print(dict)
	var old_health = health
	health = max(health-dict["dmg"],0)
	if !health:
		change_state(states.dead)
		return
	if is_in_casting_state():
		return
	var percentage_old = get_percentage(old_health,max_health)
	var percentage_curr = get_percentage(health,max_health)
	if percentage_old > 66 and  percentage_curr < 66: #in percentage
		change_state(states.stunned)
		return
	if percentage_old > 33 and  percentage_curr < 33: #in percentage
		change_state(states.stunned)
		

func get_percentage(value,out_of):
	return (value/float(out_of))*100.0

func is_in_casting_state()->bool:
	var casting:=false
	if state == states.cast_start:
		casting = true
	if state == states.casting:
		casting = true
	if state == states.cast_end:
		casting = true
	return casting

func is_shooting_guns()->bool:
	if gun_cooling_state == gun_cooling_states.barrage_ongoing:
		return true
	return false

func is_gun_ready()->bool:
	if gun_cooling_state == gun_cooling_states.none:
		return true
	return false

func _on_NavigationAgent_target_reached():
	change_state(states.idle)

func start_gun_barrage():
	gun_barrage_shots = 0
	gun_cooling_state = gun_cooling_states.barrage_ongoing
	_on_gun_cooldown_timeout()

func _on_gun_cooldown_timeout():
	match gun_cooling_state:
		gun_cooling_states.none:
			pass
		gun_cooling_states.barrage_ongoing:
			if gun_barrage_shots<guns_shots_count:
				$gun_cooldown.start(guns_shots_interval)
				#fireshots
				gun_barrage_shots -=1
			else:
				gun_cooling_state = gun_cooling_states.barrage_over
				$gun_cooldown.start(guns_cool_time)
		gun_cooling_states.barrage_over:
			gun_cooling_state = gun_cooling_states.none
			pass

func fire_guns():
	var inst = BULLET.instance()
	get_tree().current_scene.add_child(inst)
	inst.look_at_from_position(muzzle_left.global_translation,-global_transform.basis.z,Vector3.UP)
	inst = BULLET.instance()
	get_tree().current_scene.add_child(inst)
	inst.look_at_from_position(muzzle_right.global_translation,-global_transform.basis.z,Vector3.UP)
	pass
