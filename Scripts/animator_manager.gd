extends Node

@onready var jugador: CharacterBody2D = $".."
@onready var sprite: AnimatedSprite2D = $"../AnimatedSprite2D"
@onready var gancho: Node2D = $"../LanzarBufanda"
@onready var efecto_abajo: AnimatedSprite2D = $"../Ataque/HitboxAbajo/AnimatedSprite2D"
@onready var efecto_ataque: AnimatedSprite2D = $"../Ataque/Hitbox/AnimatedSprite2D"


@export_group("Nombres de animacion")
@export var anim_idle: StringName = &"Idle"
@export var anim_correr: StringName = &"correr"
@export var anim_salto: StringName = &"salto"
@export var anim_caida: StringName = &"caida"
@export var anim_dano: StringName = &"dano"
@export var anim_lanzar: StringName = &"lanzar"
@export var anim_ataque: StringName = &"ataque"
@export var anim_ataque_abajo: StringName = &"ataque_abajo"
@export var anim_colgado_tranquila: StringName = &"balanceo_tranquila"
@export var anim_colgado_asustada: StringName = &"balanceo_asustada"
@export var anim_colgado_desesperada: StringName = &"balanceo_desesperada"
@export var anim_muerte_colgado: StringName = &"muerte_colgado"
@export var anim_muerte: StringName = &"muerte"

@export_group("efectos")
@export var anim_efecto_ataque: StringName = &"efecto_ataque"
@export var anim_efecto_abajo: StringName = &"efecto_abajo"
@export var velocidad_guardado: float = 1.0

@export_group("Ajustes")
@export var umbral_movimiento: float = 10.0
@export_range(0.0, 1.0) var umbral_asustada: float = 0.6
@export_range(0.0, 1.0) var umbral_desesperada: float = 0.3
@export var dano_interrumpe_colgado: bool = false

@export_group("Alineacion por animacion")
@export var ajustes: Dictionary = {
	"SaltandoAbajo": Vector2(-1, -56),
	"balanceo_tranquila": Vector2(1,-28),
	"balanceo_asustada": Vector2(1,-28),
	"balanceo_desesperada": Vector2(1,-28),
	"correr": Vector2(-15,0),
	"lanzar": Vector2(1,-20),
	"muerte_colgado": Vector2(1,-28),
}

var offset_base: Vector2

var animacion_actual: StringName = &""
var bloqueado: bool = false
var prioridad_bloqueo: int = 0
var avisadas: Dictionary = {}
var efectos_guardando: Dictionary = {}

func _ready() -> void:
	offset_base = sprite.offset
	sprite.animation_changed.connect(_aplicar_ajuste)
	_aplicar_ajuste()
	sprite.animation_finished.connect(_on_animation_finished)
	gancho.bufanda_lanzada.connect(reproducir_lanzar)
	_forzar_sin_loop(anim_dano)
	_forzar_sin_loop(anim_lanzar)
	_forzar_sin_loop(anim_muerte_colgado)
	_forzar_sin_loop(anim_muerte)
	_forzar_sin_loop(anim_ataque)
	_forzar_sin_loop(anim_ataque_abajo)
	_preparar_efecto(efecto_ataque, anim_efecto_ataque)
	_preparar_efecto(efecto_abajo, anim_efecto_abajo)

func _physics_process(_delta: float) -> void:
	_aplicar_ajuste()
	if jugador.muriendo:
		bloqueado = false
		prioridad_bloqueo = 0
		_reproducir(anim_muerte)
		return
	if jugador.muriendoColgado:
		bloqueado = false
		prioridad_bloqueo = 0
		_reproducir(anim_muerte_colgado)
		return
	if bloqueado:
		return
	_reproducir(_determinar_animacion())

func _determinar_animacion() -> StringName:
	if _esta_colgado():
		return _animacion_colgado()
	if not jugador.is_on_floor():
		return anim_salto if jugador.velocity.y < 0.0 else anim_caida
	if absf(jugador.velocity.x) > umbral_movimiento:
		return anim_correr
	return anim_idle

