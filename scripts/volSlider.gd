extends HSlider
class_name VolumeSlider

@export var busName : String
@export var label : Label
var busIdx : int

func _ready() -> void:
	busIdx = AudioServer.get_bus_index(busName)
	value = AudioServer.get_bus_volume_linear(busIdx)
	label.text = str(int(value*100)) + "%"

func _on_value_changed(_value: float) -> void:
	AudioServer.set_bus_volume_db(
		busIdx,
		linear_to_db(_value)
	)
	label.text = str(int(value*100)) + "%"
