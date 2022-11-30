#enemy controller script
#Arch shooter
extends BaseEnemy

enum states{

	CHASE,
	ATTACK,
	STUN,
	DEATH

}

onready var label = $BodyRotationHelper/Label3D as Label3D
onready var ARC = preload("res://scenes/enemy/arc_shooter/arc.tscn")
onready var cut_grapple = preload("res://scenes/enemy/arc_shooter/grapple_cut_projectile.tscn")

func _ready() -> void:
	
	player = get_tree().current_scene.get_node('Player')
	set_state(states.CHASE)


func _process(delta: float) -> void:
	
	print(get_state())
	
	nav_agent.set_target_location(player.global_transform.origin)
	
	if $AttackCooldown.is_stopped():
		set_state(states.ATTACK)
	else :
		set_state(states.CHASE)
		
	
	match get_state():
		
		states.CHASE:
			
			if weapon.get_collider() == player:
				if $AttackCooldown.is_stopped():
					set_state(states.ATTACK)
		
		states.ATTACK :
			
			if $ShootTimer.is_stopped():
				$ShootTimer.start()
			
			if weapon.get_collider() != player :
				set_state(states.CHASE)
				
		states.STUN:
			pass
			
		states.DEATH:
			
			pass
			
			
func _physics_process(delta: float) -> void:
	
	_aim_at_player()
	
	match get_state():
		
		
		states.CHASE:
			
			velocity = _calc_velocity(chase_speed) * delta
			move_and_slide(velocity,Vector3.UP)
			
						
		states.ATTACK:
			
			if $ShootTimer.is_stopped():
				$ShootTimer.start()
				
			if $ShootCooldown.is_stopped():
					
				if !player.grappling: 
					_shoot()
				else:
					_predicted_shoot()
				
		states.DEATH:
			pass


#signals
func _shoot():
	
		var inst = ARC.instance()
		get_tree().current_scene.add_child(inst)
		inst.look_at_from_position(global_translation,player.global_translation,Vector3.UP)
		$ShootCooldown.start()


func _predicted_shoot():
	
	var inst = cut_grapple.instance()
	get_tree().current_scene.add_child(inst)
	inst.look_at_from_position(global_translation,_predict_player_movement(),Vector3.UP)
	$ShootCooldown.start()


#return a value from already predicted player pos
func _predict_player_movement() -> Vector3:
	return player.predict_future_pos[8]


func _on_AttackCooldown_timeout() -> void:
	print("attack cooldown")
	set_state(states.ATTACK)


func _on_ShootTimer_timeout() -> void:
	print("shoot timer")
	$AttackCooldown.start()
