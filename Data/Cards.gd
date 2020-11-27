extends Node

func _onready() -> void:
	pass

	
onready var BasicShield = {
	'name': 'Basic Shield', 
	'imagePath':'whatever.jpg',
	'type': 'shield',
	'upgrades': null,
	'cost': 0,
	'cardList': [
		ShieldCharge,
		ShieldCharge
	]
}

onready var Welder = {
	'name': 'Welder', 
	'imagePath':'whatever.jpg',
	'type': 'weapon',
	'upgrades': null,
	'cost': 50,
	'cardList': [
		Weld,
		Weld,
		Weld,
		Repair,	
		OverCharge,
	]
}
	
onready var PlasmaBolter = {
	'name': 'Plasma Bolter', 
	'imagePath':'whatever.jpg',
	'type': 'weapon',
	'upgrades': null,
	'cost': 100,
	'cardList': [
		QuickShot,
		QuickShot,
		QuickShot,
		SteadySight,
		RevUp
	]
}

onready var PlasmaRifle = {
	'name': 'Plasma Rifle', 
	'imagePath':'whatever.jpg',
	'type': 'weapon',
	'upgrades': null,
	'cost': 200,
	'cardList': [
		IronSights,
		IronSights,
		RapidFire,
		Collateral,
		Collateral
	]
}

#onready var PowerHammer = {
#	'name': 'Plasma Rifle', 
#	'imagePath':'whatever.jpg',
#	'type': 'weapon',
#	'upgrades': null,
#	'cost': 100,
#	'cardList': [
#		HammerDown,
#		HammerDown,
#		HammerSpin,
#		Stun,
#		Stun,
#		Fury
#	]
#}

onready var GrenadeLauncher = {
	'name': 'Grenade Launcher', 
	'imagePath':'whatever.jpg',
	'type': 'weapon',
	'upgrades': null,
	'cost': 250, 
	'cardList': [
		LobbedShot,
		ClusterBomb,
		PrimedGrenade,
		PrimedGrenade,
		PrimedGrenade
	]
}
	
onready var AllItems = [
	BasicShield,
	Welder,
	PlasmaBolter,
	PlasmaRifle,
	GrenadeLauncher
]

const ShieldCharge = {
	'name': 'Shield Charge',
	'description': 'Gain {blk} block.',
	'texturePath': 'res://Sprite/CardImages/ShieldCharge.jpg',
	'onAction': {
		'cost': 1,
		'damage': null,
		'block': 2,
		'special': null,
		'heal': null,
		'power': null,
		'stun': null,
		'effect': null,
	},
	'onSpecial': null,
	'onSkip': null,
}

const Fortify = {
	'name': 'Fortify',
	'description': 'Gain {blk} block.',
	'texturePath': 'res://Sprite/CardImages/Common/Fortify.png',
	'onAction': {
		'cost': 2,
		'damage': null,
		'block': 6,
		'special': null,
		'heal': null,
		'power': null,
		'stun': null,
		'effect': null,
	},
	'onSpecial': null,
	'onSkip': null,
}

const Energize = {
	'name': 'Energize',
	'description': 'Restore 1 energy.',
	'texturePath': 'res://Sprite/CardImages/Common/Energize.png',
	'onAction': {
		'cost': 0,
		'damage': null,
		'block': null,
		'special': null,
		'heal': null,
		'power': ['restoreEnergy'],
		'stun': null,
		'effect': 1,
	},
	'onSpecial': null,
	'onSkip': null,
}

const Phaser = {
	'name': 'Phaser',
	'description': 'Stun an enemy for 1 turn.',
	'texturePath': 'res://Sprite/CardImages/Common/Phaser.png',
	'onAction': {
		'cost': 0,
		'damage': null,
		'block': null,
		'special': null,
		'heal': null,
		'power': null,
		'stun': 1,
		'effect': null,
	},
}

