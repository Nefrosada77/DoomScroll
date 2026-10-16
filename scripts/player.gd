extends Character
class_name Player

@export var defend : Skill
@export var camera : Camera3D
@export var model : Node3D
@export var interact_area : Area3D

@export var xp_to_level : int = 8
@export var mp_evolve : int = 7


@export var raycast_pos_x : RayCast3D
@export var raycast_neg_x : RayCast3D
@export var raycast_pos_z : RayCast3D
@export var raycast_neg_z : RayCast3D
var battles : int = 0

var interactable : Interactable

const SPEED = 7.5
const turn_speed = 2.5
var walk_timer := .0

var look : bool = false
var collide_pos_x : bool = true
var collide_neg_x : bool = true
var collide_pos_z : bool = true
var collide_neg_z : bool = true

func _physics_process(delta: float) -> void:
	velocity += get_gravity() * delta

	if Global.game_state == Global.game_states.WORLD:
		if Input.is_action_pressed("turn_left") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			rotate(Vector3.UP, turn_speed * delta)
		if Input.is_action_pressed("turn_right") or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			rotate(Vector3.UP, -turn_speed * delta)
		
		if raycast_neg_x.is_colliding():
			collide_neg_x = true
		else:
			collide_neg_x = false
		if raycast_pos_x.is_colliding():
			collide_pos_x = true
		else:
			collide_pos_x = false
		if raycast_neg_z.is_colliding():
			collide_neg_z = true
		else:
			collide_neg_z = false
		if raycast_pos_z.is_colliding():
			collide_pos_z = true
		else:
			collide_pos_z = false

		var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			#print(direction)
			look = true
			for char_animation : StringName in animation.get_animation_list():
				if char_animation.containsn("jog"):
					animation.play(char_animation, -1, 1.5)
			if (direction.x > .0 and collide_pos_x) or (direction.x < .0 and collide_neg_x):
				velocity.x = direction.x * SPEED
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
			if (direction.z > .0 and collide_pos_z) or (direction.z < .0 and collide_neg_z):
				velocity.z = direction.z * SPEED
			else:
				velocity.z = move_toward(velocity.z, 0, SPEED)
			if direction.x != .0 or direction.z != .0:
				model.look_at(Vector3(global_position.x - direction.x, model.global_position.y, global_position.z - direction.z), Vector3.UP)
			walk_timer += delta
		else:
			for char_animation : StringName in animation.get_animation_list():
				if char_animation.containsn("idle"):
					animation.play(char_animation)
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
		
		if Input.is_action_pressed("Interact"):
			if interactable:
				Global.new_state(Global.game_states.INTERACT)
				velocity.x = move_toward(velocity.x, 0, SPEED)
				velocity.z = move_toward(velocity.z, 0, SPEED)
				for char_animation : StringName in animation.get_animation_list():
					if char_animation.containsn("interact"):
						animation.play(char_animation, -1, 5)
						await animation.animation_finished
				interactable.interact()

	move_and_slide()

func level_up():
	xp -= xp_to_level
	level += 1
	xp_to_level = (level+1) ** 3
	maxHP += hp_evolve
	maxMP += mp_evolve
	currHP = maxHP
	currMP = maxMP
	attack += atk_evolve
	curr_attack = attack
	defense += def_evolve
	curr_defense = defense

func update_stats(player_updated : Player):
	currHP = player_updated.currHP
	maxHP = player_updated.maxHP
	currMP = player_updated.currMP
	maxMP = player_updated.maxMP

func _on_interact_body_entered(body: Node3D) -> void:
	if body.get_parent().is_in_group("interactable"):
		interactable = body.get_parent()
		Global.level.interact_label.clear()
		Global.level.interact_label.append_text(interactable.description)
		Global.level.interact_label.set_visible(true)


func _on_interact_body_exited(body: Node3D) -> void:
	if body.get_parent().is_in_group("interactable"):
		if Global.game_state != Global.game_states.INTERACT:
			interactable = null
			Global.level.interact_label.set_visible(false)
