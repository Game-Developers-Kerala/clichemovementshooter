class_name BaseState
extends Node

signal switch_to(state_name)

var target : Enemy

func enter() -> void:
	pass
	
func exit() -> void:
	pass

func update(delta : float)-> void:
	pass

func physics_update(delta : float)-> void:
	pass

func input(event : InputEvent)-> void:
	pass


