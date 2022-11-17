#ground shaker enemy
extends BaseEnemy

enum states{
	CHASE,
	SHOCKWAVE,
	MEELE,
	DEATH
}

var meele_speed = 200
onready var label : Label3D = $BodyRotationHelper/Label3D
onready var attack_area : Area = $AttackArea


func _ready() -> void:
	.set_state(states.CHASE)
	
func _process(delta: float) -> void:
	
	match get_state():
		
		states.CHASE:
		
			label.text = "Chase"
			
		states.SHOCKWAVE:
			
			label.text = "Shock wave"
			
		states.MEELE:
			label.text = "Meele"
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
			
		states.MEELE:
			
			#to make enemy aim at the player 
			body.look_at(player.global_transform.origin, Vector3.UP)
			weapon.look_at(player.global_transform.origin, Vector3.UP)
			body.rotation.x = 0
			
			nav_agent.set_target_location(player.global_transform.origin)
			var target_pos = nav_agent.get_next_location()
			var dir : Vector3 = (target_pos - global_transform.origin).normalized()
			velocity = dir * meele_speed * delta
			move_and_slide(velocity,Vector3.UP)
			
			if weapon.get_collider() == player:
				print("meele attack")
		
		states.SHOCKWAVE:
			
			print("shock_wave")
			
		states.DEATH:
			pass





func _on_AttackArea_body_entered(body: Node) -> void:
	
	if body.is_in_group("player"):
		if player.in_slide:
			set_state(states.SHOCKWAVE)
		else:
			set_state(states.MEELE)

func _on_AttackArea_body_exited(body: Node) -> void:
	
	if body.is_in_group("player"):
		set_state(states.CHASE)
