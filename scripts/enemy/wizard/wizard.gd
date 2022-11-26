#enemy controller script
#Wizard
extends BaseEnemy

enum states{

	CHASE,
	ATTACK,
	DEATH

}

onready var label = $BodyRotationHelper/Label3D as Label3D
onready var missle_target = preload("res://scenes/enemy/wizard/homing_missle_target.tscn")

func _ready() -> void:
	
	player = get_tree().current_scene.get_node('Player')
	set_state(states.CHASE)

func _process(delta: float) -> void:
	
	match get_state():
		
		states.CHASE:

			#here enemy will navigate to the player
			nav_agent.set_target_location(player.global_transform.origin)
			_aim_at_player()
			label.text = "Chase"
			
			if weapon.get_collider() == player:
				set_state(states.ATTACK)
			
		states.ATTACK:
			
			#here enemy will navigate to the player
			nav_agent.set_target_location(player.global_transform.origin)
			_aim_at_player()
			
			label.text = "Attack"
		
		states.DEATH:
			
			label.text = "Death"
	
	
func _physics_process(delta: float) -> void:
	
	match get_state():
		
		states.CHASE:

			velocity = _calc_velocity(chase_speed)
			move_and_slide(velocity,Vector3.UP)
			
		states.ATTACK:
			
				if weapon.get_collider() == player:
				
					if $HomingMissleTimer.is_stopped():
						_homing_missle()
				else:
				
					_calc_velocity(attack_speed)

		states.DEATH:
			pass

	
func _homing_missle() -> void:
	
	$HomingMissleTimer.start()
	var inst = missle_target.instance()
	inst.global_transform.origin = player.global_translation
	get_tree().current_scene.add_child(inst)
