extends Button

var Item
onready var GameManager = self.get_parent().get_parent()
onready var UserCreditsTotalLabelNode = get_parent().get_node("CreditsLabel")

func InitializeButton(ItemObject):
	Item = ItemObject

func _on_ShopButton_pressed() -> void:
	$AudioPlayer.stream = load("res://Sound/SFX/BuyWeapon.wav")
	$AudioPlayer.play()
	var PlayerCredits = GameManager.Player.credits
	if PlayerCredits >= Item.cost:
		GameManager.Player.inventory.push_back(Item)
		GameManager.Player.credits = GameManager.Player.credits - Item.cost
		UserCreditsTotalLabelNode.set_text('Credits: ' + str(GameManager.Player.credits))
		var world_map = GameManager.get_node("WorldMap")
		if world_map: GameManager.get_node("WorldMap").SetCreditLabel(GameManager.Player.credits)
		GameManager.AddItemToInventory(Item)
