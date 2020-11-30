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
		'weapon2': ClosedSlot,
		'weapon3': ClosedSlot,
		'shield': Cards.BasicShield
	},
	'inventory': [Cards.Welder, Cards.BasicShield],
	'looseCards': [],
	'credits': 0,
	'stage': null,
	'skills': {}
}

var UnusedSlot = { 'name': 'unused'}
var ClosedSlot = { 'name': 'closed'}

func _ready():
	# XXX: workaround godot web audio latency issue by recreating script processor
	var jsCode = """
		setTimeout(function () {
			var channelCount = _audioDriver_audioContext.destination.channelCount;
			var bufferSize = _audioDriver_scriptNode.bufferSize;
			var process = _audioDriver_scriptNode.onaudioprocess;
			_audioDriver_scriptNode.disconnect();
			_audioDriver_scriptNode = _audioDriver_audioContext.createScriptProcessor(bufferSize, 2, channelCount);
			_audioDriver_scriptNode.onaudioprocess = process;
			_audioDriver_scriptNode.connect(_audioDriver_audioContext.destination);
		}, 0);
	"""
	if OS.get_name() == 'HTML5':
		JavaScript.eval(jsCode)
