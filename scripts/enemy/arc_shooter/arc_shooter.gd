#enemy controller script
#Arch shooter
extends BaseEnemy

enum states{

	CHASE,
	ATTACK,
	DEATH

}

onready var label = $BodyRotationHelper/Label3D as Label3D
onready var ARC = preload("res://scenes/enemy/arc_shooter/arc.tscn")
onready var cut_grapple = preload("res://scenes/enemy/arc_shooter/grapple_cut_projectile.tscn")

func _ready() -> void:
	player = get_tree().current_scene.get_node('Player')
	set_state(states.CHASE)


func _process(delta: float) -> void:
	
	match get_state():
		
		states.CHASE:
			nav_agent.set_target_location(player.global_transform.origin)
			
			label.text = "Chase"
			print("chase")
			_aim_at_player()
			
			if weapon.get_collider() == player:
				
				if $AttackCooldown.is_stopped():
					set_state(states.ATTACK)
					
			
		states.ATTACK:
			
			nav_agent.set_target_location(player.global_transform.origin)
			
			label.text = "Attack"
			_aim_at_player()
			
			if !weapon.get_collider() == player:
				set_state(states.CHASE)
			
		states.DEATH:
			
			label.text = "Death"
	
	
func _physics_process(delta: float) -> void:
	
	match get_state():
		
		
		states.CHASE:
			
			#here enemy will navigate to the player
			velocity = _calc_velocity(chase_speed) * delta
			move_and_slide(velocity,Vector3.UP)
			
			
		states.ATTACK:
			
			
			if $AttackCooldown.is_stopped():
				
				if $ShootTimer.is_stopped():
				
					if !player.grappling: 
						_shoot()
					else:
						_predicted_shoot()
				else :
					
					$AttackCooldown.start()


		states.DEATH:
			pass



#signals
func _shoot():
	
		var inst = ARC.instance()
		get_tree().current_scene.add_child(inst)
		inst.look_at_from_position(global_translation,player.global_translation,Vector3.UP)
		$ShootTimer.start()


func _predicted_shoot():
	
	var inst = cut_grapple.instance()
	get_tree().current_scene.add_child(inst)
	inst.look_at_from_position(global_translation,_predict_player_movement(),Vector3.UP)
	$ShootTimer.start()

#return a value from already predicted player pos
func _predict_player_movement() -> Vector3:
	return player.predict_future_pos[8]



func _on_ShootTimer_timeout() -> void:
	
	pass
	#$AttackCooldown.start()
	#set_state(states.CHASE)


func _on_AttackCooldown_timeout() -> void:
	
	set_state(states.ATTACK)
