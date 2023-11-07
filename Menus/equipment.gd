extends Control

@export var defense : int = 0
@onready var equipemnt_description = $Panel/RichTextLabel
enum equipment_effect {
	NONE,
	SLIP_RESISTANCE,
	HEAT_RESISTANCE,
	COLD_RESISTANCE,
	GLIDE
}
var current_effect = equipment_effect.NONE

func reset():
	defense = 0
	current_effect = equipment_effect.NONE
	equipemnt_description.clear()


func _on_unequipmenticon_pressed():
	reset()
	equipemnt_description.add_text('Please select a peice of equipment to equip')


func _on_cling_equipment_pressed():
	reset()
	defense = 5
	current_effect = equipment_effect.SLIP_RESISTANCE
	equipemnt_description.add_text('This equipment, when equiped, prevents slipping on surfaces while climbing when raining.')


func _on_warm_equipment_pressed():
	reset()
	defense = 10
	current_effect = equipment_effect.HEAT_RESISTANCE
	equipemnt_description.add_text('This equipment, when equiped, prevents damage from excessively hot areas.')


func _on_cold_equipment_pressed():
	reset()
	defense = 7
	current_effect = equipment_effect.COLD_RESISTANCE
	equipemnt_description.add_text('This equipment, when equiped, prevents damage and stamina loss from excessively cold areas.')


func _on_glide_equipment_pressed():
	reset()
	defense = 3
	current_effect = equipment_effect.GLIDE
	equipemnt_description.add_text('This equipment, when equiped, allows you to glide through the air.')

