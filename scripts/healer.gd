extends Interactable

@export var price : int = 150

func interact():
	if Global.level.player.money >= price:
		Global.level.player.money -= price
		description = "[img=100]Assets/Images/InteractIcon.png[/img] [font_size=42]Heal: {price}[/font_size]".format({"price": str(price)})
		price += 50
		Global.level.player.currHP = Global.level.player.maxHP
		Global.level.player.currMP = Global.level.player.maxMP
		Global.level.updateGUI()
		Global.new_state(Global.game_states.WORLD)
	else:
		Global.new_state(Global.game_states.WORLD)
