extends Node2D

signal enemy_selected(Enemy)

onready var EnemyNameLabel = get_node("EnemyLabel")
onready var EnemyHPLabel = get_node("EnemyHP")
onready var EnemySelector = get_node("EnemySelector")

var Enemy

func _ready() -> void:
	pass # Replace with function body.

func InstanciateEnemy(EnemyFromProps):
	Enemy = EnemyFromProps
	EnemyNameLabel.set_text(Enemy.name)
	EnemyHPLabel.set_text(str(Enemy.health) + '/' + str(Enemy.maxHealth))
	print('self in node', self)

func OnHealthUpdate():
	EnemyHPLabel.set_text(str(Enemy.health) + '/' + str(Enemy.maxHealth))
	
func OnDeselect():
	EnemySelector.visible = false

func OnSelect():
	EnemySelector.visible = true

func _on_TextureButton_pressed() -> void:
	emit_signal('enemy_selected', Enemy, self)
	pass # Replace with function body.
