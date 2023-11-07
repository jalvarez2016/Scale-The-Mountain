extends Node3D

@onready var cling_position = $cling_position
var isClinging = false
var player

func _physics_process(_delta):
	if Input.is_action_just_pressed("ui_accept") and isClinging:
		jump()

func _on_area_3d_area_entered(area):
	if area.is_in_group("Player"):
		var area_owner = area.get_owner()
		area_owner.canMove = false
		var tween = get_tree().create_tween()
		tween.tween_property(area_owner, "position", cling_position.global_transform.origin, .5)
		#add tween here for the player position
#		area_owner.position = cling_position.global_transform.origin
		isClinging = true
		player = area_owner
		
func jump():
	player.canMove = true
	player.velocity.y = 8.0
	player.is_climbing = false
	isClinging = false
