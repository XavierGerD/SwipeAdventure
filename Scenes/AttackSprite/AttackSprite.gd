extends Node2D

signal anim_done

func AnimateAttack(StartingX):
	self.set_position(Vector2(StartingX, -128))
	var AnimTween = Tween.new()
	AnimTween.interpolate_property(
		self,
		'position',
		self.get_position(),
		Vector2(StartingX, 250),
		0.2,
		Tween.TRANS_LINEAR, 
		Tween.EASE_IN
		)
	AnimTween.connect("tween_all_completed", self, 'OnComplete')
	add_child(AnimTween)
	AnimTween.start()

func OnComplete():
	emit_signal('anim_done')
	self.queue_free()
