extends Node3D

var isActive = false
@export var animator : AnimationPlayer
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if !isActive: return
	if Input.is_action_just_pressed("tool"):
		swing_axe()


func swing_axe():
	animator.play("swing")
