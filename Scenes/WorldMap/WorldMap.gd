extends Node2D

signal load_encounter(Encounter)
signal show_or_hide_skill_tree
signal show_or_hide_inventory

var EmptyEncounter = load('res://Scenes/WorldMap/Encounter.tscn')
onready var QuadrantOneEncounterOne = get_node("QuadrantOne/QuandrantOneEncounterOne")
onready var QuadrantOneEncounterTwo = get_node("QuadrantOne/QuandrantOneEncounterTwo")
onready var QuadrantOneEncounterThree = get_node("QuadrantOne/QuandrantOneEncounterThree")
onready var QuadrantOneEncounterFour = get_node("QuadrantOne/QuandrantOneEncounterFour")
onready var QuadrantOneEncounterFive = get_node("QuadrantOne/QuandrantOneEncounterFive")
onready var QuadrantOneEncounterSix = get_node("QuadrantOne/QuandrantOneEncounterSix")
onready var QuadrantOneEncounterSeven = get_node("QuadrantOne/QuandrantOneEncounterSeven")
onready var QuadrantOneEncounterEight = get_node("QuadrantOne/QuandrantOneEncounterEight")
onready var QuadrantOneEncounterNodes = [
	QuadrantOneEncounterOne,
	QuadrantOneEncounterTwo,
	QuadrantOneEncounterThree,
	QuadrantOneEncounterFour,
	QuadrantOneEncounterFive,
	QuadrantOneEncounterSix,
	QuadrantOneEncounterSeven,
	QuadrantOneEncounterEight
]

onready var QuadrantTwoEncounterOne = get_node("QuadrantTwo/QuandrantTwoEncounterOne")
onready var QuadrantTwoEncounterTwo = get_node("QuadrantTwo/QuandrantTwoEncounterTwo")
onready var QuadrantTwoEncounterThree = get_node("QuadrantTwo/QuandrantTwoEncounterThree")
onready var QuadrantTwoEncounterFour = get_node("QuadrantTwo/QuandrantTwoEncounterFour")
onready var QuadrantTwoEncounterFive = get_node("QuadrantTwo/QuandrantTwoEncounterFive")
onready var QuadrantTwoEncounterNodes = [
	QuadrantTwoEncounterOne,
	QuadrantTwoEncounterTwo,
	QuadrantTwoEncounterThree,
	QuadrantTwoEncounterFour,
	QuadrantTwoEncounterFive
]

onready var QuandrantThreeEncounterOne = get_node("QuandrantThreeEncounterOne")

onready var QuadrantThreeEncounterNodes = [
	QuandrantThreeEncounterOne
]

onready var AllEncounterNodes = [QuadrantOneEncounterNodes, QuadrantTwoEncounterNodes, QuadrantThreeEncounterNodes]
onready var CreditTotalLabel = get_node("CreditTotalLabel")

func FindNodeForEncounter(EncounterNodes, NewEncounter):
	randomize()
	var EncounterIndex = randi()%EncounterNodes.size()
	var EncounterNode = EncounterNodes[EncounterIndex]
	if EncounterNode.get_child_count() != 0:
		return FindNodeForEncounter(EncounterNodes, NewEncounter)
	EncounterNode.add_child(NewEncounter)
	return

func CreateEncountersByQuadrant(EncounterSet, EncounterNodes):
	for i in range(EncounterSet.size()):
		var NewEncounter = EmptyEncounter.instance()
		FindNodeForEncounter(EncounterNodes, NewEncounter)
		NewEncounter.InstanciateEncounter(EncounterSet[i])
		NewEncounter.connect('encounter_chosen', self, 'LoadEncounter')

func _ready() -> void:
	for i in range(Encounters.AllEncounters.size()):
		CreateEncountersByQuadrant(Encounters.AllEncounters[i], AllEncounterNodes[i])
	
func InstanciateWorldMap(Player):
	CreditTotalLabel.set_text('Credits: ' + str(Player.credits))

func LoadEncounter(Encounter):
	emit_signal("load_encounter", Encounter)

func _on_SkillTreeButton_pressed() -> void:
	emit_signal('show_or_hide_skill_tree')
	pass

func _on_InventoryButton_pressed() -> void:
	emit_signal('show_or_hide_inventory')
	pass # Replace with function body.
