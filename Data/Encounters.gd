extends Node

onready var AllEncounters = [LevelOneEncounters, LevelTwoEncounters, LevelThreeEncounters]

var LevelOneEncounters = [
	Encounter1,
	Encounter1,
	Encounter1,
	Encounter2,
]

var LevelTwoEncounters = [
	Encounter2,
	Encounter2,
	Encounter3,
	Encounter3
]

var LevelThreeEncounters = [
	Boss1
]

const Encounter1 = {
	'name': 'Asteroid',
	'enemies': [
		Enemies.Heckler,
		Enemies.SlaveWatcher,
		Enemies.SlaveWatcher
	],
	'completed': false,
}

const Encounter2 = {
	'name': 'Space Station',
	'enemies': [
		Enemies.Heckler,
		Enemies.Heckler,
		Enemies.SlaveWatcher
	],
	'completed': false,
}

const Encounter3 = {
	'name': 'Comet',
	'enemies': [
		Enemies.Heckler,
		Enemies.LongStepper,
	],
	'completed': false,
}

const Encounter4 = {
	'name': 'Astral Body',
	'enemies': [
		Enemies.DuneMaker,
		Enemies.SlaveWatcher,
		Enemies.SlaveWatcher,
		Enemies.SlaveWatcher
	],
}

const Boss1 = {
	'name': 'Argon Moon',
	'enemies' : [
		Enemies.SlaveWatcher,
		Enemies.SlaverMaster,
		Enemies.SlaveWatcher
	]
}
