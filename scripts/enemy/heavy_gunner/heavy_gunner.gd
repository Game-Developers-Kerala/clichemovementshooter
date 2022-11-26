#heavy gunner
extends BaseEnemy

enum states{
	
	CHASE,
	ATTACK,
	DEATH
	
}


func _ready() -> void:
	player = get_tree().current_scene.get_node('Player')
	set_state(states.CHASE)
	

func _process(delta: float) -> void:
	
	match get_state():
		
		
		states.CHASE:
			
			nav_agent.set_target_location(player.global_transform.origin)
			_aim_at_player()
			
			
		states.ATTACK:
			
			nav_agent.set_target_location(player.global_transform.origin)
			_aim_at_player()
			
			
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

