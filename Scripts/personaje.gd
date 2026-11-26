extends CharacterBody2D
@onready var salto: Node2D = $Salto
@onready var flash_animation: AnimationPlayer = $AnimatedSprite2D/FlashAnimation


#Esto es el movimiento basico del personaje
@export var SPEED = 350.0 #300 es el original
var walk = 100
var ultima_direccion: int = 1
@export var friccion = 2000
@export var friccionCaminata:int = 20
@export var friccion_aire = 55
@export var friccionMuerte = 135
@export var friccionAireMuerte = 100

#Esto es para que despues de soltarte, puedas saltar
var saltoGancho:bool = false
#@onready var sprite = $Sprite2D
@onready var animatedSprite = $AnimatedSprite2D
@onready var animador:Node = $AnimatorManager
@onready var gancho: Node2D = $LanzarBufanda
var muriendo:bool = false
var muriendoColgado:bool = false

#Esto es para que, cuando el personaje se muera, se desplome sobre el suelo
@export var velocidadGiro:float = 0.02
@export var velocidadAcomodo:float = 2.0

#Esto es para el daño recibido del enemigo
var golpeado_de_espalda:bool = true
@export var duracionKnockback:float = 0.25
@export var friccionKnockback:float = 300.0
var knockbackRestante:float = 0.0
@export var Invulnerabilidad:float = 1.0
var invulnerable:bool = false
var tiempoInvulnerabilidadRestante:float = 0.0
@export var Knockback_Aerero:float = 400

#Esto es para el ataque del personaje
@onready var hitbox_ataque:Area2D = $Ataque/Hitbox
@onready var hitbox_ataque_forma:CollisionShape2D = $Ataque/Hitbox/CollisionShape2D
@export var duracion_Hitbox_Ataque:float = 0.15
@export var Cooldown_Ataque:float = 0.4
var atacando:bool = false
var cooldownAtaque_restante:float = 0.0
var gastoAtaque

#Esto es para el ataque hacia abajo del personaje
@onready var hitboxAbajo:Area2D = $Ataque/HitboxAbajo
@onready var hitboxAbajo_forma:CollisionShape2D = $Ataque/HitboxAbajo/CollisionShape2D
@export var duracion_HitboxAbajo_ataque:float = 0.15
@export var cooldown_AtaqueAbajo:float = 0.3
@export var fuerzaRebote:float = -500.0
var enPicada:bool = false
var cooldownPicada_restante:float = 0.0

#Esto es para las particulas de polvo al caminar y saltar
@onready var dustParticles: GPUParticles2D = $GPUParticles2D
@onready var salto_caida: GPUParticles2D = $SaltoCaida


#Esto es para el respawn
signal reaparecio
var posicion_inicial: Vector2
var _reapareciendo:bool = false

var estabaAire: bool = false
@export var knockback_vertical:float = -450.0

#Esto es para la cinematica final
var cinematica: bool = false
var cine_direccion: float = 0.0
var cine_velocidad: float = 100.0
var cine_levitando: bool = false
var cine_vy: float = 0.0

func _ready() -> void:
	posicion_inicial = global_position
	if Checkpoint.tiene_checkpoint:
		global_position = Checkpoint.posicion_respawn
	Estamina.reiniciar()
	Estamina.seguir_a(self)
	Estamina.muerto.connect(_on_estamina_muerto)
	Estamina.listoReinicio.connect(listoReinicio)
	hitboxAbajo.golpeo.connect(_on_picada_golpeo)
	TransitionScreen.revelar()
	

signal aterrizo(velocidad_caida:float)
func _physics_process(delta: float) -> void:
	var is_moving = abs(velocity.x) > 10
	var on_ground = is_on_floor()
	dustParticles.emitting = is_moving and on_ground
	
	if is_moving and on_ground:
		AudioController.play_caminar()
	
	if tiempoInvulnerabilidadRestante > 0:
		tiempoInvulnerabilidadRestante -= delta
		invulnerable = tiempoInvulnerabilidadRestante > 0
	
	if knockbackRestante > 0:
		knockbackRestante -= delta
	
	if cooldownAtaque_restante > 0:
		cooldownAtaque_restante -= delta
	
	if cooldownPicada_restante > 0:
		cooldownPicada_restante -= delta
	
	if not muriendo and not muriendoColgado:
		if not cinematica and Input.is_action_just_pressed("Ataque") and not atacando and not enPicada:
			if Input.is_action_pressed("AtaqueAbajo") and not is_on_floor() and cooldownPicada_restante <= 0:
				ataqueAbajo()
			elif cooldownAtaque_restante <= 0:
				ataque()
		
