extends Node

var enemy_count :int = 0


onready var vantage_points :Node= get_tree().get_nodes_in_group("vantage_points")[0]


enum enemy_types {sniper,megawizard,golem,ufo,arcgirl,wizard}

const SPAWN_ORDER = [enemy_types.megawizard,enemy_types.ufo, enemy_types.wizard,
					enemy_types.sniper,enemy_types.arcgirl,enemy_types.ufo]

func get_spawn_order(enemy_type:int)->int:
	return SPAWN_ORDER.find(enemy_type)

const ENEMY_DICT = {
		"megawizard":{
			"scene":preload("res://scenes/enemy/megawizard/megawizard.tscn"),
			"get_spawn_point":"get_megawizard_random_vantage_point"
			},
		"sniper":{
			"scene":preload("res://scenes/enemy/sniper/sniper.tscn"),
			"get_spawn_point":"get_sniper_random_vantage_point"
			},
#			get_ufo_random_spawn_point()
		"ufo":{
#			"scene":preload(""),
			"get_spawn_point":"get_ufo_random_spawn_point",
			},
		"wizard":{
			"scene":preload("res://scenes/enemy/wizard/wizard.tscn"),
			"get_spawn_point":"get_sniper_random_vantage_point"
			}
		}

func get_enemy_dict(enemy_type:int)->Dictionary:
	return ENEMY_DICT[enemy_types.keys()[enemy_type]]

func get_enemy_dict_from_spawn_order(idx:int)->Dictionary:
	var enemy_type = SPAWN_ORDER[idx]
	return get_enemy_dict(enemy_type)

var random = RandomNumberGenerator.new()

func _ready():
	random.randomize()
	game.connect("wave_start",self,"_on_wave_start")
	game.connect("enemy_killed",self,"_on_enemy_killed")
	pass

func _on_wave_start(wave_idx):
	enemy_count = 0
	spawn_enemies([1,0,1,1,0,0])
	game.emit_signal("enemy_count_changed",enemy_count)



func spawn_enemies(counts:=[]):
	var assigned_points := []
	if !counts:
		return
	for enemy_by_order in counts.size():
		if !counts[enemy_by_order]:
			continue
		var enemy_dict = get_enemy_dict_from_spawn_order(enemy_by_order)
		for i in counts[enemy_by_order]:
			var spawned = false
			while !spawned:
				var spawn_point = vantage_points.call(enemy_dict["get_spawn_point"])
				if assigned_points.has(spawn_point):
					continue
				spawn_at_point(enemy_dict["scene"],spawn_point)
				spawned=true
				assigned_points.push_back(spawn_point)

func spawn_at_point(enemy_scene:PackedScene,point:Node):
	var inst = enemy_scene.instance()
	get_tree().current_scene.add_child(inst)
	inst.global_transform = point.global_transform
	enemy_count += 1

func _on_enemy_killed():
	enemy_count -= 1
	game.emit_signal("enemy_count_changed",enemy_count)

