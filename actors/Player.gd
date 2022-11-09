extends KinematicBody


var mouse_sens = 0.1
const GRAPPLESPEED = 40
const GRAPPLEAIRCONTROL = 10
const AIRCONTROL = 15
const ACCEL = 10
const GRAVITY = 20
const FRICTION_DAMPING = 0.9

var velocity : Vector3 = Vector3.ZERO
var snap := Vector3.ZERO

onready var cam = $Camera

var grappling = false
var groundslide = false
var last_velocity = Vector3.ZERO

var health := 100

func _ready():
	$GrappleRay/GrappleMesh.hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x*mouse_sens))
		cam.rotate_x(deg2rad(-event.relative.y*mouse_sens))
		cam.rotation.x = clamp(cam.rotation.x,deg2rad(-88),deg2rad(88))

#====================================

func _physics_process(delta):
	var in_dir = Input.get_vector("left","right","forward","back")
	var dir = Vector3(in_dir.x,0,in_dir.y).normalized().rotated(Vector3.UP,global_rotation.y)
	var floornorm = get_floor_normal()
	var speed = GRAPPLESPEED
	var grapplevec = Vector3.ZERO
	var grapplelength = 0.0
	
	if grappling:
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
		velocity = lerp(velocity,grapplevec*speed+aircontrol*GRAPPLEAIRCONTROL,ACCEL*delta)
		snap = Vector3.ZERO

	else:
		
		if !is_on_floor():
			velocity.x = lerp(velocity.x,dir.x*AIRCONTROL,ACCEL*delta)
			velocity.z = lerp(velocity.z,dir.z*AIRCONTROL,ACCEL*delta)
			velocity.y -= GRAVITY*delta
			snap = Vector3.ZERO
		else:
			if groundslide:
				velocity.x = last_velocity.x
				velocity.z = last_velocity.z
			else:
				var velocity_damped = Vector2(velocity.x,velocity.y).length()*FRICTION_DAMPING
				velocity.x = lerp(velocity.x,dir.x*velocity_damped,ACCEL*delta)
				velocity.z = lerp(velocity.z,dir.z*velocity_damped,ACCEL*delta)
			snap = -floornorm
			velocity.y = 0.0
	
	velocity = move_and_slide_with_snap(velocity,snap,Vector3.UP,true)
	
	if Input.is_action_pressed("crouch") and !groundslide and is_on_floor():
		last_velocity = velocity
		groundslide = true
	if Input.is_action_just_released("crouch"):
		groundslide = false
	if Input.is_action_pressed("shoot"):
		shoot()
	if Input.is_action_pressed("grapple"):
		grapple()
		
func shoot():
	pass

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
