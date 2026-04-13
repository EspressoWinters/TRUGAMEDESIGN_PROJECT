extends Node

#welcome to my mess of code!

const SAVE_PATH = "user://party_save_data.tres"
const MAX_MEMBERS = 6

#this path to the Grid resource so the Manager can hand it to new Units. I realized we probably could have just stuck it on in the unit scene instead of doing this, but i already did this and it works :/
const GRID_RES = preload("res://Entities/GameBoard/Grid.tres")

#this is the active array the UI and GameBoard
var active_party: Array[Unit_Interaction] = []

func _ready() -> void:
	load_party()

## Attempts to load existing party; if none exists, creates the starter trio.
func load_party() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var save_res = ResourceLoader.load(SAVE_PATH) as PartySaveData
		if save_res:
			active_party = save_res.members
			return
	
	setup_starter_party()

#starts the party with the mandatory Tank Musketeer and Healer
func setup_starter_party() -> void:
	active_party.clear()
	
	var starter_paths = [
		"res://Resources/Classes/Tank/Class_Tank.tres",
		"res://Resources/Classes/Musketeer/Musketeer.tres",
		"res://Resources/Classes/Medic/Medic.tres"
	]
	
	for path in starter_paths:
		var res = load(path) as Unit_Interaction
		if res:
			#duplicate() to ensures each unit has unique current_health instances
			active_party.append(res.duplicate())
	
	save_party()

#saves the current active_party array to the user directory
func save_party() -> void:
	var save_data = PartySaveData.new()
	save_data.members = active_party
	var result = ResourceSaver.save(save_data, SAVE_PATH)
	if result != OK:
		push_error("PartyManager: Failed to save party data!")

#hiring function to add new units
func hire_unit(class_template: Unit_Interaction) -> bool:
	if active_party.size() < MAX_MEMBERS:
		active_party.append(class_template.duplicate())
		save_party()
		return true
	
	print("Party is full! Max 6 members allowed.")
	return false

#removing function to remove units
func fire_unit(index: int) -> void:
	if index >= 0 and index < active_party.size():
		active_party.remove_at(index)
		save_party()

#checks if hiring is possible
func can_hire() -> bool:
	return active_party.size() < MAX_MEMBERS

#clears the save file just incase we need it for something probably won't end up using it
func reset_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		# Delete the file
		DirAccess.remove_absolute(SAVE_PATH)
		setup_starter_party()

#file directories to each resource there was probably a better way to do this
@export var class_library: Array[Unit_Interaction] = [
	preload("res://Resources/Classes/Tank/Class_Tank.tres"),
	preload("res://Resources/Classes/Musketeer/Musketeer.tres"),
	preload("res://Resources/Classes/Medic/Medic.tres"),
	preload("res://Resources/Classes/Grenadier/Grenadier_Resource.tres"),
	preload("res://Resources/Classes/Flamethrower/FlameThrower.tres")
]

var available_to_hire: Array[Unit_Interaction] = []

#this generates 3 new heroes to hire from yay!
func refresh_hiring_pool() -> void:
	available_to_hire.clear()
	var temp_pool = class_library.duplicate()
	temp_pool.shuffle()
	
	for i in range(3):
		if temp_pool.size() > i:
			available_to_hire.append(temp_pool[i])
