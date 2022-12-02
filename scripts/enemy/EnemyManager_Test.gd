extends Node

var enemy_count :int = 0



onready var vantage_points :Node= get_tree().get_nodes_in_group("vantage_points")[0]


enum enemy_types {sniper,megawizard,golem,ufo,arcgirl,wizard}

const SPAWN_ORDER = [enemy_types.megawizard,enemy_types.golem, enemy_types.wizard,
					enemy_types.sniper,enemy_types.arcgirl,enemy_types.ufo]

const WAVES = [
				[0,0,2,0,1,0], # 1
				[0,0,2,0,2,1], #2
				[0,1,2,1,2,1], #3
				[0,1,3,2,2,2], #4
				[0,2,4,2,1,2], # 5
				[1,2,4,3,2,2], #6
				[1,3,3,3,2,3], #7
				[2,2,4,2,3,3], #8
				[3,3,3,3,3,3], #9
				[4,4,4,2,2,3], #10
				]

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
			"scene":preload("res://scenes/enemy/heavy_gunner/heavy_gunner.tscn"),
			"get_spawn_point":"get_ufo_random_spawn_point",
			},
		"wizard":{
			"scene":preload("res://scenes/enemy/wizard/wizard.tscn"),
			"get_spawn_point":"get_sniper_random_vantage_point"
			},
		"arcgirl":{
			"scene":preload("res://scenes/enemy/arc_shooter/arc_shooter.tscn"),
			"get_spawn_point":"get_sniper_random_vantage_point"
			},
		"golem":{
			"scene":preload("res://scenes/enemy/ground_pounder/ground_pounder.tscn"),
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
	if wave_idx <= WAVES.size():
		spawn_enemies(WAVES[wave_idx-1])
	else:
		spawn_enemies(get_random_roster())
##	spawn_enemies(get_random_roster())
#	spawn_enemies([0,1,0,0,1,1])
	game.emit_signal("enemy_count_changed",enemy_count)

func get_random_roster():
	var roster :=[]
	roster.push_back(random.randi()%4) #mega
	roster.push_back(random.randi()%4) #golem
	roster.push_back(random.randi()%4) #wizard
	roster.push_back(random.randi()%4) #sniper
	roster.push_back(random.randi()%4) #arcgirl
	roster.push_back(0) #ufo
	return roster
	
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

