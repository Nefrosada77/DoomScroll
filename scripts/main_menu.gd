extends SubViewportContainer

@export var animation : AnimationPlayer

var options : bool = false

func _ready() -> void:
	material.set_shader_parameter("progress", .0)
	%START.grab_focus()


func _on_start_pressed() -> void:
	#TODO REMOVE AFTER
	Global.player = Global.debug_player_scene.instantiate() #DEBUG PLAYER
	%START.disabled = true
	animation.play("start_game")
	await animation.animation_finished
	%AudioStreamPlayer.stop()
	get_tree().change_scene_to_node(Global.levels[0][0].instantiate())

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("return"):
		if options:
			options = false
			%OptionsMenu.set_visible(false)
			%StartMenu.set_visible(true)
			%START.grab_focus()

func _on_options_pressed() -> void:
	options = true
	%StartMenu.set_visible(false)
	%OptionsMenu.set_visible(true)
	%OptionsMenu.get_tab_bar().grab_focus()
