class_name Hitbox
extends Area2D

@export var dañoAtaque = 20
@export var mascara_obstaculos:int = 16
signal golpeo(hurtbox)

func _init() -> void:
	collision_layer = 4
	collision_mask = 2
func _ready() -> void:
	area_entered.connect(_on_area_entered)
	print("Hitbox listo: ", name, " | layer: ", collision_layer, " | mask: ", collision_mask)
	
func _on_area_entered(area:Area2D) -> void:
	print("Area detectada por hitbox: ", area.name, " | es Hurtbox? ", area is Hurtbox)
	if area is Hurtbox and hay_linea_de_vision(area):
		golpeo.emit(area)

func hay_linea_de_vision(objetivo:Area2D) -> bool:
	var espacio = get_world_2d().direct_space_state
	var excluidos: Array[RID] = []
	if objetivo.owner:
		excluidos.append(objetivo.owner.get_rid())

	var intentos = 0
	while intentos < 8:
		var consulta = PhysicsRayQueryParameters2D.create(global_position, objetivo.global_position)
		consulta.collision_mask = mascara_obstaculos
		consulta.exclude = excluidos
		var resultado = espacio.intersect_ray(consulta)
		print("Intento ", intentos, " -> resultado: ", resultado)

		if resultado.is_empty():
			print("Sin obstáculos, línea de visión libre")
			return true

		var collider = resultado["collider"]
		if collider is CharacterBody2D:
			print("Ignorando personaje: ", collider.name)
			excluidos.append(resultado["rid"])
			intentos += 1
			continue
		else:
			print("Bloqueado por: ", collider.name)
			return false

	return false
