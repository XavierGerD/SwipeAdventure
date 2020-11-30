extends Node2D

signal buy_skill(GameManager, SkillModalNode, ButtonNode)

onready var SkillModalNode = get_node("SkillModal")
onready var UserCreditsTotalLabelNode = get_node("UserCreditsTotalLabel")
onready var TreeContainer = get_node("TreeContainer")

const ControlButtonPath = "TreeContainer/"

onready var GameManager = self.get_parent()
var CurrentBuySignal = null
var CurrentBuyButton
var IsClicked
var DeltaY
var TotalDisplacementY
var MousePosition

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
		print("Skill.key ",Skill.key)
		var SkillNodeButton = get_node(ControlButtonPath + Skill.key)
		SkillNodeButton.connect('pressed', self, 'OnSkillButtonPressed', [Skill, SkillNodeButton])
		SkillNodeButton.set_text(Skill.skillName)
	UpdatePrerequisited()

func OnSkillButtonPressed(Skill, SkillNodeButton):
	$AudioPlayer.stream = load("res://Sound/SFX/Click.wav")
	$AudioPlayer.play()
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
	$AudioPlayer.stream = load("res://Sound/SFX/BuySkill.wav")
	$AudioPlayer.play()
	if (CurrentBuySignal != null):
# warning-ignore:return_value_discarded
		print(CurrentBuySignal)
		self.connect('buy_skill', Skills, CurrentBuySignal)
		emit_signal('buy_skill', GameManager, Skill.effect)
		self.disconnect('buy_skill', Skills, CurrentBuySignal)
		GameManager.Player.credits -= Skill.cost
		SkillModalNode.visible = false
		UpdateUserCreditTotal()
		GameManager.Player.skills[Skill.key] = Skill.skillName
		UpdatePrerequisited()
	
func _input(event):
	if "position" in event:
		MousePosition = event.position.y
		if IsClicked:
			TotalDisplacementY = event.position.y - DeltaY
			TreeContainer.set_position(Vector2(TreeContainer.get_position().x, TotalDisplacementY))
			if (TreeContainer.get_position().y > -500):
				TreeContainer.set_position(Vector2(TreeContainer.get_position().x, -500))

func _on_TreeContainer_button_up() -> void:
	IsClicked = false
	pass # Replace with function body.


func _on_TreeContainer_button_down() -> void:
	DeltaY = MousePosition - TreeContainer.get_position().y
	IsClicked = true
	pass # Replace with function body.
