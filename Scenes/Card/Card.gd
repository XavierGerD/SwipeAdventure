extends Node2D

signal card_action
signal card_skip

<<<<<<< HEAD
var IsClicked = false
var DeltaX = 0
var MousePosition = Vector2(0, 0)

func _ready() -> void:
	pass # Replace with function body.

func InstanciateCard(CardNameLabel, CostLabel, DescriptionLabel):
	# Je comprends pas pourquoi mais si je les mets onready ca marche pas!!!
	var CardName = get_node("CardName")
	var Cost = get_node("Cost")
	var Description = get_node("Description")
	CardName.set_text(CardNameLabel)
	Cost.set_text(CostLabel)
	Description.set_text(DescriptionLabel)
=======
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

func _ready() -> void:
	pass # Replace with function body.
	
func InstanciateCard(CardNameLabel, CostLabel, DescriptionLabel, CardX, CardY, HasSpecialFromProps):
	CardName.set_text(CardNameLabel)
	Cost.set_text(CostLabel)
	Description.set_text(DescriptionLabel)
	CardStartingPosition.x = CardX
	CardStartingPosition.y = CardY
	HasSpecial = HasSpecialFromProps
	print(HasSpecial)
>>>>>>> d80633ae3778d5896ba92f58542f5d211b235762

func _input(event):
	MousePosition = event.position
	if IsClicked:
<<<<<<< HEAD
		self.set_position(Vector2(event.position.x - DeltaX, self.get_position().y))
		rotation = (event.position.x - DeltaX) * 0.001
=======
		TotalDisplacementX = MousePosition.x - DeltaX
		TotalDisplacementY = MousePosition.y - DeltaY
		self.rotation = (TotalDisplacementX - CardStartingPosition.x) * 0.001
		self.set_position(Vector2(TotalDisplacementX, TotalDisplacementY))
		#self.set_position(Vector2(event.position.x - DeltaX, self.get_position().y))
>>>>>>> d80633ae3778d5896ba92f58542f5d211b235762
	pass

func _on_Button_button_down() -> void:
	DeltaX = MousePosition.x - self.get_position().x
<<<<<<< HEAD
	IsClicked = true
	pass # Replace with function body.


func _on_Button_button_up() -> void:
	IsClicked = false
	if self.get_position().x >= 448:
		emit_signal('card_action')
	if self.get_position().x <= -416:
		emit_signal('card_skip')
	if self.get_position().x < 448 && self.get_position().x > -416:
=======
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
	IsClicked = false
	if self.get_global_position().y <= 120 && HasSpecial:
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
	if self.get_global_position().x >= 448:
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
	if self.get_global_position().x < 448 && self.get_global_position().x > 128:
>>>>>>> d80633ae3778d5896ba92f58542f5d211b235762
		var PositionTween = Tween.new()
		PositionTween.interpolate_property(
			self, 
			"position", 
			self.get_position(), 
<<<<<<< HEAD
			Vector2(16, self.get_position().y), 
=======
			Vector2(CardStartingPosition.x, CardStartingPosition.y), 
>>>>>>> d80633ae3778d5896ba92f58542f5d211b235762
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
