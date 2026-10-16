extends Node
class_name skill_events

@onready var Battle: battle_manager = $".."
@export var skill_label : Label
var last_turn : Character

func skill_effect(attacker: CharContainer, target: CharContainer, skill : Skill):
	last_turn = attacker.charRef
	skill_label.text = skill.SkName
	skill_label.set_visible(true)
	if attacker is PlayerContainer:
		attacker.loseMP(skill.SkCost)
	#TODO animation time
	await get_tree().create_timer(0.5).timeout
	var crit : bool = 0.01 + skill.crit_bonus + attacker.charRef.crit_chance > randf_range(.0, 1.) 
	var damage = (((2 * float(attacker.charRef.curr_attack) + 2) * skill.skPower) / 50) * ((float(attacker.charRef.curr_attack) / target.charRef.curr_defense) + 2)
	#BEFORE EFFECT
	match skill.skID:
		2:
			damage = ((2 * float(attacker.charRef.maxHP) + 2) * skill.skPower) / 50
		3:
			attacker.defend()
			print(attacker.charRef.charName + " defended")
		6:
			target.corrupt()
		7:
			if target.charRef.curr_attack > (attacker.charRef.curr_attack / 2):
				target.charRef.curr_attack -= (0.2 * target.charRef.attack)
				target.update_stats()
		9:
			if target.charRef.guarding:
				damage = (((2 * float(attacker.charRef.curr_attack) + 2) * (skill.skPower * 2)) / 50)
	for char_animation : StringName in attacker.charRef.animation.get_animation_list():
		if char_animation.containsn(skill.SkName):
			attacker.charRef.animation.play(char_animation)
	match skill.skType:
		Skill.skillType.ATTACK:
			if target.charRef.guarding:
				damage *= 0.5
				crit = false
			if crit:
				damage *= 2
			if damage < 1.0:
				damage = 1
			for passive : Skill in target.charRef.passiveSkills:
				if passive.skID == 102:
					if damage > 30:
						damage = 30
			print(attacker.charRef.charName + " attacked " + target.charRef.charName + " with " + skill.SkName  + " dealing " + str(int(damage))+ " damage")
			for i in range(0, skill.maxhits):
				if target != null:
					await target.hitChar(int(damage), true)
		Skill.skillType.HEAL:
			print(attacker.charRef.charName + " healed " + target.charRef.charName + " with " + skill.SkName  + " healing " + str(int(damage))+ " HP")
			await target.hitChar(int(-damage), false)
		_:
			print(attacker.charRef.charName + " used " + skill.SkName)
	if attacker.charRef.animation.current_animation.containsn(skill.SkName):
		await attacker.charRef.animation.animation_finished
	#AFTER EFFECT
	match skill.skID:
		-1:
			if attacker.charRef.freezed:
				await  get_tree().create_timer(0.5).timeout
				attacker.charRef.freezed = false
				attacker.set_self_modulate(Color(1.0, 1.0, 1.0, 1.0))
				for char_animation : StringName in attacker.charRef.animation.get_animation_list():
					if char_animation.containsn("idle"):
						attacker.charRef.animation.play(char_animation)
			attacker.status_texture.set_visible(false)
			
		0:
			if attacker is PlayerContainer:
				if attacker.charRef.currMP < attacker.charRef.maxMP:
					await attacker.loseMP(float(-attacker.charRef.maxMP)/10)
		1:
			var freeze_num = Global.RNG.randf_range(.0,1)
			if freeze_num <= GlobalBattle.freeze_chance:
				#print(target.charRef.name + " freezed")
				target.freeze()
				await  get_tree().create_timer(0.5).timeout
		3:
			if attacker is PlayerContainer:
				if attacker.charRef.currMP < attacker.charRef.maxMP:
					await attacker.loseMP(float(-attacker.charRef.maxMP)/10)
		4:
			if attacker.charRef.curr_defense < attacker.charRef.defense * 2:
				attacker.charRef.curr_defense += (0.25 * attacker.charRef.defense)
				attacker.update_stats()
		8:
			if attacker.charRef.curr_attack < attacker.charRef.attack * 2:
				attacker.charRef.curr_attack += (0.25 * attacker.charRef.attack)
				attacker.update_stats()
		10:
			Battle.add_char(Global.enemies[1][0].instantiate())
		11:
			for i in range(2):
				await Battle.add_char(Global.enemies[0][0].instantiate())
			await attacker.hitChar(attacker.charRef.maxHP, true)
	await get_tree().create_timer(0.20).timeout
	skill_label.set_visible(false)
	Battle.state_manager.passTurn()

func usePassive(user : CharContainer, skill : Skill):
	skill_label.text = skill.SkName
	skill_label.set_visible(true)
	match skill.skID:
		100:
			user.charRef.curr_attack += (0.2 * user.charRef.attack)
		101:
			user.charRef.curr_defense += (0.2 * user.charRef.defense)
		103:
			user.charRef.crit_chance += 0.1
	user.update_stats()
	await get_tree().create_timer(0.5).timeout
	skill_label.set_visible(false)
