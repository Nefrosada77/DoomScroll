extends Control
class_name GUICONTROL

var hovered : Control = null
var focused : Control = null

enum GUISTATE {STARTMENU, SKILLMENU, ITEMSMENU, ANALYSISMENU, 
				SINGLEENEMY, ALLENEMIES, SINGLEALLY, ALLALIES,
				HIDEALL}
				

@onready var debug_hover: Label = $MarginContainer/DebugLabels/DebugHover
@onready var debug_select: Label = $MarginContainer/DebugLabels/DebugSelect
@onready var debug_focused: Label = $MarginContainer/DebugLabels/DebugFocused
@onready var description_label: Label = $MarginContainer/AllButtons/DescriptionLabel
@onready var debug_game_state: Label = $MarginContainer/DebugLabels/DebugGameState
@onready var debug_battle_state: Label = $MarginContainer/DebugLabels/DebugBattleState
@export var camera_marker : Marker3D
@export var attack_button: SkillButton
@export var defend_button: SkillButton
@export var battle: battle_manager
@export var enemyContainer : PackedScene
@export var playerContainer : PackedScene
@export var skill_button_base : PackedScene
@export var Manager : stateManager
@export var camera : Camera3D
@export var battle_sfx : AudioStreamPlayer2D

var selected_skill : Skill

var rememberButton0 : Control
var rememberEnemy : Control
var rememberAlly : Control

func start() -> void:
	Global.new_state(Global.game_states.PAUSED) 
	for menus in %AllButtons.get_children():
		for btn in menus.get_children(): 
			connectButton(btn)
	Global.new_state(Global.game_states.BATTLE)
	Manager.passTurn()

func addPlayerGUI(player: Character):
	var newPlayer : PlayerContainer = playerContainer.instantiate()
	newPlayer.get_char(player) 
	newPlayer.material = newPlayer.material.duplicate()
	newPlayer.focus_entered.connect(_on_button_focus_entered.bind(newPlayer))
	newPlayer.focus_exited.connect(_on_button_focus_exited.bind(newPlayer))
	newPlayer.mouse_entered.connect(_on_button_mouse_entered.bind(newPlayer))
	newPlayer.mouse_exited.connect(_on_button_mouse_exited.bind(newPlayer))
	newPlayer.gui_input.connect(_on_container_gui_input.bind(newPlayer))
	%PlayerContainer.add_child(newPlayer)
	for skill in player.skills:
		create_skill_button(skill)
	attack_button.setup(newPlayer.charRef.main_attack)
	defend_button.setup(newPlayer.charRef.defend)
	battle.turn_list.append(newPlayer)
	

func addEnemyGUI(enemy : Character): 
	var newEnemy : EnemyContainer = enemyContainer.instantiate()
	newEnemy.get_char(enemy)
	newEnemy.material = newEnemy.material.duplicate()
	newEnemy.focus_entered.connect(_on_button_focus_entered.bind(newEnemy))
	newEnemy.focus_exited.connect(_on_button_focus_exited.bind(newEnemy))
	newEnemy.mouse_entered.connect(_on_button_mouse_entered.bind(newEnemy))
	newEnemy.mouse_exited.connect(_on_button_mouse_exited.bind(newEnemy))
	newEnemy.gui_input.connect(_on_container_gui_input.bind(newEnemy))
	%EnemiesContainer.add_child(newEnemy)
	battle.turn_list.append(newEnemy)
	

func create_skill_button(skill : Skill):
	var newSkillBtn := skill_button_base.instantiate()
	newSkillBtn.setup(skill)
	%SkillsContainer.add_child(newSkillBtn)

func connectButton(btn : BaseButton):
	btn.material = btn.material.duplicate()
	btn.focus_entered.connect(_on_button_focus_entered.bind(btn))
	btn.focus_exited.connect(_on_button_focus_exited.bind(btn))
	btn.mouse_entered.connect(_on_button_mouse_entered.bind(btn))
	btn.mouse_exited.connect(_on_button_mouse_exited.bind(btn))
	btn.gui_input.connect(_on_container_gui_input.bind(btn))
	btn.pressed.connect(_on_texture_button_pressed.bind(btn))
	

func _on_button_mouse_entered(source: Control) -> void:
	if source is EnemyContainer and (Manager.state == GUISTATE.SINGLEENEMY or Manager.state == GUISTATE.ANALYSISMENU):
		if get_viewport().gui_get_focus_owner() != source:
			source.grab_focus()
		debug_hover.text = "BUTTON HOVERED: " + source.name
		source.material.set_shader_parameter('Hovered', true)
	if source is PlayerContainer and (Manager.state == GUISTATE.SINGLEALLY or Manager.state == GUISTATE.ANALYSISMENU):
		if get_viewport().gui_get_focus_owner() != source:
			source.grab_focus()
		debug_hover.text = "BUTTON HOVERED: " + source.name
		source.material.set_shader_parameter('Hovered', true)
	if source is GUIButton:
		if get_viewport().gui_get_focus_owner() != source:
			source.grab_focus()
		description_label.text = source.desctription
		debug_hover.text = "BUTTON HOVERED: " + source.name
		source.material.set_shader_parameter('Hovered', true)


func _on_button_mouse_exited(_source: Control) -> void:
	debug_hover.text = "BUTTON HOVERED: None"


