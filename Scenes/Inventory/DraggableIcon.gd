extends Control

signal icon_dropped

onready var ButtonWithName = get_node("ButtonWithName")

var Deltas: Vector2 = Vector2(0, 0)
var MousePosition: Vector2
var IsDragging = false
var Type
var Item

func InstanciateDraggableIcon(Icon):
	ButtonWithName.set_text(Icon.name)
	Type = Icon.type
	Item = Icon

func _input(event):
	if "position" in event:
		if IsDragging:
			self.set_position(Vector2(event.position.x - Deltas.x, event.position.y - Deltas.y))
			return
		MousePosition = Vector2(event.position)

func _on_Button_button_down() -> void:
	var CurrentButtonPosition = self.get_position()
	Deltas = Vector2(MousePosition.x - CurrentButtonPosition.x, MousePosition.y - CurrentButtonPosition.y)
	IsDragging = true

func _on_Button_button_up() -> void:
	IsDragging = false
	emit_signal('icon_dropped', self)
