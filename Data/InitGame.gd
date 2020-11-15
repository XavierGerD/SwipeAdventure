extends Node

onready var NewPlayerTemplate = {
	'health': 60,
	'maxHealth': 60,
	'block': 0,
	'energy': 3,
	'maxEnergy': 3,
	'loadout': {
		'weapon': Cards.Welder,
		'shield': Cards.BasicShield
	},
	'inventory': [],
	'credits': 0,
	'stage': null,
}