func _on_texture_button_pressed(source: GUIButton) -> void:
	debug_select.text = "BUTTON SELECTED: " + source.name
	source.material.set_shader_parameter('Hovered', false)
	
	if source is GUIButton:
		if source.name == "SKILLS":
			Manager.changeState(GUISTATE.SKILLMENU)
		if source.name == "ANALYSE":
			Manager.changeState(GUISTATE.ANALYSISMENU)
			
	if source is SkillButton:
		if source.skill.SkCost > battle.curr_char.charRef.currMP:
			source.material.set_shader_parameter('Hovered', true)
			battle_sfx.stream = Global.decline_sound
			battle_sfx.play()
			return
		selected_skill = source.skill
		match source.skill.SkHit:
			Skill.skillHit.SINGLEENEMY:
				Manager.changeState(GUISTATE.SINGLEENEMY)

			Skill.skillHit.SINGLEALLY:
				Manager.changeState(GUISTATE.SINGLEALLY)
		if Global.rememberChoice:
			rememberButton0 = source

	battle_sfx.stream = Global.accept_sound
	battle_sfx.play()


func _on_button_focus_entered(source: Control) -> void:
	focused = source
	debug_focused.text = "BUTTON FOCUSED: " + source.name
	source.material.set_shader_parameter('Hovered', true)
	if source is CharContainer and Manager.state == GUISTATE.ANALYSISMENU:
		%AnalysisPanel.change_info(source.charRef)
		var tween : Tween = create_tween()
		tween.tween_property(camera, "global_position", source.charRef.marker_analysis.global_position, 0.15).set_ease(Tween.EASE_OUT_IN)
		tween.tween_property(camera, "rotation", source.charRef.marker_analysis.rotation, 0.15).set_ease(Tween.EASE_OUT_IN)
		await tween.finished
		tween.kill()


	if source is GUIButton:
		description_label.text = source.desctription


func _on_button_focus_exited(source: Control) -> void:
	debug_focused.text = "BUTTON FOCUSED: None"
	source.material.set_shader_parameter('Hovered', false)
	description_label.text = ""


func _on_container_gui_input(event: InputEvent, source: Control) -> void:
	if event is InputEventMouseMotion:
		if source.focus_mode == Control.FocusMode.FOCUS_ALL:
			if get_viewport().gui_get_focus_owner() != source:
				source.grab_focus()
			if Manager.state == GUISTATE.ANALYSISMENU:
				var tween : Tween = create_tween()
				tween.tween_property(camera, "global_position", source.charRef.marker_analysis.global_position, 0.2).set_ease(Tween.EASE_OUT_IN)
				await tween.finished
				tween.kill()

	if event.is_action_pressed("return"):
		Manager.backState()
	
	if event is InputEventMouseButton or event.is_action_pressed("ui_accept"):
		if source is EnemyContainer and Manager.state == GUISTATE.SINGLEENEMY:
			battle_sfx.stream = Global.accept_sound
			battle_sfx.play()
			for btn : EnemyContainer in %EnemiesContainer.get_children():
				btn.focus_mode = Control.FOCUS_NONE
			source.material.set_shader_parameter('Hovered', false)
			Manager.changeState(GUISTATE.HIDEALL)
			battle.useSkill(source, selected_skill)
			return

		if source is PlayerContainer and Manager.state == GUISTATE.SINGLEALLY:
			battle_sfx.stream = Global.accept_sound
			battle_sfx.play()
			for btn : PlayerContainer in %PlayerContainer.get_children():
				btn.focus_mode = Control.FOCUS_NONE
			source.material.set_shader_parameter('Hovered', false)
			Manager.changeState(GUISTATE.HIDEALL)
			battle.useSkill(source, selected_skill)
			return

func camera_back():
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.global_position = camera_marker.global_position
	camera.rotation = camera_marker.rotation
	#var tween : Tween = create_tween()
	#tween.tween_property(camera, "global_position", camera_marker.global_position, 0.1).set_ease(Tween.EASE_OUT_IN)
	#tween.tween_property(camera, "rotation", camera_marker.rotation, 0.1).set_ease(Tween.EASE_OUT_IN)
	#await tween.finished

func _process(_delta: float) -> void:
	if Global.game_state == Global.game_states.BATTLE:
		if focused:
			if Manager.state != GUISTATE.HIDEALL:
				if !focused.has_focus():
					focused.grab_focus()
	if (Manager.state != GUISTATE.ANALYSISMENU and Manager.state != GUISTATE.HIDEALL) and (camera.global_position != camera_marker.global_position or camera.rotation != camera_marker.rotation):
		camera_back()
	debug_battle_state.text = "BATTLE STATE: " + str(GUISTATE.find_key(Manager.state))
	debug_game_state.text = "GAME STATE: " + str(Global.game_states.find_key(Global.game_state))

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("return"):
		if Manager.state != GUISTATE.HIDEALL:
			if Manager.state != GUISTATE.STARTMENU:
				battle_sfx.stream = Global.decline_sound
				battle_sfx.play()
			Manager.backState()
	if event.is_action_pressed("debug"):
		if %DebugLabels.visible:
			%DebugLabels.set_visible(false)
		else:
			%DebugLabels.set_visible(true)
