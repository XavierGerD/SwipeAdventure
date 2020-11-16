extends Node2D

onready var PlayerHealthLabel = get_node("PlayerHealth")
onready var PlayerEnergyLabel = get_node("PlayerEnergy")
onready var PlayerBlockLabel = get_node("PlayerBlock")
onready var EnemyNameLabel = get_node("MonsterName")
onready var EnemyHealthLabel = get_node("MonsterEnergy")
onready var CardName = get_node('CardName')
onready var CardCost = get_node('CardCost')
onready var Description = get_node('Effect')
onready var DiscardPileTotalLabel = get_node("DiscardTotal")
onready var DrawPileTotalLabel = get_node("DrawTotal")
onready var HandTotalLabel = get_node("HandTotal")
onready var WinLoseText = get_node("WinLoseText")

onready var LoadoutManager = load('res://Scenes/LoadoutManager/LoadoutManager.gd')

onready var Card = load('res://Scenes/Card/Card.tscn')

onready var HandStack = get_node("HandStack")

onready var RewardScreen = load('res://Scenes/RewardScreen/RewardScreen.tscn')
onready var LosingScreen = load('res://Scenes/LosingScreen/LosingScreen.tscn')

var IsGameLost = false
var IsGameWon = false

var TopCard

var EncounterEnemies
var EncounterEnemyNodes = []
var TargetEnemy

var CurrentLoadoutManager
var Player
var Deck
var Hand = []
var DrawPile = []
var DiscardPile = []
var LocalDamageModifier = 1
var PendingPlayerToEnemyDamage = 0

#init functions
func InstanciateLoadout(CurrentLoadout):
	var NewDeck = []
	NewDeck += CurrentLoadout.weapon
	NewDeck += CurrentLoadout.shield
	Deck = NewDeck

func InstanciateEnemy(CurrentEnemies):
	for Enemy in CurrentEnemies:
		

func InstanciatePlayer(CurrentPlayer):
	Player = CurrentPlayer
	SetGetUtils.SetPlayerHealth(PlayerHealthLabel, Player, Player.health)
	SetGetUtils.SetPlayerEnergy(PlayerEnergyLabel, Player, Player.maxEnergy)
	SetGetUtils.SetPlayerBlock(PlayerBlockLabel, Player, Player.block)
	

func InstanciateCombat(CurrentPlayer, CurrentEnemies):
	InstanciatePlayer(CurrentPlayer)
	InstanciateEnemies(CurrentEnemies)
	InstanciateLoadout(CurrentPlayer.loadout)
	PrepareDeck()

func PrepareDeck():
	DrawPile = Deck.duplicate() 
	randomize()
	DrawPile.shuffle()
	for i in (Player.maxCardsInHand):
		Hand.push_back(DrawPile[i])
		DrawPile.pop_front()
	UpdateHand()

#getters
func GetPlayerEnergy():
	return Player.energy

#game loop
func _process(_delta):
	if IsGameWon:
		var NewRewardScreen = RewardScreen.instance()
		get_parent().add_child(NewRewardScreen)
		NewRewardScreen.InstanciateRewardScreen([Enemy])
		self.queue_free()
	if IsGameLost:
		get_parent().add_child(LosingScreen.instance())
		self.queue_free()
			
#setters and getters
func OnSelectEnemy(SelectedEnemy, EnemyNode):
	for EnemyNode in EncounterEnemyNodes:
		if EnemyNode.node != null:
			EnemyNode.node.OnDeselect()
	EnemyNode.OnSelect()
	TargetEnemy = { 
		'node': EnemyNode,
		'enemyRef': SelectedEnemy, 
	}

#card methods
func DisplayCard(card):
	var NewCard = Card.instance()
	add_child(NewCard)
	NewCard.connect('card_action', self, 'OnAction')
	NewCard.connect('card_skip', self, 'OnSkip')
	NewCard.connect('card_special', self, 'OnSpecial')
	NewCard.connect('card_pressed', HandStack, "OnCardPressed")
	NewCard.connect('card_released', HandStack, "OnCardReleased")
	NewCard.InstanciateCard(
		card,
		Constants.CARD_STARTING_POSITION_X,
		Constants.CARD_STARTING_POSITION_Y,
		card.special != null,
		true,
		card.texturePath,
		LocalDamageModifier
	)
	TopCard = NewCard
	

func UpdateHand():
	if TopCard:
		TopCard.queue_free()
	DisplayCard(Hand[0])
	SetGetUtils.SetDiscardTotal(DiscardPileTotalLabel, DiscardPile.size())
	SetGetUtils.SetDrawTotal(DrawPileTotalLabel, DrawPile.size())
	SetGetUtils.SetHandTotal(HandTotalLabel, Hand.size())
	
func GoToNextCard():
	#Take the top card from your hand and place it in the discard pile
	DiscardPile.push_back(Hand[0])
	#Remove the card from your hand
	Hand.pop_front()
	#Check to see if turn is done
	var IsTurnDone = GetIsTurnDone()
	if IsTurnDone:
		print('turn is done')
		EndTurn()
		return
	print('turn is not done')
	UpdateHand()
	
func MoveCardFromDiscardToDrawPile():
	DrawPile += DiscardPile
	DiscardPile = []
	randomize()
	DrawPile.shuffle()
	TopCard.queue_free()

