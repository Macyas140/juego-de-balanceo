extends HSlider

@export var audio_bus_name_Inicio:String

var audio_bus_id_Inicio

func _ready():
	audio_bus_id_Inicio = AudioServer.get_bus_index(audio_bus_name_Inicio)
	if audio_bus_id_Inicio == -1:
		push_warning("HSlider: el bus '%s' no existe." % audio_bus_name_Inicio)
		return
	var db_actual = AudioServer.get_bus_volume_db(audio_bus_id_Inicio)
	set_value_no_signal(db_to_linear(db_actual))

func _on_value_changed(value: float) -> void:
	var db2 = linear_to_db(value)
	AudioServer.set_bus_volume_db(audio_bus_id_Inicio, db2)
