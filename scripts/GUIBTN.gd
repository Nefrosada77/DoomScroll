extends TextureButton
class_name GUIButton

@export var desctription: String
@export var label : Label
@export var animation : AnimationPlayer

func changeLabel():
	label.text = name

func _on_hover() -> void:
	animation.play("Hover")

func _on_not_hover() -> void:
	animation.play("RESET")
