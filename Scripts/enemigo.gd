extends CharacterBody2D
class_name EnemigoTierra
@onready var animation_player: AnimationPlayer = $Sprite2D/AnimationPlayer


const  speed = 40
var vida = 100
var vidaMaxima = 100
var vidaMinima = 0
var muerto:bool = false
var tomandoDaño:bool = false
var daño = 35
var dir:Vector2 = Vector2.RIGHT
const gravity = 2000
var Knockback = 200
var sePasea:bool = true

@export var rangoPatrulla = 100
var Origen:float = 0.0

@onready var area_daño: Area2D = $AreaDaño
@onready var sprite_2d: Sprite2D = $Sprite2D

@export var KnockbackRecibido:float = 120
@export var duracionKnockback:float = 0.2
@export var friccionKnockback:float = 600
var KnockbackRestante:float = 0.0

@export var Invulnerabilidad:float = 0.1
var invulnerable:bool = false
var tiempoInvulnerabilidadRestante:float = 0.0

@onready var raycast_borde: RayCast2D = $RaycastBorde
@export var offset_Borde: float = 16.0

@export var TiempoIdleMin: float = 0.2
@export var TiempoIdleMax: float = 0.6
@export var IdleAleatoreo: float = 0.15
var enIdle:bool = false
var idle_restante:float = 0.0
var forzarGiro:bool = false

@export var proteccionPostIdle:float = 0.3
var proteccionRestante: float = 0.0


func _ready() -> void:
	Origen = global_position.x
	area_daño.body_entered.connect(area_daño_body_entered)

func _physics_process(delta: float) -> void:
	if tiempoInvulnerabilidadRestante > 0:
		tiempoInvulnerabilidadRestante -= delta
		invulnerable = tiempoInvulnerabilidadRestante > 0
	
	if KnockbackRestante > 0:
		KnockbackRestante -= delta
	
	if proteccionRestante > 0:
		proteccionRestante -= delta
	
	if not is_on_floor():
		velocity.y += gravity * delta
		if KnockbackRestante <= 0:
			velocity.x = 0
	move(delta)
	move_and_slide()
	if not muerto and not enIdle and proteccionRestante <= 0:
		for i in get_slide_collision_count():
			var colision = get_slide_collision(i)
			if colision.get_collider() is EnemigoTierra:
				entrar_idle(true)
				break
	
func move(delta):
	if muerto:
		velocity.x = 0
		return
	if KnockbackRestante > 0:
		velocity.x = move_toward(velocity.x, 0, friccionKnockback * delta)
		return
	if enIdle:
		idle_restante -= delta
		velocity.x = 0
		if idle_restante <= 0:
			salir_idle()
		return
		
	if global_position.x <= Origen - rangoPatrulla:
		dir = Vector2.RIGHT
	elif global_position.x >= Origen + rangoPatrulla:
		dir = Vector2.LEFT
		
	
	raycast_borde.position.x = offset_Borde * dir.x
	raycast_borde.force_raycast_update()
	var hay_pared = is_on_wall()
	var hay_precipicio = is_on_floor() and not raycast_borde.is_colliding()
	
	if hay_pared or hay_precipicio:
		dir = Vector2.RIGHT if dir.x < 0 else Vector2.LEFT
		
	
	velocity.x = dir.x * speed
	if sprite_2d:
		sprite_2d.flip_h = dir.x < 0
	sePasea = true
	
func entrar_idle(forzar_giro:bool) -> void:
	if enIdle or muerto:
		return
	enIdle = true
	forzarGiro = forzar_giro
	idle_restante = randf_range(TiempoIdleMin, TiempoIdleMax)
	velocity.x = 0
	sePasea = false

func salir_idle() -> void:
	enIdle = false
	proteccionRestante = proteccionPostIdle
	if forzarGiro or randf() < 0.5:
		dir = Vector2.RIGHT if dir.x < 0 else Vector2.LEFT

func _on_direction_timer_timeout():
	$DirectionTimer.wait_time = choose([1.5,2.0,2.5])
	dir = choose([Vector2.RIGHT, Vector2.LEFT])
	if not enIdle and not muerto and randf() < IdleAleatoreo:
		entrar_idle(false)
	
func choose(array):
	array.shuffle()
	return array.front()

func area_daño_body_entered(body: Node2D) -> void:
	if muerto:
		return
	if body.has_method("recibir_ataque"):
		var direccion_Knockback = (body.global_position - global_position).normalized()
		body.recibir_ataque(daño, direccion_Knockback, Knockback)

func RecibirDaño(cantidad: float, direccion_knockback: Vector2 = Vector2.ZERO) -> void:
	if muerto or invulnerable:
		invulnerable = false
		return
	vida = max(vida - cantidad, vidaMinima)
	animation_player.play("HitFlash")
	HitStopManager.hit_stop_short()
	if direccion_knockback != Vector2.ZERO:
		velocity.x = direccion_knockback.x * KnockbackRecibido
		KnockbackRestante = duracionKnockback
	invulnerable = true
	tiempoInvulnerabilidadRestante = Invulnerabilidad
	if vida <= 0:
		morir()
		
func morir() -> void:
	muerto = true
	velocity = Vector2.ZERO
	area_daño.set_deferred("monitoring", false)
	collision_layer = 0
	set_physics_process(false)
