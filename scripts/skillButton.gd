extends "res://scripts/GUIBTN.gd"
class_name SkillButton

@export var skill : Skill
@export var power_container : PanelContainer
@export var power_label : Label
@export var cost_container : PanelContainer
@export var cost_label : Label

func setup(new_skill : Skill):
	skill = new_skill
	name = skill.SkName.to_upper()
	if skill.SkIcon:
		texture_normal = skill.SkIcon
	else:
		texture_normal = PlaceholderTexture2D.new()
		texture_normal.size = Vector2i(128,128)
	changeLabel()
	if skill.skPower > 0:
		power_label.text = str(skill.skPower)
		power_container.set_visible(true)
	else:
		power_container.set_visible(false)
	if skill.SkCost > 0:
		cost_label.text = str(skill.SkCost)
		cost_container.set_visible(true)
	else:
		cost_container.set_visible(false)
	desctription = skill.SkDesc

func _on_hover() -> void:
	if GlobalBattle.player:
		if GlobalBattle.player.currMP < skill.SkCost:
			self_modulate = Color(1.0, 0.585, 0.533, 1.0)
		else:
			animation.play("Hover")

func _on_not_hover() -> void:
	animation.play("RESET")
	if GlobalBattle.player:
		if GlobalBattle.player.currMP < skill.SkCost:
			self_modulate = Color(1.0, 0.585, 0.533, 1.0)
