extends Node2D

onready var WeaponSlotOne = get_node("WeaponSlot1")
onready var WeaponSlotTwo = get_node("WeaponSlot2")
onready var WeaponSlotThree = get_node("WeaponSlot3")
onready var ShieldSlot = get_node("ShieldSlot")
onready var InventoryBox = get_node("InventoryBox")
onready var WeaponSlots = [WeaponSlotOne, WeaponSlotTwo, WeaponSlotThree, InventoryBox]

onready var GameManager = self.get_parent()
onready var DraggableIconNode = load('res://Scenes/Inventory/DraggableIcon.tscn')

const ACTIVE_COLOR = '#757575'
const DISABLED_COLOR = '#343333'
var MousePointer

func _on_HideButton_pressed() -> void:
	self.visible = false
	GameManager.move_child(self, 0)
	GameManager.ShowWorldMap()

func _input(event):
	MousePointer = event.position
	
func AddNewIcon(Item):
	var NewDraggableIcon = DraggableIconNode.instance()
	InventoryBox.add_child(NewDraggableIcon)
	NewDraggableIcon.InstanciateDraggableIcon(Item)
	NewDraggableIcon.connect('icon_dropped', self, 'OnIconDrop')

func InitializeSlot(Slot, Disabled):
	var Background = get_node(Slot.get_name() + 'BackGround')
	print(Background)
	if Disabled:
		Slot.IsDisabled = true
		Background.color = DISABLED_COLOR
	else:
		Slot.IsDisabled = false
		Background.color = ACTIVE_COLOR

func AssignIconToSlot(Item, Icon):
	if (Item.name == GameManager.Player.loadout.weapon1.name):
		WeaponSlotOne.add_child(Icon)
	elif (
		Item.name == GameManager.Player.loadout.weapon2.name
	):
		WeaponSlotTwo.add_child(Icon)
	elif (
		Item.name == GameManager.Player.loadout.weapon3.name
	):
		WeaponSlotThree.add_child(Icon)
	elif (Item.name == GameManager.Player.loadout.shield.name):
		ShieldSlot.add_child(Icon)
	else:
		InventoryBox.add_child(Icon)

#This is getting ugly
func FindSlotForPlayerLoadout(LoadoutSlot):
	var ReturnedSlot
	for WeaponSlot in WeaponSlots:
		#print(LoadoutSlot, WeaponSlot.Name)
		if LoadoutSlot == WeaponSlot.Name:
			ReturnedSlot = WeaponSlot
	return ReturnedSlot

func _ready():
	var Inventory = GameManager.Player.inventory
	var Loadout = GameManager.Player.loadout.keys()
	var LoadoutValues = GameManager.Player.loadout.values()
	for i in range(Loadout.size()):
		var Disabled = LoadoutValues[i].name == 'closed'
		var WeaponSlot = FindSlotForPlayerLoadout(Loadout[i])
		if WeaponSlot:
			InitializeSlot(WeaponSlot, Disabled)
	
	for i in range(Inventory.size()):
		var NewDraggableIcon = DraggableIconNode.instance()
		AssignIconToSlot(Inventory[i], NewDraggableIcon)
		NewDraggableIcon.InstanciateDraggableIcon(Inventory[i])
		NewDraggableIcon.connect('icon_dropped', self, 'OnIconDrop')

func DetectCollisionForDrop(Slot):
	if (MousePointer.x > Slot.get_position().x &&
		MousePointer.x < Slot.get_position().x + Slot.rect_size.x &&
		MousePointer.y > Slot.get_position().y &&
		MousePointer.y < Slot.get_position().y + Slot.rect_size.y):
		return true
	return false

func GetPositionInSlotWithOffset(Slot):
	return Vector2(Slot.get_position().x + 8, Slot.get_position().y + 8)
	
func GetPositionInBoxWithOffset(Index):
	return Vector2(InventoryBox.get_position().x + 8 + Index * 128, 800)

func SetPositionInsideSlot(Icon, Slot):
	Icon.set_position(GetPositionInSlotWithOffset(Slot))
	
func FindInterSectingBoxes(Boxes):
	var IntersectingBox = false
	for Box in Boxes:
		var IsMouseIntersecting = DetectCollisionForDrop(Box)
		if IsMouseIntersecting:
			IntersectingBox = Box
	return IntersectingBox	

func AddIconToNewParent(Icon, Parent):
	Icon.get_parent().remove_child(Icon)
	Parent.add_child(Icon)
	
func GetCanIconBeDroppedInSlot(Slot, Icon):
	return !Slot.IsDisabled && Slot.Type == Icon.Type

func OnIconDrop(DraggableIcon):
	var IntersectingBox = FindInterSectingBoxes(WeaponSlots)
	if !IntersectingBox:
		var CurrentParent = DraggableIcon.get_parent()
		AddIconToNewParent(DraggableIcon, CurrentParent)
		return
		
	if IntersectingBox.Type == DraggableIcon.Type:
		#if item can't be dropped, restore it to its old parent
		if (!GetCanIconBeDroppedInSlot(IntersectingBox, DraggableIcon)):
			AddIconToNewParent(DraggableIcon, DraggableIcon.get_parent())
			return
		#If already an item in slot, remove the old one
		if IntersectingBox.get_child(0) != null:
			AddIconToNewParent(IntersectingBox.get_child(0), InventoryBox)
		#In any case, add the dragged item to the slot and update player loadout
		AddIconToNewParent(DraggableIcon, IntersectingBox)
		GameManager.Player.loadout[IntersectingBox.Name] = DraggableIcon.Item
		
	if IntersectingBox.Type == 'inventory':
		AddIconToNewParent(DraggableIcon, IntersectingBox)
		IntersectingBox.move_child(DraggableIcon, IntersectingBox.get_child_count())
	AddIconToNewParent(DraggableIcon, DraggableIcon.get_parent())
