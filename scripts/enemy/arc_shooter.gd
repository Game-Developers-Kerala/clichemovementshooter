#enemy controller script
#Arch shooter
extends BaseEnemy

enum states{

	CHASE,
	ATTACK,
	DEATH

}

var player
onready var label = $BodyRotationHelper/Label3D as Label3D
onready var ARC = preload("res://scenes/enemy/arc_shooter/arc.tscn")

func _ready() -> void:
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
				
				if !player.grappling: 
					if $ShootTimer.is_stopped():
						_shoot()
				else:
					print("shoot grapple")
					
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


func _shoot():
	
		$ShootTimer.start()
		var inst = ARC.instance()
		get_tree().current_scene.add_child(inst)
		inst.look_at_from_position(global_translation,player.global_translation,Vector3.UP)
