class_name EnemyManager
extends Node

#spawners
export(NodePath) var arc_enemy_spawner_path
export(NodePath) var ground_pounder_spawner_path
export(NodePath) var wizard_spawner_path
export(NodePath) var sniper_spawner_path
export(NodePath) var ufo_spawn_path

onready var arc_enemy_spawner = get_node(arc_enemy_spawner_path)
onready var ground_pounder_spawner = get_node(ground_pounder_spawner_path)
onready var wizard_spawner = get_node(wizard_spawner_path)
onready var sniper_spawner = get_node(sniper_spawner_path)
onready var ufo_spawner = get_node(ufo_spawn_path)


onready var arc_enemy = preload("res://scenes/enemy/arc_shooter/arc_shooter.tscn")
onready var ground_pounder = preload("res://scenes/enemy/ground_pounder/ground_pounder.tscn")
onready var wizard = preload("res://scenes/enemy/wizard/wizard.tscn")
onready var ufo = preload("res://scenes/enemy/heavy_gunner/heavy_gunner.tscn")
onready var sniper = preload("res://scenes/enemy/sniper/Sniper.tscn")

onready var timer = Timer.new()

#stores enemy spawn points
var arc_enemy_spawn_point = []
var ground_pounder_spawn_point = []
var wizard_spawn_point = []


func _ready() -> void:
	
	arc_enemy_spawn_point = _get_spawn_points(arc_enemy_spawner)
	ground_pounder_spawn_point = _get_spawn_points(ground_pounder_spawner)
	wizard_spawn_point = _get_spawn_points(wizard_spawner)
	
	add_child(timer)
	timer.start(4)
	timer.connect("timeout",self,"ontimeout_start_spawn")

	
func ontimeout_start_spawn():

	_start_spawn(arc_enemy,arc_enemy_spawn_point)
	_start_spawn(ground_pounder,ground_pounder_spawn_point)
	_start_spawn(wizard,wizard_spawn_point)
	
	#comment out the stop function to spawn unlimited
	timer.stop()

#function to spawn enemies
func _start_spawn(spawnable,spawn_point : Array,count : int = 2) -> void:
	
	for i in range(count - 1):
		
		var inst = spawnable.instance()
		inst.global_transform.origin = spawn_point[randi() % spawn_point.size()].global_transform.origin
		add_child(inst)


#function to iterate over spawn points
func _get_spawn_points(spawner : Node) -> Array :
	
	var spawn_points : Array = []
	if spawner:
		for child in spawner.get_children():
			spawn_points.append(child)
	
	return spawn_points
	
#spawn function
func start_wave(wave : int):
	pass
