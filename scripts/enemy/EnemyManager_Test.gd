extends Node

const SNIPER = preload("res://scenes/enemy/sniper/sniper.tscn")

onready var vantage_points = get_tree().get_nodes_in_group("vantage_points")[0]

func _ready():
	game.connect("wave_start",self,"_on_wave_start")
	pass
	
func _on_wave_start():
	pass

func spawn_snipers(count:int):
	var assigned_spawn_points :=[]
	count = clamp(count,0,20)
	if !count:
		return
		
	pass
