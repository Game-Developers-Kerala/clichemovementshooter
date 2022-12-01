extends Node


var player_in_room :=false
const region_and_vantages = {}

export(Array, NodePath) var sniper
export(Array, NodePath) var wizard
export(Array, NodePath) var megawizard

export(Array, NodePath) var room_points
var sniper_room_points :=[]

var random =  RandomNumberGenerator.new()

func _ready():
	random.randomize()
	for point in room_points:
		if sniper.has(point):
			sniper_room_points.push_back(point)


func get_sniper_vantage_point()->Vector3:
	if player_in_room:
		var idx = random.randi()%sniper_room_points.size()
		return get_node(sniper_room_points[idx]).global_translation
	else:
		var idx = random.randi()%sniper.size()
		return get_node(sniper[idx]).global_translation


func _on_roomarea_body_entered(body):
	player_in_room = true


func _on_roomarea_body_exited(body):
	player_in_room = false
