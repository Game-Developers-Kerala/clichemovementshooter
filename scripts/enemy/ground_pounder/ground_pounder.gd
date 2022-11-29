#ground pounder enemy
extends BaseEnemy

enum states{
	CHASE,
	ATTACK,
	DEATH
}

onready var model = $BodyRotationHelper/model_enemy_golem
var meele_speed = 200
var shockwave = preload("res://scenes/enemy/ground_pounder/circular_wave.tscn")
#var straight_wave = preload("res://scenes/enemy/ground_pounder/straight_wave.tscn")

onready var label : Label3D = $BodyRotationHelper/Label3D
onready var attack_area : Area = $AttackArea


func _ready() -> void:
	player = get_tree().current_scene.get_node('Player')
	set_state(states.CHASE)
	
func _process(delta: float) -> void:
	
	nav_agent.set_target_location(player.global_transform.origin)
	
	match get_state():
		
		states.CHASE:
			
			if weapon.get_collider() == player:
				set_state(states.ATTACK)
		
		states.ATTACK :
			
			if weapon.get_collider() != player :
				set_state(states.CHASE)
				
		states.DEATH:
			pass
			
			
func _physics_process(delta: float) -> void:
	
#STATE MANAGMENT

	match get_state():
		
		states.CHASE:
			
			velocity = _calc_velocity(chase_speed) * delta
			move_and_slide(velocity,Vector3.UP)
		
		states.ATTACK:
			
			pass
			#straight wave
			
			
		states.DEATH:
			pass



	
#SIGNALS
func _on_AttackArea_body_entered(body: Node) -> void:
	
	if body.is_in_group("player"):
		set_state(states.ATTACK)

func _on_AttackArea_body_exited(body: Node) -> void:
	
	if body.is_in_group("player"):
		set_state(states.CHASE)

