extends Area

const FIRE_INTERVAL = 0.1
const MISSILE_COUNT = 12
var missiles_fired = 0
const RANDOM_LOOK = 0.2

var pack_position_lerp_targ := 0.0

var detect_queue = []
var locked_enemies = []

var odd := true
var checking_queue = false


const LOCK_INDICATOR = preload("res://scenes/vfx_lockon_indicator.tscn")
const MISSILE = preload("res://scenes/player_homing_missile.tscn")

var randgen  = RandomNumberGenerator.new()

func _ready():
	$PackMeshes/left.translation.z = 0.2
	$PackMeshes/right.translation.z = 0.2
	translation.y = -0.25
	rotation.x = deg2rad(10)
	randgen.randomize()
#	print("missile pack activated =========")
	translate(Vector3.ZERO)
	force_update_transform()
	$Timer.start(FIRE_INTERVAL)
	


func _process(delta):
	animate(delta)
	if !detect_queue:
		return
	var popped = detect_queue.pop_front()
	var already_locked = false
	for enemy in locked_enemies:
		if enemy[0]==popped:
			already_locked = true
	if already_locked:
#		print("already locked:",popped.name)
		return
#	print("raychecking:",popped.name)
	$RayCast.look_at(popped.global_translation+popped.CENTER_OF_MASS,Vector3.UP)
	$RayCast.force_raycast_update()
	if $RayCast.is_colliding():
		if $RayCast.get_collider() == popped:
			print("ray colliding:",popped.name)
			# adding the enemy to locked enemies and the number of times fired at as an array
			$fx.play()
			var indic = LOCK_INDICATOR.instance()
			popped.add_child(indic)
			indic.translation = Vector3.UP
			locked_enemies.push_back([popped,0]) # 0 means the enemy was shot at 0 times as of now
#			print("locked enemy:",popped.name)

func _on_player_lockon_missile_pack_body_entered(body):
	detect_queue.push_back(body)
	print("detected:",body.name)

func _on_Timer_timeout():
	var minfiredat = 12
	var targ :Node = null
	for enemy in locked_enemies:
		if is_instance_valid(enemy[0]):
			minfiredat = min(minfiredat,enemy[1])
	for enemy in locked_enemies:
		if is_instance_valid(enemy[0]):
			if enemy[1] == minfiredat:
				enemy[1]+=1
				targ = enemy[0]
#				print("fired at:",enemy[0].name," ",enemy[1]," times.")
				break
	var missile = MISSILE.instance()
	missile.target = targ
	#org_local is local origin, the offset to the sides, every odd missile is offset to the opposite side
	var org_local = global_transform.basis.x*(1-2*(missiles_fired%2))
	var randlook = -global_transform.basis.z + org_local*randgen.randf_range(0.0,RANDOM_LOOK)
	randlook += Vector3.UP*randgen.randf_range(-RANDOM_LOOK*0.5,RANDOM_LOOK)
	missile.look_dir = randlook
	get_tree().current_scene.add_child(missile)
	missile.global_translation = org_local*0.5 +global_translation
	if missiles_fired%2:
#		print("left")
#		missile.global_translation = $PackMeshes/left.global_translation
		$PackMeshes/left.translation.z = 0.04
		$left.play()
	else:
#		print("right")
#		missile.global_translation = $PackMeshes/right.global_translation
		$PackMeshes/right.translation.z =0.04
		$right.play()
	missiles_fired += 1
	if missiles_fired == MISSILE_COUNT:
#		print("all missiles fired")
		pack_position_lerp_targ = 0.2
		$Timer.stop()
		yield(get_tree().create_timer(0.2),"timeout")
		queue_free()


func animate(delta):
	$PackMeshes/left.translation.z = lerp($PackMeshes/left.translation.z,pack_position_lerp_targ,delta*10)
	$PackMeshes/right.translation.z = lerp($PackMeshes/right.translation.z,pack_position_lerp_targ,delta*10)
