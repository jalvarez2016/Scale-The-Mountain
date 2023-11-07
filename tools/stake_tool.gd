extends Node3D

var isActive = false
@onready var surface_detector = $RayCast3D
const stake = preload("res://tools/stake.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if !isActive: return
	var isColliding = surface_detector.is_colliding()
	if isColliding:
		var surface = surface_detector.get_collider()
		if surface.is_in_group("stake"):
			return
		if surface.is_in_group("climbable") && Input.is_action_just_pressed("tool"):
			spawn_stake()
			
func spawn_stake():
	var stake_instance = stake.instantiate()
	var surface = surface_detector.get_collider()
	surface.add_child(stake_instance)
	stake_instance.global_transform.origin = surface_detector.get_collision_point()
	stake_instance.rotation.y = -(atan2(surface_detector.get_collision_normal().z, surface_detector.get_collision_normal().x) - PI/2) 