#game logic
func DealEnemyDamage():
	for Enemy in EncounterEnemyNodes:
		if Enemy.node != null:	
			var damage = Enemy.enemyRef.baseDamage - Player.block if Enemy.enemyRef.baseDamage - Player.block > 0 else 0
			var block = Player.block - Enemy.enemyRef.baseDamage if Player.block - Enemy.enemyRef.baseDamage > 0 else 0
			SetGetUtils.SetPlayerHealth(PlayerHealthLabel, Player, Player.health - damage)
			SetGetUtils.SetPlayerBlock(PlayerBlockLabel, Player, block)
	
func GetIsTurnDone():
	if (Hand.size() == 0 || Player.energy == 0):
		return true
	return false
	
func BeginTurn():
	print('beginning turn', PendingPlayerToEnemyDamage)
	var newEnemyHealth = Enemy.health - PendingPlayerToEnemyDamage if Enemy.health - PendingPlayerToEnemyDamage >= 0 else 0
	SetEnemyHealth(newEnemyHealth)
	PendingPlayerToEnemyDamage = 0
	UpdateHand()
	
func EndTurn():
	DealEnemyDamage()
	ConditionallyLoseGame()
	SetGetUtils.SetPlayerEnergy(PlayerEnergyLabel, Player, Player.maxEnergy)
	DiscardPile += Hand
	Hand = []
	for i in (Player.maxCardsInHand):
		if DrawPile.size() == 0:
			MoveCardFromDiscardToDrawPile()
		Hand.push_back(DrawPile[0])
		DrawPile.pop_front()
	TopCard.queue_free()
	BeginTurn()

func ContidionallyDestroyEnemies():
	var WasAnEnemyDestroyed = false
	#There HAS to be a better way to do this......
	for i in range(EncounterEnemyNodes.size()):
		if EncounterEnemyNodes[i].enemyRef.health == 0:
			if (EncounterEnemyNodes[i].node != null):
				EncounterEnemyNodes[i].node.queue_free()
				EncounterEnemyNodes[i].node = null
				WasAnEnemyDestroyed = true
	if WasAnEnemyDestroyed:
		var index = -1
		for i in range(EncounterEnemyNodes.size()):
			if (EncounterEnemyNodes[i].enemyRef.health > 0  && index == -1):
				index = i
		if EncounterEnemyNodes[index].node:
			OnSelectEnemy(EncounterEnemyNodes[index].enemyRef, EncounterEnemyNodes[index].node)

func CheckGameWinCondition():
	if (Enemy.health <= 0):
		WinLoseText.set_text("You Win!")
		IsGameWon = true
		return true
	return false
		
func ConditionallyWinGame():
	var IsGameWon = CheckGameWinCondition()
	if !IsGameWon:
		GoToNextCard()
	
func ConditionallyLoseGame():
	if (Player.health <= 0):
		WinLoseText.set_text("You Lose!")
		IsGameLost = true
		return

#player actions
func OnAction():
	if IsGameLost:
		return
	var CurrentCard = Hand[0]
	if (CurrentCard.damage != null):
		var CardDamage = GetCardDamage(CurrentCard)
		var newEnemyHealth = Enemy.health - CardDamage if  Enemy.health - CardDamage >= 0 else 0
		SetEnemyHealth(newEnemyHealth)
	if (CurrentCard.block != null):
		SetGetUtils.SetPlayerBlock(PlayerBlockLabel, Player, Player.block + CurrentCard.block)
	if (CurrentCard.heal != null):
		var newPlayerHealth = Player.health + CurrentCard.heal if Player.health + CurrentCard.heal <= Player.maxHealth else Player.maxHealth
		SetGetUtils.SetPlayerHealth(PlayerHealthLabel, Player, newPlayerHealth)
	if (CurrentCard.power != null):
		HandleCardPower(CurrentCard)
	SetGetUtils.SetPlayerEnergy(PlayerEnergyLabel, Player, Player.energy - CurrentCard.cost)
	ConditionallyWinGame()

func OnSkip() -> void:
	if IsGameLost:
		return
	GoToNextCard()

func OnSpecial() -> void:
	if IsGameLost:
		return
	var CurrentCard = Hand[0]
	if CurrentCard.special:
		if (CurrentCard.special.damage != null):
			SetEnemyHealth(Enemy.health - (CurrentCard.special.damage * LocalDamageModifier))
		if (CurrentCard.special.condition == 'discard'):
			Hand.pop_front()
		if (CurrentCard.special.power == 'pendingDamage'):
			PendingPlayerToEnemyDamage = CurrentCard.special.effect
	SetGetUtils.SetPlayerEnergy(PlayerEnergyLabel, Player, Player.energy - CurrentCard.cost)
	ConditionallyWinGame()
	pass # Replace with function body.

func HandleCardPower(CurrentCard):
	if (CurrentCard.power == 'doubleDamage'):
		LocalDamageModifier = 2 if LocalDamageModifier == 1 else LocalDamageModifier + 2

func GetCardDamage(CurrentCard):
	var Damage = CurrentCard.damage * LocalDamageModifier
	LocalDamageModifier = 1
	return Damage
