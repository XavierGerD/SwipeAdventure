extends Node2D

signal load_encounter(Encounter)
signal show_or_hide_skill_tree

var EmptyEncounter = load('res://Scenes/WorldMap/Encounter.tscn')
onready var CreditTotalLabel = get_node("CreditTotalLabel")

func _ready() -> void:
	for i in range(Encounters.LevelOneEncounters.size()):
		var NewEncounter = EmptyEncounter.instance()
		add_child(NewEncounter)
		NewEncounter.position = Vector2(i * 100, i * 200)
		NewEncounter.InstanciateEncounter(Encounters.LevelOneEncounters[i])
		NewEncounter.connect('encounter_chosen', self, 'LoadEncounter')

func InstanciateWorldMap(Player):
	CreditTotalLabel.set_text('Credits: ' + str(Player.credits))

func LoadEncounter(Encounter):
	emit_signal("load_encounter", Encounter)

func _on_SkillTreeButton_pressed() -> void:
	emit_signal('show_or_hide_skill_tree')
	pass
