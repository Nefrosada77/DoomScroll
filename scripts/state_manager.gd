extends Node
class_name stateManager

var last_state : GUICONTROL.GUISTATE
var state : GUICONTROL.GUISTATE
var changing : bool = false

signal turn_ended

func changeState(newState : GUICONTROL.GUISTATE):
	#print("Changed State to "+ GUICONTROL.GUISTATE.keys()[newState])
	%ButtonsContainer.visible = false
	%SkillsContainer.visible = false
	%DescriptionLabel.visible = false
	%AnalysisPanel.visible = false
	%EnemiesContainer.size_flags_horizontal = Control.SizeFlags.SIZE_SHRINK_BEGIN
	%EnemiesContainer.size_flags_vertical = Control.SizeFlags.SIZE_SHRINK_CENTER
	%PlayerContainer.size_flags_horizontal = Control.SizeFlags.SIZE_SHRINK_END
	%PlayerContainer.size_flags_vertical = Control.SizeFlags.SIZE_SHRINK_CENTER
	for btn : EnemyContainer in %EnemiesContainer.get_children():
		btn.focus_mode = Control.FOCUS_NONE
	for btn : PlayerContainer in %PlayerContainer.get_children():
		btn.focus_mode = Control.FOCUS_NONE
		btn.material.set_shader_parameter('direction', 3)
		btn.stats_status.size_flags_vertical = Control.SIZE_SHRINK_END
		btn.stats_status.offset_transform_position.y = 42
	match newState:
		GUICONTROL.GUISTATE.STARTMENU:
			last_state = GUICONTROL.GUISTATE.STARTMENU
			state = GUICONTROL.GUISTATE.STARTMENU
			%ButtonsContainer.visible = true
			%DescriptionLabel.visible = true
			%ButtonsContainer.get_child(0).grab_focus()

		GUICONTROL.GUISTATE.SKILLMENU:
			last_state = GUICONTROL.GUISTATE.STARTMENU
			state = GUICONTROL.GUISTATE.SKILLMENU
			%SkillsContainer.visible = true
			%DescriptionLabel.visible = true
			if %SkillsContainer.get_child_count() > 0:
				%SkillsContainer.get_child(0).grab_focus()
		
		GUICONTROL.GUISTATE.ANALYSISMENU:
			last_state = state
			state = GUICONTROL.GUISTATE.ANALYSISMENU
			get_parent().camera.projection = Camera3D.PROJECTION_PERSPECTIVE
			%AnalysisPanel.visible = true
			for btn : EnemyContainer in %EnemiesContainer.get_children():
				btn.focus_mode = Control.FOCUS_ALL
			for btn : PlayerContainer in %PlayerContainer.get_children():
				btn.focus_mode = Control.FOCUS_ALL
				btn.material.set_shader_parameter('direction', 1)
				btn.stats_status.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
				btn.stats_status.offset_transform_position.y = -42
			#var tween : Tween = create_tween()
			#tween.tween_property(%EnemiesContainer, "size_flags_horizontal", Control.SizeFlags.SIZE_SHRINK_BEGIN, 0.1).set_ease(Tween.EASE_OUT_IN)
			#tween.tween_property(%EnemiesContainer, "size_flags_vertical", Control.SizeFlags.SIZE_SHRINK_BEGIN, 0.1).set_ease(Tween.EASE_OUT_IN)
			#tween.tween_property(%PlayerContainer, "size_flags_horizontal", Control.SizeFlags.SIZE_SHRINK_BEGIN, 0.1).set_ease(Tween.EASE_OUT_IN)
			#tween.tween_property(%PlayerContainer, "size_flags_vertical", Control.SizeFlags.SIZE_SHRINK_END, 0.1).set_ease(Tween.EASE_OUT_IN)
			#await tween.finished
			#tween.kill()
			%EnemiesContainer.size_flags_horizontal = Control.SizeFlags.SIZE_SHRINK_BEGIN
			%EnemiesContainer.size_flags_vertical = Control.SizeFlags.SIZE_SHRINK_BEGIN
			%PlayerContainer.size_flags_horizontal = Control.SizeFlags.SIZE_SHRINK_BEGIN
			%PlayerContainer.size_flags_vertical = Control.SizeFlags.SIZE_SHRINK_END
			%EnemiesContainer.get_child(0).grab_focus()

		GUICONTROL.GUISTATE.SINGLEENEMY:
			if state == GUICONTROL.GUISTATE.STARTMENU or state == GUICONTROL.GUISTATE.SKILLMENU:
				last_state = state
			state = GUICONTROL.GUISTATE.SINGLEENEMY
			for btn : EnemyContainer in %EnemiesContainer.get_children():
				btn.focus_mode = Control.FOCUS_ALL
			%EnemiesContainer.get_child(0).grab_focus()

		GUICONTROL.GUISTATE.SINGLEALLY:
			if state == GUICONTROL.GUISTATE.STARTMENU or state == GUICONTROL.GUISTATE.SKILLMENU:
				last_state = state
			state = GUICONTROL.GUISTATE.SINGLEALLY
			for btn : PlayerContainer in %PlayerContainer.get_children():
				btn.focus_mode = Control.FOCUS_ALL
			%PlayerContainer.get_child(0).grab_focus()
		
		GUICONTROL.GUISTATE.HIDEALL:
			state = GUICONTROL.GUISTATE.HIDEALL
		

func passTurn():
	turn_ended.emit()

func backState():
	if last_state != state:
		get_parent().camera_back()
		state = last_state
		print("Going Back to "+ GUICONTROL.GUISTATE.keys()[state])
		changeState(state)
		
func checkEnd():
	if %EnemiesContainer.get_children().is_empty() or %PlayerContainer.get_children().is_empty():
		return true
	else:
		return false
