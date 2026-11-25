extends Control

@onready var options: Panel = $Options

var _cambiando := false
const DESPLAZAMIENTO := 80.0

func _ready():
	$MenuInicioTrans/AnimationPlayer.play("AnimacionInicioFinal")
	_animar_entrada()

func _animar_entrada() -> void:
	var destino_y := options.position.y
	options.position.y = destino_y + DESPLAZAMIENTO
	options.modulate.a = 0.0

	var t := create_tween().set_parallel(true)
	t.tween_property(options, "position:y", destino_y, 0.55).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(options, "modulate:a", 1.0, 0.35)

func _animar_salida() -> void:
	var t := create_tween().set_parallel(true)
	t.tween_property(options, "position:y", options.position.y + DESPLAZAMIENTO, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	t.tween_property(options, "modulate:a", 0.0, 0.25)
	await t.finished

func _on_back_pressed() -> void:
	if _cambiando:
		return
	_cambiando = true
	await _animar_salida()
	get_tree().change_scene_to_file("res://Scenes/menu_inicio.tscn")
