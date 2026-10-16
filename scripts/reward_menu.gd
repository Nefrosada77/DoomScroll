extends PanelContainer

#CONTAINERS
@export var level_up_menu : VBoxContainer
@export var skill_reward_menu : VBoxContainer
@export var Skill_change_menu : VBoxContainer

#BATTLE DROPS
@export var xp_gain : Label
@export var xp_bar : ProgressBar
@export var money_gain : Label
@export var curr_money : Label

#LEVEL UP
@export var hp_gain : Label
@export var curr_hp : Label
@export var mp_gain : Label
@export var curr_mp : Label
@export var atk_gain : Label
@export var curr_atk : Label
@export var def_gain : Label
@export var curr_def : Label

#SKILL REWARD
@export var skill_name : Label
@export var skill_effect : Label
@export var skill_icon : TextureRect

#BUTTONS
@export var next_button : Button

var player : Player
var enemy : Enemy
var skill_reward : Skill

signal end_battle

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = Global.level.player
	enemy = Global.level.battling_enemy
	level_up_menu.set_visible(false)
	skill_reward_menu.set_visible(false)
	Skill_change_menu.set_visible(false)
	next_button.set_visible(false)
	#TODO CHANGE DEBUG PLAYER TO ACTUAL PLAYER
	xp_bar.max_value = player.xp_to_level
	xp_bar.value = player.xp
	curr_money.text = "$" + str(player.money) 

func change_info(skill : Skill):
	set_visible(true)
	skill_reward = skill
	Global.level.player.update_stats(%Players.get_child(0))
	await Level_Up()
	if skill_reward:
		skill_name.text = skill_reward.SkName
		skill_effect.text = skill_reward.SkDesc
		skill_icon.texture = skill_reward.SkIcon
		skill_reward_menu.set_visible(true)
		%Learn.grab_focus()
	else:
		next_button.set_visible(true)
		next_button.grab_focus()
	

func Level_Up():
	player.xp += enemy.xp
	xp_gain.set_visible(true)
	xp_gain.text = "+" + str(enemy.xp) + "XP"
	await get_tree().create_timer(0.2).timeout
	player.money += enemy.money
	money_gain.set_visible(true)
	money_gain.text = "+$" + str(enemy.money)
	await get_tree().create_timer(0.2).timeout
	var tween : Tween = create_tween()
	if player.xp > player.xp_to_level: 
		tween.parallel().tween_property(xp_bar, "value", player.xp_to_level, 0.75).set_ease(Tween.EASE_IN_OUT)
	else:
		tween.parallel().tween_property(xp_bar, "value", player.xp, 0.75).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(curr_money, "text", "$" + str(player.money), 0.75).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	tween.kill()
	var level_up = 0
	while player.xp >= player.xp_to_level:
		level_up += 1
		player.level_up()
		xp_bar.value = 0
		hp_gain.text = "+" + str(player.hp_evolve * level_up)
		hp_gain.set_visible(true)
		mp_gain.text = "+" + str(player.mp_evolve * level_up)
		mp_gain.set_visible(true)
		atk_gain.text = "+" + str(player.atk_evolve * level_up)
		atk_gain.set_visible(true)
		def_gain.text = "+" + str(player.def_evolve * level_up)
		def_gain.set_visible(true)
		curr_hp.text = str(player.maxHP - player.hp_evolve * level_up)
		curr_mp.text = str(player.maxMP - player.mp_evolve * level_up)
		curr_atk.text = str(player.attack - player.atk_evolve * level_up)
		curr_def.text = str(player.defense - player.def_evolve * level_up)
		level_up_menu.set_visible(true)
		xp_bar.max_value = player.xp_to_level
		if player.xp > player.xp_to_level:
			tween = create_tween()
			tween.tween_property(xp_bar, "value", player.xp_to_level, 0.75).set_ease(Tween.EASE_IN_OUT)
			await tween.finished
			tween.kill()
		else:
			tween = create_tween()
			tween.tween_property(xp_bar, "value", player.xp, 0.75).set_ease(Tween.EASE_IN_OUT)
			await tween.finished
			tween.kill()
		#await get_tree().create_timer(0.2).timeout
	tween = create_tween()
	tween.parallel().tween_property(curr_hp, "text", str(player.maxHP), 0.5).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(curr_mp, "text", str(player.maxMP), 0.5).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(curr_atk, "text", str(player.attack), 0.5).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(curr_def, "text", str(player.defense), 0.5).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	tween.kill()

func _on_cancel_pressed() -> void:
	skill_reward_menu.set_visible(false)
	next_button.set_visible(true)
	next_button.grab_focus()

