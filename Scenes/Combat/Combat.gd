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
onready var PlayerHitAnim = get_node("Flasher/PlayerHitAnim")

onready var LoadoutManager = load('res://Scenes/LoadoutManager/LoadoutManager.gd')
onready var Card = load('res://Scenes/Card/Card.tscn')
onready var EnemyNode = load('res://Scenes/Enemy/Enemy.tscn')
onready var DamageIndicator = load('res://Scenes/DamageIndicator/DamageIndicator.tscn')

onready var AttackSpriteNode = load('res://Scenes/AttackSprite/AttackSprite.tscn')

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
var CurrentCard
var LocalDamageModifier = 1
var PendingPlayerToEnemyDamage = 0

var IsAnimatingAttack = false
var EnemyAttackIndex = 0

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
	NewEnemyNode.set_position(Vector2((i * Constants.ENEMY_POSITION_X_OFFSET) + Constants.ENEMY_POSITION_X_MUTLIPLIER, Constants.ENEMY_POSITION_Y))
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
	SetGetUtils.SetPlayerHealth(PlayerHealthLabel, Player, Player.health)
	SetGetUtils.SetPlayerEnergy(PlayerEnergyLabel, Player, Player.maxEnergy)
	SetGetUtils.SetPlayerBlock(PlayerBlockLabel, Player, Player.block)
	
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
	for i in (Player.maxCardsInHand):
		Hand.push_back(DrawPile[i])
		DrawPile.pop_front()
	UpdateHand()

#getters
func GetPlayerEnergy():
	return Player.energy

#game loop
func CheckGameWinCondition():
	var AreAllEnemiesDead = true
	for Enemy in EncounterEnemyNodes:
		if Enemy.node != null:
			AreAllEnemiesDead = false
	if (AreAllEnemiesDead):
		IsGameWon = true
		return true
	return false
	
func CheckGameLostCondition():
	if (Player.health <= 0):
		IsGameLost = true
		return

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

func _process(_delta):
	if !IsAnimatingAttack:
		ContidionallyDestroyEnemies()
	CheckGameWinCondition()
	CheckGameLostCondition()
	if IsGameWon:
		emit_signal("game_is_won", EncounterEnemies)
	if IsGameLost:
		emit_signal("game_is_lost")

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
		card.onSpecial != null,
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
		DealEnemyDamage()
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
	if EnemyAttackIndex > EncounterEnemyNodes.size() - 1:
		EndTurn()
		EnemyAttackIndex = 0
		return
	var Enemy = EncounterEnemyNodes[EnemyAttackIndex]
	if (Enemy.node == null):
		EnemyAttackIndex += 1
		DealEnemyDamage()
		return
	IsAnimatingAttack = true
	PlayerHitAnim.play("Blink")
	Enemy.node.FlipAnimation.play('Flip')

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
	
func DealDamageToEnemy():
	var NewAttackAnim = AttackSpriteNode.instance()
	add_child(NewAttackAnim)
	IsAnimatingAttack = true
	NewAttackAnim.connect('anim_done', self, 'OnAttackDone')
	NewAttackAnim.AnimateAttack(TargetEnemy.node.get_position().x)
	
func OnAttackDone():
	IsAnimatingAttack = false
	var CardDamage = GetCardDamage()
	TargetEnemy.enemyRef.health = TargetEnemy.enemyRef.health - CardDamage if TargetEnemy.enemyRef.health - CardDamage >= 0 else 0
	emit_signal("update_health")

#player actions
func OnAction():
	if IsGameLost && IsAnimatingAttack:
		return
	CurrentCard = Hand[0]
	if (CurrentCard.onAction.damage != null):
		DealDamageToEnemy()
	if (CurrentCard.onAction.block != null):
		SetGetUtils.SetPlayerBlock(PlayerBlockLabel, Player, Player.block + CurrentCard.onAction.block)
	if (CurrentCard.onAction.heal != null):
		var newPlayerHealth = Player.health + CurrentCard.onAction.heal if Player.health + CurrentCard.onAction.heal <= Player.maxHealth else Player.maxHealth
		SetGetUtils.SetPlayerHealth(PlayerHealthLabel, Player, newPlayerHealth)
	if (CurrentCard.onAction.power != null):
		HandleCardPower(CurrentCard)
	SetGetUtils.SetPlayerEnergy(PlayerEnergyLabel, Player, Player.energy - CurrentCard.onAction.cost)
	if !IsGameWon:
		GoToNextCard()

func OnSkip() -> void:
	if IsGameLost && IsAnimatingAttack:
		return
	GoToNextCard()

func OnSpecial() -> void:
	if IsGameLost && IsAnimatingAttack:
		return
	CurrentCard = Hand[0]
	if CurrentCard.onSpecial:
		if (CurrentCard.onSpecial.damage != null):
			TargetEnemy.enemyRef.health = TargetEnemy.enemyRef.health - CurrentCard.onSpecial.damage * LocalDamageModifier if TargetEnemy.enemyRef.health - CurrentCard.onSpecial.damage * LocalDamageModifier >= 0 else 0
			emit_signal("update_health")
		if (CurrentCard.onSpecial.condition == 'discard'):
			Hand.pop_front()
		if (CurrentCard.onSpecial.power == 'pendingDamage'):
			PendingPlayerToEnemyDamage = CurrentCard.onSpecial.effect
	SetGetUtils.SetPlayerEnergy(PlayerEnergyLabel, Player, Player.energy - GetCardCost(CurrentCard))
	if !IsGameWon:
		GoToNextCard()
	pass # Replace with function body.

func GetCardCost(Card):
	if Card.onSpecial.cost != null:
		return Card.onSpecial.cost
	else:
		return Card.onAction.cost

func HandleCardPower(CurrentCard):
	if (CurrentCard.onAction.power == 'doubleDamage'):
		LocalDamageModifier = 2 if LocalDamageModifier == 1 else LocalDamageModifier + 2

func GetCardDamage():
	var Damage = CurrentCard.onAction.damage * LocalDamageModifier
	LocalDamageModifier = 1
	return Damage

func PlayDamageIndicator(damage):
	var NewDamageIndicator = DamageIndicator.instance()
	add_child(NewDamageIndicator)
	NewDamageIndicator.set_position(Vector2(768 / 2, 1366 / 2))
	NewDamageIndicator.PlayAnimWithValue(damage)

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	var Enemy = EncounterEnemyNodes[EnemyAttackIndex]
	var damage = Enemy.enemyRef.baseDamage - Player.block if Enemy.enemyRef.baseDamage - Player.block > 0 else 0
	var block = Player.block - Enemy.enemyRef.baseDamage if Player.block - Enemy.enemyRef.baseDamage > 0 else 0
	SetGetUtils.SetPlayerHealth(PlayerHealthLabel, Player, Player.health - damage)
	SetGetUtils.SetPlayerBlock(PlayerBlockLabel, Player, block)
	EnemyAttackIndex += 1
	IsAnimatingAttack = false
	DealEnemyDamage()
	PlayDamageIndicator(damage)
	pass # Replace with function body.

func GetIsAnimatingAttack():
	return IsAnimatingAttack
