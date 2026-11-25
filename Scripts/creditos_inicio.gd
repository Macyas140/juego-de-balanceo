extends Control

@export var contenido: Control   # arrastra aquí tu Panel/contenedor de créditos desde el inspector

var _cambiando := false


func _ready():
	_animar_entrada()


func _animar_entrada() -> void:
	contenido.pivot_offset = contenido.size / 2.0
	contenido.scale = Vector2(0.8, 0.8)
	contenido.modulate.a = 0.0

	var t := create_tween().set_parallel(true)
	t.tween_property(contenido, "scale", Vector2.ONE, 0.55)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(contenido, "modulate:a", 1.0, 0.35)


func _animar_salida() -> void:
	contenido.pivot_offset = contenido.size / 2.0

	var t := create_tween().set_parallel(true)
	t.tween_property(contenido, "scale", Vector2(0.85, 0.85), 0.3)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	t.tween_property(contenido, "modulate:a", 0.0, 0.25)
	await t.finished


func _on_back_pressed() -> void:
	if _cambiando:
		return
	_cambiando = true
	await _animar_salida()
	get_tree().change_scene_to_file("res://Scenes/menu_inicio.tscn")
