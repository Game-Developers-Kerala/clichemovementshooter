extends KinematicBody

enum movestates {none,ground,wall,air,grapple}
var movestate = movestates.ground

var mouse_sens = 0.1
const GRAPPLESPEED = 40
const GRAPPLEAIRCONTROL = 10
const AIRCONTROL = 15
const GRAPPLEACCEL = 20
const GROUNDACCEL = 10
const AIRACCEL = 10
const GRAVITY = 20
const SLIDESPEED = 10
const FRICTION_DAMPING = 0.9

var velocity : Vector3 = Vector3.ZERO
var snap := Vector3.ZERO

onready var cam = $Camera

var grappling = false
var braking = false
var jumping = false
var on_wall = false
var in_slide_raw = false
var in_slide = false
var last_velocity = Vector3.ZERO

var health := 100

const ROCKET_COOLDOWN_DUR = 0.7
const ROCKET = preload("res://scenes/player_rocket.tscn")
const RAILSHOT = preload("res://scenes/player_railshot.tscn")

func _ready():
	$GrappleRay/GrappleMesh.hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x*mouse_sens))
		cam.rotate_x(deg2rad(-event.relative.y*mouse_sens))
		cam.rotation.x = clamp(cam.rotation.x,deg2rad(-88),deg2rad(88))

func _unhandled_key_input(event):
	if event.is_action_pressed("slide"):
		in_slide_raw = true
		in_slide = true
	if event.is_action_released("slide"):
		in_slide = false
		in_slide_raw = false

#====================================

func _physics_process(delta):
	var in_dir = Input.get_vector("left","right","forward","back")
	var dir = Vector3.ZERO
	var floornorm = get_floor_normal()
	var speed = GRAPPLESPEED
	var grapplevec = Vector3.ZERO
	var grapplelength = 0.0
	
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
			$GrappleRay.look_at($floaters/Grappletarg.global_translation,Vector3.UP)
			grapplevec = $floaters/Grappletarg.global_translation-$GrappleRay.global_translation
			grapplelength = grapplevec.length()
			grapplevec = grapplevec.normalized()
			var aircontrol = Vector3.ZERO
			aircontrol.y = -in_dir.y
			aircontrol += $Camera.global_transform.basis.x*in_dir.x
			$GrappleRay/GrappleMesh.scale = Vector3(1,1,grapplelength)
			if grapplelength < 1.8:
				grapple_stop()
			velocity = lerp(velocity,grapplevec*speed+aircontrol*GRAPPLEAIRCONTROL,GRAPPLEACCEL*delta)
			snap = Vector3.ZERO
		movestates.air:
			dir = Vector3(in_dir.x,0,in_dir.y).normalized().rotated(Vector3.UP,global_rotation.y)
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

	velocity = move_and_slide_with_snap(velocity,snap,Vector3.UP,true)
	last_velocity = velocity
	jumping = false

	if Input.is_action_pressed("shoot"):
		shoot()
	if Input.is_action_pressed("grapple"):
		grapple()
	if Input.is_action_pressed("use"):
		shoot_rail()
	if Input.is_action_just_pressed("ui_page_down"):
		print("Wall area overlapping bodies:",$WallArea.get_overlapping_bodies())
	$Label.text = movestates.keys()[movestate]
	$Label.text +="\nInput Slide:"+str(in_slide)

func set_move_state():
	if grappling:
		movestate = movestates.grapple
		return
	if is_on_floor():
		match movestate:
			movestates.none:
				if jumping:
					movestate = movestates.air
					return
				if velocity.length()>0.001 and in_slide:
					movestate = movestates.ground
				return
			movestates.ground:
				if jumping:
					movestate = movestates.air
					return
				if !in_slide:
					movestate = movestates.none
					return
			_:
				if in_slide:
					movestate = movestates.ground
					return
				movestate = movestates.none
		return
	if on_wall:
		if in_slide:
			movestate = movestates.wall
		else:
			movestate = movestates.air
		return
	movestate = movestates.air

func shoot():
	if !$RocketCooldown.is_stopped():
		return
	$RocketCooldown.start(ROCKET_COOLDOWN_DUR)
	var rkt = ROCKET.instance()
	get_tree().current_scene.add_child(rkt)
	var campos = $Camera.global_translation
	var camfront = -$Camera.global_transform.basis.z
	rkt.look_at_from_position(campos+camfront*0.25,campos+camfront*2,Vector3.UP)

func get_hit(arg):
	pass

func grapple():
	if grappling:
		if $GrappleCancel.is_stopped():
			grapple_stop()
		return
	if !$GrappleCancel.is_stopped():
		return
	if $Camera/AimRay.is_colliding():
		var point = $Camera/AimRay.get_collision_point()
		$floaters/Grappletarg.global_translation = point
		grappling = true
		$GrappleRay/GrappleMesh.show()
		$GrappleCancel.start()

func grapple_stop():
	grappling = false
	$GrappleRay/GrappleMesh.hide()
	$GrappleCancel.start()

func get_pushed(push_dict:={}):
	print("got pushed")
	jumping = true
	snap = Vector3.ZERO
	var push_dir:Vector3 = (global_translation+Vector3.UP)-push_dict.origin
	var push_force = push_dict.force/(push_dir.length()+0.01)
	velocity += push_dir.normalized()*push_force

func shoot_rail():
	if !$RocketCooldown.is_stopped():
		return
	print(OS.get_ticks_msec()," shot rail")
	$RocketCooldown.start(ROCKET_COOLDOWN_DUR)
	$Camera/RailShot.shoot()


func _on_WallArea_body_entered(body):
	on_wall = true


func _on_WallArea_body_exited(body):
	if !$WallArea.get_overlapping_bodies():
		on_wall = false
