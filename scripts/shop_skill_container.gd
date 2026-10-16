extends PanelContainer
class_name SkillContainer

@export var skNameLabel : Label
@export var skIcon : TextureRect
@export var skEffectLabel : Label
@export var priceLabel : Label
@export var learnMenu : VBoxContainer
@export var skillchangeMenu : VBoxContainer
@export var learnButton : Button
var price : int = 99999
var skill : Skill

signal button_disable
signal button_enable

func change_info(new_skill : Skill):
	skill = new_skill
	skNameLabel.text = skill.SkName
	skIcon.texture = skill.SkIcon
	skEffectLabel.text = skill.SkDesc
	if skill.skType == Skill.skillType.PASSIVE:
		price = 100
	else:
		price = 75
	priceLabel.text = "Price: $" + str(price)


func _on_learn_pressed() -> void:
	if Global.level.player.money >= price:
		if skill.skType == Skill.skillType.PASSIVE:
			if Global.level.player.passiveSkills.size() < 4:
				Global.level.player.passiveSkills.append(skill)
				learnedSkill()
				%Learn.grab_focus()
			else:
				%Skill1.clear()
				%Skill2.clear()
				%Skill3.clear()
				%Skill4.clear()
				%CANCEL_LEARN.grab_focus()
				%Skill1.append_text("[font_size=20]{0}[/font_size]".format({"0" : Global.level.player.passiveSkills[0].SkName}))
				%Skill1.append_text("\n[ul]{0}[/ul]".format({"0" : Global.level.player.passiveSkills[0].SkDesc}))
				%Skill2.append_text("[font_size=20]{0}[/font_size]".format({"0" : Global.level.player.passiveSkills[1].SkName}))
				%Skill2.append_text("\n[ul]{0}[/ul]".format({"0" : Global.level.player.passiveSkills[1].SkDesc}))
				%Skill3.append_text("[font_size=20]{0}[/font_size]".format({"0" : Global.level.player.passiveSkills[2].SkName}))
				%Skill3.append_text("\n[ul]{0}[/ul]".format({"0" : Global.level.player.passiveSkills[2].SkDesc}))
				%Skill4.append_text("[font_size=20]{0}[/font_size]".format({"0" : Global.level.player.passiveSkills[3].SkName}))
				%Skill4.append_text("\n[ul]{0}[/ul]".format({"0" : Global.level.player.passiveSkills[3].SkDesc}))
				button_disable.emit()
				learnMenu.set_visible(false)
				skillchangeMenu.set_visible(true)
		else:
			if Global.level.player.skills.size() < 4:
				Global.level.player.skills.append(skill)
				learnedSkill()
				%Learn.grab_focus()
			else:
				%Skill1.clear()
				%Skill2.clear()
				%Skill3.clear()
				%Skill4.clear()
				%CANCEL_LEARN.grab_focus()
				%Skill1.append_text("[font_size=20]{0}[/font_size]".format({"0" : Global.level.player.skills[0].SkName}))
				%Skill1.append_text("\n[ul]{0}[/ul]".format({"0" : Global.level.player.skills[0].SkDesc}))
				%Skill2.append_text("[font_size=20]{0}[/font_size]".format({"0" : Global.level.player.skills[1].SkName}))
				%Skill2.append_text("\n[ul]{0}[/ul]".format({"0" : Global.level.player.skills[1].SkDesc}))
				%Skill3.append_text("[font_size=20]{0}[/font_size]".format({"0" : Global.level.player.skills[2].SkName}))
				%Skill3.append_text("\n[ul]{0}[/ul]".format({"0" : Global.level.player.skills[2].SkDesc}))
				%Skill4.append_text("[font_size=20]{0}[/font_size]".format({"0" : Global.level.player.skills[3].SkName}))
				%Skill4.append_text("\n[ul]{0}[/ul]".format({"0" : Global.level.player.skills[3].SkDesc}))
				button_disable.emit()
				learnMenu.set_visible(false)
				skillchangeMenu.set_visible(true)

func learn_button_disable() -> void:
	learnButton.set_disabled(true)

func learn_button_enable() -> void:
	if learnButton.text != "SKILL LEARNED":
		learnButton.set_disabled(false)

func _on_sk_btn_pressed(idx: int) -> void:
	if skill.skType == Skill.skillType.PASSIVE:
		Global.level.player.passiveSkills[idx] = skill
	else:
		Global.level.player.skills[idx] = skill
	learnMenu.set_visible(true)
	skillchangeMenu.set_visible(false)
	learnedSkill()
	%Learn.grab_focus()

func _on_cancel_learn_pressed() -> void:
	learnMenu.set_visible(true)
	skillchangeMenu.set_visible(false)
	button_enable.emit()
	%Learn.grab_focus()

func learnedSkill():
	Global.level.player.money -= price
	priceLabel.set_visible(false)
	%Learn.set_disabled(true)
	%Learn.text = "SKILL LEARNED"
	button_enable.emit()
