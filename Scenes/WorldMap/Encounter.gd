extends Node2D

signal encounter_chosen(Encounter, EncouterNode)
signal boss_defeated

onready var EncounterButton = get_node("TextureButton")
onready var EncounterLabel = get_node("EncounterNameLabel")
onready var XMarksTheSpot = get_node("XMarksTheSpot")

var CurrentEncounter
onready var WorldMap = get_node("/root/GameManager/WorldMap")

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

func _on_TextureButton_pressed() -> void:
	emit_signal("encounter_chosen", CurrentEncounter, self)

func OnCompleteEncounter():
	WorldMap.EncouterCounter += 1
	WorldMap.ConditionnallyCompleteQuadrant()
	XMarksTheSpot.visible = true
	EncounterButton.disabled = true
	if CurrentEncounter.name == 'Argon Moon':
		emit_signal("boss_defeated")
