extends Node
var tiene_checkpoint: bool = false
var posicion_respawn: Vector2

func guardar(pos: Vector2) -> void:
	tiene_checkpoint = true
	posicion_respawn = pos

func es_checkpoint_actual(pos: Vector2) -> bool:
	return tiene_checkpoint and posicion_respawn.distance_to(pos) < 1.0

func borrar() -> void:
	tiene_checkpoint = false
