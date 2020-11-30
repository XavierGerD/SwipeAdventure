extends Node2D

onready var WorldMapNode = load('res://Scenes/WorldMap/WorldMap.tscn')
onready var CombatNode = load('res://Scenes/Combat/Combat.tscn')
onready var RewardScreenNode = load('res://Scenes/RewardScreen/RewardScreen.tscn')
onready var LosingScreenNode = load('res://Scenes/LosingScreen/LosingScreen.tscn')
onready var SkillTreeNode = load('res://Scenes/SkillTree/SkillTree.tscn')
onready var InventoryNode = load('res://Scenes/Inventory/Inventory.tscn')
onready var ShopNode = load('res://Scenes/Shop/Shop.tscn')
onready var WinScreenNode = load('res://Scenes/Win Screen/WinScreen.tscn')

var Player
var WorldMap
var Combat
var RewardScreen
var LosingScreen
var SkillTree
var Inventory
var Shop
var WinScreen

var CurrentEncounter

func StartNewGame():
	print("starting new game")
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
	
func _ready() -> void:
	StartNewGame()

func OnWorldMapLoad():
	WorldMap = WorldMapNode.instance()
	WorldMap.connect('load_encounter', self, 'OnEncounterLoad')
	add_child(WorldMap)
	WorldMap.InstanciateWorldMap(Player, self)
	WorldMap.connect('show_or_hide_skill_tree', self, 'OnShowSkillTree')
	WorldMap.connect('show_or_hide_inventory', self, 'OnShowInventory')
	WorldMap.connect('show_or_hide_shop', self, 'OnShowShop')
	WorldMap.connect('boss_defeated', self, 'OnBossDefeated')
	
func OnEncounterLoad(Encounter, EncounterNode):
	$ButtonsAudioPlayer.stream = load("res://Sound/SFX/Combat.wav")
	$ButtonsAudioPlayer.play()
	Combat = CombatNode.instance()
	add_child(Combat)
	Combat.InstanciateCombat(Player, Encounter.enemies.duplicate(true))
	Combat.connect('game_is_won', self, 'OnGameWin')
	Combat.connect('game_is_lost', self, 'OnGameLose')
	CurrentEncounter = EncounterNode

func OnGameWin(EncounterEnemies):
	CurrentEncounter.OnCompleteEncounter()
	RewardScreen = RewardScreenNode.instance()
	add_child(RewardScreen)
	RewardScreen.InstanciateRewardScreen(EncounterEnemies)
	RewardScreen.connect("credits_claimed", self, 'OnRewardsClaimed')
	Combat.queue_free()
	
func OnGameLose():
	LosingScreen = LosingScreenNode.instance()
	add_child(LosingScreen)
	Combat.queue_free()

#This func name will probably change in time
func OnRewardsClaimed(Credits):
	$ButtonsAudioPlayer.stream = load("res://Sound/SFX/Click.wav")
	$ButtonsAudioPlayer.play()
	Player.credits += Credits
	RewardScreen.queue_free()
	Shop.SetCreditLabel(Player.credits)
	WorldMap.SetCreditLabel(Player.credits)
	WorldMap.SetHealthLabel(Player.health, Player.maxHealth)

func GetPlayerCredits():
	return Player.credits
	
func OnShowSkillTree():
	$ButtonsAudioPlayer.stream = load("res://Sound/SFX/Click.wav")
	$ButtonsAudioPlayer.play()
	SkillTree.show()
	SkillTree.UpdateUserCreditTotal()
	HideWorldMap()
	self.move_child(SkillTree, self.get_child_count())

func OnShowInventory():
	$ButtonsAudioPlayer.stream = load("res://Sound/SFX/Click.wav")
	$ButtonsAudioPlayer.play()
	Inventory.show()
	HideWorldMap()
	self.move_child(Inventory, self.get_child_count())
	
func OnShowShop():
	$ButtonsAudioPlayer.stream = load("res://Sound/SFX/Click.wav")
	$ButtonsAudioPlayer.play()
	Shop.show()
	HideWorldMap()
	self.move_child(Shop, self.get_child_count())
	
func OnBossDefeated():
	WinScreen = WinScreenNode.instance()
	add_child(WinScreen)

func HideWorldMap():
	WorldMap.visible = false
	
func ShowWorldMap():
	$ButtonsAudioPlayer.stream = load("res://Sound/SFX/Click.wav")
	$ButtonsAudioPlayer.play()
	WorldMap.visible = true

func AddItemToInventory(Item):
	Player.inventory.push_back(Item)
	Inventory.AddNewIcon(Item)
