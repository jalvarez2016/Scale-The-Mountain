extends Control

# The equipment variable is here for easier access to the equipment state
# ie. equipment.current_effect can be used to check the equipment effect for player logic
@onready var equipment = $PanelContainer/Panel/TabContainer/Equipment
signal update_UI_state()
var can_open: bool = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("bag"):
		if can_open:
			print('bag opened')
			visible = true
			emit_signal("update_UI_state")
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			print('bag closed')
			visible = false
			emit_signal("update_UI_state")
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
