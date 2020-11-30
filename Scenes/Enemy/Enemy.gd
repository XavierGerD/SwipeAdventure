extends Node2D

signal enemy_selected(Enemy)

onready var EnemyNameLabel = get_node("EnemyLabel")
onready var EnemyHPLabel = get_node("EnemyHP")
onready var EnemySelector = get_node("EnemySelector")
onready var FlipAnimation = get_node("Texture/FlipAnimation")
onready var TextureNode = get_node("Texture")

var Enemy

func _ready() -> void:
	pass # Replace with function body.

func InstanciateEnemy(EnemyFromProps):
	Enemy = EnemyFromProps
	EnemyNameLabel.bbcode_text = '[center]' + Enemy.name + '[/center]'
	EnemyHPLabel.set_text(str(Enemy.health) + '/' + str(Enemy.maxHealth))
	TextureNode.set_normal_texture(load(Enemy.texture))

func OnHealthUpdate():
	EnemyHPLabel.set_text(str(Enemy.health) + '/' + str(Enemy.maxHealth))
	
func OnDeselect():
	EnemySelector.visible = false

func OnSelect():
	$AudioPlayer.stream = load("res://Sound/SFX/SelectEnemy.wav")
	$AudioPlayer.play()
	EnemySelector.visible = true

func _on_TextureButton_pressed() -> void:
	var IsAnimatingAttack = self.get_parent().GetIsAnimatingAttack()
	if IsAnimatingAttack:
		return
	emit_signal('enemy_selected', Enemy, self)
	pass # Replace with function body.
