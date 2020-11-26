extends Node

onready var NewPlayerTemplate = {
	'health': 60,
	'maxHealth': 60,
	'block': 0,
	'energy': 3,
	'maxEnergy': 3,
	'maxCardsInHand': 3,
	'loadout': {
		'weapon1': Cards.Welder,
		'weapon2': null,
		'weapon3': null,
		'shield': Cards.BasicShield
	},
	'inventory': [Cards.Welder, Cards.PlasmaBolter, Cards.BasicShield],
	'credits': 0,
	'stage': null,
	'skills': {}
}
