extends Node2D

onready var TextLabelNode = get_node("TextLabel")
onready var AnimNode = get_node("TextLabel/AnimationPlayer")

func PlayAnimWithValue(value):
	TextLabelNode.bbcode_text = "[center] -" + str(value) + "[/center]"
	AnimNode.play("Damage")

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	self.queue_free()
