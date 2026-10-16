extends Node
class_name battle_manager

@export var state_manager: stateManager
@export var skill_effects: skill_events
@export var gui_control: GUICONTROL 
@export var ground : Node3D
@export var animation_player: AnimationPlayer
@export var reward_menu : PanelContainer
@export var passTurnSkill : Skill
@export var music_player : AudioStreamPlayer

var turn : int = 0
var turn_list : Array[CharContainer]
var curr_char : CharContainer
var reward_skill : Skill

func _ready() -> void:
	ground.change_color(Global.curr_level_color)
	start_battle()
	gui_control.camera.set_current(true)
	Global.level.animation_player.play_backwards("start_battle")
	animation_player.play("start_battle")
	await animation_player.animation_finished
	gui_control.start()
	

func start_battle():
	for player : Player in %Players.get_children():
		GlobalBattle.player = player
		player.global_position = Vector3(2.0,1.0,.0)
		player.look_at(%Enemies.global_position)
		player.model.rotation_degrees = Vector3(.0, 180.0, .0)
		player.velocity = Vector3.ZERO
		gui_control.addPlayerGUI(player)
		for char_animation : StringName in player.animation.get_animation_list():
			if char_animation.containsn("idle"):
				player.animation.play(char_animation)
	for enemy : Enemy in %Enemies.get_children():
		enemy.global_position = Vector3(-2.0,1.0,.0)
		enemy.look_at(%Players.global_position)
		enemy.velocity = Vector3.ZERO
		gui_control.addEnemyGUI(enemy)
		for char_animation : StringName in enemy.animation.get_animation_list():
			if char_animation.containsn("idle"):
				enemy.animation.play(char_animation)
	await get_tree().create_timer(0.5).timeout

func add_char(character : Character):
	if character is Player:
		%Players.add_child(character)
		gui_control.addPlayerGUI(character)
	else:
		%Enemies.add_child(character)
		gui_control.addEnemyGUI(character)
		character.global_position = Vector3(-2.0,1.0,-2.0)
		character.look_at(%Players.global_position)
		character.velocity = Vector3.ZERO
		for char_animation : StringName in character.animation.get_animation_list():
			if char_animation.containsn("idle"):
				character.animation.play(char_animation)

func round_start():
	if turn == 0:
		for character: CharContainer in turn_list:
			if turn_list[0] != null:
				for passive: Skill in character.charRef.passiveSkills:
						skill_effects.usePassive(character, passive)
	if state_manager.checkEnd():
		await get_tree().create_timer(0.2).timeout
		if %EnemiesContainer.get_children().is_empty():
			Global.new_state(Global.game_states.PAUSED)
			battle_reward()
			%Camera3D.projection = Camera3D.PROJECTION_PERSPECTIVE
			var tween : Tween = create_tween()
			tween.tween_property(%Camera3D, "global_position", %Players.get_child(0).marker_analysis.global_position, 0.15).set_ease(Tween.EASE_OUT_IN)
			tween.tween_property(%Camera3D, "rotation", %Players.get_child(0).marker_analysis.rotation, 0.15).set_ease(Tween.EASE_OUT_IN)
			await tween.finished
			tween.kill()
			reward_menu.change_info(reward_skill)

		else:
			#TODO DEATH MENU
			get_tree().change_scene_to_file("res://scenes/Main_Menu.tscn")
		return

	if turn_list[0] == null:
		turn_list.pop_front()
	curr_char = turn_list[0]
	
	
	await curr_char.start_effects()
	await get_tree().create_timer(0.2).timeout
	
	
	if state_manager.checkEnd():
		await get_tree().create_timer(0.2).timeout
		if %EnemiesContainer.get_children().is_empty():
			Global.new_state(Global.game_states.PAUSED)
			battle_reward()
			%Camera3D.projection = Camera3D.PROJECTION_PERSPECTIVE
			var tween : Tween = create_tween()
			tween.tween_property(%Camera3D, "global_position", %Players.get_child(0).marker_analysis.global_position, 0.15).set_ease(Tween.EASE_OUT_IN)
			tween.tween_property(%Camera3D, "rotation", %Players.get_child(0).marker_analysis.rotation, 0.15).set_ease(Tween.EASE_OUT_IN)
			await tween.finished
			tween.kill()
			reward_menu.change_info(reward_skill)

		else:
			#TODO DEATH MENU
			Global.level.animation_player.play("start_battle")
			await Global.level.animation_player.animation_finished
			get_tree().change_scene_to_file("res://scenes/Main_Menu.tscn")
		return

	if curr_char is EnemyContainer:
		%BorderGUI.self_modulate = Color("eb7263")
		#print("ENEMIES TURN")
		if curr_char.charRef.freezed:
			passTurn()
		else:
			enemyTurn()

	else:
		%BorderGUI.self_modulate = Color("00acd4")
		#print("PLAYER TURN")
		if curr_char.charRef.freezed:
			passTurn()
		else:
			state_manager.changeState(GUICONTROL.GUISTATE.STARTMENU)
	
	turn_list.append(turn_list.pop_front())
	curr_char.charRef.turn += 1
	turn += 1

func useSkill(target: CharContainer, skill: Skill):
	skill_effects.skill_effect(curr_char, target, skill)

func passTurn():
	skill_effects.skill_effect(curr_char, curr_char, passTurnSkill)

func enemyTurn():
	var selectedSkill : Skill = curr_char.charRef.decision(%Players)
	if selectedSkill.SkHit == Skill.skillHit.SINGLEENEMY:
		useSkill(%PlayerContainer.get_children().pick_random(), selectedSkill)
	elif selectedSkill.SkHit == Skill.skillHit.SINGLEALLY:  
		useSkill(%EnemiesContainer.get_children().pick_random(), selectedSkill)
	await get_tree().create_timer(0.75).timeout

func finish_battle():
	Global.level.animation_player.play("start_battle")
	await Global.level.animation_player.animation_finished
	Global.level.end_battle()
	Global.level.battling_enemy.queue_free()
	queue_free()

func battle_reward():
	var reward_list : Array = [null]
	var weight_list : PackedFloat32Array = [0.35]
	for skill in Global.level.battling_enemy.skills:
		if skill.reward:
			if Global.level.player.skills.find(skill) == -1:
				reward_list.append(skill)
				weight_list.append(skill.reward_chance)
	for skill in Global.level.battling_enemy.passiveSkills:
		if Global.level.player.passiveSkills.find(skill) == -1:
			if skill.reward:
				reward_list.append(skill)
				weight_list.append(skill.reward_chance)
	reward_skill = reward_list[Global.RNG.rand_weighted(weight_list)]
