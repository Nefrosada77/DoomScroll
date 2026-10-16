extends SubViewportContainer
var res_text : String
enum menu_states {INITIAL, OPTIONS, STATS}

var menu_state : menu_states 

@onready var options_menu: TabContainer = $SubViewport/MenuControl/MarginContainer/PanelContainer/OptionsMenu
@onready var menu_initial: MarginContainer = $SubViewport/MenuControl/MarginContainer/PanelContainer/MenuInitial
@export var stats_menu : MarginContainer
@export var moneylabel : Label
@export var playerIcon : TextureRect
@export var ATKLabel : Label
@export var DEFLabel : Label
@export var hpBar : ProgressBar
@export var hpLabel : Label
@export var mpBar : ProgressBar
@export var mpLabel : Label
@export var xpBar : ProgressBar
@export var xpLabel : Label
@export var skills_tab : TabContainer
@export var skill_list : RichTextLabel
@export var passive_skill_list : RichTextLabel

@export var sfx : AudioStreamPlayer


func _ready() -> void:
		res_text = str(DisplayServer.window_get_size().x) + " X " + str(DisplayServer.window_get_size().y)
		for item_idx in range(%RESOLUTIONS.item_count):
			if %RESOLUTIONS.get_item_text(item_idx) == res_text:
				%RESOLUTIONS.select(item_idx)
				break



func _physics_process(_delta: float) -> void:
	if visible:
		mouse_target = true
	else:
		mouse_target = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left"):
		skills_tab.select_previous_available()
	if event.is_action_pressed("ui_right"):
		skills_tab.select_next_available()
	if event.is_action_pressed("menu") or event.is_action_pressed("return"):
		match menu_state:
			menu_states.INITIAL:
				if visible:
					sfx.stream = Global.decline_sound
					sfx.play()
					set_visible(false)
					Global.back_state()
				else:
					if Global.game_state != Global.game_states.PAUSED:
						if event.is_action_pressed("return"):
							return
						Global.new_state(Global.game_states.PAUSED)
						set_visible(true)
						menu_initial.get_child(0).get_child(0).grab_focus()
					
			menu_states.OPTIONS:
				sfx.stream = Global.decline_sound
				sfx.play()
				options_menu.set_visible(false)
				menu_state = menu_states.INITIAL
				menu_initial.set_visible(true)
				menu_initial.get_child(0).get_child(0).grab_focus()
				
			menu_states.STATS:
				sfx.stream = Global.decline_sound
				sfx.play()
				stats_menu.set_visible(false)
				menu_state = menu_states.INITIAL
				menu_initial.set_visible(true)
				menu_initial.get_child(0).get_child(0).grab_focus()

func _on_option_button_item_selected(index: int, source: OptionButton) -> void:
	DisplayServer.window_set_size(Vector2i(int(source.get_item_text(index).get_slice(" X ", 0)), int(source.get_item_text(index).get_slice(" X ",1))))
	res_text = str(DisplayServer.window_get_size().x) + " X " + str(DisplayServer.window_get_size().y)
	print(DisplayServer.window_get_size())

func _on_check_button_toggled(toggled_on: bool, source : Control) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		source.text = "ON"
		%RESOLUTIONS.disabled = true
		
		res_text = str(DisplayServer.window_get_size().x) + " X " + str(DisplayServer.window_get_size().y)
		for item_idx in range(%RESOLUTIONS.item_count):
			if %RESOLUTIONS.get_item_text(item_idx) == res_text:
				%RESOLUTIONS.select(item_idx)
				break

	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		source.text = "OFF"
		%RESOLUTIONS.disabled = false
		res_text = str(DisplayServer.window_get_size().x) + " X " + str(DisplayServer.window_get_size().y)
		for item_idx in range(%RESOLUTIONS.item_count):
			if %RESOLUTIONS.get_item_text(item_idx) == res_text:
				%RESOLUTIONS.select(item_idx)
				break


func _on_button_pressed(source: BaseButton) -> void:
	match source.name:
		"RETURN":
			sfx.stream = Global.decline_sound
			sfx.play()
			set_visible(false)
			Global.back_state()
		"OPTIONS":
			sfx.stream = Global.accept_sound
			sfx.play()
			menu_initial.set_visible(false)
			menu_state = menu_states.OPTIONS
			options_menu.set_visible(true)
			options_menu.get_tab_bar().grab_focus()
		"STATS":
			sfx.stream = Global.accept_sound
			sfx.play()
			skill_list.text = ""
			passive_skill_list.text = ""
			hpBar.max_value = Global.level.player.maxHP
			hpBar.value = Global.level.player.currHP
			hpLabel.text = str(Global.level.player.currHP) + " / " + str(Global.level.player.maxHP)
			mpBar.max_value = Global.level.player.maxMP
			mpBar.value = Global.level.player.currMP
			mpLabel.text = str(Global.level.player.currMP) + " / " + str(Global.level.player.maxMP)
			xpBar.max_value = Global.level.player.xp_to_level
			xpBar.value = Global.level.player.xp
			xpLabel.text = str(Global.level.player.xp) + " / " + str(Global.level.player.xp_to_level)
			ATKLabel.text = str(Global.level.player.attack)
			DEFLabel.text = str(Global.level.player.defense)
			moneylabel.text = "$" + str(Global.level.player.money)
			var line := 4
			for skill : Skill in Global.level.player.skills:
				line -= 1
				skill_list.text += "[font_size=20]{0} | {1} POWER | {2} MP[/font_size]".format({"0": skill.SkName, "1": skill.skPower, "2": skill.SkCost})
				skill_list.text += "\n[ul]{0}[/ul]".format({"0": skill.SkDesc})
				skill_list.text += "[hr]\n"
			for i in range(line):
				skill_list.text += " [bgcolor=#1a1a1a4d][font_size=20][fill][/fill][/font_size][/bgcolor]"
				skill_list.text += "[hr]\n"

			line = 4
			for passive_skill : Skill in Global.level.player.passiveSkills:
				line -= 1
				passive_skill_list.append_text("[font_size=20]{0}[/font_size]".format({"0" : passive_skill.SkName,}))
				passive_skill_list.append_text("\n[ul]{0}[/ul]".format({"0" : passive_skill.SkDesc}))
				passive_skill_list.append_text("[hr]\n")
			for i in range(line):
				passive_skill_list.append_text(" [bgcolor=#1a1a1a4d][font_size=20][fill][/fill][/font_size][/bgcolor]")
				passive_skill_list.append_text("[hr]\n")
			menu_initial.set_visible(false)
			stats_menu.set_visible(true)
			menu_state = menu_states.STATS
		"MENU":
			pass
			#TODO CHANGE BACK TO MENU
		"EXIT":
			get_tree().quit()
	
