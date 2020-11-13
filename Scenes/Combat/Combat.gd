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
onready var WinLoseText = get_node("WinLoseText")
onready var Card = load('res://Scenes/Card/Card.tscn')
onready var Cards = load('res://Scenes/Data/Cards.gd')
onready var RewardScreen = load('res://Scenes/RewardScreen.tscn')

var IsGameLost = false
var IsGameWon = false

var TopCard

var MaxCardsInHand = 3

const CARD_STARTING_POSITION_X = 288.5
const CARD_STARTING_POSITION_Y = 642.5

var Player = {
	'health': 10,
	'block': 0,
	'energy': 3,
	'maxEnergy': 3
}

var Enemy = {
	'name': 'Space Bad Guy',
	'health': 10,
	'damage': 3
}

onready var Deck = [
	Cards.Weld,
	Cards.Weld,
	Cards.Weld,
	Cards.ShieldCharge,
	Cards.ShieldCharge,
	Cards.ShieldCharge,
]

var Hand = []

var DrawPile = []

var DiscardPile = []

func _ready() -> void:
	SetPlayerHealth(Player.health)
	SetPlayerEnergy(Player.maxEnergy)
	SetPlayerBlock(Player.block)
	EnemyNameLabel.set_text('Enemy: ' + Enemy.name)
	SetEnemyHealth(Enemy.health)
	DrawPile = Deck.duplicate() 
	randomize()
	DrawPile.shuffle()
	for i in (MaxCardsInHand):
		Hand.push_back(DrawPile[i])
		DrawPile.pop_front()
	print(Hand.size())
	print(DrawPile.size())
	print(Deck.size())
	DisplayCard(Hand[0])
	SetDiscardTotal()
	SetDrawTotal()
	pass # Replace with function body.
	
func _process(delta):
	if IsGameWon:
		get_parent().add_child(RewardScreen.instance())
		self.queue_free()
	
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

func DisplayCard(card):
	var NewCard = Card.instance()
	add_child(NewCard)
	NewCard.connect('card_action', self, 'OnAction')
	NewCard.connect('card_skip', self, 'OnSkip')
	NewCard.connect('card_special', self, 'OnSpecial')
	NewCard.InstanciateCard(card.name, str(card.cost), card.description, CARD_STARTING_POSITION_X, CARD_STARTING_POSITION_Y, card.special != null, true)
	TopCard = NewCard
	
func GetIsTurnDone():
	if (Hand.size() == 0):
		return true
	return false
	
func GoToNextCard():
	TopCard.queue_free()
	#Take the top card from your hand and place it in the discard pile
	DiscardPile.push_back(Hand[0])
	#Remove the card from your hand
	Hand.pop_front()
	#Check to see if turn is done
	var IsTurnDone = GetIsTurnDone()
	if IsTurnDone:
		EndTurn()
		return
	DisplayCard(Hand[0])
	SetDiscardTotal()
	SetDrawTotal()
	
func MoveCardFromDiscardToDrawPile():
	DrawPile = DiscardPile.duplicate()
	DiscardPile = []
	randomize()
	DrawPile.shuffle()
	TopCard.queue_free()
	
func DealEnemyDamage():
	var damage = Enemy.damage - Player.block if Enemy.damage - Player.block > 0 else 0
	var block = Player.block - Enemy.damage if Player.block - Enemy.damage > 0 else 0
	SetPlayerHealth(Player.health - damage)
	SetPlayerBlock(block)
	
func EndTurn():
	DealEnemyDamage()
	ConditionallyLoseGame()
	SetPlayerEnergy(Player.maxEnergy)
	for i in (MaxCardsInHand):
		if DrawPile.size() == 0:
			MoveCardFromDiscardToDrawPile()
		Hand.push_back(DrawPile[0])
		DrawPile.pop_front()
	TopCard.queue_free()
	GoToNextCard()


func ClearScreen():
	for child in self.get_children():
		child.queue_free()
	pass

func ConditionallyWinGame():
	if (Enemy.health <= 0):
		WinLoseText.set_text("You Win!")
		IsGameWon = true
		return
	GoToNextCard()
	
func ConditionallyLoseGame():
	if (Player.health <= 0):
		WinLoseText.set_text("You Lose!")
		IsGameLost = true
		return

func OnAction():
	if IsGameLost:
		return
	var currentCard = Hand[0]
	if (currentCard.damage != null):
		var newEnemyHealth = Enemy.health - currentCard.damage if  Enemy.health - currentCard.damage >=0 else 0
		SetEnemyHealth(newEnemyHealth)
	if (currentCard.block != null):
		SetPlayerBlock(Player.block + currentCard.block)
	SetPlayerEnergy(Player.energy - currentCard.cost)
	ConditionallyWinGame()

func OnSkip() -> void:
	if IsGameLost:
		return
	GoToNextCard()

func OnSpecial() -> void:
	if IsGameLost:
		return
	var currentCard = Hand[0]
	if currentCard.special:
		SetEnemyHealth(Enemy.health - currentCard.special.damage)
		if currentCard.special.condition == 'discard':
			Hand.pop_front()
		GoToNextCard()
	pass # Replace with function body.
