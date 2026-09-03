extends Area3D

## Debería poder activarse SOLO estando cerca de la puerta.

var jugador_cerca: bool = false


func _ready() -> void:
	body_entered.connect(_al_entrar)


func _al_entrar(_cuerpo: Node3D) -> void:
	jugador_cerca = true


func _al_salir(_cuerpo: Node3D) -> void:
	jugador_cerca = false


func _process(_delta: float) -> void:
	if jugador_cerca and Input.is_action_pressed("accion"):
		print("Puerta activada")
