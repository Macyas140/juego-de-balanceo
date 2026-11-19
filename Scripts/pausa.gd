extends Control
@onready var main_buttons: VBoxContainer = $"PanelContainer/Main Buttons"
@onready var options: Panel = $Options

var _reiniciando: bool = false

func _ready():
	main_buttons.visible = true
	options.visible = false


func pausa():
	if _reiniciando:
		return
	get_tree().paused =! get_tree().paused
	visible = get_tree().paused

func _input(event):
	if event.is_action_pressed("Pausa"):
		pausa()

func _on_resume_pressed() -> void:
	pausa()

func _on_settings_pressed() -> void:
	main_buttons.visible = false
	options.visible = true


func _on_restart_pressed() -> void:
	if _reiniciando:
		return                              
	_reiniciando = true
	Checkpoint.borrar()
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished   
	get_tree().paused = false
	get_tree().reload_current_scene()
	_reiniciando = false


func _on_main_menu_pressed() -> void:
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/menu_inicio.tscn")


func _on_exit_game_pressed() -> void:
	get_tree().quit()


func _on_back_options_pressed() -> void:
	_ready()
