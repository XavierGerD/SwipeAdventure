extends Node2D

signal card_action
signal card_skip
signal card_special

onready	var CardName = get_node("CardName")
onready var Cost = get_node("Cost")
onready	var Description = get_node("Description")

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

func _ready() -> void:
	pass # Replace with function body.
	
func InstanciateCard(CardNameLabel, CostLabel, DescriptionLabel, CardX, CardY, HasSpecialFromProps, IsCardPlayableFromProps):
	CardName.set_text(CardNameLabel)
	Cost.set_text(CostLabel)
	Description.set_text(DescriptionLabel)
	CardStartingPosition.x = CardX
	CardStartingPosition.y = CardY
	HasSpecial = HasSpecialFromProps
	CardCost = int(CostLabel)
	self.set_position(Vector2(CardX, CardY))
	IsCardPlayable = IsCardPlayableFromProps


func _input(event):
	MousePosition = event.position
	if IsClicked:
		rotation = (event.position.x - DeltaX) * 0.001
		TotalDisplacementX = MousePosition.x - DeltaX
		TotalDisplacementY = MousePosition.y - DeltaY
		self.rotation = (TotalDisplacementX - CardStartingPosition.x) * 0.001
		self.set_position(Vector2(TotalDisplacementX, TotalDisplacementY))
		#self.set_position(Vector2(event.position.x - DeltaX, self.get_position().y))
	pass

func _on_Button_button_down() -> void:
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
	print(IsCardPlayable)
	if !IsCardPlayable:
		return
	IsClicked = false
	var Energy = self.get_parent().GetPlayerEnergy()
	if self.get_global_position().y <= 352 && HasSpecial && CardCost <= Energy:
		print('special activated')
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
		PositionTween.connect('tween_all_completed', self, 'TweenEndAction')
		return
	if self.get_global_position().x >= 448 && CardCost <= Energy:
		var PositionTween = Tween.new()
		PositionTween.interpolate_property(
			self, 
			"position", 
			self.get_position(), 
			Vector2(1000, CardStartingPosition.y), 
			0.2, 
			Tween.TRANS_LINEAR, 
			Tween.EASE_IN_OUT
		)
		add_child(PositionTween)
		PositionTween.start()
		PositionTween.connect('tween_all_completed', self, 'TweenEndAction')
		return
	if self.get_global_position().x <= 128:
		var PositionTween = Tween.new()
		PositionTween.interpolate_property(
			self, 
			"position", 
			self.get_position(), 
			Vector2(-1000, CardStartingPosition.y), 
			0.2, 
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
