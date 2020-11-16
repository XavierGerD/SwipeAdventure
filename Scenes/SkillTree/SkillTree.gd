extends Node2D

signal buy_skill(GameManager, SkillModalNode, ButtonNode)

onready var SkillModalNode = get_node("SkillModal")
onready var UserCreditsTotalLabelNode = get_node("UserCreditsTotalLabel")

const ControlButtonPath = "TreeContainer/"

onready var GameManager = self.get_parent()
var CurrentBuySignal = null
var CurrentBuyButton

func _ready() -> void:
	InstanciateSkillButtons()
	UpdateUserCreditTotal()
	SkillModalNode.connect("buy_button_pressed", self, 'OnBuySkill')
	
func UpdatePrerequisited():
	for Skill in Skills.SkillList.values():
		var SkillButton = get_node(ControlButtonPath + Skill.key)
		if (Skill.prerequisite != null):
			if !(Skill.prerequisite in GameManager.Player.skills):
				SkillButton.disabled = true
			else:
				SkillButton.disabled = false
		if (Skill.key in GameManager.Player.skills):
			SkillButton.disabled = true
			

func InstanciateSkillButtons():
	for Skill in Skills.SkillList.values():
		print("TreeContainer/" + Skill.key)
		var SkillNodeButton = get_node(ControlButtonPath + Skill.key)
		SkillNodeButton.connect('pressed', self, 'OnSkillButtonPressed', [Skill, SkillNodeButton])
		SkillNodeButton.set_text(Skill.skillName)
	UpdatePrerequisited()

func OnSkillButtonPressed(Skill, SkillNodeButton):
	SkillModalNode.UpdateSkillModal(Skill)
	SkillModalNode.visible = true
	CurrentBuySignal = Skill.onBuy
	CurrentBuyButton = SkillNodeButton

func _on_Button_pressed() -> void:
	self.visible = false
	GameManager.move_child(self, 0)
	GameManager.ShowWorldMap()

func GetUserCreditTotal():
	return GameManager.GetPlayerCredits()

func UpdateUserCreditTotal():
	UserCreditsTotalLabelNode.set_text('Credits: ' + str(GetUserCreditTotal()))
	
func OnBuySkill(Skill):
	if (CurrentBuySignal != null):
		self.connect('buy_skill', Skills, CurrentBuySignal)
		emit_signal('buy_skill', GameManager, Skill.effect)
		GameManager.Player.credits -= Skill.cost
		SkillModalNode.visible = false
		UpdateUserCreditTotal()
		GameManager.Player.skills[Skill.key] = Skill.skillName
		UpdatePrerequisited()
	
