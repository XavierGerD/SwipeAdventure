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
var SkipNext = false
var IsPlayerFocused = false
var PlayerFocusDamage = 0
var PlayerFocusDamageIncrease = 0

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
var LocalDamageMultiplier = 1
var PendingPlayerToEnemyDamage = []

var IsAnimatingAttack = false
var EnemyAttackIndex = 0

#init functions
func _ready() -> void:
	pass # Replace with function body.
	
func InstanciateLoadout(CurrentLoadout):
	var NewDeck = []
	var Items = CurrentLoadout.values()
	for i in range(Items.size()):
		if Items[i] != null && 'cardList' in Items[i]:
				NewDeck += Items[i].cardList
	Deck = NewDeck
	Deck += Player.looseCards

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
# warning-ignore:return_value_discarded
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

func GetTotalCardsToDraw():
	return Player.maxCardsInHand if Player.maxCardsInHand <= Deck.size() else Deck.size()

func PrepareDeck():
	DrawPile = Deck.duplicate(true) 
	randomize()
	DrawPile.shuffle()
	for i in GetTotalCardsToDraw():
		Hand.push_back(DrawPile[0])
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
	ContidionallyDestroyEnemies()
	CheckGameWinCondition()
	CheckGameLostCondition()
	if IsGameWon:
		OnGameWin()
	if IsGameLost:
		emit_signal("game_is_lost")

func OnGameWin():
	IsGameWon = false
	WinLoseText.set_text('You Win!')
	Player.block = 0
	emit_signal("game_is_won", EncounterEnemies)
	

#setters and getters
func OnSelectEnemy(SelectedEnemy, SelectedEnemyNode):
	for IteratedEnemyNode in EncounterEnemyNodes:
		if IteratedEnemyNode.node != null:
			IteratedEnemyNode.node.OnDeselect()
	SelectedEnemyNode.OnSelect()
	TargetEnemy = { 
		'node': SelectedEnemyNode,
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
		LocalDamageMultiplier,
		PlayerFocusDamage
	)
	TopCard = NewCard
	

func UpdateHand():
	if TopCard:
		TopCard.queue_free()
	DisplayCard(Hand[0])
	SetGetUtils.SetDiscardTotal(DiscardPileTotalLabel, DiscardPile.size())
	SetGetUtils.SetDrawTotal(DrawPileTotalLabel, DrawPile.size())
	SetGetUtils.SetHandTotal(HandTotalLabel, Hand.size())

func MoveCardFromHandToDiscard():
	DiscardPile.push_back(Hand[0])
	Hand.pop_front()

func GoToNextCard():
	if Hand.size() != 0:
		MoveCardFromHandToDiscard()
	if SkipNext:
		SkipNext = false
		if Hand.size() != 0:
			MoveCardFromHandToDiscard()
	#Check to see if turn is done
	var IsTurnDone = GetIsTurnDone()
	if IsTurnDone:
		yield(get_tree().create_timer(0.5), 'timeout')
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
	for PendingDamage in PendingPlayerToEnemyDamage:
		PendingDamage.target.enemyRef.health = (
			PendingDamage.target.enemyRef.health - PendingDamage.damage if
			PendingDamage.target.enemyRef.health - PendingDamage.damage >= 0 else
			0
		)
	emit_signal("update_health")
	PendingPlayerToEnemyDamage = []
	UpdateHand()
	
func EndTurn():
	SetGetUtils.SetPlayerEnergy(PlayerEnergyLabel, Player, Player.maxEnergy)
	DiscardPile += Hand
	Hand = []
	for i in GetTotalCardsToDraw():
		if DrawPile.size() == 0:
			MoveCardFromDiscardToDrawPile()
		Hand.push_back(DrawPile[0])
		DrawPile.pop_front()
	TopCard.queue_free()
	BeginTurn()
	
func GetEnemyDamageAnim():
	var NewAttackAnim = AttackSpriteNode.instance()
	add_child(NewAttackAnim)
	IsAnimatingAttack = true
	return NewAttackAnim
	