const StrangeBrew = {
	'name': 'StrangeBrew',
	'description': 'Heal {hp} HP. Skip your next card.',
	'texturePath': 'res://Sprite/CardImages/Common/StrangeBrew.png',
	'onAction': {
		'cost': 0,
		'damage': null,
		'block': null,
		'special': null,
		'heal': 7,
		'power': ['skipNext'],
		'stun': null,
		'effect': null,
	},
	'onSpecial': null,
	'onSkip': null,
}

const Focus = {
	'name': 'Focus',
	'description': 'For each card you skip until your next attack, deal 2 additional damage on your next attack.',
	'texturePath': 'res://Sprite/CardImages/Common/Focus.png',
	'onAction': {
		'cost': 2,
		'damage': null,
		'block': null,
		'special': null,
		'heal': null,
		'power': ['focus'],
		'stun': null,
		'effect': null,
	},
	'onSpecial': null,
	'onSkip': null,
}


const Restoration = {
	'name': 'Restoration',
	'description': 'All your cards gain “Heal 1 HP on skip.” until the end of combat.',
	'texturePath': 'res://Sprite/CardImages/Common/Restoration.png',
	'onAction': {
		'cost': 3,
		'damage': null,
		'block': null,
		'special': null,
		'heal': null,
		'power': ['appendEffect'],
		'stun': null,
		'effect': {
			'onSkip' : {
				'cost': null,
				'damage': null,
				'block': null,
				'special': null,
				'heal': 1,
				'power': null,
				'stun': null,
				'effect': null,
			}
		},
	},
	'onSpecial': null,
	'onSkip': null,
}

const Agression = {
	'name': 'Restoration',
	'description': 'All your cards gain “Deal 1 damage on skip.” until the end of combat.',
	'texturePath': 'res://Sprite/CardImages/Common/Aggression.png',
	'onAction': {
		'cost': 3,
		'damage': null,
		'block': null,
		'special': null,
		'heal': null,
		'power': ['appendEffect'],
		'stun': null,
		'effect': {
			'onSkip' : {
				'cost': null,
				'damage': 1,
				'block': null,
				'special': null,
				'heal': null,
				'power': null,
				'stun': null,
				'effect': null,
			}
		},
	},
	'onSpecial': null,
	'onSkip': null,
}

const Ionization = {
	'name': 'Restoration',
	'description': 'All your cards gain “Gain 2 block on skip.” until the end of combat.',
	'texturePath': 'res://Sprite/CardImages/Common/Ionization.png',
	'onAction': {
		'cost': 3,
		'damage': null,
		'block': null,
		'special': null,
		'heal': null,
		'power': ['appendEffect'],
		'stun': null,
		'effect': {
			'onSkip' : {
				'cost': null,
				'damage': null,
				'block': 2,
				'special': null,
				'heal': null,
				'power': null,
				'stun': null,
				'effect': null,
			}
		},
	},
	'onSpecial': null,
	'onSkip': null,
}

#Welder loadout
const Weld = {
	'name': 'Weld',
	'description': 'Deal {dmg} damage.',
	'texturePath': 'res://Sprite/CardImages/Welder/Weld.png',
	'onAction': {
		'cost': 1,
		'damage': 2,
		'block': null,
		'special': null,
		'heal': null,
		'power': null,
		'stun': null,
		'effect': null,
	},
	'onSpecial': null,
	'onSkip': null,
}


const Repair = {
	'name': 'Repair',
	'description': 'Heal {hp} HP.',
	'texturePath': 'res://Sprite/CardImages/Welder/Repair.png',
	'onAction': {
		'cost': 2,
		'damage': null,
		'block': null,
		'special': null,
		'heal': 1,
		'power': null,
		'stun': null,
		'effect': null,
	},
	'onSpecial': null,
	'onSkip': null,
}
	
