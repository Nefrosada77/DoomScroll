extends Node3D
class_name Spawner

@export var enemy_scene : PackedScene
@export var timer : Timer

var spawned_enemy : Enemy

func _ready() -> void:
	_on_timer_timeout()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if !spawned_enemy:
		if timer.is_stopped():
			await get_tree().create_timer(0.5).timeout
			timer.start()


func _on_timer_timeout() -> void:
	if !spawned_enemy:
		await get_tree().create_timer(randf_range(.0,0.5)).timeout
		var newEnemy : Enemy = enemy_scene.instantiate()
		spawned_enemy = newEnemy
		add_child(spawned_enemy)
		spawned_enemy.global_position = global_position
