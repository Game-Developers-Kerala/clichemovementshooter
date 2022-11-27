#heavy gunner
extends BaseEnemy

enum states{
	
	CHASE,
	ATTACK,
	DEATH
	
}

const MISSILE = preload("res://test/test_enemy_homing_projectile.tscn")

func fire_missile():
	var missile = MISSILE.instance()
	get_tree().current_scene.add_child(missile)
	missile.target = player
	missile.look_dir = -global_transform.basis.z
	missile.global_translation = global_translation-global_transform.basis.z

func _ready() -> void:
	player = get_tree().current_scene.get_node('Player')
	set_state(states.CHASE)
	

func _process(delta: float) -> void:
	
	match get_state():
		
		
		states.CHASE:
			
			nav_agent.set_target_location(player.global_transform.origin)
			_aim_at_player()
			if $attackcooldown.is_stopped():
				$attackcooldown.start()
				fire_missile()
			
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
