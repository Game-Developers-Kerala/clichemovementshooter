class_name BaseEnemy
extends KinematicBody

const CENTER_OF_MASS = Vector3(0,1,0)

signal npc_hurt

#export(NodePath) var path_to_player
export(NodePath) var path_to_weapon
export(NodePath) var path_to_nav_agent
export(NodePath) var path_to_BodyRotationHelper
export(NodePath) var path_to_model
export var chase_speed : float = 300
export var attack_speed : float = 75


var health : float = 100 setget _set_health,get_health
var velocity : Vector3 = Vector3.ZERO 
var current_state setget set_state, get_state
var player : KinematicBody


onready var model = get_node(path_to_model)
onready var weapon = get_node(path_to_weapon) as RayCast
onready var nav_agent = get_node(path_to_nav_agent) as NavigationAgent
onready var body = get_node(path_to_BodyRotationHelper) as Spatial

#getter and setter functions
func set_state(new_state) -> void :
	print("state:" + str(new_state))
	current_state = new_state
	enter()


func get_state():
	return current_state


#this function will exectue 
func get_hit(args={}):
	
	print("Plyr got hit at:",OS.get_ticks_msec(),"=====\n",args)
	if args.has("dmg"):
		_set_health(args.dmg)
	if args.has("force"):
		if args.has("push_dir"):
			if args.has("dir_replace"):
				velocity = Vector3.ZERO
			var push_multiplier := 1.0
			if args.has("caused_by_player"):
				push_multiplier = 2.0
			velocity += args.push_dir*args.force*push_multiplier
	if args.has("origin"):
		#do something with the origin info
		return


func _calc_velocity(speed):
	
	var target_pos = nav_agent.get_next_location()
	var dir : Vector3 = (target_pos - global_transform.origin).normalized()
	return dir * speed


func _aim_at_player():
	
	#to make enemy look at player
	body.look_at(player.global_transform.origin, Vector3.UP)
	weapon.look_at(player.global_transform.origin, Vector3.UP)
	body.rotation.x = 0


func _calc_vantage_point(target : Vector3):
	pass

#function called when entered to a new state
#to play animations
func enter() -> void:
	pass

func get_health():
	return health
	
func _set_health(val):
	emit_signal("npc_hurt")
	health -= val
