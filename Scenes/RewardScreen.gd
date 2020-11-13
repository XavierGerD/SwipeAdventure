extends Node2D

onready var Cards = load('res://Scenes/Data/Cards.gd')
onready var Card = load('res://Scenes/Card/Card.tscn')
onready var CardBack = load('res://Scenes/CardBack/CardBack.tscn')

var NewCard
var NewCardBack

const OFFSCREEN_CARD_STARTING_POINT_X = 1000
const OFFSCREEN_CARD_STARTING_POINT_Y = 450

onready var PossibleRewards = [
	Cards.Weld,
	Cards.ShieldCharge,
	Cards.PlasmaBolt
]

var Reward

func _ready() -> void:
	var RandomNumber = (randf() * (3  -1)) + 1
	Reward = PossibleRewards[RandomNumber]
	NewCard = Card.instance()
	NewCardBack = CardBack.instance()
	add_child(NewCard)
	add_child(NewCardBack)
	NewCardBack.connect('card_selected', self, 'OnRewardSelected')
	NewCardBack.set_position(Vector2(OFFSCREEN_CARD_STARTING_POINT_X, OFFSCREEN_CARD_STARTING_POINT_Y))
	NewCard.InstanciateCard(Reward.name, str(Reward.cost), Reward.description, OFFSCREEN_CARD_STARTING_POINT_X, OFFSCREEN_CARD_STARTING_POINT_Y, Reward.special != null, false)
	var PositionTween = Tween.new()
	PositionTween.interpolate_property(
		NewCard, 
		"position", 
		NewCard.get_position(), 
		Vector2(288.5, NewCard.get_position().y), 
		2, 
		Tween.TRANS_LINEAR, 
		Tween.EASE_IN_OUT
	)
	add_child(PositionTween)
	var CardBackPositionTween = Tween.new()
	CardBackPositionTween.interpolate_property(
		NewCardBack, 
		"position", 
		NewCardBack.get_position(), 
		Vector2(288.5, NewCardBack.get_position().y), 
		2, 
		Tween.TRANS_LINEAR, 
		Tween.EASE_IN_OUT
	)
	add_child(CardBackPositionTween)
	CardBackPositionTween.start()
	PositionTween.start()
	pass # Replace with function body.
	
func TweenToShrink(Target):
	var ShrinkTween = Tween.new()
	ShrinkTween.interpolate_property(
		Target,
		'scale',
		Vector2(1, 1),
		Vector2(0, 1),
		1,
		Tween.TRANS_LINEAR, 
		Tween.EASE_IN_OUT
	)
	add_child(ShrinkTween)
	ShrinkTween.start()
	return ShrinkTween

func OnShrinkDone():
	NewCardBack.queue_free()
	TweenToGrow(NewCard)

func TweenToGrow(Target):
	var GrownTween = Tween.new()
	GrownTween.interpolate_property(
		Target,
		'scale',
		Vector2(0, 1),
		Vector2(1, 1),
		1,
		Tween.TRANS_LINEAR, 
		Tween.EASE_IN_OUT
	)
	add_child(GrownTween)
	GrownTween.start()
	return GrownTween


func OnRewardSelected():
	var ShrinkTween = TweenToShrink(NewCardBack)
	var GrowTween = TweenToShrink(NewCard)
	ShrinkTween.connect('tween_all_completed', self, "OnShrinkDone")
	pass
