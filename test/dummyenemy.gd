extends KinematicBody

const CENTER_OF_MASS = Vector3.UP

func get_hit(args:={}):
	print(self.name," got hit=====\n",args)
	return
