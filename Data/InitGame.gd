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
		'weapon2': UnusedSlot,
		'weapon3': ClosedSlot,
		'shield': Cards.BasicShield
	},
	'inventory': [Cards.Welder, Cards.PlasmaBolter, Cards.BasicShield],
	'credits': 0,
	'stage': null,
	'skills': {}
}

var UnusedSlot = { 'name': 'unused'}
var ClosedSlot = { 'name': 'closed'}
