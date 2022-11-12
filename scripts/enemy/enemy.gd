#enemy controller script
class_name Enemy
extends KinematicBody

onready var fsm = $StateManager


func _ready() -> void:
	
	fsm.init(self)
	
	
func _process(delta: float) -> void:
	
	fsm.process(delta)


func _physics_process(delta: float) -> void:
	
	fsm.physics_process(delta)
	
