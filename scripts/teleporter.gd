extends Interactable
class_name Teleporter

@export var boss : PackedScene
@export var static_body : StaticBody3D
@export var next_level : PackedScene

@export var boss_won : bool = false

func interact():
	if boss_won:
		Global.new_state(Global.game_states.PAUSED)
		Global.level.animation_player.play("start_battle")
		await Global.level.animation_player.animation_finished
		Global.level.player.get_parent().remove_child(Global.level.player)
		Global.world_timer.get_parent().remove_child(Global.world_timer)
		get_tree().change_scene_to_packed(next_level)
	else:
		await Global.level.enter_battle(boss.instantiate())
		boss_won = true

func level_beat():
	set_visible(true)
	static_body.collision_layer = 1
