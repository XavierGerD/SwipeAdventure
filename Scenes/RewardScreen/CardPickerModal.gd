extends Node2D

signal card_picked

onready var CardNode = get_node("Card")
onready var GameManager = get_node('/root/GameManager')

var CurrentCard

func UpdateModal(Card):
	CardNode.InstanciateCard(
		Card,
		CardNode.get_position().x,
		CardNode.get_position().y,
		false,
		false,
		Card.texturePath
	)
	CurrentCard = Card


func _on_CancelButton_pressed() -> void:
	self.visible = false


func _on_ClaimButton_pressed() -> void:
	GameManager.Player.looseCards.push_back(CurrentCard)
	self.visible = false
	emit_signal('card_picked')