func _esta_colgado() -> bool:
	return gancho.proyectil_actual != null and gancho.proyectil_actual.agarrado

func _animacion_colgado() -> StringName:
	var porcentaje = Estamina.estamina / float(Estamina.estamina_max)
	if porcentaje <= umbral_desesperada:
		return anim_colgado_desesperada
	if porcentaje <= umbral_asustada:
		return anim_colgado_asustada
	return anim_colgado_tranquila

func reproducir_dano() -> void:
	if jugador.muriendo or jugador.muriendoColgado:
		return
	if _esta_colgado() and not dano_interrumpe_colgado:
		return
	reproducir_una_vez(anim_dano, 10)

func reproducir_lanzar() -> void:
	if jugador.muriendo or jugador.muriendoColgado:
		return
	reproducir_una_vez(anim_lanzar, 5)

func reproducir_ataque() -> void:
	if jugador.muriendo or jugador.muriendoColgado:
		return
	reproducir_una_vez(anim_ataque, 5)
	_mostrar_efecto(efecto_ataque, anim_efecto_ataque)


func reproducir_ataque_abajo() -> void:
	if jugador.muriendo or jugador.muriendoColgado:
		return
	reproducir_una_vez(anim_ataque_abajo, 5)
	_mostrar_efecto(efecto_abajo, anim_efecto_abajo)


func reproducir_una_vez(nombre: StringName, prioridad: int = 1) -> void:
	if bloqueado and prioridad < prioridad_bloqueo:
		return
	if not _existe(nombre):
		return
	bloqueado = true
	prioridad_bloqueo = prioridad
	animacion_actual = nombre
	sprite.stop()
	sprite.play(nombre)

func _on_animation_finished() -> void:
	if bloqueado and sprite.animation == animacion_actual:
		bloqueado = false
		prioridad_bloqueo = 0

func _preparar_efecto(efecto: AnimatedSprite2D, nombre: StringName) -> void:
	efecto.visible = false
	efectos_guardando[efecto] = false
	efecto.animation_finished.connect(_on_efecto_terminado.bind(efecto))
	if efecto.sprite_frames and efecto.sprite_frames.has_animation(nombre):
		efecto.sprite_frames.set_animation_loop(nombre, false)

func _mostrar_efecto(efecto: AnimatedSprite2D, nombre: StringName) -> void:
	if not _existe_en(efecto, nombre):
		return
	efectos_guardando[efecto] = false
	efecto.visible = true
	efecto.stop()
	efecto.frame = 0
	efecto.play(nombre)

func _on_efecto_terminado(efecto: AnimatedSprite2D) -> void:
	if efectos_guardando.get(efecto, false):
		efectos_guardando[efecto] = false
		efecto.hide()
	else:
		efectos_guardando[efecto] = true
		efecto.play(efecto.animation, -velocidad_guardado, true)

func _reproducir(nombre: StringName) -> void:
	if nombre == animacion_actual:
		return
	if not _existe(nombre):
		return
	animacion_actual = nombre
	sprite.play(nombre)

func _existe(nombre: StringName) -> bool:
	return _existe_en(sprite, nombre)

func _existe_en(animado: AnimatedSprite2D, nombre: StringName) -> bool:
	if animado.sprite_frames == null or not animado.sprite_frames.has_animation(nombre):
		var clave = str(animado.get_path()) + "/" + str(nombre)
		if not avisadas.has(clave):
			avisadas[clave] = true
			push_warning("AnimatorManager: no existe la animacion '%s' en %s" % [nombre, animado.get_path()])
		return false
	return true

func _forzar_sin_loop(nombre: StringName) -> void:
	if sprite.sprite_frames and sprite.sprite_frames.has_animation(nombre):
		sprite.sprite_frames.set_animation_loop(nombre, false)

func _aplicar_ajuste() -> void:
	var extra: Vector2 = ajustes.get(String(sprite.animation), Vector2.ZERO)
	var lado := -1.0 if sprite.flip_h else 1.0
	sprite.offset = Vector2((offset_base.x + extra.x) * lado, offset_base.y + extra.y)
