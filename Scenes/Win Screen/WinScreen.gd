extends Node2D

onready var Combat = load('res://Scenes/Combat/Combat.tscn')

func _on_Button_pressed() -> void:
	get_node('/root/GameManager').StartNewGame()
	self.queue_free()
