extends Node2D

var totalOxygen = 5
var inventory = []

onready var gameText = get_node("GameText")
onready var actionText = get_node("ActionText")
onready var oxygenBar = get_node("OxygenBar")
onready var itemsText = get_node("ItemList")


var encounters2firstEncounter = {
	gameText = "Air rushes out of the sealed doors. A heavy toolbox hits you. You lose a salvaged object.",
	actionText = "Okay",
	action = "LoseObject"
}

var encounters2secondEncounter = {
	gameText = "In the room past the door, you see a corpse floating. You search it. It had a portable welding torch.",
	actionText = "Take the torch?",
	item = "Welding torch"
}

var encounters2thirdEncounter = {
	gameText = "You search the room but find nothing of interest.",
	actionText = "Okay",
}

var firstEncounter = {
	gameText = "The ship's dark hull engulfs you. A light hum of static fills your headset. You begin to search.",
	actionText = "Keep exploring"
}
var secondEncounter = {
	gameText = "In the cold darkness, you spot a blinking LED. As you get closer, you realize it's a radio emitter. It looks in good condition.",
	actionText = "Take the emitter?",
	item = "Radio emitter"
}
var thirdEncounter = {
	gameText = "To your left, sealing doors are shut. The control panel still looks in working condition.",
	actionText = "Open the doors?",
	newStoryLine = [encounters2firstEncounter, encounters2secondEncounter, encounters2thirdEncounter]
}
var fourthEncounter = {
	gameText = "In the cold darkness, you spot a blinking LED. As you get closer, you realize it's a radio emitter. It looks in good condition.",
	actionText = "Do you take it?",
	item = "Radio emitter"
}
var fifthEncounter = {
	gameText = "In the cold darkness, you spot a blinking LED. As you get closer, you realize it's a radio emitter. It looks in good condition.",
	actionText = "Do you take it?",
	item = "Radio emitter"
}

var encounters = [firstEncounter, secondEncounter, thirdEncounter, fourthEncounter, fifthEncounter]

var index = 0
var currentEncounter = encounters[index]


func _ready():
	oxygenBar.value = totalOxygen
	oxygenBar.max_value = totalOxygen
	gameText.text = currentEncounter.gameText
	actionText.text = currentEncounter.actionText
	drawItemList()

func drawItemList():
	var inventoryText = ""
	for item in inventory:
		inventoryText = inventoryText + " " + item
	itemsText.text = "Items: " + inventoryText

func loseObject():
	inventory.pop_back()
	drawItemList()

func goToNext():
	totalOxygen -= 1
	oxygenBar.value = totalOxygen
	index += 1
	if index < encounters.size():
		currentEncounter = encounters[index]
		gameText.text = encounters[index].gameText
		actionText.text = encounters[index].actionText
	else:
		gameText.text = "You return to your ship"
		actionText.text = "Collect loot"
	
func switchEncounterLine(newEncounter):
	encounters = newEncounter
	index = 0
	currentEncounter = encounters[index]

func _on_Skip_pressed():
	goToNext()
	pass # Replace with function body.


func _on_Match_pressed():
	if "item" in currentEncounter:
		inventory.push_back(currentEncounter.item)
		drawItemList()
	if "newStoryLine" in currentEncounter:
		switchEncounterLine(currentEncounter.newStoryLine)
	if "action" in currentEncounter:
		if currentEncounter.action == "LoseObject":
			loseObject()
	goToNext()
	pass # Replace with function body.
