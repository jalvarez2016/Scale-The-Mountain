extends Node3D

@export var axe_slot_icon : Texture2D
@export var stake_slot_icon : Texture2D
@export var bow_slot_icon : Texture2D
@export var lighter_slot_icon : Texture2D

@onready var axe_scene: Node = $Tools/Axe
#@onready var bow_scene: Node = 
@onready var stake_scene: Node = $Tools/Stake_tool
#@onready var lighter_scene: Node = 

@onready var toolWheel = $Control
@onready var axe_slot = $"Control/Transparent-wheel/Axe"
@onready var bow_slot = $"Control/Transparent-wheel/Bow"
@onready var lighter_slot = $"Control/Transparent-wheel/Lighter"
@onready var stake_slot = $"Control/Transparent-wheel/Stake"

var can_open = true

enum tool_state {
	NONE,
	STAKE,
	AXE,
	BOW,
	LIGHTER
}
var tool_scene = null
var active_tool = tool_state.NONE

func _ready():
	axe_slot.texture = axe_slot_icon
	bow_slot.texture = bow_slot_icon
	stake_slot.texture = stake_slot_icon
	lighter_slot.texture = lighter_slot_icon

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if can_open:
		if Input.is_action_just_pressed("bag"):
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			toolWheel.visible = false
			return
		if Input.is_action_just_pressed('tool-toggle'):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			toolWheel.visible = true
			if tool_scene != null :
				clear_tool()
		if Input.is_action_just_released("tool-toggle"):
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			toolWheel.visible = false
		if active_tool == tool_state.AXE:
			equip_axe()
		elif active_tool == tool_state.BOW:
			pass
		elif active_tool == tool_state.LIGHTER:
			pass
		elif active_tool == tool_state.STAKE:
			equip_stake()

func clear_tool():
	print('unequip')
	tool_scene.visible = false
	tool_scene.isActive = false
	tool_scene = null

func equip_axe():
	print('axe equip')
	if tool_scene:
		tool_scene.isActive = false
		tool_scene.visible = false
	tool_scene = axe_scene
	axe_scene.isActive = true 
	axe_scene.visible = true 

func equip_stake():
	print('stake equip')
	if tool_scene:
		tool_scene.isActive = false
		tool_scene.visible = false
	tool_scene = stake_scene
	stake_scene.isActive = true
	stake_scene.visible = true
	
	
#Axe
func _on_slot_1_mouse_entered():
	active_tool = tool_state.AXE

func _on_slot_1_mouse_exited():
#	active_tool = tool_state.NONE
	pass

#Stake
func _on_slot_4_mouse_entered():
	active_tool = tool_state.STAKE


func _on_slot_4_mouse_exited():
#	active_tool = tool_state.NONE
	pass