const OverCharge = {
	'name': 'Plasma Bolt',
	'description': 'Deal {dmg} damage. Overload this card to deal {spDmg} damage and remove it from the game until the end of battle.',
	'texturePath': 'res://Sprite/CardImages/Welder/Overcharge.png',
	'onAction': {
		'cost': 2,
		'damage': 3,
		'block': null,
		'heal': null,
		'power': null,
		'stun': null,
		'effect': null,
	},
	'onSpecial': {
		'cost': null,
		'block': null,
		'damage': 5,
		'power': ['removeFromGame'],
		'effect': null,
		'heal': null
	},
	'onSkip': null
}
	
#Plasma Bolter loadout
const QuickShot = {
	'name': 'Quick Shot',
	'description': 'Deal {dmg} damage.',
	'texturePath': 'res://Sprite/CardImages/PlasmaBolter/QuickShot.png',
	'onAction': {
		'cost': 1,
		'damage': 3,
		'block': null,
		'special': null,
		'heal': null,
		'power': null,
		'stun': null,
		'effect': null,
	},
	'onSpecial': null,
	'onSkip': null,
}

const SteadySight = {
	'name': 'Steady Sight',
	'description': 'Deal {dmg} damage. Overload: pay 2 energy to deal {spDmg} damage next turn.',
	'texturePath': 'res://Sprite/CardImages/PlasmaBolter/SteadyShot.png',
	'onAction': {
		'cost': 2,
		'damage': 4,
		'block': null,
		'heal': null,
		'power': null,
		'stun': null,
		'effect': null,
	},
	'onSpecial': {
		'cost': null,
		'damage': null,
		'condition': null,
		'heal': null,
		'block': null,
		'power': ['pendingDamage'],
		'effect': 6
	},
	'onSkip': null
}

const RevUp = {
	'name': 'Rev Up',
	'description': 'Your next attack deals double damage.',
	'texturePath': 'res://Sprite/CardImages/PlasmaBolter/RevUp.png',
	'onAction': {
		'cost': 2,
		'damage': null,
		'block': null,
		'special': null,
		'heal': null,
		'stun': null,
		'effect': null,
		'power': ['doubleDamage'],
	},
	'onSpecial': null,
	'onSkip': null,
}

# Plasma Rifle loadout 
const IronSights = {
	'name': 'Iron Sights',
	'description': 'Deal {dmg} damage.',
	'texturePath': 'res://Sprite/CardImages/PlasmaRifle/IronSight.png',
	'onAction': {
		'cost': 1,
		'damage': 3,
		'block': null,
		'special': null,
		'heal': null,
		'stun': null,
		'power': null,
		'effect': null,
	},
	'onSpecial': null,
	'onSkip': null,
}

const RapidFire = {
	'name': 'Rapid Fire',
	'description': 'Deal {dmg} damage to all enemies. Overload: pay 3 energy to deal {spDmg} damage to all enemies.',
	'texturePath': 'res://Sprite/CardImages/PlasmaRifle/RapidFire.png',
	'onAction': {
		'cost': 2,
		'damage': 2,
		'block': null,
		'heal': null,
		'stun': null,
		'effect': 2,
		'power': ['allEnemies'],
	},
	'onSpecial': {
		'damage': 3,
		'cost': 3,
		'condition': null,
		'heal': null,
		'block': null,
		'power': ['allEnemies'],
		'effect': 3
	},
	'onSkip': null
}

const Collateral = {
	'name': 'Collateral',
	'description': 'Deal {dmg} damage to the target enemy and {efDmg} damage to all other enemies.',
	'texturePath': 'res://Sprite/CardImages/PlasmaRifle/Collateral.png',
	'onAction': {
		'cost': 1,
		'damage': 3,
		'block': null,
		'special': null,
		'heal': null,
		'stun': null,
		'power': ['allEnemies'],
		'effect': 1,
	},
	'onSpecial': null,
	'onSkip': null,
}

