class_name EnemyManager
extends Node

signal start_wave
signal spawn(spawnable,spawner)

var is_wave setget set_wave,get_wave

export(NodePath) var path_to_player 
#spawners
export(NodePath) var arc_enemy_spawner_path
export(NodePath) var ground_pounder_spawner_path
export(NodePath) var wizard_spawner_path
#export(NodePath) var arc_enemy_spawner_path


onready var arc_enemy_spawner = get_node(arc_enemy_spawner_path)
onready var ground_pounder_spawner = get_node(ground_pounder_spawner_path)
onready var wizard_spawner = get_node(wizard_spawner_path)

export(PackedScene) var arc_enemy
export(PackedScene) var ground_pounder
export(PackedScene) var wizard


onready var timer = Timer.new()

var arc_enemy_list = []

func _ready() -> void:
	timer.connect("timeout",self,"_on_time_out")
	#connect("spawn",self,"_spawner")
	add_child(timer)
	timer.start(3)


func _on_time_out():
	
	print("bad guys are coming")
	if arc_enemy_list.size() > 1:
		print("enough enemies")
	else:
		emit_signal("spawn",arc_enemy,arc_enemy_spawner)
	

#function to spawn enemies
func _spawner(spawnable : BaseEnemy,spawner : Position3D):

	var inst = spawnable.instance()
	inst.global_transform.origin = spawner.global_transform.origin
	add_child(inst)



func set_wave(wave : bool) -> void:
	is_wave = wave
	
func get_wave() -> bool:
	return is_wave


func _on_EnemyManager_spawn(spawnable, spawner) -> void:
	
	var inst = spawnable.instance()
	inst.player = get_node(path_to_player)
	inst.global_transform.origin = spawner.global_transform.origin
	get_tree().current_scene.add_child(inst)
	arc_enemy_list.append(inst)
