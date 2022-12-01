extends Node


var player_in_room :=false
const region_and_vantages = {}

export(Array, NodePath) var sniper

export(Array, NodePath) var megawizard

export(Array, NodePath) var room_points
var sniper_room_points :=[]
var megawizard_room_points :=[]

var random =  RandomNumberGenerator.new()

func _ready():
	random.randomize()
	for point in room_points:
		if sniper.has(point):
			sniper_room_points.push_back(point)
		if megawizard.has(point):
			megawizard_room_points.push_back(point)

#Sniper============

func get_sniper_vantage_point(idx)->Node:
	return get_node(sniper[idx])

func get_sniper_random_vantage_point(idx)->Node:
	return get_node(sniper[random.randi()%sniper.size()])

func get_random_sniper_vantage_position()->Vector3:
	if player_in_room:
		var idx = random.randi()%sniper_room_points.size()
		return get_node(sniper_room_points[idx]).global_translation
	else:
		var idx = random.randi()%sniper.size()
		return get_node(sniper[idx]).global_translation

#MegaWizard============

func get_megawizard_vantage_point(idx)->Node:
	return get_node(megawizard[idx])

func get_megawizard_random_vantage_point()->Node:
	return get_node(megawizard[random.randi%megawizard.size()])

func get_random_megawizard_vantage_position()->Vector3:
	if player_in_room:
		var idx = random.randi()%megawizard_room_points.size()
		return get_node(megawizard_room_points[idx]).global_translation
	else:
		var idx = random.randi()%megawizard.size()
		return get_node(megawizard[idx]).global_translation

func _on_roomarea_body_entered(body):
	player_in_room = true
	print("player_in_room:", player_in_room)


func _on_roomarea_body_exited(body):
	player_in_room = false
	print("player_in_room:", player_in_room)
