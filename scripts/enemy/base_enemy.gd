class_name BaseEnemy
extends KinematicBody

const CENTER_OF_MASS = Vector3(0,1,0)


#export(NodePath) var path_to_player
export(NodePath) var path_to_weapon
export(NodePath) var path_to_nav_agent
export(NodePath) var path_to_BodyRotationHelper
export var chase_speed : float = 300
export var attack_speed : float = 75


var health : float = 100
var velocity : Vector3 = Vector3.ZERO 
var current_state setget set_state, get_state



#onready var player = get_parent().get_node("Player")

onready var weapon = get_node(path_to_weapon) as RayCast
onready var nav_agent = get_node(path_to_nav_agent) as NavigationAgent
onready var body = get_node(path_to_BodyRotationHelper) as Spatial

#getter and setter functions
func set_state(new_state) -> void :
	current_state = new_state


func get_state():
	return current_state


#this function will exectue 
func get_hit(args={}):
	
	print("Plyr got hit at:",OS.get_ticks_msec(),"=====\n",args)
	if args.has("dmg"):
		health = -args.dmg
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

