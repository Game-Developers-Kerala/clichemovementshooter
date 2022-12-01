extends Node
class_name cmn

enum colliders {player = 0,enemy = 1,pickup = 2, grapple_breaker = 3, grapple_target = 4,
			enemy_hurtbox = 5, player_custom = 6, enemy_custom = 7,
			 level = 8, level_porous = 9,level_seethrough = 10, level_no_grapple = 11}

static func get_all_children(in_node,arr:=[]):
	arr.push_back(in_node)
	for child in in_node.get_children():
		arr = get_all_children(child,arr)
	return arr
