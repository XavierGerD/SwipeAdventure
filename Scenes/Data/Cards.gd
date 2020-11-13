extends Node

func _onready() -> void:
	pass

const Weld = {
		'name': 'Weld',
		'cost': 1,
		'damage': 3,
		'block': null,
		'special': null,
		'description': 'Use your welder to deal 3 damage'
	}

const ShieldCharge = {
		'name': 'Shield Charge',
		'cost': 1,
		'damage': null,
		'block': 3,
		'special': null,
		'description': 'Charge up your shield and gain 3 block'
	}

const PlasmaBolt = {
	'name': 'Plasma Bolt',
	'cost': 2,
	'damage': 5,
	'block': null,
	'special': {
		'damage': 7,
		'condition': 'discard'
	},
	'description': 'Deal 5 damage with your plasma bolt. Overload this card to deal 7 damage and discard it.'
}
