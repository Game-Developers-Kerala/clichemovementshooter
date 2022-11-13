extends Area

const FIRE_INTERVAL = 0.15
const MISSILE_COUNT = 12
var missiles_fired = 0

var detect_queue = []
var locked_enemies = []

var odd := true
var checking_queue = false

const LOCK_INDICATOR = preload("res://scenes/vfx_lockon_indicator.tscn")

var geh :Node

func _ready():
	print("missile pack activated =========")
	translate(Vector3.ZERO)
	force_update_transform()
	$Timer.start(FIRE_INTERVAL)
	


func _process(delta):
	if !detect_queue:
		return
	var popped = detect_queue.pop_front()
	var already_locked = false
	for enemy in locked_enemies:
		if enemy[0]==popped:
			already_locked = true
	if already_locked:
		print("already locked:",popped.name)
		return
	print("raychecking:",popped.name)
	$RayCast.look_at(popped.global_translation+Vector3.UP,Vector3.UP)
	$RayCast.force_raycast_update()
	if $RayCast.is_colliding():
		if $RayCast.get_collider() == popped:
			print("ray colliding:",popped.name)
			# adding the enemy to locked enemies and the number of times fired at as an array
			var indic = LOCK_INDICATOR.instance()
			popped.add_child(indic)
			indic.translation = Vector3.UP
			locked_enemies.push_back([popped,0,indic])
			print("locked enemy:",popped.name)

func _on_player_lockon_missile_pack_body_entered(body):
	detect_queue.push_back(body)
	print("detected:",body.name)

func _on_Timer_timeout():
	var minfiredat = 12
	for enemy in locked_enemies:
		if is_instance_valid(enemy[0]):
			minfiredat = min(minfiredat,enemy[1])
	for enemy in locked_enemies:
		if is_instance_valid(enemy[0]):
			if enemy[1] == minfiredat:
				enemy[1]+=1
				print("fired at:",enemy[0].name," ",enemy[1]," times.")
				break
	missiles_fired += 1
	if missiles_fired == MISSILE_COUNT:
		print("all missiles fired")
		for enemy in locked_enemies:
			if enemy[0]:
				enemy[2].queue_free()
		queue_free()
