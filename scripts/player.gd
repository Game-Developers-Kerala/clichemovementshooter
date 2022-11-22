extends KinematicBody


enum movestates {none,ground,wall,air,grapple}
var movestate = movestates.ground

const CENTER_OF_MASS = Vector3.UP

var mouse_sens = 0.1
const GRAPPLESPEED = 30
const GRAPPLEAIRCONTROL = 10
const AIRCONTROL = 15
var air_accel = 0.0
const AIRACCEL = 10
const AIRACCEL_LERPRATE = 100
const GRAPPLEACCEL = 20
const GROUNDACCEL = 10
const GRAVITY = 20
const SLIDESPEED = 20
const FRICTION_DAMPING = 0.9

var velocity : Vector3 = Vector3.ZERO
var snap := Vector3.ZERO

var grapplevec = Vector3.ZERO
var grapplelength = 0.0
var grappled_enemy :Node = null
var grappling_enemy :bool = false
onready var grapple_targ = $floaters/GrappleTargArea


onready var cam = $Camera

var auto_slide = false

var grappling = false
var braking = false
var jumping = false
var on_wall = false
var wallsidecheck = false
onready var in_slide = auto_slide
var in_jump = false
var last_velocity = Vector3.ZERO
var air_auto_dir = false

var stats = {
	"health":100,
	"weapon_rail":null,
	"weapon_missilepack":false,
	"powerup_spikecage":false,
	}
const STAT_RANGES = {
		"health":{"min":0,"max":100}
		}

export(bool) var gun_ready = true
export(bool) var rocket_ready = true
const ROCKET_COOLDOWN_DUR = 0.7
const ROCKET = preload("res://scenes/player_rocket.tscn")
const RAILSHOT = preload("res://scenes/player_railshot.tscn")
const MISSILE_PACK = preload("res://scenes/player_lockon_missile_pack.tscn")


var predict_past_pos :PoolVector3Array = []
var predict_past_vel :PoolVector3Array = []
var predict_future_pos :PoolVector3Array = []
onready var predict_blink_timer = $PredictionBlink
var prediction_suspend_time := 0.5

func _ready():
	predict_past_pos.resize(4)
	predict_past_pos.fill(global_translation+CENTER_OF_MASS)
	predict_past_vel.resize(4)
	predict_past_vel.fill(Vector3.ZERO)
	predict_future_pos.resize(12)
	predict_future_pos.fill(global_translation+CENTER_OF_MASS)
	
	$floaters/GrappleRay/GrappleMesh.hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x*mouse_sens))
		cam.rotate_x(deg2rad(-event.relative.y*mouse_sens))
		cam.rotation.x = clamp(cam.rotation.x,deg2rad(-88),deg2rad(88))

func _unhandled_key_input(event):
	#if auto slide is off pressing slide will enable slide
	#if auto slide is on pressing slide will disable slide
	if event.is_action_pressed("slide"):
		in_slide = !auto_slide
	if event.is_action_released("slide"):
		in_slide = auto_slide


#====================================

func _physics_process(delta):
	var in_dir = Input.get_vector("left","right","forward","back")
	var dir = Vector3.ZERO
	var floornorm = get_floor_normal()
	var speed = GRAPPLESPEED
