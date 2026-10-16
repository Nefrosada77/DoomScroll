extends Level
class_name Shop

var sellSkills : Array[Skill] = []
@export var ContainerSkills : Array[SkillContainer]
@export var ShopGUI : Control
@export var playerMoneyLabel : Label

func _physics_process(_delta: float) -> void:
	playerMoneyLabel.text = "$" + str(player.money)

func _ready() -> void:
	for container in ContainerSkills:
		container.set_visible(false)
	super._ready()
	var options : Array[Skill] = []
	for skill in Global.shopSkill:
		if (!player.skills.has(skill) and !player.passiveSkills.has(skill)):
			options.append(skill)
	while len(sellSkills) < (3 if len(options) >= 3 else len(options)):
		var picked_skill : Skill = options.pick_random()
		if (!player.skills.has(picked_skill) and !player.passiveSkills.has(picked_skill)) and !sellSkills.has(picked_skill):
			sellSkills.append(picked_skill)
	for i in range(len(sellSkills)):
		ContainerSkills[i].set_visible(true)
		ContainerSkills[i].change_info(sellSkills[i])
