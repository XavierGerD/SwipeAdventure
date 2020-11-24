extends Node2D

onready var GameManager = self.get_parent()

func _on_HideButton_pressed() -> void:
	self.visible = false
	GameManager.move_child(self, 0)
	GameManager.ShowWorldMap()

