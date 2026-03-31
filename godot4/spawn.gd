extends Area2D

@export var unit = PackedScene
var isIn = false
@onready var board:GameBoard = $"../GameBoard"

func _physics_process(delta):
	if Input.is_action_just_pressed("click") and isIn == true:
		print("spawn")

func _on_mouse_entered():
	isIn = true
	print("yes")
	


func _on_mouse_exited():
	isIn = false
	print("no")
