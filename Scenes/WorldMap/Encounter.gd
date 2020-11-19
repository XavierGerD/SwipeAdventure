extends Node2D

signal encounter_chosen(Encounter)

onready var EncounterLabel = get_node("EncounterNameLabel")

var CurrentEncounter

func InstanciateEncounter(Encounter):
	CurrentEncounter = Encounter
	EncounterLabel.set_text(Encounter.name)
	pass

func _on_TextureButton_pressed() -> void:
	emit_signal("encounter_chosen", CurrentEncounter)
	pass # Replace with function body.
