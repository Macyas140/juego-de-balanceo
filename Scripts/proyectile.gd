extends CharacterBody2D
var jugador: Node2D

@export var Velocidad = 2000
@export var DistanciaMaxima = 1000
var dir:Vector2 = Vector2.RIGHT
var spawnPos:Vector2
var spawnRot:float
var distanciaRecorrida:float = 0.0
var regreso:bool = false
var agarrado:bool = false
var distanciaEnganche:float = 0.0
@onready var hit_area: Area2D = $AreadeImpacto
var enganche: Vector2
@export var distanciaMinima:float = 10


func _ready():
	global_position = spawnPos
	global_rotation = spawnRot
	collision_layer = 1
	collision_mask = 1
	hit_area.body_entered.connect(_on_hit_area_body_entered)

	
	
func _physics_process(delta: float) -> void:
	if agarrado:
		global_position = enganche
		#print("Agarrado - posicion actual:" , global_position, "enganche: ", enganche)
		return
	if not regreso:
#Esto es para que la bufanda vaya en linea recta
		velocity = dir * Velocidad
		move_and_slide()
	
#Aqui calculo la Distancia recorrida
		distanciaRecorrida += Velocidad * delta
	
		if distanciaRecorrida >= DistanciaMaxima:
			regreso = true
	else:
		if jugador and is_instance_valid(jugador):
			var direccionRegreso = (jugador.global_position - global_position).normalized()
			velocity = direccionRegreso * Velocidad
			move_and_slide()
			
			if global_position.distance_to(jugador.global_position)<20:
				queue_free()
		else:
			queue_free()
func soltar():
	if agarrado:
		agarrado = false
		regreso = true

func _on_hit_area_body_entered(body: Node2D) -> void:
	if regreso and body == jugador:
		queue_free()
	elif not regreso and not agarrado and body.is_in_group("Agarrable"):
		agarrado = true
		velocity = Vector2.ZERO
		enganche = global_position
		if jugador and is_instance_valid(jugador):
			var distancia = jugador.global_position.distance_to(enganche)
			if distancia < distanciaMinima:
				distancia *= 2
			distanciaEnganche = min(distancia, DistanciaMaxima)
		else:
			distanciaEnganche = DistanciaMaxima
