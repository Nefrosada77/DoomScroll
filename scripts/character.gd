extends CharacterBody3D
class_name Character

@export var charName : String
@export_range(1,99) var level : int = 1
@export var xp : int = 0
@export var money : int = 0
@export_range(1,999) var maxHP : int = 20
@export_range(1,999) var currHP : int = 20
@export_range(1,999) var maxMP : int = 10
@export_range(1,999) var currMP : int = 10
@export_range(1,999) var attack : int = 5
@export_range(1,999) var curr_attack : float = 5
@export_range(1,999) var defense : int = 5
@export_range(1,999) var curr_defense : float = 5
@export var main_attack : Skill
@export var skills : Array[Skill]
@export var passiveSkills : Array[Skill]

@export var hp_evolve : int = 5
@export var atk_evolve : int = 1
@export var def_evolve : int = 1

@export var animation : AnimationPlayer
@export var marker_analysis : Marker3D

var turn : int = 0
var crit_chance : float = .0
var guarding : bool = false
var virus : bool = false
var freezed : bool = false
