class_name BaseEnemy
extends KinematicBody

const CENTER_OF_MASS = Vector3(0,1,0)


export(NodePath) var path_to_player
export(NodePath) var path_to_weapon
export(NodePath) var path_to_nav_agent
export(NodePath) var path_to_BodyRotationHelper
export(NodePath) var path_to_shootRange
export var chase_speed : float = 300
export var attack_speed : float = 75


var health : float = 100
var velocity : Vector3 = Vector3.ZERO 
var current_state setget set_state, get_state
var attacks = {}


onready var player = get_node(path_to_player) as KinematicBody
onready var weapon = get_node(path_to_weapon) as RayCast
onready var nav_agent = get_node(path_to_nav_agent) as NavigationAgent
onready var body = get_node(path_to_BodyRotationHelper) as Spatial
onready var shoot_range = get_node(path_to_shootRange) as Area

#getter and setter functions
func set_state(new_state) -> void :
	current_state = new_state


func get_state():
	return current_state


#this function will exectue 
func get_hit(args={}):
	pass