#Aqui voy a hacer que el personaje mire para otros lados dependiendo del input del jugador
		var direction: float = cine_direccion if cinematica else Input.get_axis("Izquierda", "Derecha")
		#var direction := Input.get_axis("Izquierda", "Derecha")
		if direction != 0:
			ultima_direccion = direction
			animatedSprite.flip_h = direction < 0
			
		var colgado = gancho.proyectil_actual != null and gancho.proyectil_actual.agarrado
		var colgando_en_aire = colgado and not is_on_floor()
		Estamina.actualizar_Estado(colgando_en_aire, is_on_floor(), delta, colgado, ultima_direccion)
		
		if knockbackRestante > 0:
			velocity.x = move_toward(velocity.x, 0, friccionKnockback * delta)
		elif not colgado:
			if direction:
				if cinematica:
					velocity.x = direction * cine_velocidad
				elif Input.is_action_pressed("Caminar"):
					velocity.x = direction * walk
				else:
					velocity.x = direction * SPEED
			else:
				velocity.x = move_toward(velocity.x / friccionCaminata, 0, friccion * delta)
		else:
			if direction:
				velocity.x += direction * SPEED * delta
			else: 
				velocity.x = move_toward(velocity.x, 0, friccion_aire * delta)
			if Input.is_action_pressed("Impulso"):
				velocity.x = move_toward(velocity.x, 0, friccion_aire * delta)
	elif muriendoColgado:
		velocity.x = move_toward(velocity.x, 0, friccionAireMuerte * delta)
	else:
		var colgado = gancho.proyectil_actual != null and gancho.proyectil_actual.agarrado
		if colgado:
			velocity.x = move_toward(velocity.x, 0, friccionMuerte * delta)
		else:
			if is_on_floor():
				velocity.x = move_toward(velocity.x, 0, friccion * delta)
			#acomodar_caidaMuerte(delta)
			
	if cinematica and cine_levitando:
		velocity.y = cine_vy
	
	var velocidadEnYAntes = velocity.y
	
	move_and_slide()
	var enElAireAhora = not is_on_floor()
	
	if not estabaAire and enElAireAhora and not muriendo and not muriendoColgado:
		_emitir_polvo_mundo(salto_caida)
	
	if estabaAire and not enElAireAhora and not muriendo and not muriendoColgado:
		aterrizo.emit(velocidadEnYAntes)
		_emitir_polvo_mundo(salto_caida)
	estabaAire = enElAireAhora
	
func ataque() -> void:
	print("ataque")
	atacando = true
	AudioController.play_Attack()
	cooldownAtaque_restante = Cooldown_Ataque
	hitbox_ataque.scale.x = ultima_direccion
	hitbox_ataque_forma.disabled = false
	animador.reproducir_ataque()
	Estamina.gasto_Ataque()
	
	await  get_tree().create_timer(duracion_Hitbox_Ataque).timeout
	
	hitbox_ataque_forma.disabled = true
	atacando = false

func ataqueAbajo() -> void:
	print("Ataque detectado")
	Estamina.gasto_Ataque()
	enPicada = true
	AudioController.play_Attack()
	cooldownPicada_restante = cooldown_AtaqueAbajo
	hitboxAbajo.scale.x = ultima_direccion
	hitboxAbajo_forma.disabled = false
	animador.reproducir_ataque_abajo()
	
	
	
	await get_tree().create_timer(duracion_HitboxAbajo_ataque).timeout
	
	hitboxAbajo_forma.disabled = true
	enPicada = false

func _on_picada_golpeo(_hurtbox: Hurtbox) -> void:
	print("aplicando Salto")
	velocity.y = fuerzaRebote
	#saltoGancho = true

func recibir_daño(cantidad:float) -> void:
	Estamina.recibir_daño(cantidad)
	flash_animation.play("Flash2")
	animador.reproducir_dano()
	HitStopManager.hit_stop_short()
	AudioController.play_Recieve_Attack()
	

