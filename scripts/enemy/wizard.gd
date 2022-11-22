#enemy controller script
#Wizard
extends BaseEnemy

enum states{

	CHASE,
	ATTACK,
	DEATH

}

onready var label = $BodyRotationHelper/Label3D as Label3D


func _ready() -> void:
	
	player = get_tree().current_scene.get_node('Player')
	set_state(states.CHASE)



func _process(delta: float) -> void:
	
	match get_state():
		
		states.CHASE:
		
			label.text = "Chase"
			
		states.ATTACK:
			
			label.text = "Attack"
		
		states.DEATH:
			
			label.text = "Death"
	
	
func _physics_process(delta: float) -> void:
	
	match get_state():
		
		states.CHASE:
			
			#to make enemy look at player
			body.look_at(player.global_transform.origin, Vector3.UP)
			weapon.look_at(player.global_transform.origin, Vector3.UP)
			body.rotation.x = 0
			
			#here enemy will navigate to the player
			nav_agent.set_target_location(player.global_transform.origin)
			var target_pos = nav_agent.get_next_location()
			var dir : Vector3 = (target_pos - global_transform.origin).normalized()
			velocity = dir * chase_speed * delta
			move_and_slide(velocity,Vector3.UP)
			
		states.ATTACK:
			
			#to make enemy aim at the player 
			body.look_at(player.global_transform.origin, Vector3.UP)
			weapon.look_at(player.global_transform.origin, Vector3.UP)
			body.rotation.x = 0
			
			if weapon.get_collider() == player:
				pass

		states.DEATH:
			pass


#signals

#emits when player is in-range
func _on_ShootRange_body_entered(_body: Node) -> void:
	
	if _body.is_in_group('player'):
		
		print("player in range")
		set_state(states.ATTACK)


#emits when player is out of range
func _on_ShootRange_body_exited(_body: Node) -> void:
	
	if _body.is_in_group('player'):
		
		print("player out of range")
		set_state(states.CHASE)
