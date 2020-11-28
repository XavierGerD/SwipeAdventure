extends Node2D

onready var CardBack = get_node("CardBack")

var IsCardPressed = false
var MousePosition = { 'x': 0, 'y': 0}
var MouseDownPoint = { 'x': 0, 'y': 0}
onready var StartingPositionY1 = CardBack.get_position().y
var CARD_LOWER_Y_LIMIT = 645

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
	add_child(ScaleTween)
	ScaleTween.start()

func _input(event):
	if "position" in event:
		MousePosition = event.position
		if IsCardPressed:
			var square = pow(MousePosition.x - MouseDownPoint.x, 2) + pow(MousePosition.y - MouseDownPoint.y, 2)
			var hypotenuse = sqrt(square)
			CardBack.position.y = StartingPositionY1 - hypotenuse / 10
			if CardBack.position.y < CARD_LOWER_Y_LIMIT:
				CardBack.position.y = CARD_LOWER_Y_LIMIT
