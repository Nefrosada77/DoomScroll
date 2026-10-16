extends Node3D
class_name Level

enum level_type {COMBAT, ELITE, BOSS, SHOP, HEAL, EVENT}
enum encounter {CALM, WARNING, COMBAT}

@export var level_id : int = 0
@export var level_color : Color = Color(1,1,1)
@export var type : level_type
@export var spawn_point : Marker3D
@export var animation_player : AnimationPlayer
@export var world : Node3D
@export var interact_label : RichTextLabel
@export var encounter_radar : PanelContainer
@export var battle : bool = true
@export var worldGUI : Control
@export var healthGUI : ProgressBar
@export var manaGUI : ProgressBar
@export var levelGUI : ProgressBar
@export var ambient_player : AudioStreamPlayer
@export var world_level_label : Label
@export var world_level_bar : ProgressBar
@export var world_timer_label : Label

var player : Player
const battle_scene = preload("res://scenes/battle.tscn")
var battling_enemy : Enemy
var encounter_state : encounter = encounter.CALM

signal enemy_defeat

func _ready() -> void:
	Global.level = self
	add_child(Global.world_timer)
	world_level_bar.max_value = Global.world_timer.wait_time
	animation_player.play_backwards("start_battle")
	player = Global.player
	world.add_child(player)
	player.global_position = spawn_point.global_position
	player.set_process(true)
	updateGUI()
	Global.curr_level_color = level_color
	RenderingServer.global_shader_parameter_set("level_color", level_color)
	await animation_player.animation_finished
	Global.new_state(Global.game_states.WORLD)
	Global.world_timer.start()

func _physics_process(_delta: float) -> void:
	world_level_bar.value = Global.world_timer.time_left
	world_timer_label.text = "{0} / {1}".format({"0": "%0.2f" % Global.world_timer.time_left, "1": "%0.2f" % Global.world_timer.wait_time})
	if battle:
		if Global.game_state == Global.game_states.WORLD:
			if player.walk_timer >= 1.:
				player.walk_timer = .0
				match encounter_state:
					encounter.CALM:
						if randf_range(.0, 1.) <= 0.15:
							encounter_state = encounter.WARNING
							encounter_radar.modulate = Color("fdc500")
					encounter.WARNING:
						if randf_range(.0, 1.) <= 0.34:
							encounter_state = encounter.COMBAT
							encounter_radar.modulate = Color("d82e20")
					encounter.COMBAT:
						encounter_state = encounter.CALM
						var randenemy : Enemy = Global.enemies[level_id].pick_random().instantiate()
						while randenemy.baseLevel > player.level + 3:
							randenemy = Global.enemies[level_id].pick_random().instantiate()
						await enter_battle(randenemy)
						encounter_radar.modulate = Color("25bd46")



func enter_battle(enemy_entered : Enemy):
	Global.world_timer.set_paused(true)
	battling_enemy = enemy_entered
	Global.new_state(Global.game_states.PAUSED)
	player.velocity = Vector3.ZERO
	player.battles += 1
	var new_battle : battle_manager = battle_scene.instantiate()
	new_battle.find_child("Players").add_child(player.duplicate())
	new_battle.find_child("Enemies").add_child(enemy_entered.duplicate())
	ambient_player.stop()
	animation_player.play("start_battle", -1, 2.0)
	await animation_player.animation_finished
	world.set_visible(false)
	worldGUI.set_visible(false)
	add_child(new_battle)
	new_battle.music_player.set_stream(battling_enemy.battle_music)
	new_battle.music_player.play()
	if $ConfigMenu.visible:
		Global.back_state()
		$ConfigMenu.set_visible(false)
	move_child($ConfigMenu, get_child_count()-1)

func end_battle():
	Global.level.updateGUI()
	world.set_visible(true)
	worldGUI.set_visible(true)
	animation_player.play_backwards("start_battle")
	await animation_player.animation_finished
	ambient_player.play()
	Global.world_timer.set_paused(false)
	Global.new_state(Global.game_states.WORLD)
	enemy_defeat.emit()


func updateGUI():
	levelGUI.max_value = player.xp_to_level
	levelGUI.value = player.xp
	levelGUI.get_child(0).text = "Lvl. " + str(player.level)
	levelGUI.get_child(1).text = "{0} / {1}".format([str(player.xp), str(player.xp_to_level)])
	
	healthGUI.max_value = player.maxHP
	healthGUI.value = player.currHP
	healthGUI.get_child(0).get_child(0).get_child(1).text = "{0} / {1}".format([str(player.currHP), str(player.maxHP)])
	
	manaGUI.max_value = player.maxMP
	manaGUI.value = player.currMP
	manaGUI.get_child(0).get_child(0).get_child(1).text = "{0} / {1}".format([str(player.currMP), str(player.maxMP)])

func world_levelup():
	world_level_bar.max_value = Global.world_timer.wait_time
	if Global.world_level == 0:
		Global.world_level += 1
	else:
		Global.world_level += Global.world_level - int(float(Global.world_level)/2)
	world_level_label.text = "World Level: +{0}".format([str(Global.world_level)])
	for Act in Global.enemies:
		for enemy : Enemy in Act:
			for x in range(Global.world_level):
				enemy.level_up()
	for Act in Global.bosses:
		for boss : Enemy in Act:
			for x in range(Global.world_level-2):
				boss.level_up()
