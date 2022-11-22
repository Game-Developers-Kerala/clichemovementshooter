#ground pounder enemy
extends BaseEnemy

enum states{
	CHASE,
	ATTACK,
	DEATH
}

var meele_speed = 200
var shockwave = preload("res://scenes/enemy/ground_pounder/circular_wave.tscn")
#var straight_wave = preload("res://scenes/enemy/ground_pounder/straight_wave.tscn")

onready var label : Label3D = $BodyRotationHelper/Label3D
onready var attack_area : Area = $AttackArea


func _ready() -> void:
	player = get_tree().current_scene.get_node('Player')
	set_state(states.CHASE)
	
func _process(delta: float) -> void:
	
	match get_state():
		
		states.CHASE:
			label.text = "Chase"
		states.ATTACK:
			label.text = "Attack"
		states.MEELE:
			label.text = "Meele"
		states.DEATH:
			label.text = "Death"
	
	
func _physics_process(delta: float) -> void:
	
#STATE MANAGMENT

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
			
			#to make enemy look at player
			body.look_at(player.global_transform.origin, Vector3.UP)
			weapon.look_at(player.global_transform.origin, Vector3.UP)
			body.rotation.x = 0
			
			if weapon.get_collider() == player:
				if player.in_slide :
					var inst = shockwave.instance()
					get_tree().current_scene.add_child(inst)
			
		states.DEATH:
			pass


#SIGNALS
func _on_AttackArea_body_entered(body: Node) -> void:
	
	if body.is_in_group("player"):
		set_state(states.ATTACK)

func _on_AttackArea_body_exited(body: Node) -> void:
	
	if body.is_in_group("player"):
		set_state(states.CHASE)

