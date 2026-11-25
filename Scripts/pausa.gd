extends Control
@onready var main_buttons: VBoxContainer = $"PanelContainer/Main Buttons"
@onready var options: Panel = $Options
@onready var panelConteiner: PanelContainer = $"PanelContainer"

var _reiniciando: bool = false
var _tween_entrada: Tween
var _tween_salida: Tween
var _tweens_float: Array[Tween] = []
var _en_transicion := false

const Float_Altura := 4.0
const Float_Duracion := 1.4
const SLIDE_DURACION := 0.45
var _tween_slide: Tween

func _ready():
	main_buttons.visible = true
	options.visible = false
	_conectar_hover()


func pausa():
	if _reiniciando:
		return
	var pausar := not get_tree().paused
	get_tree().paused = pausar
	
	if pausar:
		_animar_entrada()
	else:
		_animar_salida()

func _input(event):
	if event.is_action_pressed("Pausa"):
		pausa()

func _animar_entrada():
	_matar_tweens()
	visible = true
	main_buttons.visible = true
	options.visible = false
	
	panelConteiner.pivot_offset = panelConteiner.size / 2.0
	panelConteiner.modulate.a = 0.0
	panelConteiner.scale = Vector2(0.85, 0.85)
	
	_tween_entrada = create_tween()
	_tween_entrada.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_tween_entrada.set_parallel(true)
	_tween_entrada.tween_property(panelConteiner, "modulate:a", 1.0, 0.25)
	_tween_entrada.tween_property(panelConteiner, "scale", Vector2.ONE, 0.6).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	
	
	var botones := _get_botones()
	for i in botones.size():
		var b: Control = botones[i]
		b.modulate.a = 0.0
		b.pivot_offset = b.size / 2.0
		b.position.y += 0.0
		
		var t := create_tween()
		t.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		t.set_parallel(true)
		var delay := 0.08 * i
		t.tween_property(b, "modulate:a", 1.0, 0.3).set_delay(delay)
		t.tween_property(b, "scale", Vector2.ONE, 0.5).from(Vector2(0.6, 0.6)).set_delay(delay).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _animar_salida():
	_matar_tweens()
	_tween_salida = create_tween()
	_tween_salida.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_tween_salida.set_parallel(true)
	_tween_salida.tween_property(panelConteiner, "modulate:a", 0.0, 0.2)
	_tween_salida.tween_property(panelConteiner, "scale", Vector2(0.9, 0.9), 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_tween_salida.finished.connect(func(): visible = false, CONNECT_ONE_SHOT)

func _conectar_hover():
	for b in _get_botones():
		b.mouse_entered.connect(_on_hover.bind(b, true))
		b.mouse_exited.connect(_on_hover.bind(b, false))
		b.focus_entered.connect(_on_hover.bind(b, true))
		b.focus_exited.connect(_on_hover.bind(b, false))

func _get_botones() -> Array[Control]:
	var lista: Array[Control] = []
	for c in main_buttons.get_children():
		if c is Button:
			lista.append(c)
	return lista

func _on_hover(b: Control, entrando: bool):
	b.pivot_offset = b.size / 2.0
	var objetivo := Vector2(1.08, 1.08) if entrando else Vector2.ONE
	var t := create_tween()
	t.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	t.tween_property(b, "scale", objetivo, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _matar_tweens():
	if _tween_entrada and _tween_entrada.is_valid():
		_tween_entrada.kill()
	if _tween_salida and _tween_salida.is_valid():
		_tween_salida.kill()
	for t in _tweens_float:
		if t and t.is_valid():
			t.kill()
	_tweens_float.clear()

func _on_resume_pressed() -> void:
	pausa()

func _on_settings_pressed() -> void:
	_deslizar(main_buttons, options, -1)


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
	_deslizar(options, main_buttons, 1)


func _deslizar(saliente: Control, entrante: Control, direccion: int) -> void:
	if _en_transicion:
		return
	_en_transicion = true
	if _tween_slide and _tween_slide.is_valid():
		_tween_slide.kill()
	var distancia := get_viewport_rect().size.x * 0.5
	
	entrante.visible = true
	entrante.modulate.a = 0.0

	var pos_saliente := saliente.position
	var pos_entrante := entrante.position
	entrante.position.x = pos_entrante.x - distancia * direccion

	_tween_slide = create_tween()
	_tween_slide.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_tween_slide.set_parallel(true)
	
	_tween_slide.tween_property(saliente, "position:x", pos_saliente.x + distancia * direccion, SLIDE_DURACION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_tween_slide.tween_property(saliente, "modulate:a", 0.0, SLIDE_DURACION * 0.7)
	
	_tween_slide.tween_property(entrante, "position:x", pos_entrante.x, SLIDE_DURACION).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(0.1)
	_tween_slide.tween_property(entrante, "modulate:a", 1.0, SLIDE_DURACION * 0.7).set_delay(0.1)
	
	_tween_slide.chain().tween_callback(func():
		saliente.visible = false
		saliente.position = pos_saliente
		saliente.modulate.a = 1.0
		_en_transicion = false
	)
