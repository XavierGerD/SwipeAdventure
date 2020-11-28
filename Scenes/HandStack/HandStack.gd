extends Node2D

onready var CardBack = get_node("CardBack")

var IsCardPressed = false
var MousePosition = { 'x': 0, 'y': 0}
var MouseDownPoint = { 'x': 0, 'y': 0}
onready var StartingPositionY1 = CardBack.get_position().y
var CARD_LOWER_Y_LIMIT = 645

func _ready() -> void:
#	SetScale(CardBack, 0.9, 1)
	pass # Replace with function body.

#func SetScale(Card, value, maximum):
#	Card.scale = Vector2(value, value)
#	if Card.scale.x > maximum:
#		Card.scale.x = maximum
#	if Card.scale.y > maximum:
#		Card.scale.y = maximum

func OnCardPressed():
	IsCardPressed = true
	MouseDownPoint = MousePosition

func OnCardReleased():
	IsCardPressed = false
	var PositionTween = Tween.new()
	PositionTween.interpolate_property(
		CardBack,
		'position',
		CardBack.get_position(),
		Vector2(CardBack.get_position().x, StartingPositionY1),
		0.2, 
		Tween.TRANS_LINEAR, 
		Tween.EASE_IN_OUT
	)
	add_child(PositionTween)
	PositionTween.start()
	var ScaleTween = Tween.new()
#	ScaleTween.interpolate_property(
#		CardBack,
#		'scale',
#		CardBack.scale,
#		Vector2(0.9, 0.9),
#		0.2, 
#		Tween.TRANS_LINEAR, 
#		Tween.EASE_IN_OUT
#	)
	add_child(ScaleTween)
	ScaleTween.start()

func _input(event):
	MousePosition = event.position
	if IsCardPressed:
		var square = pow(MousePosition.x - MouseDownPoint.x, 2) + pow(MousePosition.y - MouseDownPoint.y, 2)
		var hypotenuse = sqrt(square)
		CardBack.position.y = StartingPositionY1 - hypotenuse / 10
#		SetScale(CardBack, 0.9 + hypotenuse / 2000, 1)
		if CardBack.position.y < CARD_LOWER_Y_LIMIT:
			CardBack.position.y = CARD_LOWER_Y_LIMIT
	pass
