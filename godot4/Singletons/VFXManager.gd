extends Node

var animations := {
	"electro_attack": preload("res://Entities/Animations/ElectroAttack.tscn"),
	"explosion_attack": preload("res://Entities/Animations/ExplosionAttack.tscn"),
	"fire_attack": preload("res://Entities/Animations/FireAttack.tscn"),
	"gun_attack": preload("res://Entities/Animations/GunAttack.tscn"),
	"heal_attack": preload("res://Entities/Animations/HealAttack.tscn"),
	"slash_attack": preload("res://Entities/Animations/SlashAttack.tscn"),
}

func play_vfx(type: String, world_position: Vector2) -> void:
	if not animations.has(type):
		return

	#makes the animation in the world
	var vfx = animations[type].instantiate()
	
	# Set the position
	vfx.global_position = world_position
	vfx.z_index = 10 
	
	add_child(vfx)
	
	#plays animation and kills itself when its done playing
	if vfx is AnimatedSprite2D:
		vfx.play("default")
		vfx.animation_finished.connect(func(): vfx.queue_free())