#Power Hammer
const HammerDown = {
	'name': 'Hammer Down',
	'description': 'Deal {dmg} damage. Lose {hp} health. Overload: deal 6 damage and receive 1 stun.',
	'texturePath': 'res://Sprite/CardImages/RevUp.png',
	'onAction': {
		'cost': 1,
		'damage': 4,
		'block': null,
		'heal': -1,
		'stun': null,
		'effect': null,
		'power': null,
	},
	'onSpecial': {
		'damage': 6,
		'cost': null,
		'condition': null,
		'heal': null,
		'block': null,
		'power': ['selfStun'],
		'effect': 1
	},
	'onSkip': null
}

const HammerSpin = {
	'name': 'Hammer Spin',
	'description': 'Deal {dmg} damage to all enemies and to yourself. Overload: deal {spDmg} damage to all enemies and {spHp} damage to yourself.',
	'texturePath': 'res://Sprite/CardImages/RevUp.png',
	'onAction': {
		'cost': 2,
		'damage': 2,
		'block': null,
		'heal': -2,
		'stun': null,
		'effect': null,
		'power': ['allEnemies'],
	},
	'onSpecial': {
		'damage': 4,
		'cost': null,
		'condition': null,
		'heal': -4,
		'block': null,
		'power': ['allEnemies', 'selfStun'],
		'effect': 1
	},
	'onSkip': null
}

const Stun = {
	'name': 'Stun',
	'effect': 1,
	'description': 'Deal {dmg} damage. Stun an enemy for 1 turn. Lose {hp} health.',
	'texturePath': 'res://Sprite/CardImages/RevUp.png',
	'onAction': {
		'cost': 1,
		'damage': 3,
		'block': null,
		'special': null,
		'heal': -1,
		'stun': null,
		'power': ['stun'],
	},
	'onSpecial': null,
	'onSkip': null,
}

const Fury = {
	'name': 'Stun',
	'description': 'Deal 2X damage to a target enemy and receive X damage.',
	'texturePath': 'res://Sprite/CardImages/RevUp.png',
	'onAction': {
		'cost': 2,
		'damage': null,
		'block': null,
		'special': null,
		'heal': -1,
		'stun': null,
		'power': ['scalableCost'],
		'effect': null,
	},
	'onSpecial': null,
	'onSkip': null,
}

#Grenade Launcher
const LobbedShot = {
	'name': 'Lobbed Shot',
	'description': 'Deal 8 damage. Skip your next card.',
	'texturePath': 'res://Sprite/CardImages/GrenadeLauncher/LobbedShot.png',
	'onAction': {
		'cost': 3,
		'damage': 8,
		'block': null,
		'special': null,
		'heal': null,
		'stun': null,
		'power': ['skipNext'],
		'effect': null,
	},
	'onSpecial': null,
	'onSkip': null,
}

const ClusterBomb = {
	'name': 'Cluster Bomb',
	'description': 'Deal {dmg} damage to all enemies. Skipping this card deals 1 damage to you.',
	'texturePath': 'res://Sprite/CardImages/GrenadeLauncher/ClusterBomb.png',
	'onAction': {
		'cost': 1,
		'damage': 2,
		'block': null,
		'special': null,
		'heal': null,
		'stun': null,
		'power': ['allEnemies'],
		'effect': null,
	},
	'onSkip': {
		'cost': null,
		'damage': null,
		'block': null,
		'special': null,
		'heal': -1,
		'stun': null,
		'power': null,
		'effect': null,
	},
	'onSpecial': null
}

const PrimedGrenade = {
	'name': 'PrimedGrenade',
	'description': 'Deal {dmg} damage. Skipping this card deals 1 damage to you.',
	'texturePath': 'res://Sprite/CardImages/GrenadeLauncher/PrimedGrenade.png',
	'onAction': {
		'cost': 2,
		'damage': 4,
		'block': null,
		'special': null,
		'heal': null,
		'stun': null,
		'power': null,
		'effect': 2,
	},
	'onSkip': {
		'cost': null,
		'damage': null,
		'block': null,
		'special': null,
		'heal': -1,
		'stun': null,
		'power': null,
		'effect': null,
	},
	'onSpecial': null
}
