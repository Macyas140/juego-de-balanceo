extends Node
@onready var enemigo: EnemigoTierra = $".."
@onready var sprite: AnimatedSprite2D = $"../AnimatedSprite2D"

@export_group("Nombres de animacion")
@export var anim_caminando: StringName = &"Caminando"
@export var anim_muriendo: StringName = &"Muriendo"

var animacion_actual: StringName = &""
var avisadas: Dictionary = {}




func _ready() -> void:
	_forzar_sin_loop(anim_muriendo)
	_reproducir(anim_caminando)

func _physics_process(_delta: float) -> void:
	if enemigo.muerto:
		sprite.speed_scale = 1.0
		_reproducir(anim_muriendo)
		set_physics_process(false)  # ya no hay nada más que decidir
		return
	# En idle el enemigo está quieto: congela la animación de caminar en su frame actual
	sprite.speed_scale = 0.0 if enemigo.enIdle else 1.0
	_reproducir(anim_caminando)


func _reproducir(nombre: StringName) -> void:
	if nombre == animacion_actual:
		return
	if not _existe(nombre):
		return
	animacion_actual = nombre
	sprite.play(nombre)

func _existe(nombre: StringName) -> bool:
	if sprite.sprite_frames == null or not sprite.sprite_frames.has_animation(nombre):
		if not avisadas.has(nombre):
			avisadas[nombre] = true
			push_warning("AnimationManager: no existe la animacion '%s'" % nombre)
		return false
	return true

func _forzar_sin_loop(nombre: StringName) -> void:
	if sprite.sprite_frames and sprite.sprite_frames.has_animation(nombre):
		sprite.sprite_frames.set_animation_loop(nombre, false)
