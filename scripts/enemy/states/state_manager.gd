class_name StateManager
extends Node

onready var idle_state : BaseState = $Idle
onready var patrol_state : BaseState = $Patrol
onready var alert_state : BaseState = $Alert
onready var chase_state : BaseState = $Chase
onready var attack_state : BaseState = $Attack
onready var dead_state : BaseState = $Dead 

onready var initial_state : BaseState = idle_state
var current_state : BaseState


func init(enemy) -> void:
	
	for child in get_children():
		child.target = enemy
		
	_change_to(initial_state)

func _change_to(new_state : BaseState):
	if current_state:
		current_state.exit()
		
	current_state = new_state
	current_state.enter()


func _on_PlayerFSM_switch_to(new_state) -> void:
	
	match(new_state):
		
		"IDLE":
			_change_to(idle_state)
		"PATROL":
			_change_to(patrol_state)
		"ALERT":
			_change_to(alert_state)
		"Chase":
			_change_to(chase_state)
		"ATTACk":
			_change_to(attack_state)
		"DEAD":
			_change_to(dead_state)



func _ready() -> void:
	pass


func process(delta: float) -> void:
	current_state.update(delta)


func physics_process(delta: float) -> void:
	current_state.physics_update(delta)


func unhandled_input(event: InputEvent) -> void:
	current_state.input(event)
