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
onready var Card = load('res://Scenes/Card/Card.tscn')

var TopCard

var MaxCardsInHand = 3

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

const Weld = {
		'name': 'Weld',
		'cost': 1,
		'damage': 3,
		'block': null,
		'special': null,
		'description': 'Use your welder to deal 3 damage'
	}

const ShieldCharge = {
		'name': 'Shield Charge',
		'cost': 1,
		'damage': null,
		'block': 3,
		'special': null,
		'description': 'Charge up your shield and gain 3 block'
	}

const PlasmaBolt = {
	'name': 'Plasma Bolt',
	'cost': 2,
	'damage': 5,
	'block': null,
	'special': {
		'damage': 7,
		'condition': 'discard'
	},
	'description': 'Deal 5 damage with your plasma bolt. Overload this card to deal 7 damage and discard it.'
}

var Deck = [
	Weld,
	Weld, 
	Weld,
	ShieldCharge,
	ShieldCharge,
	ShieldCharge,
	PlasmaBolt,
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
	DisplayCard(Hand[0])
	SetDiscardTotal()
	SetDrawTotal()
	pass # Replace with function body.
	
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
	NewCard.InstanciateCard(card.name, str(card.cost), card.description)
	NewCard.set_position(Vector2(16, 330))
	NewCard.connect('card_action', self, 'OnAction')
	NewCard.connect('card_skip', self, 'OnSkip')
	TopCard = NewCard
	add_child(NewCard)
	
func GoToNextCard():
	TopCard.queue_free()
	DiscardPile.push_back(Hand[0])
	Hand.pop_front()
	ConditionnalyEndTurn()
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

func ConditionnalyEndTurn():
	if (Hand.size() == 0):
		DealEnemyDamage()
		SetPlayerEnergy(Player.maxEnergy)
		for i in (MaxCardsInHand):
			if DrawPile.size() == 0:
				MoveCardFromDiscardToDrawPile()
			Hand.push_back(DrawPile[0])
			DrawPile.pop_front()
		TopCard.queue_free()	
		

func OnAction():
	var currentCard = Hand[0]
	if currentCard.cost > Player.energy:
		return
	if (currentCard.damage != null):
		SetEnemyHealth(Enemy.health - currentCard.damage)
	if (currentCard.block != null):
		SetPlayerBlock(Player.block + currentCard.block)
	SetPlayerEnergy(Player.energy - currentCard.cost)
	GoToNextCard()

func OnSkip() -> void:
	GoToNextCard()
	pass # Replace with function body.

func _on_SpecialButton_pressed() -> void:
	var currentCard = Hand[0]
	if currentCard.special:
		SetEnemyHealth(Enemy.health - currentCard.special.damage)
		if currentCard.special.condition == 'discard':
			Hand.pop_front()
		GoToNextCard()
	pass # Replace with function body.
