extends Control
@onready var tempo: TextureProgressBar = $TextureProgressBar
@onready var temporizador_bloqueo: Timer = $TemporizadorBloqueo
@onready var pantalla_muerte: Timer = $PantallaMuerte

@export var estamina_max = 200
@export var cansancio:float = 20
@export var costo_disparo:float = 15
@export var cargaRapida:float = 150
@export var espera_tras_daño:float = 2.5
@export var offset_sobre_personaje:Vector2 = Vector2(5,-40)
@export var costoImpulso = 30
var gastoAtaque:float = 15.0

signal muerto
signal listoReinicio

var estamina:float
var bloqueada:bool = false                                                                                                                                         
var ya_murio:bool = false
var jugador_objetivo:Node2D = null

func _ready():
	top_level = true
	temporizador_bloqueo.one_shot = true
	temporizador_bloqueo.timeout.connect(_on_temporizador_bloqueo_timeout)
	pantalla_muerte.one_shot = true
	pantalla_muerte.timeout.connect(onPantallaMuerte_timeout)
	reiniciar()
	
func reiniciar() -> void:
	estamina = estamina_max
	tempo.max_value = estamina_max
	tempo.value = estamina
	bloqueada = false
	ya_murio = false
	temporizador_bloqueo.stop()
	pantalla_muerte.stop()
	_actualizar_visibilidad()

func seguir_a(jugador:Node2D) -> void:
	jugador_objetivo = jugador

func _process(delta: float) -> void:
	if jugador_objetivo and is_instance_valid(jugador_objetivo):
		global_position = jugador_objetivo.global_position + offset_sobre_personaje

#Aqui llamo a todo lo que el jugador tendra acceso del temporizador
func actualizar_Estado(colgando_en_aire:bool, en_suelo:bool, delta:float) -> void:
	if ya_murio:
		return
	if colgando_en_aire:
		gastar(cansancio * delta)
	elif not bloqueada and en_suelo:
		estamina = min(estamina + cargaRapida * delta, estamina_max)
		tempo.value = estamina
		_actualizar_visibilidad()
	
func gastar_por_disparo() -> void:
	gastar(costo_disparo)

func recibir_daño(cantidad:float) -> void:
	gastar(cantidad)
	bloqueada = true
	temporizador_bloqueo.start(espera_tras_daño)
	
func gastar(cantidad:float) -> void:
	if ya_murio:
		return
	estamina = max(estamina - cantidad, 0.0)
	tempo.value = estamina
	_actualizar_visibilidad()
	if estamina <= 0.0:
		ya_murio = true
		muerto.emit()
		pantalla_muerte.start(pantalla_muerte.wait_time)

func gasto_impulso() -> void:
	gastar(costoImpulso)

func _actualizar_visibilidad() -> void:
	visible = estamina < estamina_max

func _on_temporizador_bloqueo_timeout() -> void:
	bloqueada = false

func onPantallaMuerte_timeout() -> void:
	listoReinicio.emit()

func gasto_Ataque() -> void:
	gastar(gastoAtaque)
