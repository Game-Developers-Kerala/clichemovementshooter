extends Node

var enemy_count :int = 0

const SNIPER = preload("res://scenes/enemy/sniper/sniper.tscn")

onready var vantage_points = get_tree().get_nodes_in_group("vantage_points")[0]




func _ready():
	game.connect("wave_start",self,"_on_wave_start")
	game.connect("enemy_killed",self,"_on_enemy_killed")
	pass

func _on_wave_start(wave_idx):
	enemy_count = 0
	spawn_snipers(wave_idx)
	game.emit_signal("enemy_count_changed",enemy_count)

func spawn_snipers(count:int):
	var assigned_spawn_points :=[]
	count = clamp(count,0,20)
	if !count:
		return
	var max_idx = vantage_points.sniper.size()-1
	while assigned_spawn_points.size()<count:
		var number = randi()%max_idx
		if !assigned_spawn_points.has(number):
			assigned_spawn_points.push_back(number)
	if assigned_spawn_points:
		for point_idx in assigned_spawn_points:
			var inst = SNIPER.instance()
			get_tree().current_scene.add_child(inst)
			var point_node = vantage_points.get_sniper_vantage_point(point_idx)
			inst.global_transform = point_node.global_transform
			enemy_count += 1
	pass

func _on_enemy_killed():
	enemy_count -= 1
	game.emit_signal("enemy_count_changed",enemy_count)
