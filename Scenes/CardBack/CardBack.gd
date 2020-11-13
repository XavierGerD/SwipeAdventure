extends Node2D

signal card_selected

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_Button_pressed() -> void:
	emit_signal("card_selected")
	pass
