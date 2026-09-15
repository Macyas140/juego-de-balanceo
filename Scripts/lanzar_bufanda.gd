extends Node2D
@onready var jugador: CharacterBody2D = $".."

var proyectile: PackedScene = preload("res://Scenes/proyectile.tscn")
var seDisparo:bool = false
var proyectil_actual: Node2D = null
var muriendo:bool = false
@export var fuerzaDelImpulso:float = 500.0

func _ready() -> void:
	jugador.get_parent()
	
func _physics_process(delta: float) -> void:
	if not muriendo and Input.is_action_just_pressed("LanzarBufanda"):
		if proyectil_actual == null:
			Lanzar_Bufanda()
		elif proyectil_actual.agarrado:
			proyectil_actual.soltar()
			jugador.saltoGancho = true
			
	if not muriendo and Input.is_action_just_pressed("SoltarBufanda"):
		if proyectil_actual and proyectil_actual.agarrado:
			proyectil_actual.soltar()
			jugador.saltoGancho = true
			
	if not muriendo and Input.is_action_just_pressed("Impulso"):
		if proyectil_actual and proyectil_actual.agarrado:
			Impulso_gacho()
			
	if proyectil_actual and proyectil_actual.agarrado:
		balanceo_Gancho()

func Lanzar_Bufanda():
	if proyectile and not seDisparo:
		var instancia = proyectile.instantiate()
		var canvas_transform = get_viewport().get_canvas_transform()
		var jugadorEnPantalla = canvas_transform * jugador.global_position
		var mouse_pantalla = get_viewport().get_mouse_position()
		var direccion = (mouse_pantalla - jugadorEnPantalla).normalized()
		
		instancia.spawnPos = global_position
		instancia.dir = direccion
		instancia.spawnRot = direccion.angle() + PI/2
		instancia.jugador = jugador
		get_parent().add_child(instancia)
		instancia.add_collision_exception_with(jugador)
		seDisparo = true
		proyectil_actual = instancia
		instancia.tree_exiting.connect(ProyectilDestruido)
		
		Estamina.gastar_por_disparo()
		
func ProyectilDestruido() -> void:
	seDisparo = false
	proyectil_actual = null

func balanceo_Gancho():
	var ancla = proyectil_actual.global_position
	var distanciaAlejamiento = proyectil_actual.distanciaEnganche
	var offset = jugador.global_position - ancla
	var distanciaActual = offset.length()
	
	if distanciaActual > distanciaAlejamiento:
		var direccionRadial = offset.normalized()
		var componenteRadial = jugador.velocity.dot(direccionRadial)
		if componenteRadial > 0:
			jugador.velocity -= direccionRadial * componenteRadial
		jugador.global_position = ancla + (direccionRadial * distanciaAlejamiento)

func Impulso_gacho():
	var direccion_impulso = proyectil_actual.dir
	proyectil_actual.soltar()
	jugador.saltoGancho = true
	jugador.velocity = direccion_impulso * fuerzaDelImpulso * 1.2
	Estamina.gasto_impulso()
