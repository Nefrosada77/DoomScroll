extends "res://scripts/char_container.gd"
class_name PlayerContainer

@export var healthMaxHP : Label
@export var healthcurrHP : Label
@export var manaBar : ProgressBar
@export var manaMaxMP : Label
@export var manacurrMP : Label


func _ready() -> void:
	if charRef:
		NameLabel.text = charRef.charName
		updateHP()
		updateMP()

func hitChar(damage : int, hit_animation : bool):
	charRef.currHP -= damage
	if charRef.currHP > charRef.maxHP:
		charRef.currHP = charRef.maxHP
	await get_tree().create_timer(0.2).timeout
	if hit_animation:
		for char_animation : StringName in charRef.animation.get_animation_list():
			if char_animation.containsn("hit"):
				charRef.animation.play(char_animation)
	var tween : Tween = create_tween()
	tween.tween_property(healthBar, "value", charRef.currHP, 0.2).set_ease(Tween.EASE_OUT_IN)
	tween.tween_property(healthcurrHP, "text", str(int(healthBar.value)), 0.2).set_ease(Tween.EASE_OUT_IN)
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
		charRef.queue_free()
		Global.level.player.queue_free()
		get_parent().remove_child(self)
	return

func loseMP(mp_lost: int):
	charRef.currMP -= mp_lost
	var tween : Tween = create_tween()
	tween.tween_property(manaBar, "value", charRef.currMP, 0.2).set_ease(Tween.EASE_OUT_IN)
	tween.tween_property(manacurrMP, "text", str(int(manaBar.value)), 0.2).set_ease(Tween.EASE_OUT_IN)
	await tween.finished
	tween.kill()

func updateMP():
	manaBar.max_value = charRef.maxMP
	manaBar.value = charRef.currMP

func _physics_process(_delta: float) -> void:
	healthMaxHP.text = str(int(healthBar.max_value))
	healthcurrHP.text = str(int(healthBar.value))
	manaMaxMP.text = str(int(manaBar.max_value))
	manacurrMP.text = str(int(manaBar.value))
