extends Node2D

signal buy_button_pressed

onready var DescriptionLabelNode = get_node("DescriptionLabel")
onready var SkillnameLabelNode = get_node("SkillNameLabel")
onready var CostLabelNode = get_node("CostLabel")
onready var BuyButtonNode = get_node("BuyButton")

var CurrentSkill

func UpdateSkillModal(Skill):
	DescriptionLabelNode.set_text(Skill.description)
	SkillnameLabelNode.set_text(Skill.skillName)
	CostLabelNode.set_text('Credits: ' + str(Skill.cost))
	CurrentSkill = Skill
	SetCanUserBuySkill(Skill)
	pass
	
func SetCanUserBuySkill(Skill):
	if GetCanUserBuySkill(Skill):
		BuyButtonNode.disabled = false
		return
	BuyButtonNode.disabled = true
		
func GetCanUserBuySkill(Skill):
	var UserCreditTotal = GetUserCreditTotal()
	if UserCreditTotal >= Skill.cost:
		return true	
	return false
	
# Is there a better way than hard-coupling these scenes?
func GetUserCreditTotal():
	return self.get_parent().get_parent().GetPlayerCredits()

func _on_CancelButton_pressed() -> void:
	self.visible = false
	self.get_parent().CurrentBuySignal = null
	self.get_parent().CurrentBuyButton = null
	pass # Replace with function body.

func _on_BuyButton_pressed() -> void:
	emit_signal("buy_button_pressed", CurrentSkill)
	pass # Replace with function body.
