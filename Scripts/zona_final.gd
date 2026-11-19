extends Area2D

@export var camara_final: PhantomCamera2D        
@export var prioridad_camara_final: int = 20     
@export var espera_camara: float = 1.5           
@export var margen_salida: float = 80.0         
@export_file("*.tscn") var escena_siguiente: String = ""   

@export_group("Victoria")
@export var repeticiones_victoria_1: int = 2
@export var altura_victoria: float = 90.0     
@export var tiempo_subida: float = 0.7        
@export var tiempo_flotando: float = 2.0

signal secuencia_terminada

var _activada: bool = false

func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if _activada or not body.is_in_group("Jugador"):
		return
	if body.muriendo or body.muriendoColgado:
		return
	_activada = true
	print("ZonaFinal: inicia la cinemática")
	if camara_final:
		camara_final.priority = prioridad_camara_final
	else:
		push_warning("ZonaFinal: asigna camara_final en el Inspector")
	await _secuencia(body)

#Aqui es donde puse lo que se hace en la cinematica
func _secuencia(j) -> void:
	j.iniciar_cinematica()
	await _esperar_suelo(j)          # si entró en el aire, espera a que caiga
	await _pausa(espera_camara)      # deja que la cámara llegue
	
	j.cine_mover(1, 0)               # se voltea hacia la derecha sin moverse (quítalo si prefieres que conserve su dirección)
	await _pausa(0.2)
	
	# Celebra: Victoria1 (las veces configuradas), luego Victoria2 sube, flota y cae
	await _victoria(j)
	
	# Corre hasta salirse de la cámara
	j.cine_mover(1, j.SPEED)
	await _hasta_salir(j)
	j.cine_mover(0)
	
	print("ZonaFinal: terminó la cinemática")
	secuencia_terminada.emit()
	if escena_siguiente != "":
		TransitionScreen.transition()
		await TransitionScreen.on_transition_finished
		get_tree().change_scene_to_file(escena_siguiente)

# ---------- Ayudas ----------
func _pausa(segundos: float) -> void:
	await get_tree().create_timer(segundos, false).timeout   # false: se detiene si abres la pausa

func _esperar_suelo(j, maximo: float = 3.0) -> void:
	var t := 0.0
	while not j.is_on_floor() and t < maximo:
		await get_tree().physics_frame
		t += get_physics_process_delta_time()

func _saltar(j) -> void:
	j.cine_saltar()
	await _pausa(0.3)                
	await _esperar_suelo(j)

func _hasta_salir(j) -> void:
	if camara_final == null:
		await _pausa(3.0)
		return
	var mitad_ancho := get_viewport_rect().size.x / (2.0 * camara_final.zoom.x)
	var meta := camara_final.global_position.x + mitad_ancho + margen_salida
	var t := 0.0
	while j.global_position.x < meta and t < 8.0:
		await get_tree().physics_frame
		t += get_physics_process_delta_time()

func _victoria(j) -> void:
	var anim = j.animador
	await anim.reproducir_victoria_1(repeticiones_victoria_1)
	
	# Victoria2: la animación corre mientras el cuerpo sube
	anim.reproducir_victoria_2()
	# velocidad inicial que, bajando poco a poco hasta 0, recorre justo "altura_victoria"
	j.cine_levitar(-2.0 * altura_victoria / tiempo_subida)
	var tw := create_tween()
	tw.tween_property(j, "cine_vy", 0.0, tiempo_subida)
	await tw.finished
	
	await _pausa(tiempo_flotando)         # se queda flotando
	
	j.cine_soltar_levitacion()            # vuelve la gravedad
	anim.terminar_victoria()              # entra la animación de caída
	await _esperar_suelo(j)
	await _pausa(0.4)
