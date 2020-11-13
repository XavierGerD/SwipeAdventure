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

var MaxCardsInHand = 3

var Enemy

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
	InstanciateCombat(InitGame.NewPlayerTemplate.duplicate(), Enemies.SlaveWatcher)
	pass # Replace with function body.
	
func InstanciateLoadout(CurrentLoadout):
	var NewDeck = []
	NewDeck += CurrentLoadout.weapon
	NewDeck += CurrentLoadout.shield
	Deck = NewDeck

func InstanciateEnemy(CurrentEnemy):
	Enemy = CurrentEnemy
	EnemyNameLabel.set_text('Enemy: ' + Enemy.name)
	SetEnemyHealth(Enemy.health)

func InstanciatePlayer(CurrentPlayer):
	Player = CurrentPlayer
	SetPlayerHealth(Player.health)
	SetPlayerEnergy(Player.maxEnergy)
	SetPlayerBlock(Player.block)
	

func InstanciateCombat(CurrentPlayer, CurrentEnemy):
	InstanciatePlayer(CurrentPlayer)
	InstanciateEnemy(CurrentEnemy)
	InstanciateLoadout(CurrentPlayer.loadout)
	PrepareDeck()

func PrepareDeck():
	DrawPile = Deck.duplicate() 
	randomize()
	DrawPile.shuffle()
	for i in (MaxCardsInHand):
		Hand.push_back(DrawPile[i])
		DrawPile.pop_front()
	UpdateHand()

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
func GetPlayerEnergy():
	return Player.energy
	
func SetEnemyHealth(NewHealthTotal):
	Enemy.health = NewHealthTotal
	EnemyHealthLabel.set_text(str(Enemy.health))

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
	var damage = Enemy.baseDamage - Player.block if Enemy.baseDamage - Player.block > 0 else 0
	var block = Player.block - Enemy.baseDamage if Player.block - Enemy.baseDamage > 0 else 0
	SetPlayerHealth(Player.health - damage)
	SetPlayerBlock(block)
	
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
			SetEnemyHealth(Enemy.health - (CurrentCard.special.damage * LocalDamageModifier))
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
