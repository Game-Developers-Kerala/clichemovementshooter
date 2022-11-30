#enemy controller script
#sniper shooter
extends BaseEnemy

enum states{

	CHASE,
	ATTACK,
	DEATH

}

var lazer = preload("res://scenes/enemy/sniper/sniper_railshot.tscn")

func _ready() -> void:
	
	player = get_tree().current_scene.get_node('Player')
	set_state(states.CHASE)


func _process(delta: float) -> void:
	
	nav_agent.set_target_location(player.global_transform.origin)
	
	match get_state():
		
		states.CHASE:
			
			if weapon.get_collider() == player:
				weapon.look_at(weapon.get_collision_point(),Vector3.UP)
				set_state(states.ATTACK)
		
		states.ATTACK :
			pass
				
		states.DEATH:
			
			pass
			
			
func _physics_process(delta: float) -> void:
	
	
	match get_state():
		
		states.CHASE:
			
			_aim_at_player()
			velocity = _calc_velocity(chase_speed) * delta
			move_and_slide(velocity,Vector3.UP)
			
		states.ATTACK:
			
			if $ShootTimer.is_stopped():
				
				if weapon.get_collider() == player:
					var inst = lazer.instance()
					add_child(inst)
					inst.init(global_translation,weapon.get_collision_point())
					$ShootTimer.start()
			
		states.DEATH:
			pass


func _on_ShootTimer_timeout() -> void:
	
	if weapon.get_collider() == player:
		print("shoot")
	else :
		set_state(states.CHASE)
