extends Node2D

@onready var button_manager: Control = $Button_Manager

var button_type = null
var _cambiando := false

const DESPLAZAMIENTO := 60.0

func _ready():
	_animar_entrada()

func _animar_entrada() -> void:
	var botones := button_manager.get_children()
	for i in botones.size():
		var b := botones[i] as Control
		if b == null:
			continue
		var destino_y := b.position.y
		b.position.y = destino_y + DESPLAZAMIENTO
		b.modulate.a = 0.0

		var t := create_tween().set_parallel(true)
		t.tween_property(b, "position:y", destino_y, 0.5).set_delay(i * 0.08).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		t.tween_property(b, "modulate:a", 1.0, 0.3).set_delay(i * 0.08)

func _animar_salida() -> void:
	var botones := button_manager.get_children()
	var t := create_tween().set_parallel(true)
	for i in botones.size():
		var b := botones[i] as Control
		if b == null:
			continue
		t.tween_property(b, "position:y", b.position.y + DESPLAZAMIENTO, 0.3).set_delay(i * 0.05).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		t.tween_property(b, "modulate:a", 0.0, 0.25).set_delay(i * 0.05)
	await t.finished

func _on_start_pressed() -> void:
	if _cambiando:
		return
	_cambiando = true
	button_type = "Start"
	
	get_tree().change_scene_to_file("res://Scenes/juego.tscn")
	


func _on_settings_pressed() -> void:
	if _cambiando:
		return
	_cambiando = true
	button_type = "Settings"
	await _animar_salida()
	get_tree().change_scene_to_file("res://Scenes/settingsPausa.tscn")
	




func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_creditos_pressed() -> void:
	if _cambiando:
		return
	_cambiando = true
	button_type = "Creditos"
	await _animar_salida()
	get_tree().change_scene_to_file("res://Scenes/Creditos_inicio.tscn")
