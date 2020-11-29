extends Node2D

onready var Combat = load('res://Scenes/Combat/Combat.tscn')

func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass


func _on_Button_pressed() -> void:
	get_node('/root/GameManager').StartNewGame()
	self.queue_free()
