#enemy controller script
class_name Enemy
extends KinematicBody

enum states{

	CHASE,
	ATTACK,
	DEATH

}


const CENTER_OF_MASS = Vector3(0,1,0)
export(NodePath) var path_to_player

var chase_speed : float = 300
var attack_speed : float = 100
var velocity : Vector3 = Vector3.ZERO 

var current_state = states.CHASE  setget set_state, get_state
var gun_cool_down = false

onready var label = $BodyRotationHelper/Label3D as Label3D
onready var nav_agent = $NavigationAgent as NavigationAgent
onready var player = get_node(path_to_player) as KinematicBody
onready var aim = $BodyRotationHelper/Aim as RayCast
onready var body = $BodyRotationHelper


func _ready() -> void:
	pass

func _process(delta: float) -> void:
	
	match get_state():
		
		states.CHASE:
			
			label.text = "CHASE"
			if aim.is_colliding():
				set_state(states.ATTACK)
			
		states.ATTACK:
			if !aim.is_colliding():
				set_state(states.CHASE)
			label.text = "ATTACK"
			
		states.DEATH:
			
			label = "DEATH"


func _physics_process(delta: float) -> void:
	
	match get_state():
		
		states.CHASE:
			
			#to make enemy aim at the player 
			body.look_at(player.global_transform.origin, Vector3.UP)
			aim.look_at(player.global_transform.origin, Vector3.UP)
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
			aim.look_at(player.global_transform.origin, Vector3.UP)
			body.rotation.x = 0
			
		states.DEATH:
			pass


#getter and setter functions
func set_state(new_state) -> void :
	current_state = new_state


func get_state():
	return current_state


func _on_GunCoolDown_timeout() -> void:
	$RailShot.shoot()


func _on_Area_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		$GunCoolDown.start()
