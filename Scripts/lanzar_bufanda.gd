extends Node2D
@onready var jugador: CharacterBody2D = $".."

var proyectile: PackedScene = preload("res://Scenes/proyectile.tscn")
var seDisparo:bool = false
var proyectil_actual: Node2D = null
var muriendo:bool = false
@export var fuerzaDelImpulso:float = 500.0

@export var offset_mano:Vector2 = Vector2(0, -40)

signal bufanda_lanzada

func posicion_mano() -> Vector2:
	return jugador.global_position + offset_mano

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


#func _draw() -> void:
#	draw_circle(to_local(posicion_mano()), 3.0, Color.YELLOW)

func Lanzar_Bufanda():
	if proyectile and not seDisparo:
		var instancia = proyectile.instantiate()
		var origen_disparo = posicion_mano()
		var canvas_transform = get_viewport().get_canvas_transform()
		var manoEnPantalla = canvas_transform * origen_disparo
		var mouse_pantalla = get_viewport().get_mouse_position()
		var direccion = (mouse_pantalla - manoEnPantalla).normalized()
		
		instancia.spawnPos = origen_disparo
		instancia.dir = direccion
		instancia.spawnRot = direccion.angle() + PI/2
		instancia.jugador = jugador
		instancia.origen = self # NUEVO: el proyectil le pregunta a este nodo dónde está la mano
		jugador.get_parent().add_child(instancia) # CAMBIO: va al nivel, no dentro del Personaje
		instancia.add_collision_exception_with(jugador)
		seDisparo = true
		proyectil_actual = instancia
		instancia.tree_exiting.connect(ProyectilDestruido)
		
		Estamina.gastar_por_disparo()
		bufanda_lanzada.emit()
		
func ProyectilDestruido() -> void:
	seDisparo = false
	proyectil_actual = null

func balanceo_Gancho():
	var ancla = proyectil_actual.global_position
	var largo = proyectil_actual.distanciaEnganche
	var offset = posicion_mano() - ancla   # CAMBIO: se mide desde la mano
	var distanciaActual = offset.length()
	
	if distanciaActual > largo:
		var direccionRadial = offset / distanciaActual
		var componenteRadial = jugador.velocity.dot(direccionRadial)
		if componenteRadial > 0:
			jugador.velocity -= direccionRadial * componenteRadial
		# CAMBIO: se mueve a la jugadora solo lo que se pasó de la cuerda
		jugador.global_position -= direccionRadial * (distanciaActual - largo)

func Impulso_gacho():
	var direccion_impulso = proyectil_actual.dir
	proyectil_actual.soltar()
	jugador.saltoGancho = true
	jugador.velocity = direccion_impulso * fuerzaDelImpulso * 1.2
	Estamina.gasto_impulso()
