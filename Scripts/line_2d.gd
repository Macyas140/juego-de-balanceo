extends Line2D
# Cuerda.gd: va en el nodo Line2D "Cuerda", hijo del nodo raíz de proyectil.tscn

@export var segmentos: int = 14
@export var gravedad: Vector2 = Vector2(0, 700)
@export var iteraciones: int = 10
@export_range(0.8, 1.0) var amortiguacion: float = 0.98
@export var ajustar_a_pixel: bool = true

var proyectil = null   # sin tipo a propósito: leemos origen, agarrado y distanciaEnganche
var _p := PackedVector2Array()
var _prev := PackedVector2Array()
var _iniciada := false

func _ready() -> void:
	# La cuerda se dibuja en coordenadas del mundo, ignorando la rotación del proyectil
	top_level = true
	global_transform = Transform2D.IDENTITY
	segmentos = maxi(segmentos, 3)
	proyectil = get_parent()

func _physics_process(delta: float) -> void:
	if proyectil == null or not is_instance_valid(proyectil.origen):
		return

	var a: Vector2 = proyectil.origen.posicion_mano()   #Zona de origen de la cuerda
	var b: Vector2 = proyectil.global_position          #Zona final de la cuerda
	if not _iniciada:
		_iniciar(a, b)

	# Largo de la cuerda
	var dist := a.distance_to(b)
	var largo := dist
	if proyectil.agarrado:
		largo = maxf(dist, proyectil.distanciaEnganche)
	var reposo := largo / segmentos
	for i in range(1, _p.size() - 1):
		var actual := _p[i]
		var vel := (actual - _prev[i]) * amortiguacion
		_prev[i] = actual
		_p[i] = actual + vel + gravedad * delta * delta
	for _it in iteraciones:
		_p[0] = a
		_p[segmentos] = b
		for i in segmentos:
			var d := _p[i + 1] - _p[i]
			var l := d.length()
			if l < 0.0001:
				continue
			var corr := d * ((l - reposo) / l)
			if i == 0:
				_p[i + 1] -= corr
			elif i + 1 == segmentos:
				_p[i] += corr
			else:
				_p[i] += corr * 0.5
				_p[i + 1] -= corr * 0.5
	_p[0] = a
	_p[segmentos] = b

	_dibujar()

func _iniciar(a: Vector2, b: Vector2) -> void:
	_p.resize(segmentos + 1)
	_prev.resize(segmentos + 1)
	for i in _p.size():
		var pt := a.lerp(b, float(i) / segmentos)
		_p[i] = pt
		_prev[i] = pt
	_iniciada = true

func _dibujar() -> void:
	if ajustar_a_pixel:
		var t := PackedVector2Array()
		t.resize(_p.size())
		for i in _p.size():
			t[i] = _p[i].round()
		points = t
	else:
		points = _p
