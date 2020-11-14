extends Node2D

signal game_is_won(Enemy)
signal game_is_lost
signal update_health

onready var PlayerHealthLabel = get_node("PlayerHealth")
onready var PlayerEnergyLabel = get_node("PlayerEnergy")
onready var PlayerBlockLabel = get_node("PlayerBlock")
onready var CardName = get_node('CardName')
onready var CardCost = get_node('CardCost')
onready var Description = get_node('Effect')
onready var DiscardPileTotalLabel = get_node("DiscardTotal")
onready var DrawPileTotalLabel = get_node("DrawTotal")
onready var HandTotalLabel = get_node("HandTotal")
onready var WinLoseText = get_node("WinLoseText")

onready var LoadoutManager = load('res://Scenes/LoadoutManager/LoadoutManager.gd')
onready var Card = load('res://Scenes/Card/Card.tscn')
onready var EnemyNode = load('res://Scenes/Enemy/Enemy.tscn')

onready var HandStack = get_node("HandStack")

var IsGameLost = false
var IsGameWon = false

var TopCard

var MaxCardsInHand = 3

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
func _ready() -> void:
	pass # Replace with function body.
	
func InstanciateLoadout(CurrentLoadout):
	var NewDeck = []
	NewDeck += CurrentLoadout.weapon
	NewDeck += CurrentLoadout.shield
	Deck = NewDeck

func InstanciateEnemy(CurrentEnemy, i):
	var NewEnemyNode = EnemyNode.instance()
	add_child(NewEnemyNode)
	NewEnemyNode.set_position(Vector2((i * 175) + 128, 150))
	NewEnemyNode.InstanciateEnemy(CurrentEnemy)
	NewEnemyNode.connect('enemy_selected', self, 'OnSelectEnemy')
	EncounterEnemyNodes.push_back(
		{
			'node': NewEnemyNode,
			'enemyRef': CurrentEnemy,			
		}
	)
	self.connect('update_health', NewEnemyNode, 'OnHealthUpdate')

func InstanciatePlayer(CurrentPlayer):
	Player = CurrentPlayer
	SetPlayerHealth(Player.health)
	SetPlayerEnergy(Player.maxEnergy)
	SetPlayerBlock(Player.block)
	
func InstanciateCombat(CurrentPlayer, CurrentEnemies):
	InstanciatePlayer(CurrentPlayer)
	EncounterEnemies = CurrentEnemies
	for i in range(CurrentEnemies.size()):
		InstanciateEnemy(CurrentEnemies[i], i)
	OnSelectEnemy(EncounterEnemyNodes[0].enemyRef, EncounterEnemyNodes[0].node)
	InstanciateLoadout(CurrentPlayer.loadout)
	PrepareDeck()

func PrepareDeck():
	DrawPile = Deck.duplicate(true) 
	randomize()
	DrawPile.shuffle()
	for i in (MaxCardsInHand):
		Hand.push_back(DrawPile[i])
		DrawPile.pop_front()
	UpdateHand()

#game loop
func _process(_delta):
	if IsGameWon:
		emit_signal("game_is_won", EncounterEnemies)
	if IsGameLost:
		emit_signal("game_is_lost")
			
#setters and getters
func GetPlayerEnergy():
	return Player.energy
	
func SetPlayerEnergy(NewEnergyTotal):
	Player.energy = NewEnergyTotal
	PlayerEnergyLabel.set_text('PWR: ' + str(Player.energy))

func SetPlayerHealth(NewHealthTotal):
	Player.health = NewHealthTotal
	PlayerHealthLabel.set_text('HP: ' + str(Player.health))

func SetPlayerBlock(NewBlockTotal):
	Player.block = NewBlockTotal
	PlayerBlockLabel.set_text('BLK: ' + str(Player.block))

func SetDiscardTotal():
	DiscardPileTotalLabel.set_text('Discard: ' + str(DiscardPile.size()))
	
func SetDrawTotal():
	DrawPileTotalLabel.set_text('Draw: ' + str(DrawPile.size()))
	
