extends Node2D
@onready var jugador: CharacterBody2D = $".."
@onready var tempCoyTi: Timer = $TemporizadorCoyoteTime
@onready var temporizador_buffer: Timer = $TemporizadorBuffer

#esto es el coyote time
var coyoteTime:bool = false
var enElSuelo: bool = false
@export var coyoteTimer:float = 0.3

#Diferentes velocidades del salto
@export var salto_min:float = -100.0
@export var salto_max:float = -300.0

#Esto es para que cuando saltas en el aire y tocas el suelo saltes
var salto_al_tocar_El_Suelo:bool = false
@export var duracionBuffering:float = 0.15

#Esto es la gravedadaaa
@export var gravity = 2000
var current_gravity = gravity
var saltando:bool = false
var muriendo:bool = false

func _ready() -> void:
	jugador = get_parent()
	tempCoyTi.one_shot = true
	tempCoyTi.timeout.connect(TemporizadorCoyoteTime_Timeout)
	temporizador_buffer.one_shot = true
	temporizador_buffer.timeout.connect(TemporizadorBuffer_Timeout)

func _physics_process(delta: float) -> void:
#Aqui se aplica la gravedad del personaje
	if not jugador.is_on_floor():
		jugador.velocity.y += gravity * delta
	else:
		jugador.saltoGancho = false
	
	if muriendo:
		return

# Esto es lo que se encarga del salto y el buffering.
	if Input.is_action_just_pressed("Saltar"):
		if (jugador.is_on_floor() or coyoteTime):
			saltar()
		elif jugador.saltoGancho:
			saltar()
			jugador.saltoGancho = false
		else:
			salto_al_tocar_El_Suelo = true
			temporizador_buffer.start(duracionBuffering)
			saltando = false
			
#Aqui se supone que se aplica el salto diferente
	if Input.is_action_just_released("Saltar") and saltando:
		if jugador.velocity.y < salto_min:
			jugador.velocity.y = salto_min
		saltando = false
	
	#Aqui puse la logica para el coyote time
	if enElSuelo and not jugador.is_on_floor() and (jugador.get_real_velocity().y >= 0):
		print("El jugador esta cayendo")
		coyoteTime = true
		tempCoyTi.start(coyoteTimer)
		saltando = false
	
	#Aqui se detiene el contador del buffer y se aplica el salto-buffer
	if not enElSuelo and jugador.is_on_floor() and salto_al_tocar_El_Suelo:
		salto_al_tocar_El_Suelo = false
		temporizador_buffer.stop()
		saltar()
	
	if jugador.is_on_floor():
		current_gravity = gravity
		
	
	enElSuelo = jugador.is_on_floor()

func TemporizadorCoyoteTime_Timeout() -> void:
	coyoteTime = false

func TemporizadorBuffer_Timeout() -> void:
	salto_al_tocar_El_Suelo = false

func saltar() -> void:
	jugador.velocity.y = salto_max
	saltando = true