signal murioColgado(colgado: bool)
func _on_estamina_muerto() -> void:
	var colgado_Muerto = gancho.proyectil_actual != null and gancho.proyectil_actual.agarrado
	if colgado_Muerto:
		muriendoColgado = true
		
	else:
		muriendo = true
		
	gancho.muriendo = true
	salto.muriendo = true
	if knockbackRestante <= 0:
		golpeado_de_espalda = sign(velocity.x) != 0 and sign(velocity.x) == ultima_direccion
	murioColgado.emit(colgado_Muerto)

func listoReinicio() -> void:
	if _reapareciendo:
		return
	_reapareciendo = true
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	reaparecer()                                    
	_reapareciendo = false
	#get_tree().call_deferred("reload_current_scene")

func acomodar_caidaMuerte(delta:float) -> void:
	if not is_on_floor():
		animatedSprite.rotation += velocity.x * velocidadGiro * delta
	else:
		var angulo_objetivo = PI/2 if velocity.x > 0 else -PI/2
		animatedSprite.rotation = lerp_angle(animatedSprite.rotation, angulo_objetivo, delta * velocidadAcomodo)
		animatedSprite.flip_h = golpeado_de_espalda

func recibir_ataque(cantidad:float, direccion_knockback:Vector2, fuerza:float) -> void:
	if muriendo or muriendoColgado or cinematica:
		return
	recibir_daño(cantidad)
	golpeado_de_espalda = sign(direccion_knockback.x) == ultima_direccion
	salto.saltando = false
	velocity.x = direccion_knockback.x * fuerza
	velocity.y = knockback_vertical
	knockbackRestante = duracionKnockback
	invulnerable = true
	tiempoInvulnerabilidadRestante = Invulnerabilidad

func _emitir_polvo_mundo(plantilla: GPUParticles2D) -> void:
	var copia = plantilla.duplicate()
	get_tree().current_scene.add_child(copia)
	copia.global_position = plantilla.global_position
	copia.emitting = true
	
	await get_tree().create_timer(copia.lifetime + 0.2).timeout
	copia.queue_free()

func reaparecer() -> void:
	muriendo = false
	muriendoColgado = false
	golpeado_de_espalda = true
	velocity = Vector2.ZERO
	knockbackRestante = 0.0
	invulnerable = false
	tiempoInvulnerabilidadRestante = 0.0
	atacando = false
	enPicada = false
	cooldownAtaque_restante = 0.0
	cooldownPicada_restante = 0.0
	hitbox_ataque_forma.set_deferred("disabled", true)
	hitboxAbajo_forma.set_deferred("disabled", true)
	gancho.reiniciar()
	salto.muriendo = false
	saltoGancho = false
	animatedSprite.rotation = 0.0
	if Checkpoint.tiene_checkpoint:
		global_position = Checkpoint.posicion_respawn
	else:
		global_position = posicion_inicial
	reset_physics_interpolation()
	Estamina.reiniciar()
	get_tree().call_group("enemigos", "reiniciar")
	reaparecio.emit()

#esta es la parte de la cinematica, la neta no la entiendo del todo
func iniciar_cinematica() -> void:
	cinematica = true
	cine_direccion = 0.0
	knockbackRestante = 0.0
	atacando = false
	enPicada = false
	hitbox_ataque_forma.set_deferred("disabled", true)
	hitboxAbajo_forma.set_deferred("disabled", true)
	gancho.reiniciar()        # suelta la bufanda si estabas colgada (esto deja gancho.muriendo en false)
	gancho.muriendo = true    # por eso se bloquea DESPUÉS: sin input de bufanda ni impulso
	salto.muriendo = true     # sin input de salto (la gravedad sigue activa)
	saltoGancho = false
	Estamina.reiniciar()      # barra llena y oculta

# direccion: 1 derecha, -1 izquierda, 0 quieto. Con velocidad 0 solo se voltea sin moverse.
func cine_mover(direccion: float, velocidad: float = 100.0) -> void:
	cine_direccion = direccion
	cine_velocidad = velocidad

func cine_saltar() -> void:
	if is_on_floor():
		salto.saltar()

func cine_levitar(vy: float) -> void:
	cine_levitando = true
	cine_vy = vy
	AudioController.play_end_level()

func cine_soltar_levitacion() -> void:
	cine_levitando = false
