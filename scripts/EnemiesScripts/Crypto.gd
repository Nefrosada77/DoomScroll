extends Enemy

func decision(playerNode : Node3D) -> Skill:
	var corrupt_skill : Skill
	for skill : Skill in Global.skills: 
		if skill.skID == 6:
			corrupt_skill = skill
	for player : Player in playerNode.get_children():
		if !player.virus:
			return skills[skills.find(corrupt_skill)]
	var skills_array : Array[Skill] = skills
	var weight_list : PackedFloat32Array
	skills_array.pop_at(skills.find(corrupt_skill))
	skills_array.append(main_attack)
	for skill : Skill in skills_array:
		weight_list.append(skill.use_weight)
	return skills_array[Global.RNG.rand_weighted(weight_list)]
