extends Node2D

onready var SkillModalNode = get_node("SkillModal")
onready var UserCreditsTotalLabelNode = get_node("UserCreditsTotalLabel")

func _ready() -> void:
	UpdateUserCreditTotal()

#No choice here, each skill node will be hardcoded
func _on_LifeBoost_pressed() -> void:
	SkillModalNode.UpdateSkillModal(Skills.LifeBoost)
	SkillModalNode.visible = true
	pass # Replace with function body.

func _on_Button_pressed() -> void:
	self.visible = false
	self.get_parent().move_child(self, 0)
	self.get_parent().ShowWorldMap()
	pass # Replace with function body.

func GetUserCreditTotal():
	return self.get_parent().GetPlayerCredits()

func UpdateUserCreditTotal():
	UserCreditsTotalLabelNode.set_text('Credits: ' + str(GetUserCreditTotal()))
