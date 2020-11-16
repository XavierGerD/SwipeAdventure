extends Node

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
	'name': 'Asteroid',
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

onready var LevelOneEncounters = [Encounter1, Encounter2, Encounter3, Encounter4]
