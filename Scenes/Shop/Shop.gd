extends Node2D

onready var GameManager = self.get_parent()
onready var ShopButtonNode = load('res://Scenes/Shop/ShopButton.tscn')
onready var CreditsLabel = get_node("CreditsLabel")

func _ready():
	for i in range(Cards.AllItems.size()):
		var Item = Cards.AllItems[i]
		var NewButton = ShopButtonNode.instance()
		add_child(NewButton)
		NewButton.set_position(Vector2(100, 100 * i + 200))
		NewButton.set_text(Item.name + ': '+ str(Item.cost))
		NewButton.InitializeButton(Item)
		SetCreditLabel(GameManager.Player.credits)

func _on_HideButton_pressed() -> void:
	self.visible = false
	GameManager.move_child(self, 0)
	GameManager.ShowWorldMap()

func SetCreditLabel(NewValue):
	CreditsLabel.set_text('Credits: ' + str(NewValue))
