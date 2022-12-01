#heavy gunner
extends BaseEnemy

enum states{
	
	CHASE,
	ATTACK,
	DEATH
	
}
const PROJECTILE = preload("res://scenes/enemy/heavy_gunner/heavy_gunner_projectile.tscn")

func _fire_shot(left:bool=true):
	var origin = $muzzle_left
	if !left:
		origin = $muzzle_right
	var projectile = PROJECTILE.instance()
	get_tree().current_scene.add_child(projectile)
	var to = player.global_translation + player.CENTER_OF_MASS # change this to predicted location
	projectile.look_at_from_position(origin.global_translation,to,Vector3.UP)

func _ready() -> void:
	player = get_tree().current_scene.get_node('Player')
	set_state(states.CHASE)
	

func _process(delta: float) -> void:
	
	match get_state():
		
		
		states.CHASE:
			
			nav_agent.set_target_location(player.global_transform.origin)
			_aim_at_player()
			
			if weapon.get_collider() == player:
				set_state(states.ATTACK)
			#=== testing projectile in chase state itself==
#			if $GunCoolTimer.is_stopped():
#				_start_barrage()
#			elif !$GunBarrageTimer.is_stopped(): # barrage is ongoing
#				if $GunshotIntervalTimer.is_stopped(): #time to shoot
#					$GunshotIntervalTimer.start()
#					_fire_shot(true) #left
#					_fire_shot(false) #right
			
		states.ATTACK:
			
			if weapon.get_collider() != player:
				set_state(states.ATTACK)
			
			nav_agent.set_target_location(player.global_transform.origin)
			_aim_at_player()
			
			if $GunCoolTimer.is_stopped():
				_start_barrage()
			elif !$GunBarrageTimer.is_stopped(): # barrage is ongoing
				if $GunshotIntervalTimer.is_stopped(): #time to shoot
					$GunshotIntervalTimer.start()
					_fire_shot(true) #left
					_fire_shot(false) #right
			
		states.DEATH:
			pass
		
		
		
func _physics_process(delta: float) -> void:
	
	match get_state():
		
		
		states.CHASE:
			
			velocity = _calc_velocity(chase_speed) * delta
			move_and_slide(velocity,Vector3.UP)
			
		states.ATTACK:
			pass
			
			
		states.DEATH:
			pass


func _start_barrage() -> void:
	$GunCoolTimer.start()
	$GunBarrageTimer.start()
	$GunshotIntervalTimer.start()
	pass
