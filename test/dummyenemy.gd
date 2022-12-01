extends KinematicBody

const CENTER_OF_MASS = Vector3.UP

const SPEED = 10
var velocity := Vector3.ZERO
var time :=0.0

func get_hit(args:={}):
	print(self.name," got hit=====\n",args)
	return

func _physics_process(delta):
	time += delta
	velocity.x = sin(time)*SPEED
	velocity.z = cos(time)*SPEED
	move_and_slide(velocity)
