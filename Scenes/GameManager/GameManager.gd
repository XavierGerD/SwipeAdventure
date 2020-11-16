extends Node2D

onready var WorldMapNode = load('res://Scenes/WorldMap/WorldMap.tscn')
onready var CombatNode = load('res://Scenes/Combat/Combat.tscn')
onready var RewardScreenNode = load('res://Scenes/RewardScreen/RewardScreen.tscn')
onready var LosingScreenNode = load('res://Scenes/LosingScreen/LosingScreen.tscn')
onready var SkillTreeNode = load('res://Scenes/SkillTree/SkillTree.tscn')

var Player
var WorldMap
var Combat
var RewardScreen
var LosingScreen
var SkillTree

func _ready() -> void:
	Player = InitGame.NewPlayerTemplate.duplicate(true)
	SkillTree = SkillTreeNode.instance()
	add_child(SkillTree)
	SkillTree.hide()
	OnWorldMapLoad()
	self.move_child(SkillTree, self.get_child_count())
	
	
func OnWorldMapLoad():
	WorldMap = WorldMapNode.instance()
	WorldMap.connect('load_encounter', self, 'OnEncounterLoad')
	add_child(WorldMap)
	WorldMap.InstanciateWorldMap(Player)
	WorldMap.connect('show_or_hide_skill_tree', self, 'OnShowSkillTree')
	
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
	
func OnGameLose():
	LosingScreen = LosingScreenNode.instance()
	add_child(LosingScreen)

#This func name will probably change in time
func OnRewardsClaimed(Credits):
	Player.credits += Credits
	RewardScreen.queue_free()	
	OnWorldMapLoad()

func GetPlayerCredits():
	return Player.credits
	
func OnShowSkillTree():
	SkillTree.show()
	SkillTree.UpdateUserCreditTotal()
	HideWorldMap()
	self.move_child(SkillTree, self.get_child_count())

func HideWorldMap():
	WorldMap.visible = false
	
func ShowWorldMap():
	WorldMap.visible = true
