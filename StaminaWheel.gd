extends Node2D

var stamina = 100
var min_angle = -PI/2
var max_angle = PI * 2 + (min_angle)
var current_angle = 0
var is_exhausted = false
var is_cold = false

func _draw():
	if is_exhausted:
		draw_stamina_meter(Vector2(0,0), 10, 5, current_angle, Color.RED)
	else:
		if is_cold:
			draw_stamina_meter(Vector2(0,0), 10, 5, current_angle, Color.CORNFLOWER_BLUE)
		else:
			draw_stamina_meter(Vector2(0,0), 10, 5, current_angle, Color.GREEN)

func draw_stamina_meter(pos, size, width, current, color):
	draw_arc(pos, size, max_angle, min_angle, 800, Color(0,0,0,0.5), width, true)
	draw_arc(pos, size, max_angle, current, 800, color, width, true)

func reduce_stamina():
	if is_cold:
		stamina -= 5
	else:
		stamina -= 1
	if stamina <= 0:
		is_exhausted = true
	
func increase_stamina():
	if is_cold:
		stamina += .1
	else:
		stamina += 1
	if stamina >= 100:
		is_exhausted = false
		
func _ready():
	visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
#	if Input.is_action_pressed("ui_up"):
#		increase_stamina()
#	elif Input.is_action_pressed("ui_down"):
#		reduce_stamina()
		
	stamina = clamp(stamina, 0,  100)
	var value = ((min_angle * -1) + max_angle) /100
	current_angle = max_angle - (stamina * value)
	queue_redraw()
