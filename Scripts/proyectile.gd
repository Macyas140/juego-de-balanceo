extends CharacterBody2D
var jugador: Node2D
var origen 

@export var Velocidad = 2000
@export var DistanciaMaxima = 1000
@export var distanciaMinima:float = 200
var dir:Vector2 = Vector2.RIGHT
var spawnPos:Vector2
var spawnRot:float
var distanciaRecorrida:float = 0.0
var regreso:bool = false
var agarrado:bool = false
var distanciaEnganche:float = 0.0
@onready var hit_area: Area2D = $AreadeImpacto
var enganche: Vector2

func _ready():
	global_position = spawnPos
	global_rotation = spawnRot
	collision_layer = 1
	collision_mask = 1
	hit_area.body_entered.connect(_on_hit_area_body_entered)

func _physics_process(delta: float) -> void:
	if agarrado:
		global_position = enganche
		return
	
	if not regreso:
		#El proyectil ya no se desliza
		var choque := move_and_collide(dir * Velocidad * delta)
		if choque:
			var otro = choque.get_collider()
			if otro is Node and otro.is_in_group("Agarrable"):
				_enganchar()
			else:
				regreso = true   #Aqui regresa al personaje al chocar con cualquier superficie
			return
		
		distanciaRecorrida += Velocidad * delta
		if distanciaRecorrida >= DistanciaMaxima:
			regreso = true
	else:
		if jugador and is_instance_valid(jugador):
			var destino := _posicion_mano()
			global_position = global_position.move_toward(destino, Velocidad * delta)
			if global_position.distance_to(destino) < 20:
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
		_enganchar()


func _enganchar() -> void:
	agarrado = true
	velocity = Vector2.ZERO
	enganche = global_position
	var distancia := _posicion_mano().distance_to(enganche)
	distanciaEnganche = clampf(distancia, distanciaMinima, DistanciaMaxima)

func _posicion_mano() -> Vector2:
	if origen and is_instance_valid(origen):
		return origen.posicion_mano()
	if jugador and is_instance_valid(jugador):
		return jugador.global_position
	return global_position
