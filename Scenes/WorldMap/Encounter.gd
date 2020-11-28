extends Node2D

signal encounter_chosen(Encounter)

onready var EncounterButton = get_node("TextureButton")
onready var EncounterLabel = get_node("EncounterNameLabel")
onready var XMarksTheSpot = get_node("XMarksTheSpot")

var CurrentEncounter

func InstanciateEncounter(Encounter):
	CurrentEncounter = Encounter
	EncounterLabel.bbcode_text = '[center]' + Encounter.name + '[/center]'
# warning-ignore:return_value_discarded
	get_node('/root/GameManager').connect('encounter_complete', self, 'OnCompleteEncounter')
	#like, seriously, don't do this
	if Encounter.name == "Argon Moon":
		EncounterButton.set_normal_texture(load('res://Sprite/WorldMap/Moon.png'))
		EncounterButton.set_click_mask(load('res://Sprite/WorldMap/Moon_mask.png'))
	if Encounter.name == "Space Station":
		EncounterButton.set_normal_texture(load('res://Sprite/WorldMap/SpaceStation.png'))
		EncounterButton.set_click_mask(load('res://Sprite/WorldMap/SpaceStationMask.png'))

func _on_TextureButton_pressed() -> void:
	emit_signal("encounter_chosen", CurrentEncounter)

func OnCompleteEncounter():
	print('done')
	XMarksTheSpot.visible = true
	EncounterButton.disabled = true
