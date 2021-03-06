extends Node2D

signal card_action
signal card_skip
signal card_special
signal card_pressed
signal card_released

onready	var CardName = get_node("CardName")
onready var Cost = get_node("Cost")
onready	var DescriptionNode = get_node("Description")
onready var CardImage = get_node("CardImage")

var IsClicked = false
var DeltaX = 0
var DeltaY = 0
var TotalDisplacementX = 0
var TotalDisplacementY = 0
var MousePosition = Vector2(0, 0)
var CardStartingPosition = { 'x': 0, 'y': 0 }
var HasSpecial = false
var CardCost
var IsCardPlayable

func getCardDescription(Card, LocalDamageModifier, FocusDamage):
	var Description = Card.description
	
	if (Card.onAction.damage != null):
		Description = Description.replace('{dmg}', Card.onAction.damage * LocalDamageModifier + FocusDamage)
		
	if (Card.onAction.heal != null):
		Description = Description.replace('{hp}', Card.onAction.heal)
		
	if (Card.onAction.block != null):
		Description = Description.replace('{blk}', Card.onAction.block)

	if (Card.onAction != null && Card.onAction.effect != null):
		Description = Description.replace('{efDmg}', Card.onAction.effect * LocalDamageModifier + FocusDamage)

	if (Card.onSpecial != null && Card.onSpecial.effect != null):
		Description = Description.replace('{spDmg}', Card.onSpecial.effect * LocalDamageModifier)
	
	if (Card.onSpecial != null && Card.onSpecial.damage != null):
		Description = Description.replace('{spDmg}', Card.onSpecial.damage * LocalDamageModifier + FocusDamage)
	
	if (Card.onSpecial != null && Card.onSpecial.effect != null):
		Description = Description.replace('{spEfDmg}', Card.onSpecial.effect * LocalDamageModifier + FocusDamage)

		
	return Description

func InstanciateCard(
	Card,
	CardX, 
	CardY, 
	HasSpecialFromProps, 
	IsCardPlayableFromProps, 
	TexturePath,
	LocalDamageModifier = 1,
	FocusDamage = 0
	):
		CardName.set_text(Card.name)
		Cost.set_text(str(Card.onAction.cost))
		DescriptionNode.set_text(getCardDescription(Card, LocalDamageModifier, FocusDamage))
		CardStartingPosition.x = CardX
		CardStartingPosition.y = CardY
		HasSpecial = HasSpecialFromProps
		CardCost = Card.onAction.cost
		self.set_position(Vector2(CardX, CardY))
		IsCardPlayable = IsCardPlayableFromProps
		CardImage.texture = load(TexturePath)

func _input(event):
	if "position" in event:
		MousePosition = event.position
		if IsClicked:
			rotation = (event.position.x - DeltaX) * 0.001
			TotalDisplacementX = MousePosition.x - DeltaX
			TotalDisplacementY = MousePosition.y - DeltaY
			self.rotation = (TotalDisplacementX - CardStartingPosition.x) * 0.001
			self.set_position(Vector2(TotalDisplacementX, TotalDisplacementY))

func _on_Button_button_down() -> void:
	emit_signal("card_pressed")
	if !IsCardPlayable:
		return
	DeltaX = MousePosition.x - self.get_position().x
	DeltaY = MousePosition.y - self.get_position().y
	IsClicked = true
	pass # Replace with function body.

func TweenEndAction():
	emit_signal('card_action')
	
func TweenEndSkip():
	emit_signal('card_skip')
	
func TweenEndSpecial():
	emit_signal('card_special')

func _on_Button_button_up() -> void:
	emit_signal("card_released")
	if !IsCardPlayable:
		return
	IsClicked = false
	var Energy = self.get_parent().GetPlayerEnergy()
	if (self.get_global_position().y <= Constants.CARD_SWIPE_UPPER_LIMIT &&
		HasSpecial &&
		CardCost <= Energy):
		var PositionTween = Tween.new()
		PositionTween.interpolate_property(
			self, 
			"position", 
			self.get_position(), 
			Vector2(CardStartingPosition.x, -1000), 
			0.2, 
			Tween.TRANS_LINEAR, 
			Tween.EASE_IN_OUT
		)
		add_child(PositionTween)
		PositionTween.start()
		PositionTween.connect('tween_all_completed', self, 'TweenEndSpecial')
		return
	if (self.get_global_position().x >= Constants.CARD_SWIPE_RIGHT_LIMIT &&
		self.get_global_position().y > Constants.CARD_SWIPE_UPPER_LIMIT &&
		CardCost <= Energy):
		var PositionTween = Tween.new()
		PositionTween.interpolate_property(
			self, 
			"position", 
			self.get_position(), 
			Vector2(2000, CardStartingPosition.y), 
			0.1, 
			Tween.TRANS_LINEAR, 
			Tween.EASE_IN_OUT
		)
		add_child(PositionTween)
		PositionTween.start()
		PositionTween.connect('tween_all_completed', self, 'TweenEndAction')
		return
	if (self.get_global_position().x >= Constants.CARD_SWIPE_RIGHT_LIMIT &&
		self.get_global_position().y > Constants.CARD_SWIPE_UPPER_LIMIT &&
		CardCost > Energy):
			$AudioPlayer.stream = load("res://Sound/SFX/TooExpensive.wav")
			$AudioPlayer.play()
		
	if (self.get_global_position().x <= Constants.CARD_SWIPE_LEFT_LIMIT &&
		self.get_global_position().y > Constants.CARD_SWIPE_UPPER_LIMIT):
		var PositionTween = Tween.new()
		PositionTween.interpolate_property(
			self, 
			"position", 
			self.get_position(), 
			Vector2(-1000, CardStartingPosition.y), 
			0.1, 
			Tween.TRANS_LINEAR, 
			Tween.EASE_IN_OUT
		)
		add_child(PositionTween)
		PositionTween.start()
		PositionTween.connect('tween_all_completed', self, 'TweenEndSkip')
		return
	var PositionTween = Tween.new()
	PositionTween.interpolate_property(
		self, 
		"position", 
		self.get_position(), 
		Vector2(CardStartingPosition.x, CardStartingPosition.y), 
		0.2, 
		Tween.TRANS_LINEAR, 
		Tween.EASE_IN_OUT
	)
	add_child(PositionTween)
	var RotationTween = Tween.new()
	RotationTween.interpolate_property(
		self, 
		"rotation", 
		self.get_rotation(), 
		0, 
		0.2, 
		Tween.TRANS_LINEAR, 
		Tween.EASE_IN_OUT
	)
	add_child(RotationTween)
	PositionTween.start()
	RotationTween.start()
	pass # Replace with function body.
