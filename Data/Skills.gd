extends Node

onready var SkillList = {
	'LifeBloodI': {
		'key': 'LifeBloodI',
		'skillName': 'Life Blood I',
		'description': 'This skill permanently gives you 5 extra hit points.',
		'power': 'plusMaxHealth',
		'effect': 5,
		'cost': 10,
		'hasUserAcquired': false,
		'onBuy': 'OnBuyLifeBoost',
		'prerequisite': null,
	},
	'LifeBloodII': {
		'key': 'LifeBloodII',
		'skillName': 'Life Blood II',
		'description': 'This skill permanently gives you 7 extra hit points.',
		'power': 'plusMaxHealth',
		'effect': 7,
		'cost': 20,
		'hasUserAcquired': false,
		'onBuy': 'OnBuyLifeBoost',
		'prerequisite':'LifeBloodI'
	},
	'LifeBloodIII': {
		'key': 'LifeBloodIII',
		'skillName': 'Life Blood III',
		'description': 'This skill permanently gives you 10 extra hit points.',
		'power': 'plusMaxHealth',
		'effect': 10,
		'cost': 30,
		'hasUserAcquired': false,
		'onBuy': 'OnBuyLifeBoost',
		'prerequisite':'LifeBloodII'
	},
	'PremonitionI': {
		'key': 'PremonitionI',
		'skillName': 'Premonition I',
		'description': 'Once per turn, take a peek at the card under your top card.',
		'power': 'peakLvl1',
		'effect': null,
		'cost': 20,
		'hasUserAcquired': false,
		'onBuy': funcref(self, 'OnBuyLifeBoost'),
		'prerequisite': null
	},
	'PremonitionII': {
		'key': 'PremonitionII',
		'skillName': 'Premonition II',
		'description': 'Always have the ability to peak your second card.',
		'power': 'peakLvl2',
		'effect': null,
		'cost': 20,
		'hasUserAcquired': false,
		'onBuy': funcref(self, 'OnBuyLifeBoost'),
		'prerequisite': 'PremonitionI'
	},
	'HustleI': {
		'key': 'HustleI',
		'skillName': 'Hustle I',
		'description': 'Unlock a second weapon slot.',
		'power': 'unlockSlot',
		'effect': null,
		'cost': 20,
		'hasUserAcquired': false,
		'onBuy': funcref(self, 'OnBuyLifeBoost'),
		'prerequisite': null
	},
	'HustleII': {
		'key': 'HustleII',
		'skillName': 'Hustle II',
		'description': 'Unlock a third weapon slot.',
		'power': 'unlockSlot',
		'effect': null,
		'cost': 20,
		'hasUserAcquired': false,
		'onBuy': funcref(self, 'OnBuyLifeBoost'),
		'prerequisite': 'HustleI'
	},
	'DeterminationI': {
		'key': 'DeterminationI',
		'skillName': 'Determination I',
		'description': 'At the end of your turn, if you skipped all the cards in your hand, draw another card.',
		'power': 'drawAtEndOfTurn',
		'effect': null,
		'cost': 20,
		'hasUserAcquired': false,
		'onBuy': funcref(self, 'OnBuyLifeBoost'),
		'prerequisite': null
	},
	'DeterminationII': {
		'key': 'DeterminationII',
		'skillName': 'Determination II',
		'description': 'At the end of your turn, gain 1 health for each card you skipped.',
		'power': 'drawAtEndOfTurn',
		'effect': 1,
		'cost': 20,
		'hasUserAcquired': false,
		'onBuy': funcref(self, 'OnBuyLifeBoost'),
		'prerequisite': 'DeterminationII'
	},
	'LongevityI': {
		'key': 'LongevityI',
		'skillName': 'Longevity I',
		'description': 'Increase the maximum number of cards in your hand by one.',
		'power': 'increaseHandSize',
		'effect': 1,
		'cost': 20,
		'hasUserAcquired': false,
		'onBuy': 'OnBuyLongevity',
		'prerequisite': null
	},
	'LongevityII': {
		'key': 'LongevityII',
		'skillName': 'Longevity II',
		'description': 'Increase the maximum number of cards in your hand by one.',
		'power': 'increaseHandSize',
		'effect': 1,
		'cost': 40,
		'hasUserAcquired': false,
		'onBuy': 'OnBuyLongevity',
		'prerequisite': 'LongevityI'
	},
}

func OnBuyLifeBoost(GameManager, Effect):
	GameManager.Player.health += Effect
	GameManager.Player.maxHealth += Effect

func OnBuyLongevity(GameManager, Effect):
	GameManager.Player.maxCardsInHand += Effect