#	var grapplevec = Vector3.ZERO
#	var grapplelength = 0.0
	
	set_move_state()

	match movestate:
		movestates.none:
			velocity = lerp(velocity,Vector3.ZERO,GROUNDACCEL*delta)
			velocity.y = 0.0
			last_velocity = Vector3.ZERO
			if !jumping:
				snap = -floornorm
			else:
				snap = Vector3.ZERO
		movestates.grapple:
			if grappling_enemy:
				if is_instance_valid(grappled_enemy):
					grapple_targ.global_translation = grappled_enemy.global_translation +grappled_enemy.CENTER_OF_MASS
				else:
					grapple_stop()
			var grappletargPos = grapple_targ.global_translation
			var grappleorigin = global_translation+Vector3.UP*1.42
			$floaters/GrappleRay.look_at_from_position(grappleorigin,grappletargPos,Vector3.UP)
			$floaters/GrappleRay.force_update_transform()
			$floaters/GrappleRay.force_raycast_update()
			grapplevec = $floaters/GrappleTargArea.global_translation-$floaters/GrappleRay.global_translation
			grapplelength = grapplevec.length()
			grapplevec = grapplevec.normalized()
			var aircontrol = Vector3.ZERO
			aircontrol.y = -in_dir.y
			aircontrol += $Camera.global_transform.basis.x*in_dir.x
			$floaters/GrappleRay/GrappleMesh.scale.z = grapplelength
			if grapplelength < 1.8:
				grapple_stop()
			if $floaters/GrappleRay.is_colliding():
				var targ = $floaters/GrappleRay.get_collider()
				if !targ.get_collision_layer_bit(4):
					grapple_stop()
			velocity = lerp(velocity,grapplevec*GRAPPLESPEED+aircontrol*GRAPPLEAIRCONTROL,GRAPPLEACCEL*delta)
			snap = Vector3.ZERO
		movestates.air:
			if in_dir.length():
				dir = Vector3(in_dir.x,0,in_dir.y).normalized().rotated(Vector3.UP,global_rotation.y)
				air_auto_dir = false
			else:
				if air_auto_dir:
					dir = (velocity*Vector3(1,0,1)).normalized()
			velocity.x = lerp(velocity.x,dir.x*AIRCONTROL,AIRACCEL*delta)
			velocity.z = lerp(velocity.z,dir.z*AIRCONTROL,AIRACCEL*delta)
			velocity.y -= GRAVITY*delta
			snap = Vector3.ZERO
		movestates.wall:
			dir = last_velocity.normalized()
			velocity.y = 0.0
			velocity.x = lerp(velocity.x,dir.x*SLIDESPEED,GROUNDACCEL*delta)
			velocity.z = lerp(velocity.z,dir.z*SLIDESPEED,GROUNDACCEL*delta)
		movestates.ground:
			dir = last_velocity.normalized()
			velocity.x = lerp(velocity.x,dir.x*SLIDESPEED,GROUNDACCEL*delta)
			velocity.z = lerp(velocity.z,dir.z*SLIDESPEED,GROUNDACCEL*delta)
			velocity.y = 0.0
			if !jumping:
				snap = -floornorm
			else:
				snap = Vector3.ZERO
	if Input.is_action_pressed("jump") and on_wall: #and  $JumpCoolDown.is_stopped():
		$JumpCoolDown.start()
		walljump()
	
	velocity = move_and_slide_with_snap(velocity,snap,Vector3.UP,true)
	var lookdir = (velocity.rotated(Vector3.UP,PI*0.5)*Vector3(1,0,1)).normalized()
	if lookdir:
		$wallsidecheckarea.look_at($wallsidecheckarea.global_translation+lookdir,Vector3.UP)
	last_velocity = velocity
	jumping = false

	if Input.is_action_pressed("shoot"):
		shoot()
	if Input.is_action_pressed("grapple"):
		grapple()
	if Input.is_action_pressed("use"):
		shoot_rail()
	if Input.is_action_pressed("homingmissile"):
		shoot_missile_pack()
	if Input.is_action_just_pressed("ui_page_down"):
		pass
	if Input.is_action_just_pressed("ui_page_up"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		pass
	$Label.text = movestates.keys()[movestate]
	$Label.text = "\nWallray colliding:"+str(wallsidecheck)
	$HUD/Mrgn/FPSCounter.text = "FPS\n" + str(Engine.get_frames_per_second())

func set_move_state():
	if grappling:
		change_movestate(movestates.grapple)
		return
	if is_on_floor():
		match movestate:
			movestates.none:
				if jumping:
					change_movestate(movestates.air)
					return
				if velocity.length()>1 and in_slide:
					change_movestate(movestates.ground)
				return
			movestates.ground:
				if jumping:
					change_movestate(movestates.air)
					return
				if !in_slide:
					change_movestate(movestates.none)
					return
			_:
				if in_slide:
					change_movestate(movestates.ground)
					return
				change_movestate(movestates.none)
		return
	if on_wall:
		if in_slide:
			change_movestate(movestates.wall)
		else:
			change_movestate(movestates.air)
		return
	change_movestate(movestates.air)

func change_movestate(to_state,args:={}):
	if movestate == to_state:
		return
	match to_state:
		movestates.air:
			if $PredictionSuspend.is_stopped():
				$PredictionSuspend.start(prediction_suspend_time)
			if movestate == movestates.ground and !jumping:
				air_auto_dir = true
			if args.has("auto_dir"):
				air_auto_dir = true
			air_accel = 4.0
		_:
			air_auto_dir = false
			$PredictionSuspend.stop()
	movestate = to_state

func shoot():
	if !gun_ready:
		return
	if !rocket_ready:
		return
	gun_ready = false
	stop_animation()
	$AnimationPlayer.play("shoot_rocket",0.0)
	$AnimationPlayer.queue("idle")
	var rkt = ROCKET.instance()
	get_tree().current_scene.add_child(rkt)
	var campos = $Camera.global_translation
	var camfront = -$Camera.global_transform.basis.z
	rkt.look_at_from_position(campos+camfront*0.25,campos+camfront*2,Vector3.UP)

func shoot_rail():
	if !is_instance_valid(stats.weapon_rail):
		return
	if !gun_ready:
		return
	gun_ready = false
	print(OS.get_ticks_msec()," shot rail")
	stats.weapon_rail.shoot()
	stop_animation()
	$AnimationPlayer.play("shoot_rail",0.0)
	$AnimationPlayer.queue("rail_detach")
	$AnimationPlayer.queue("idle")
	$HUD/Mrgn/Powerups/Rail/Label.hide()

func shoot_missile_pack():
	if !stats.weapon_missilepack:
		return
	if !$RocketCooldown.is_stopped():
		return
	$RocketCooldown.start(ROCKET_COOLDOWN_DUR)
	var mispak = MISSILE_PACK.instance()
	$Camera.add_child(mispak)
	mispak.global_transform = $Camera.global_transform
	stats.weapon_missilepack = false
	$HUD/Mrgn/Powerups/Missile/Label.hide()

func pick_up(item:pickup):
	var dict :Dictionary= item.get_pickup_info()
	for key in dict.keys():
		match key:
			"health":
				if stats.health >= STAT_RANGES.health.max:
					return
				adjust_health(dict[key])
			"weapon_rail":
				if is_instance_valid(stats[key]):
					return
				$AnimationPlayer.play("rail_attach")
				$AnimationPlayer.queue("idle")
				stats[key] = RAILSHOT.instance()
				$Camera.add_child(stats[key])
				$HUD/Mrgn/Powerups/Rail/Label.show()
			"weapon_missilepack":
				if stats[key]:
					return
				stats[key] = dict[key]
				$HUD/Mrgn/Powerups/Missile/Label.show()
			"powerup_spikecage":
				pass
	item.on_pickup()

func get_hit(args:={}):
	print("Plyr got hit at:",OS.get_ticks_msec(),"=====\n",args)
	if args.has("dmg"):
		adjust_health(-args.dmg)
	if args.has("force"):
		if args.has("push_dir"):
			if args.has("dir_replace"):
				velocity = Vector3.ZERO
			var push_multiplier := 1.0
			if args.has("caused_by_player"):
				push_multiplier = 2.0
			velocity += args.push_dir*args.force*push_multiplier
			jumping = true
			snap = Vector3.ZERO
	if args.has("origin"):
		$HUD/Mrgn/attack_indicators.new_attack(global_transform,$Camera.global_transform,args.origin)

func adjust_health(in_val):
	stats.health = ceil(stats.health+in_val)
	stats.health = clamp(stats.health,STAT_RANGES.health.min,STAT_RANGES.health.max)
	$HUD/Mrgn/Health.text = "Health " + str(int(stats.health)) 
	if !stats.health:
		set_process(false)
		set_physics_process(false)
		set_process_input(false)
		game._on_player_death()

func get_pushed(push_dict:={}):
	print("got pushed")
	jumping = true
	snap = Vector3.ZERO
	var push_dir:Vector3 = (global_translation+Vector3.UP)-push_dict.origin
	var push_force = push_dict.force/(push_dir.length()+0.01)
	velocity += push_dir.normalized()*push_force

func walljump():
	jumping = true
	snap = Vector3.ZERO
	var perp_vec :Vector3 = -$wallsidecheckarea.global_transform.basis.z*Vector3(1,0,1)
	if wallsidecheck:
		perp_vec = $wallsidecheckarea.global_transform.basis.z*Vector3(1,0,1)
	if movestate == movestates.wall:
		print("perpvec:",perp_vec, " movestate:",movestates.keys()[movestate])
		velocity.y = 0.0
		velocity += Vector3.UP*6+perp_vec*10
#	else:
##		perp_vec = perp_vec.rotated(Vector3.UP,PI*(2-1*int(!wallsidecheck)))
#		print("perpvec:",perp_vec)
#		velocity += Vector3.UP*6+perp_vec*2
	change_movestate(movestates.air,{auto_dir=true})

func grapple():
	if grappling:
		if $GrappleCancel.is_stopped():
			grapple_stop()
		return
	if !$GrappleCancel.is_stopped():
		return
	if $Camera/AimRay.is_colliding():
		var collider = $Camera/AimRay.get_collider()
		if collider.get_collision_layer_bit(cmn.colliders.enemy_hurtbox):
			grappling_enemy = true
			grappled_enemy = collider.hit_receiver
			grapple_targ.global_translation = grappled_enemy.global_translation +grappled_enemy.CENTER_OF_MASS
		else:
			grapple_targ.global_translation = $Camera/AimRay.get_collision_point()
		grappling = true
		$floaters/GrappleRay/GrappleMesh.show()
		$GrappleCancel.start()

func grapple_stop():
	grappling_enemy = false
	grappled_enemy = null
	grappling = false
	$floaters/GrappleRay/GrappleMesh.hide()
	$GrappleCancel.start()


func _on_GeneralArea_body_entered(body):
	on_wall = true


func _on_GeneralArea_body_exited(body):
	if !$GeneralArea.get_overlapping_bodies():
		on_wall = false


func _on_wallsidecheckarea_body_entered(body):
	wallsidecheck = true


func _on_wallsidecheckarea_body_exited(body):
	if !$wallsidecheckarea.get_overlapping_bodies():
		wallsidecheck = false


func _on_GeneralArea_area_entered(area):
	if area.get_collision_layer_bit(cmn.colliders.pickup):
		pick_up(area)


func _on_PredictionBlink_timeout():
	var curPos = global_translation+CENTER_OF_MASS
	var interval = $PredictionBlink.wait_time
	predict_past_pos.remove(0)
	predict_past_pos.append(curPos)
	predict_past_vel.remove(0)
	predict_past_vel.append(velocity)
	if $PredictionSuspend.time_left:
#		predict_future_pos.remove(0)
#		var size = predict_future_pos.size()
##		print("suspended prediction: array size", size)
#		predict_future_pos.append(predict_future_pos[size-1])

		var avg_vel = Vector3.ZERO
		for vec in predict_past_vel:
			avg_vel += vec
		avg_vel = avg_vel / predict_past_vel.size()
		for i in predict_future_pos.size():
			predict_future_pos[i] = curPos + avg_vel*(i+1)*interval
#			$PredictionDebugIcons.get_child(i).global_translation = predict_future_pos[i]
		return
	
	match movestate:
		movestates.none:
			for i in predict_future_pos.size():
				predict_future_pos[i] = curPos
#				$PredictionDebugIcons.get_child(i).global_translation = predict_future_pos[i]
		movestates.ground:
			for i in predict_future_pos.size():
				predict_future_pos[i] = curPos + velocity*(i+1)*interval
#				$PredictionDebugIcons.get_child(i).global_translation = predict_future_pos[i]
		movestates.grapple:
			predict_future_pos.fill(grapple_targ.global_translation)
			var eta = grapplelength/float(GRAPPLESPEED)
			for i in predict_future_pos.size():
				if !(i+1)*interval > eta:
					predict_future_pos[i] = curPos + velocity*(i+1)*interval
#				$PredictionDebugIcons.get_child(i).global_translation = predict_future_pos[i]
		movestates.wall:
			for i in predict_future_pos.size():
				predict_future_pos[i] = curPos + velocity*(i+1)*interval
#				$PredictionDebugIcons.get_child(i).global_translation = predict_future_pos[i]
		movestates.air:
			var temp_vel = velocity
			for i in predict_future_pos.size():
				temp_vel -= Vector3.UP*GRAVITY*0.25
				predict_future_pos[i] = curPos + temp_vel*(i+1)*interval
#				$PredictionDebugIcons.get_child(i).global_translation = predict_future_pos[i]

func stop_animation():
	if $AnimationPlayer.current_animation == "rail_detach":
		$Camera/weapon_holder/railshot_model.hide()
	$AnimationPlayer.stop()