func OnAttackDone(Type):
	IsAnimatingAttack = false
	var CardDamage = GetCardDamage(Type)
	if IsPlayerFocused:
		CardDamage += PlayerFocusDamage
		IsPlayerFocused = false
	DealDamageToEnemy(TargetEnemy, CardDamage)
	emit_signal("update_health")

func DealDamageToEnemy(Enemy, CardDamage):
	Enemy.enemyRef.health = Enemy.enemyRef.health - CardDamage if Enemy.enemyRef.health - CardDamage >= 0 else 0
	
func ExecuteCard(CardAction, Type):
	if (CardAction.damage != null):
		var NewAttackAnim = GetEnemyDamageAnim()
		NewAttackAnim.AnimateAttack(TargetEnemy.node.get_position().x)
		yield(NewAttackAnim, 'anim_done')
		OnAttackDone(Type)
	if (CardAction.block != null):
		SetGetUtils.SetPlayerBlock(PlayerBlockLabel, Player, Player.block + CurrentCard.onAction.block)
	if (CardAction.heal != null):
		var newPlayerHealth = Player.health + CurrentCard.onAction.heal if Player.health + CurrentCard.onAction.heal <= Player.maxHealth else Player.maxHealth
		SetGetUtils.SetPlayerHealth(PlayerHealthLabel, Player, newPlayerHealth)
	if (CardAction.power != null):
		ExecuteCardPowers(CardAction)
	if !IsGameWon:
		GoToNextCard()

func ExecuteCardPowers(CardAction):
	for Power in CardAction.power:
		if Power == 'doubleDamage':
			LocalDamageMultiplier = 2 if LocalDamageMultiplier == 1 else LocalDamageMultiplier + 2
		if Power == 'pendingDamage':
			PendingPlayerToEnemyDamage.push_back({ 
				'damage': CurrentCard.onSpecial.effect,
				'target': TargetEnemy
				})
		if Power == 'removeFromGame':
			Hand.pop_front()
		if Power == 'allEnemies':
			for Enemy in EncounterEnemyNodes:
				DealDamageToEnemy(Enemy, CardAction.effect)
		if Power == 'skipNext':
			SkipNext = true
		if Power == 'restoreEnergy':
			Player.energy += CardAction.effect
		if Power == 'focus':
			IsPlayerFocused = true
			PlayerFocusDamageIncrease += CardAction.effect
		return

#player actions
func OnAction():
	if IsGameLost && IsAnimatingAttack:
		return
	CurrentCard = Hand[0]
	ExecuteCard(CurrentCard.onAction, 'onAction')
	SetGetUtils.SetPlayerEnergy(PlayerEnergyLabel, Player, Player.energy - CurrentCard.onAction.cost)


func OnSkip() -> void:
	if IsGameLost && IsAnimatingAttack:
		return
	CurrentCard = Hand[0]
	if IsPlayerFocused:
		PlayerFocusDamage += PlayerFocusDamageIncrease	
	if CurrentCard.onSkip != null:
		ExecuteCard(CurrentCard.onSkip, 'onSkip')
	else:
		GoToNextCard()

func OnSpecial() -> void:
	if IsGameLost && IsAnimatingAttack:
		return
	CurrentCard = Hand[0]
	ExecuteCard(CurrentCard.onSpecial, 'onSpecial')
	SetGetUtils.SetPlayerEnergy(PlayerEnergyLabel, Player, Player.energy - GetCardCostForSpecial(CurrentCard))

func GetCardCostForSpecial(CardForCost):
	if CardForCost.onSpecial.cost != null:
		return CardForCost.onSpecial.cost
	else:
		return CardForCost.onAction.cost

func GetCardDamage(Type):
	var Damage = CurrentCard[Type].damage * LocalDamageMultiplier
	LocalDamageMultiplier = 1
	return Damage

func PlayDamageIndicator(damage):
	var NewDamageIndicator = DamageIndicator.instance()
	add_child(NewDamageIndicator)
	NewDamageIndicator.set_position(Vector2(768 / 2, 1366 / 2))
	NewDamageIndicator.PlayAnimWithValue(damage)

# warning-ignore:unused_argument
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

func GetIsAnimatingAttack():
	return IsAnimatingAttack
