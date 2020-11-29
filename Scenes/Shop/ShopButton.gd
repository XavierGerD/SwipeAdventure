extends Button

var Item
onready var GameManager = self.get_parent().get_parent()

func InitializeButton(ItemObject):
	Item = ItemObject

func _on_ShopButton_pressed() -> void:
	var PlayerCredits = GameManager.Player.credits
	if PlayerCredits >= Item.cost:
		GameManager.Player.inventory.push_back(Item)
		GameManager.Player.credits = GameManager.Player.credits - Item.cost
		GameManager.AddItemToInventory(Item)
