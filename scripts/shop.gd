extends Interactable
class_name shop

@export var cancel_button : Button

func interact():
	Global.new_state(Global.game_states.PAUSED)
	Global.level.ShopGUI.set_visible(true)
	Global.level.worldGUI.set_visible(false)
	cancel_button.grab_focus()


func _on_close_pressed() -> void:
	Global.new_state(Global.game_states.WORLD)
	Global.level.ShopGUI.set_visible(false)
	Global.level.worldGUI.set_visible(true)
