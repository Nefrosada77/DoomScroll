extends PanelContainer
class_name analysis_panel

@export var char_name : Label
@export var char_lvl : Label
@export var hp_bar : ProgressBar
@export var currHP : Label
@export var maxHP : Label
@export var mp_bar : ProgressBar
@export var currMP : Label
@export var mp: HBoxContainer 
@export var maxMP : Label
@export var atk : Label
@export var def : Label
@export var skill_list : RichTextLabel
@export var passive_skill_list : RichTextLabel
@export var separator : HSeparator
@export var scroll_container: ScrollContainer


@export_range(1,100) var duplicate_num : int = 1


func change_info(charRef : Character):
	if charRef is Player:
		separator.get_theme_stylebox("separator")["color"] = Color(0.494, 1.0, 1.0, 0.471)
	else:
		separator.get_theme_stylebox("separator")["color"] = Color(1.0, 0.161, 0.055, 0.471)
	char_name.text = charRef.charName
	char_lvl.text = "Lvl " + str(charRef.level)
	currHP.text = str(int(charRef.currHP))
	maxHP.text = str(int(charRef.maxHP))
	hp_bar.max_value = int(charRef.maxHP)
	hp_bar.value = int(charRef.currHP)
	if charRef is Player:
		mp.set_visible(true)
		currMP.text = str(int(charRef.currMP))
		maxMP.text = str(int(charRef.maxMP))
		mp_bar.max_value = int(charRef.maxMP)
		mp_bar.value = int(charRef.currMP)
	else:
		mp.set_visible(false)
	atk.text = str(int(charRef.curr_attack))
	if charRef.curr_attack < charRef.attack:
		atk.add_theme_color_override("font_color", Color(0.85, 0.2, 0.2))
	elif charRef.curr_attack > charRef.attack:
		atk.add_theme_color_override("font_color", Color(0.2, 0.85, 0.2))
	else:
		atk.remove_theme_color_override("font_color")
	def.text = str(int(charRef.curr_defense))
	if charRef.curr_defense < charRef.defense:
		def.add_theme_color_override("font_color", Color(0.85, 0.2, 0.2))
	elif charRef.curr_defense > charRef.defense:
		def.add_theme_color_override("font_color", Color(0.2, 0.85, 0.2))
	else:
		def.remove_theme_color_override("font_color")
	skill_list.text = ""
	passive_skill_list.text = ""
	var line := 4
	for skill : Skill in charRef.skills:
		line -= 1
		skill_list.text += "[ol][font_size=20]{0} | {1} POWER | {2} MP[/font_size]".format({"0": skill.SkName, "1": skill.skPower, "2": skill.SkCost})
		skill_list.text += "\n[ul]{0}[/ul][/ol]".format({"0": skill.SkDesc})
		skill_list.text += "[hr]"
	for i in range(line):
		skill_list.text += " [bgcolor=#1a1a1a4d][font_size=20][fill][/fill][/font_size][/bgcolor]"
		skill_list.text += "[hr]"

	line = 4
	for passive_skill : Skill in charRef.passiveSkills:
		line -= 1
		passive_skill_list.append_text("[ol][font_size=20]{0}[/font_size]".format({"0" : passive_skill.SkName,}))
		passive_skill_list.append_text("\n[ul]{0}[/ul][/ol]".format({"0" : passive_skill.SkDesc}))
		passive_skill_list.append_text("[hr]")
	for i in range(line):
		passive_skill_list.append_text(" [bgcolor=#1a1a1a4d][font_size=20][fill][/fill][/font_size][/bgcolor]")
		passive_skill_list.append_text("[hr]")

func _physics_process(_delta: float) -> void:
	if Input.is_action_pressed("up_page"):
		scroll_container.scroll_vertical -= 5
	if Input.is_action_pressed("down_page"):
		scroll_container.scroll_vertical += 5
