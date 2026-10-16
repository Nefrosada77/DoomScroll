extends Level

func _ready() -> void:
	Global.create_RNG()
	Global.create_timer()
	Global.shopSkill.shuffle()
	super._ready()

	#print(Global.skills)
