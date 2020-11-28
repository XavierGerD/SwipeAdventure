extends Node2D

signal encounter_complete

onready var WorldMapNode = load('res://Scenes/WorldMap/WorldMap.tscn')
onready var CombatNode = load('res://Scenes/Combat/Combat.tscn')
onready var RewardScreenNode = load('res://Scenes/RewardScreen/RewardScreen.tscn')
onready var LosingScreenNode = load('res://Scenes/LosingScreen/LosingScreen.tscn')
onready var SkillTreeNode = load('res://Scenes/SkillTree/SkillTree.tscn')
onready var InventoryNode = load('res://Scenes/Inventory/Inventory.tscn')
onready var ShopNode = load('res://Scenes/Shop/Shop.tscn')

var Player
var WorldMap
var Combat
var RewardScreen
var LosingScreen
var SkillTree
var Inventory
var Shop

var CurrentEncounter

func _ready() -> void:
	Player = InitGame.NewPlayerTemplate.duplicate(true)
	
	SkillTree = SkillTreeNode.instance()
	add_child(SkillTree)
	SkillTree.hide()
	
	Inventory = InventoryNode.instance()
	add_child(Inventory)
	Inventory.hide()

	
	Shop = ShopNode.instance()
	add_child(Shop)
	Shop.hide()
	
	OnWorldMapLoad()
	self.move_child(SkillTree, self.get_child_count())
	
	
func OnWorldMapLoad():
	WorldMap = WorldMapNode.instance()
	WorldMap.connect('load_encounter', self, 'OnEncounterLoad')
	add_child(WorldMap)
	WorldMap.InstanciateWorldMap(Player)
	WorldMap.connect('show_or_hide_skill_tree', self, 'OnShowSkillTree')
	WorldMap.connect('show_or_hide_inventory', self, 'OnShowInventory')
	WorldMap.connect('show_or_hide_shop', self, 'OnShowShop')
	
func OnEncounterLoad(Encounter):
	Combat = CombatNode.instance()
	WorldMap.queue_free()
	add_child(Combat)
	Combat.InstanciateCombat(Player, Encounter.enemies.duplicate(true))
	Combat.connect('game_is_won', self, 'OnGameWin')
	Combat.connect('game_is_lost', self, 'OnGameLose')
	pass

func OnGameWin(EncounterEnemies):
	RewardScreen = RewardScreenNode.instance()
	add_child(RewardScreen)
	RewardScreen.InstanciateRewardScreen(EncounterEnemies)
	RewardScreen.connect("credits_claimed", self, 'OnRewardsClaimed')
	Combat.queue_free()
	emit_signal('encounter_complete')
	
func OnGameLose():
	LosingScreen = LosingScreenNode.instance()
	add_child(LosingScreen)

#This func name will probably change in time
func OnRewardsClaimed(Credits):
	Player.credits += Credits
	RewardScreen.queue_free()
	Shop.SetCreditLabel(Player.credits)
	OnWorldMapLoad()

func GetPlayerCredits():
	return Player.credits
	
func OnShowSkillTree():
	SkillTree.show()
	SkillTree.UpdateUserCreditTotal()
	HideWorldMap()
	self.move_child(SkillTree, self.get_child_count())

func OnShowInventory():
	Inventory.show()
	HideWorldMap()
	self.move_child(Inventory, self.get_child_count())
	
func OnShowShop():
	Shop.show()
	HideWorldMap()
	self.move_child(Shop, self.get_child_count())

func HideWorldMap():
	WorldMap.visible = false
	
func ShowWorldMap():
	WorldMap.visible = true

func AddItemToInventory(Item):
	Player.inventory.push_back(Item)
	Inventory.AddNewIcon(Item)
