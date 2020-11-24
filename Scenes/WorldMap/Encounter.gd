extends Node2D

signal encounter_chosen(Encounter)

onready var EncounterButton = get_node("TextureButton")
onready var EncounterLabel = get_node("EncounterNameLabel")

var CurrentEncounter

func InstanciateEncounter(Encounter):
	CurrentEncounter = Encounter
	EncounterLabel.bbcode_text = '[center]' + Encounter.name + '[/center]'
	#like, seriously, don't do this
	if Encounter.name == "Argon Moon":
		EncounterButton.set_normal_texture(load('res://Sprite/WorldMap/Moon.png'))
		EncounterButton.set_click_mask(load('res://Sprite/WorldMap/Moon_mask.png'))
	if Encounter.name == "Space Station":
		EncounterButton.set_normal_texture(load('res://Sprite/WorldMap/SpaceStation.png'))
		EncounterButton.set_click_mask(load('res://Sprite/WorldMap/SpaceStationMask.png'))
		
	pass

func _on_TextureButton_pressed() -> void:
	emit_signal("encounter_chosen", CurrentEncounter)
	pass # Replace with function body.
