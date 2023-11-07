extends Node2D

var full_heart = preload("res://Icons/Heart.png")
var empty_heart = preload("res://Icons/Empty-Heart.png")
@export var health: int = 10
@onready var health_bar: Control = $"Heart-Container"

@export var temperature: int = 50 

func _ready():
	visible = true
	show_health()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta):


func show_health():
	var count = 0
	var hearts = health_bar.get_children()
	while count < hearts.size():
		var heart = hearts[count]
		if health > count:
			heart.set_texture(full_heart)
		elif health <= count:
			heart.set_texture(empty_heart)
		count += 1
	if health == 0:
		game_over()

func game_over():
	print('death and respawn logic')


func damage(amount: int):
	health -= amount
	show_health()


func heal(amount: int):
	health += amount
	show_health()

