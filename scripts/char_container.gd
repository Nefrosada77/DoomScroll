extends PanelContainer
class_name CharContainer

@export var charRef : Character

@export var NameLabel : Label
@export var healthBar : ProgressBar
@export var animation : AnimationPlayer
@export var status_texture : TextureRect
@export var atk_stats_container : PanelContainer
@export var stats_status : HBoxContainer
@export var atk_stats_label : Label
@export var def_stats_container : PanelContainer
@export var def_stats_label : Label
const defend_texture = preload("res://Assets/Images/DefendIcon.png")
const freeze_texture = preload("res://Assets/Images/FreezeIcon.png")

func _ready() -> void:
	if charRef:
		NameLabel.text = charRef.charName
		updateHP()

func get_char(character : Character):
	charRef = character
	name = charRef.charName + "Container"
	NameLabel.text = charRef.charName
	updateHP()

func hitChar(damage : int, hit_animation : bool):
	charRef.currHP -= damage
	print("received " + str(damage) + " damage")
	if charRef.currHP > charRef.maxHP:
		charRef.currHP = charRef.maxHP
	if hit_animation:
		for char_animation : StringName in charRef.animation.get_animation_list():
			if char_animation.containsn("hit"):
				charRef.animation.play(char_animation)
	var tween : Tween = create_tween()
	tween.tween_property(healthBar, "value", charRef.currHP, 0.25).set_ease(Tween.EASE_OUT_IN)
	await tween.finished
	tween.kill()
	if charRef.animation.current_animation.containsn("hit"):
		await charRef.animation.animation_finished
	if charRef.currHP <= 0.0:
		await get_tree().create_timer(0.25).timeout
		animation.play("death_container")
		for char_animation : StringName in charRef.animation.get_animation_list():
			if char_animation.containsn("death"):
				charRef.animation.play(char_animation, -1, 1.5)
				await charRef.animation.animation_finished
		charRef.get_parent().remove_child(charRef)
		get_parent().remove_child(self)
	return

func updateHP():
	healthBar.max_value = charRef.maxHP
	healthBar.value = charRef.currHP

func start_effects():
	if charRef.guarding:
		charRef.guarding = false
		for char_animation : StringName in charRef.animation.get_animation_list():
			if char_animation.containsn("idle"):
				charRef.animation.play(char_animation)
		status_texture.set_visible(false)
	if charRef.virus:
		await hitChar(charRef.maxHP * GlobalBattle.virus_percent, false)

func update_stats():
	if charRef.curr_attack < charRef.attack or charRef.curr_attack > charRef.attack:
		atk_stats_label.text = "x{0}".format({0: "%0.2f" % (charRef.curr_attack/ charRef.attack)})
		atk_stats_container.set_visible(true)
	else:
		atk_stats_container.set_visible(false)
	if charRef.curr_defense < charRef.defense or charRef.curr_defense > charRef.defense:
		def_stats_label.text = "x{0}".format({0: "%0.2f" % (charRef.curr_defense / charRef.defense)}) 
		def_stats_container.set_visible(true)
	else:
		def_stats_container.set_visible(false)

func corrupt():
	charRef.virus = true
	self_modulate = Color(3.245, 0.0, 3.294, 1.0)

func defend():
	status_texture.texture = defend_texture
	status_texture.set_visible(true)
	charRef.guarding = true

func freeze():
	status_texture.texture = freeze_texture
	self_modulate = Color(1.572, 1.572, 1.572, 1.0)
	status_texture.set_visible(true)
	charRef.freezed = true
	for char_animation : StringName in charRef.animation.get_animation_list():
		if char_animation.containsn("freezed"):
			charRef.animation.play(char_animation)
