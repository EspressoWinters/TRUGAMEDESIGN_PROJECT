class_name tank
extends Resource

@export var skin = Texture2D

static var attack_range: int = 1

static func attack():
	print("Tank is attacking")

static func ability():
	print("Tank is abiltying")

static func passive():
	pass