func _on_learn_pressed() -> void:
	$MarginContainer/VBoxContainer/SkillReward/HBoxContainer.set_visible(false)
	level_up_menu.set_visible(false)
	%Skill1.clear()
	%Skill2.clear()
	%Skill3.clear()
	%Skill4.clear()
	if skill_reward.skType == Skill.skillType.PASSIVE:
		if len(player.passiveSkills) < 4:
			print("Learned " + skill_reward.SkName)
			player.passiveSkills.append(skill_reward)
			next_button.set_visible(true)
			next_button.grab_focus()
		else:
			%CANCEL_LEARN.grab_focus()
			%Skill1.append_text("[font_size=20]{0}[/font_size]".format({"0" : player.passiveSkills[0].SkName}))
			%Skill1.append_text("\n[ul]{0}[/ul]".format({"0" : player.passiveSkills[0].SkDesc}))
			%Skill2.append_text("[font_size=20]{0}[/font_size]".format({"0" : player.passiveSkills[1].SkName}))
			%Skill2.append_text("\n[ul]{0}[/ul]".format({"0" : player.passiveSkills[1].SkDesc}))
			%Skill3.append_text("[font_size=20]{0}[/font_size]".format({"0" : player.passiveSkills[2].SkName}))
			%Skill3.append_text("\n[ul]{0}[/ul]".format({"0" : player.passiveSkills[2].SkDesc}))
			%Skill4.append_text("[font_size=20]{0}[/font_size]".format({"0" : player.passiveSkills[3].SkName}))
			%Skill4.append_text("\n[ul]{0}[/ul]".format({"0" : player.passiveSkills[3].SkDesc}))
			skill_reward_menu.set_visible(false)
			Skill_change_menu.set_visible(true)
	else:
		if len(player.skills) < 4:
			print("Learned " + skill_reward.SkName)
			player.skills.append(skill_reward)
			next_button.set_visible(true)
			next_button.grab_focus()
		else:
			%CANCEL_LEARN.grab_focus()
			%Skill1.append_text("[font_size=20]{0} | {1} POWER | {2} MP[/font_size]".format({"0": player.skills[0].SkName, "1": player.skills[0].skPower, "2": player.skills[0].SkCost}))
			%Skill1.append_text("\n[ul]{0}[/ul]".format({"0": player.skills[0].SkDesc}))
			%Skill2.append_text("[font_size=20]{0} | {1} POWER | {2} MP[/font_size]".format({"0": player.skills[1].SkName, "1": player.skills[1].skPower, "2": player.skills[1].SkCost}))
			%Skill2.append_text("\n[ul]{0}[/ul]".format({"0": player.skills[1].SkDesc}))
			%Skill3.append_text("[font_size=20]{0} | {1} POWER | {2} MP[/font_size]".format({"0": player.skills[2].SkName, "1": player.skills[2].skPower, "2": player.skills[2].SkCost}))
			%Skill3.append_text("\n[ul]{0}[/ul]".format({"0": player.skills[2].SkDesc}))
			%Skill4.append_text("[font_size=20]{0} | {1} POWER | {2} MP[/font_size]".format({"0": player.skills[3].SkName, "1": player.skills[3].skPower, "2": player.skills[3].SkCost}))
			%Skill4.append_text("\n[ul]{0}[/ul]".format({"0": player.skills[3].SkDesc}))
			skill_reward_menu.set_visible(false)
			Skill_change_menu.set_visible(true)

func _on_cancel_learn_pressed() -> void:
	Skill_change_menu.set_visible(false)
	skill_reward_menu.set_visible(true)
	level_up_menu.set_visible(true)
	$MarginContainer/VBoxContainer/SkillReward/HBoxContainer.set_visible(true)
	%Learn.grab_focus()


func _on_sk_btn_focus_entered(source: Control) -> void:
	var label : RichTextLabel = source.get_child(0)
	label.add_theme_color_override("default_color", Color("b0b0b0"))


func _on_sk_btn_focus_exited(source: Control) -> void:
	var label : RichTextLabel = source.get_child(0)
	label.remove_theme_color_override("default_color")

func change_skill(idx : int):
	if skill_reward.skType == Skill.skillType.PASSIVE:
		player.passiveSkills[idx] = skill_reward
	else:
		player.skills[idx] = skill_reward
	Skill_change_menu.set_visible(false)
	skill_reward_menu.set_visible(true)
	next_button.set_visible(true)
	next_button.grab_focus()

func _on_next_pressed() -> void:
	end_battle.emit()
