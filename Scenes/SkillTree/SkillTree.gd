extends Node2D

onready var LifeBoostButtonNode = get_node("LifeBoost")
onready var SkillModalNode = get_node("SkillModal")
onready var UserCreditsTotalLabelNode = get_node("UserCreditsTotalLabel")

onready var GameManager = self.get_parent()
var CurrentBuyFunc = null


#TODO: Autogenerate buttons instead
func _ready() -> void:
	UpdateUserCreditTotal()
	SkillModalNode.connect("buy_button_pressed", self, 'OnBuySkill')

#No choice here, each skill node will be hardcoded
func _on_LifeBoost_pressed() -> void:
	SkillModalNode.UpdateSkillModal(Skills.LifeBoost)
	SkillModalNode.visible = true
	CurrentBuyFunc = funcref(self, 'OnBuyLifeBoost')
	pass # Replace with function body.

func _on_Button_pressed() -> void:
	self.visible = false
	GameManager.move_child(self, 0)
	GameManager.ShowWorldMap()
	pass # Replace with function body.

func GetUserCreditTotal():
	return GameManager.GetPlayerCredits()

func UpdateUserCreditTotal():
	UserCreditsTotalLabelNode.set_text('Credits: ' + str(GetUserCreditTotal()))
	
func OnBuySkill(Skill):
	if (CurrentBuyFunc != null):
		CurrentBuyFunc.call_func()
		GameManager.Player.credits -= Skill.cost
	
func OnBuyLifeBoost():
	GameManager.Player.health += 5
	GameManager.Player.maxHealth += 5
	SkillModalNode.visible = false
	LifeBoostButtonNode.disabled = true
