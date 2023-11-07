extends CharacterBody3D

#Player controller variables
#Movement
@export var climb_speed: float = 3.0
var canMove: bool = true
var is_climbing: bool = false
var near_sign: bool = false
var gravity_enabled: bool = true
const SPEED: float = 5.0
const JUMP_VELOCITY: float = 8.5
#Camera
var mouse_sensitivity := 0.001
var twist_input := 0.0
var pitch_input := 0.0
#Glider
var player_has_glider = false
var glider_activated = false


#Player related nodes
@onready var twist_pivot := $TwistPivot 
@onready var pitch_pivot := $TwistPivot/PitchPivot
@onready var playerMesh = $MeshInstance3D
@onready var camera = $TwistPivot/PitchPivot/Camera3D
@onready var stamina_wheel = $MeshInstance3D/StaminaWheel
@onready var surface_detector = $MeshInstance3D/SurfaceDetector
@onready var still_on_wall = $MeshInstance3D/StillOnWall
@onready var stick_point_holder = $MeshInstance3D/StickPointHolder
@onready var stick_point = $MeshInstance3D/StickPointHolder/StickPoint
#Will be used to store the sign node the player approaches
var _sign
var ui_can_open = true

#Equipment Variables
@onready var equipment = $BagMenu.equipment
var can_slip: bool = true
var defense: int = 0

#Player status
@onready var player_status = $PlayerStatus

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.current = true
	$BagMenu.update_UI_state.connect(toggle_UI_can_open)

func _physics_process(delta):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	# Pass is cold value to stamina wheel here
	if player_status.temperature < 26 && equipment.current_effect != equipment.equipment_effect.COLD_RESISTANCE:
		stamina_wheel.is_cold = true
	else:
		stamina_wheel.is_cold = false
	if not canMove: 
		stamina_wheel.increase_stamina()
		return
	var direction
	can_slip = equipment.current_effect != equipment.equipment_effect.SLIP_RESISTANCE
	defense = equipment.defense
	
	twist_pivot.rotate_y(twist_input)
	pitch_pivot.rotate_x(pitch_input) 
	pitch_pivot.rotation.x = clamp(pitch_pivot.rotation.x,
		deg_to_rad(-50), 
		deg_to_rad(90)
	)

	twist_input = 0 
	pitch_input = 0
	
	update_climbing_status()
	if is_climbing:
		#if player is climbing disable gravity
		velocity.y = 0
		gravity_enabled = false
		
		
		#move player relative to the walls normal
		var rot = -(atan2(surface_detector.get_collision_normal().z, surface_detector.get_collision_normal().x) - PI/2)
		var f_input = Input.get_action_strength("up") - Input.get_action_strength("down")
		var h_input = Input.get_action_strength("right") - Input.get_action_strength("left")
		direction = Vector3(h_input, f_input, 0).rotated(Vector3.UP, rot).normalized()
		playerMesh.rotation.y = -(atan2(surface_detector.get_collision_normal().z, surface_detector.get_collision_normal().x) - PI/2)
		
		#sticks player to the wall
		stick_point_holder.global_transform.origin = surface_detector.get_collision_point()
		global_transform.origin.x = stick_point.global_transform.origin.x
		global_transform.origin.z = stick_point.global_transform.origin.z
		
	else:
		# Add the gravity.
		if not is_on_floor():
			velocity.y -=  gravity * delta
			if glider_activated == false:
				velocity.y -= gravity * delta
			elif glider_activated == true:
				velocity.y = -1

	
		# Handle Reading Signs.
		if Input.is_action_just_pressed("action") and near_sign:
			read_sign()
		
		# Handle Jump.
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		
		if Input.is_action_just_pressed("glider") and player_has_glider:
			if glider_activated:
				gravity += 9
				glider_activated = false
				

			else:
				glider_activated = true
				gravity -= 9
			print("glider here")
			

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_dir = Input.get_vector("left", "right", "up", "down")
		direction = (twist_pivot.basis * transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		velocity = velocity.rotated(Vector3.UP, rotation.y)
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		if is_climbing:
			if stamina_wheel.stamina == 0:
				stop_climbing()
			else:
				stamina_wheel.reduce_stamina()
				velocity.y = direction.y * climb_speed
		else:
			playerMesh.look_at(transform.origin + Vector3(velocity.x, 0, velocity.z), Vector3.UP)
			stamina_wheel.increase_stamina()
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		stamina_wheel.increase_stamina()
		if is_climbing:
			velocity.y = move_toward(velocity.y, 0, climb_speed)

	move_and_slide()


func update_climbing_status():
	if surface_detector.is_colliding() && surface_detector.get_collider().is_in_group('climbable'):
		if still_on_wall.is_colliding():
			#should we have a climb button?
			if is_on_floor() || stamina_wheel.stamina == 0:
				is_climbing = false
			elif stamina_wheel.stamina > 0 && !stamina_wheel.is_exhausted && velocity.y < 0:
				is_climbing = true
		else:
			#if player is at top of climb, boost them over the edge
			velocity.y = JUMP_VELOCITY
			await get_tree().create_timer(0.3).timeout
			is_climbing = false
	else:
		is_climbing = false


func stop_climbing():
	velocity.x = 0
	velocity.z = 0
	is_climbing = false
	

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			twist_input = -event.relative.x * mouse_sensitivity
			pitch_input = -event.relative.y * mouse_sensitivity


func read_sign():
	if not _sign.change_reading_state.is_connected(toggle_can_move):
		#	Using bind below turns the variable passed into a 
		#	local variable no longer attached to the original variable
		#	This makes it impossible to reassign the variable passed in
		_sign.change_reading_state.connect(toggle_can_move)
	_sign._read()


func _on_area_3d_area_entered(area):
#	Add a check and on screen cue for reading the sign
	var area_owner = area.get_owner()
	if area.is_in_group('sign'):
		_sign = area_owner
		near_sign = true
	if area.is_in_group('glider'):
		player_has_glider = true
		print("ture",gravity)
		# make and show Ui here for interacting with the sign


func _on_area_3d_area_exited(area):
	if area.is_in_group('sign'):
		near_sign = false


func toggle_can_move():
	canMove = !canMove


func toggle_UI_can_open():
	ui_can_open = !ui_can_open
	update_UI_can_open_states()


func update_UI_can_open_states():
	$MeshInstance3D/ToolPosition/ToolWheel.can_open = ui_can_open
	$BagMenu.can_open = ui_can_open
