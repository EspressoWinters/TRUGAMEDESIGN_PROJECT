extends Node
#Shock, Gun Soundeffect was taken from: https://kronbits.itch.io/freesfx/download/eyJpZCI6NDg2NTIyLCJleHBpcmVzIjoxNzc2Mjk4ODI5fQ%3d%3d%2eIVN8rPs5HsU2VVHiWu8mqOy13qo%3d
#Slashing, heal and FlameThrower soundeffect was taken from: https://firahfabe.itch.io/chiptune-8-bit-sfx-pack/download/eyJleHBpcmVzIjoxNzc2Mjk5NDM1LCJpZCI6MzMwMDg0OX0%3d%2eiK%2b0oPsOfsVfWJii1z4snkwufjg%3d
#lose soundeffect was taken from: https://pixabay.com/sound-effects/film-special-effects-8-bit-video-game-fail-version-3-145479/
#ui soundeffects(buttonhover/buttonpress): https://ad-sounds.itch.io/fast-ui-sounds-sound-effects

func _ready():
	get_tree().node_added.connect(_on_node_added);
	_connect_buttons(get_tree().root)
	
func _on_node_added(node):
	if node is Button:
		node.connect("pressed", _on_pressed);
		node.connect("mouse_entered", _on_hover);
		
func _connect_buttons(node):
	if node is Button:
		node.connect("pressed", _on_pressed);
		node.connect("mouse_entered", _on_hover);

	for child in node.get_children():
		_connect_buttons(child);
		
func _play_battle_music():
	$BattleMusic.play()
	$BossMusic.stop()
	$ChillMusic.stop()
	
func _play_boss_music():
	$BossMusic.play()
	$BattleMusic.stop()
	$ChillMusic.stop()
func _play_chill_music():
	$ChillMusic.play()
	$BossMusic.stop()
	$BattleMusic.stop()
func _play_slashSFX():
	$SlashSFX.play()

func _play_gunSFX():
	$GunSFX.play()
	

func _play_explosionSFX():
	$ExplosionSFX.play()

func _play_flamethrowerSFX():
	$FlameThrowerSFX.play()

func _play_shockSFX():
	$ShockSFX.play()

func _play_healSFX():
	$HealSFX.play()

func _play_loseSFX():
	$LoseSFX.play()

func _on_pressed():
	$ButtonPressSFX.play()

func _on_hover():
	$ButtonHoverSFX.play()
