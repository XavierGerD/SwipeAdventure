extends Node

func _onready() -> void:
	pass
	
onready var BasicShield = [
	ShieldCharge,
	ShieldCharge
]

onready var Welder = [
	Weld,
	Weld,
	Weld,
	Repair,
]
	
onready var PlasmaBolter = [
	PlasmaBolt,
	PlasmaBolt,
	QuickShot,
	QuickShot,
	SteadySight,
	RevUp
]
#Welder loadout
const Weld = {
		'name': 'Weld',
		'cost': 1,
		'damage': 2,
		'block': null,
		'special': null,
		'heal': null,
		'power': null,
		'description': 'Deal {dmg} damage.',
		'texturePath': 'res://Sprite/CardImages/Weld.png' 
	}

const ShieldCharge = {
		'name': 'Shield Charge',
		'cost': 1,
		'damage': null,
		'block': 2,
		'special': null,
		'heal': null,
		'power': null,
		'description': 'Gain {blk} block.',
		'texturePath': 'res://Sprite/CardImages/ShieldCharge.jpg' 
	}

const Repair = {
	'name': 'Repair',
	'cost': 2,
	'damage': null,
	'block': null,
	'special': null,
	'heal': 1,
	'power': null,
	'description': 'Heal {hp} HP.',
	'texturePath': 'res://Sprite/CardImages/Weld.png' 
	}
	

#Plasma Bolter loadout
const PlasmaBolt = {
	'name': 'Plasma Bolt',
	'cost': 2,
	'damage': 2,
	'block': null,
	'heal': null,
	'power': null,
	'special': {
		'damage': 4,
		'condition': 'discard',
		'power': null,
		'effect': null
	},
	'description': 'Deal {dmg} damage. Overload this card to deal {spDmg} damage and discard it.',
	'texturePath': 'res://Sprite/CardImages/PlasmaBolt.jpg' 
	}

const QuickShot = {
		'name': 'Quick Shot',
		'cost': 1,
		'damage': 3,
		'block': null,
		'special': null,
		'heal': null,
		'power': null,
		'description': 'Deal {dmg} damage.',
		'texturePath': 'res://Sprite/CardImages/QuickShot.png' 
	}

const SteadySight = {
	'name': 'Steady Sight',
	'cost': 2,
	'damage': 4,
	'block': null,
	'heal': null,
	'power': null,
	'special': {
		'damage': null,
		'condition': null,
		'power': 'pendingDamage',
		'effect': 6
	},
	'description': 'Deal {dmg} damage. Overload: pay 2 energy to deal {spDmg} damage next turn.',
	'texturePath': 'res://Sprite/CardImages/SteadyShot.png' 
	}

const RevUp = {
	'name': 'Rev Up',
	'cost': 2,
	'damage': null,
	'block': null,
	'special': null,
	'heal': null,
	'power': 'doubleDamage',
	'description': 'Your next attack deals double damage.',
	'texturePath': 'res://Sprite/CardImages/RevUp.png' 
	}