func SetHandTotal():
	HandTotalLabel.set_text('Hand: ' + str(Hand.size()))

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
	SetDiscardTotal()
	SetDrawTotal()
	SetHandTotal()
	
func GoToNextCard():
	#Take the top card from your hand and place it in the discard pile
	DiscardPile.push_back(Hand[0])
	#Remove the card from your hand
	Hand.pop_front()
	#Check to see if turn is done
	var IsTurnDone = GetIsTurnDone()
	if IsTurnDone:
		EndTurn()
		return
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
			SetPlayerHealth(Player.health - damage)
			SetPlayerBlock(block)
	
func GetIsTurnDone():
	if (Hand.size() == 0 || Player.energy == 0):
		return true
	return false
	
func BeginTurn():
	TargetEnemy.enemyRef.health = TargetEnemy.enemyRef.health - PendingPlayerToEnemyDamage if TargetEnemy.enemyRef.health - PendingPlayerToEnemyDamage >= 0 else 0
	emit_signal("update_health")
	PendingPlayerToEnemyDamage = 0
	UpdateHand()
	
func EndTurn():
	DealEnemyDamage()
	ConditionallyLoseGame()
	SetPlayerEnergy(Player.maxEnergy)
	DiscardPile += Hand
	Hand = []
	for i in (MaxCardsInHand):
		if DrawPile.size() == 0:
			MoveCardFromDiscardToDrawPile()
		Hand.push_back(DrawPile[0])
		DrawPile.pop_front()
	TopCard.queue_free()
	BeginTurn()

func ContidionallyDestroyEnemies():
	var WasAnEnemyDestroyed = false
	print(TargetEnemy)
	print(EncounterEnemyNodes)
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
		OnSelectEnemy(EncounterEnemyNodes[index].enemyRef, EncounterEnemyNodes[index].node)

func CheckGameWinCondition():
	ContidionallyDestroyEnemies()
	var AreAllEnemiesDead = true
	for Enemy in EncounterEnemyNodes:
		if Enemy.node != null:
			AreAllEnemiesDead = false
	if (AreAllEnemiesDead):
		WinLoseText.set_text("You Win!")
		IsGameWon = true
		return true
	return false
		
func ConditionallyWinGame():
	var IsGameWonThisTurn = CheckGameWinCondition()
	if !IsGameWonThisTurn:
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
		TargetEnemy.enemyRef.health = TargetEnemy.enemyRef.health - CardDamage if TargetEnemy.enemyRef.health - CardDamage >= 0 else 0
		emit_signal("update_health")
	if (CurrentCard.block != null):
		SetPlayerBlock(Player.block + CurrentCard.block)
	if (CurrentCard.heal != null):
		var newPlayerHealth = Player.health + CurrentCard.heal if Player.health + CurrentCard.heal <= Player.maxHealth else Player.maxHealth
		SetPlayerHealth(newPlayerHealth)
	if (CurrentCard.power != null):
		HandleCardPower(CurrentCard)
	SetPlayerEnergy(Player.energy - CurrentCard.cost)
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
			TargetEnemy.enemyRef.health = TargetEnemy.enemyRef.health - CurrentCard.special.damage * LocalDamageModifier if TargetEnemy.enemyRef.health - CurrentCard.special.damage * LocalDamageModifier >= 0 else 0
			emit_signal("update_health")
		if (CurrentCard.special.condition == 'discard'):
			Hand.pop_front()
		if (CurrentCard.special.power == 'pendingDamage'):
			PendingPlayerToEnemyDamage = CurrentCard.special.effect
	SetPlayerEnergy(Player.energy - CurrentCard.cost)
	ConditionallyWinGame()
	pass # Replace with function body.

func HandleCardPower(CurrentCard):
	if (CurrentCard.power == 'doubleDamage'):
		LocalDamageModifier = 2

func GetCardDamage(CurrentCard):
	var Damage = CurrentCard.damage * LocalDamageModifier
	LocalDamageModifier = 1
	return Damage
