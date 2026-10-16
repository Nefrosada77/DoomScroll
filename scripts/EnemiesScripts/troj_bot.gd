extends Enemy

const sacrifice_skill : Skill = preload("res://skills/actives/sacrifice.tres")

func decision(_playerNode : Node3D) -> Skill:
	if currHP <= (maxHP * 0.25):
			return skills[skills.find(sacrifice_skill)]
	var skills_array : Array[Skill] = skills
	var weight_list : PackedFloat32Array
	skills_array.pop_at(skills.find(sacrifice_skill))
	skills_array.append(main_attack)
	for skill : Skill in skills_array:
		weight_list.append(skill.use_weight)
	return skills_array[Global.RNG.rand_weighted(weight_list)]
