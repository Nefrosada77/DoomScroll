extends "res://scripts/character.gd"
class_name Enemy

#@export var agent: NavigationAgent3D
#@export var look_area : Area3D
#@export var SPEED = 7.0
@export var baseLevel : int = 1
const battle_music : AudioStream = preload("res://Assets/Sounds/Music/normal_battle.ogg")

#var target_pos : Vector3
#var has_target : bool

#func _physics_process(delta: float) -> void:
	#velocity += get_gravity() * delta
	#
	#if Global.game_state == Global.game_states.WORLD:
		#var foundPlayer = player_on_area()
		#if foundPlayer:
			#has_target = true
			#target_pos = foundPlayer.global_position
		#
		#if has_target:
			#agent.target_position = target_pos
			#var next_target_pos := agent.get_next_path_position()
			#var direction := global_position.direction_to(next_target_pos)
			#direction.y = 0
			#velocity = direction * SPEED
			#
			#if agent.is_navigation_finished():
				#has_target = false
				#velocity = Vector3.ZERO
			#
			#var Rotation_speed = 4
			#var target_rotation := direction.signed_angle_to(Vector3.MODEL_REAR,Vector3.DOWN)
			#if abs(target_rotation - rotation.y) > deg_to_rad(60):
				#Rotation_speed = 20
			#rotation.y = move_toward(rotation.y, target_rotation, delta * Rotation_speed)
			#
			#if velocity != Vector3.ZERO:
				#for char_animation : StringName in animation.get_animation_list():
					#if char_animation.containsn("sprint"):
						#animation.play(char_animation)
			#else:
				#for char_animation : StringName in animation.get_animation_list():
					#if char_animation.containsn("idle"):
						#animation.play(char_animation)
	#
	#move_and_slide()
#
#func player_on_area() -> Player:
	#for body in look_area.get_overlapping_bodies():
		#if body is Player:
			#return body
	#return null
#
#func _on_area_3d_body_entered(body: Node3D) -> void:
	#if body is Player:
		#if Global.game_state == Global.game_states.WORLD:
			#Global.level.enter_battle(self)
			#has_target = false
			#velocity = Vector3.ZERO

func _ready() -> void:
	xp = (level+1) ** 3

func level_up():
	level += 1
	xp = (level+1) ** 3
	maxHP += hp_evolve
	currHP = maxHP
	attack += atk_evolve
	curr_attack = attack
	defense += def_evolve
	curr_defense = defense

func decision(_playerNode : Node3D) -> Skill:
	var skills_array : Array[Skill] = skills
	var weight_list : PackedFloat32Array
	skills_array.append(main_attack)
	for skill : Skill in skills_array:
		weight_list.append(skill.use_weight)
	return skills_array[Global.RNG.rand_weighted(weight_list)]
