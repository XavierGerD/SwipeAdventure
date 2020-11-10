extends Node2D

signal card_action
signal card_skip

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

func _input(event):
	MousePosition = event.position
	if IsClicked:
		self.set_position(Vector2(event.position.x - DeltaX, self.get_position().y))
		rotation = (event.position.x - DeltaX) * 0.001
	pass

func _on_Button_button_down() -> void:
	DeltaX = MousePosition.x - self.get_position().x
	IsClicked = true
	pass # Replace with function body.


func _on_Button_button_up() -> void:
	IsClicked = false
	if self.get_position().x >= 448:
		emit_signal('card_action')
	if self.get_position().x <= -416:
		emit_signal('card_skip')
	if self.get_position().x < 448 && self.get_position().x > -416:
		var PositionTween = Tween.new()
		PositionTween.interpolate_property(
			self, 
			"position", 
			self.get_position(), 
			Vector2(16, self.get_position().y), 
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
