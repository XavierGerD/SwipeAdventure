extends Node
	
func SetPlayerEnergy(PlayerEnergyLabel, Player, NewEnergyTotal):
	Player.energy = NewEnergyTotal
	PlayerEnergyLabel.set_text(str(Player.energy))

func SetPlayerHealth(PlayerHealthLabel, Player, NewHealthTotal):
	Player.health = NewHealthTotal
	PlayerHealthLabel.set_text(str(Player.health) + '/' + str(Player.maxHealth))

func SetHandTotal(HandTotalLabel, Size):
	HandTotalLabel.set_text('Hand: ' + str(Size))

func SetPlayerBlock(PlayerBlockLabel, Player, NewBlockTotal):
	Player.block = NewBlockTotal
	PlayerBlockLabel.set_text(str(Player.block))

func SetDiscardTotal(DiscardPileTotalLabel, Size):
	DiscardPileTotalLabel.set_text('Discard: ' + str(Size))
	
func SetDrawTotal(DrawPileTotalLabel, Size):
	DrawPileTotalLabel.set_text('Draw: ' + str(Size))
