extends Node

## MEDIDOR — herramienta de verificación del parcial.
##
## No es parte de lo que se evalúa y NO hay que modificarlo. Observa el juego
## mientras corre e imprime tres medidas en la consola.
##
## Cada medida depende de LOS VALORES QUE TÚ ELEGISTE en tu código, así que
## son distintas para cada quien. Anótalas en MEDIDAS.txt.

const G := 9.8

var jugador: CharacterBody3D = null
var enemigo: CharacterBody3D = null

# Medida 1 — altura máxima de un salto
var _y_suelo := 0.0
var _y_pico := -INF
var _en_salto := false
var _altura_reportada := false

# Medida 2 — cuánto tarda en alcanzar la velocidad máxima
var _t_arranque := 0.0
var _midiendo_arranque := false
var _arranque_reportado := false

# Medida 3 — primera transición de estado del enemigo
var _estado_previo := -1
var _transicion_reportada := false


func _ready() -> void:
	await get_tree().process_frame
	_buscar(get_tree().root)
	print("[MEDIDOR] listo. Las medidas aparecen aquí cuando las provoques.")


func _buscar(n: Node) -> void:
	if n is CharacterBody3D:
		# El jugador es el que tiene "speed"; el enemigo el que tiene "vida".
		if jugador == null and "speed" in n:
			jugador = n
		elif enemigo == null and "vida" in n:
			enemigo = n
	for h in n.get_children():
		_buscar(h)


func _physics_process(delta: float) -> void:
	_medir_salto()
	_medir_arranque(delta)
	_medir_enemigo()


## MEDIDA 1 · altura máxima del salto. Solo aparece si el salto funciona y el
## jugador tiene un piso sobre el que apoyarse.
func _medir_salto() -> void:
	if jugador == null or _altura_reportada:
		return
	if jugador.is_on_floor():
		if _en_salto and _y_pico > _y_suelo + 0.05:
			print("[MEDIDA 1] altura_max_salto = %.2f" % (_y_pico - _y_suelo))
			_altura_reportada = true
		_y_suelo = jugador.global_position.y
		_y_pico = -INF
		_en_salto = false
	else:
		_en_salto = true
		_y_pico = max(_y_pico, jugador.global_position.y)


## MEDIDA 2 · segundos desde que empieza a moverse hasta llegar al 95 % de su
## velocidad máxima. Si la velocidad se sigue asignando de golpe, va a dar
## prácticamente 0 — que también es un dato.
func _medir_arranque(delta: float) -> void:
	if jugador == null or _arranque_reportado:
		return
	var v := Vector2(jugador.velocity.x, jugador.velocity.z).length()
	var tope: float = jugador.speed * 0.95

	if v <= 0.01:
		_midiendo_arranque = false
		_t_arranque = 0.0
		return

	_midiendo_arranque = true
	_t_arranque += delta
	if v >= tope:
		print("[MEDIDA 2] tiempo_hasta_velocidad_max = %.2f s" % _t_arranque)
		_arranque_reportado = true


## MEDIDA 3 · a qué estado pasa el enemigo la PRIMERA vez que cambia, y a qué
## distancia estabas en ese momento.
func _medir_enemigo() -> void:
	if enemigo == null or jugador == null or _transicion_reportada:
		return
	var actual: int = enemigo.estado_actual
	if _estado_previo == -1:
		# El enemigo siempre arranca patrullando; se fija de entrada para no
		# perderse la primera transición si ocurre antes del primer sondeo.
		_estado_previo = 0
	if actual != _estado_previo:
		var d := Vector2(
			enemigo.global_position.x - jugador.global_position.x,
			enemigo.global_position.z - jugador.global_position.z).length()
		print("[MEDIDA 3] primer_cambio = %s a %.2f m" % [enemigo.Estado.keys()[actual], d])
		_transicion_reportada = true
