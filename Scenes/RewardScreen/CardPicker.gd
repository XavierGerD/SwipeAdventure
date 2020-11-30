extends Node2D

onready var PossibleRewards = Cards.LooseCards
onready var CardPickerModalNode = get_node("CardPickerModal")
onready var CardReward1Node = get_node("CardReward1")
onready var CardReward2Node = get_node("CardReward2")
onready var CardReward3Node = get_node("CardReward3")

onready var CardRewardNodes = [
	CardReward1Node,
	CardReward2Node,
	CardReward3Node
]

onready var CardRewardButton1Node = get_node("CardReward1/CardRewardButton1")
onready var CardRewardButton2Node = get_node("CardReward2/CardRewardButton2")
onready var CardRewardButton3Node = get_node("CardReward3/CardRewardButton3")

onready var CardRewardButtonNodes = [
	CardRewardButton1Node,
	CardRewardButton2Node,
	CardRewardButton3Node
]

var RandomIndices = []

func GetNewRewards():
# warning-ignore:unused_variable
	for i in range(CardRewardButtonNodes.size()):
		GetRandomNumber(RandomIndices)
	for i in range(RandomIndices.size()):
		var Index = RandomIndices[i]
		var Card = PossibleRewards[Index]
		CardRewardNodes[i].InstanciateCard(
			Card,
			CardRewardNodes[i].get_position().x,
			CardRewardNodes[i].get_position().y,
			false,
			false,
			Card.texturePath
		)
	CardPickerModalNode.connect('card_picked', self, 'OnCardPicked')
		
func GetRandomNumber(RandomNumbers):
	randomize()
	var RandomNumber = randi()%PossibleRewards.size()
	if RandomNumbers.find(RandomNumber) == -1:
		RandomNumbers.push_back(RandomNumber)
	else:
		GetRandomNumber(RandomNumbers)

func _on_CardRewardButton_pressed(Index) -> void:
	CardPickerModalNode.visible = true
	CardPickerModalNode.UpdateModal(PossibleRewards[RandomIndices[Index]])

func OnCardPicked():
	for CardButton in CardRewardButtonNodes:
		CardButton.disabled = true
	for CardNode in CardRewardNodes:
		CardNode.modulate = '#b6b6b6'
	RandomIndices = []
