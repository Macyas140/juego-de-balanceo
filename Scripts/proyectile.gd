extends CharacterBody2D
var jugador: Node2D
var origen 

@export var Velocidad = 2000
@export var DistanciaMaxima = 1000
@export var distanciaMinima:float = 200
@export var cuerda_detras_del_objeto: bool = true
var dir:Vector2 = Vector2.RIGHT
var spawnPos:Vector2
var spawnRot:float
var distanciaRecorrida:float = 0.0
var regreso:bool = false
var agarrado:bool = false
var distanciaEnganche:float = 0.0
@onready var hit_area: Area2D = $AreadeImpacto
var enganche: Vector2
var _z_original: Dictionary = {}
var _ocultos: Array = []

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
		var choque := move_and_collide(dir * Velocidad * delta)
		if choque:
			var otro = choque.get_collider()
			if otro is Node and otro.is_in_group("Agarrable"):
				_enganchar(otro)
			else:
				regreso = true
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
		_restaurar_visual()

func _on_hit_area_body_entered(body: Node2D) -> void:
	if regreso and body == jugador:
		queue_free()
	elif not regreso and not agarrado and body.is_in_group("Agarrable"):
		_enganchar(body)

func _enganchar(objeto: Node) -> void:
	agarrado = true
	velocity = Vector2.ZERO
	enganche = _centro_visual(objeto)
	global_position = enganche
	distanciaEnganche = maxf(_posicion_mano().distance_to(enganche), distanciaMinima)
	_aplicar_visual_enganche(objeto)

func _posicion_mano() -> Vector2:
	if origen and is_instance_valid(origen):
		return origen.posicion_mano()
	if jugador and is_instance_valid(jugador):
		return jugador.global_position
	return global_position

func _aplicar_visual_enganche(objeto: Node) -> void:
	for s in find_children("*", "Sprite2D", true, false) + find_children("*", "AnimatedSprite2D", true, false):
		if s.visible:
			s.visible = false
			_ocultos.append(s)
	if cuerda_detras_del_objeto:
		var cuerda := _buscar_cuerda()
		var ref: Node = _buscar_sprite(objeto)
		if ref == null:
			ref = objeto
		if cuerda and ref is CanvasItem:
			_poner_z(cuerda, _z_efectivo(ref) - 1)

func _restaurar_visual() -> void:
	for item in _z_original:
		if is_instance_valid(item):
			item.z_index = _z_original[item][0]
			item.z_as_relative = _z_original[item][1]
	_z_original.clear()
	for s in _ocultos:
		if is_instance_valid(s):
			s.visible = true
	_ocultos.clear()

func _centro_visual(objeto: Node) -> Vector2:
	var marca := objeto.find_child("CentroGancho", true, false)
	if marca is Node2D:
		return marca.global_position
	var spr := _buscar_sprite(objeto)
	if spr is Sprite2D:
		var s2 := spr as Sprite2D
		return s2.to_global(s2.get_rect().get_center())
	if spr is AnimatedSprite2D:
		var a2 := spr as AnimatedSprite2D
		if a2.sprite_frames:
			var tex := a2.sprite_frames.get_frame_texture(a2.animation, a2.frame)
			if tex:
				var local := a2.offset
				if not a2.centered:
					local += tex.get_size() / 2.0
				return a2.to_global(local)
	if objeto is Node2D:
		return (objeto as Node2D).global_position
	return global_position

func _buscar_sprite(objeto: Node) -> Node:
	var lista := objeto.find_children("*", "Sprite2D", true, false)
	if lista.is_empty():
		lista = objeto.find_children("*", "AnimatedSprite2D", true, false)
	return lista[0] if not lista.is_empty() else null

func _buscar_cuerda() -> Line2D:
	for h in get_children():
		if h is Line2D:
			return h
	return null

func _poner_z(item: CanvasItem, z: int) -> void:
	if not _z_original.has(item):
		_z_original[item] = [item.z_index, item.z_as_relative]
	item.z_as_relative = false
	item.z_index = z

func _z_efectivo(item: CanvasItem) -> int:
	var z := item.z_index
	var nodo: CanvasItem = item
	while nodo.z_as_relative:
		var padre := nodo.get_parent()
		if padre is CanvasItem:
			nodo = padre
			z += nodo.z_index
		else:
			break
	return z
