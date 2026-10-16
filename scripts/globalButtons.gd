extends Node

enum game_states {MAIN_MENU, PAUSED, BATTLE, WORLD, INTERACT, SHOP}

var RNG : RandomNumberGenerator

const accept_sound : AudioStream = preload("res://Assets/Sounds/SFX/accept.wav")
const decline_sound : AudioStream = preload("res://Assets/Sounds/SFX/decline.wav")

var skills : Array[Skill]
var shopSkill : Array[Skill]

var world_level : int = 0
var world_timer : Timer

var levels : Array = [[preload("res://scenes/Levels/level_1.tscn")]]

var enemies : Array = [[preload("res://characters/Neko.tscn"), preload("res://characters/BrainRot.tscn"), preload("res://characters/TrojBot.tscn")], [preload("res://characters/ratBot.tscn")]]
var bosses : Array = [[preload("res://characters/crypto.tscn")], [preload("res://characters/ratkingbot.tscn")]]

var game_state : game_states = game_states.MAIN_MENU
var last_state : game_states = game_states.MAIN_MENU

const debug_player_scene : PackedScene = preload("res://characters/HackersMan.tscn")

var rememberChoice : bool = true
var level : Level
var player : Player
var curr_level_color : Color = Color(1,1,1)

func _ready() -> void:
	skills.clear()
	var active_skills_files := DirAccess.get_files_at("res://skills/actives")
	for active_skill in active_skills_files:
		var new_skill : Skill = load("res://skills/actives/" + active_skill)
		if new_skill.reward or new_skill.sellable:
				skills.append(new_skill)
	var passive_skills_files := DirAccess.get_files_at("res://skills/passives")
	for passive_skill in passive_skills_files:
		var new_skill : Skill = load("res://skills/passives/" + passive_skill)
		if new_skill.reward or new_skill.sellable:
				skills.append(new_skill)
	for skill in skills:
		if skill.sellable:
			shopSkill.append(skill)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fullScreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN)

func new_state(state : game_states):
	if state == game_states.PAUSED:
		last_state = game_state
		level.world.call_deferred("set_process_mode", Node.PROCESS_MODE_DISABLED)
	else:
		level.world.call_deferred("set_process_mode", Node.PROCESS_MODE_INHERIT)
		level.world.set_process(true)
	game_state = state

func back_state():
	new_state(last_state)

func create_RNG():
	RNG = RandomNumberGenerator.new()
	seed(RNG.seed)

func create_timer():
	world_timer = Timer.new()
	world_timer.wait_time = 300
