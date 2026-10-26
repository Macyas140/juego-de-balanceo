extends HBoxContainer

@export var frames_moneda: SpriteFrames
@export var anim_moneda: StringName = &"idle"
@export var duracion_vuelo: float = 0.6
@export var color_vacio: Color = Color(0.15, 0.15, 0.15, 0.7)
@export var color_lleno: Color = Color.WHITE

var slots = []
var sprites_slot = []
var monedas_recogidas: int = 0

func _ready() -> void:
	add_to_group("hud_monedas")
	if frames_moneda == null or not frames_moneda.has_animation(anim_moneda):
		push_warning("HudMonedas: asigna Frames Moneda y revisa el nombre de la animacion")
		return
	for hijo in get_children():
		var slot := hijo as Control
		if slot == null:
			continue
		var spr := AnimatedSprite2D.new()
		spr.sprite_frames = frames_moneda
		spr.animation = anim_moneda
		spr.frame = 0
		spr.modulate = color_vacio   # vacia: oscura y quieta en el cuadro 0
		spr.play(anim_moneda)
		slot.add_child(spr)
		slot.resized.connect(_ajustar_sprite.bind(slot, spr))
		_ajustar_sprite(slot, spr)
		slots.append(slot)
		sprites_slot.append(spr)

func _ajustar_sprite(slot: Control, spr: AnimatedSprite2D) -> void:
	spr.position = slot.size / 2.0
	spr.scale = Vector2.ONE * _escala_para(slot.size)

func _escala_para(tam: Vector2) -> float:
	var tex := frames_moneda.get_frame_texture(anim_moneda, 0)
	if tex == null:
		return 1.0
	var t := tex.get_size()
	return minf(tam.x / t.x, tam.y / t.y)

func recibir_moneda(pos_pantalla: Vector2, frames: SpriteFrames, animacion: StringName, frame: int, escala_inicial: Vector2) -> void:
	if monedas_recogidas >= slots.size():
		return
	var indice := monedas_recogidas
	monedas_recogidas += 1
	var slot: Control = slots[indice]
	var spr_slot: AnimatedSprite2D = sprites_slot[indice]

	var volador := AnimatedSprite2D.new()
	volador.sprite_frames = frames
	volador.animation = animacion
	volador.frame = frame
	volador.position = pos_pantalla
	volador.scale = escala_inicial
	get_parent().add_child(volador)
	volador.play(animacion)

	var destino := slot.global_position + slot.size / 2.0
	var escala_final := Vector2.ONE * _escala_para(slot.size)

	var tween := create_tween().set_parallel(true)
	tween.tween_property(volador, "position", destino, duracion_vuelo)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(volador, "scale", escala_final, duracion_vuelo)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(func():
		spr_slot.frame = volador.frame   # el espacio retoma exactamente el cuadro de la voladora
		spr_slot.modulate = color_lleno
		spr_slot.play(animacion)
		volador.queue_free()
	)
