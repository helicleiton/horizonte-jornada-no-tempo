class_name Chico3D
extends Node3D
## Chico em 3D, montado a partir de assets/3d/chico.glb. Os braços e as pernas são girados
## pelos pivôs do modelo, com ângulos calculados em código para cada estado.

const MODELO := "res://assets/3d/chico.glb"

var _pivos := {}


func _ready() -> void:
	var modelo: Node3D = load(MODELO).instantiate()
	add_child(modelo)
	for nome in ["PivoBracoE", "PivoBracoD", "PivoPernaE", "PivoPernaD"]:
		_pivos[nome] = modelo.find_child(nome, true, false)


## Posiciona os membros para o estado (parado, andar, pular, cair ou dano). `t` é o tempo em segundos.
func animar(estado: String, t: float) -> void:
	var braco := 0.0
	var perna := 0.0
	match estado:
		"andar":
			var balanco := sin(t * TAU * 1.6)
			perna = 35.0 * balanco
			braco = 30.0 * balanco
		"pular":
			braco = 150.0
			perna = -20.0
		"cair":
			braco = 70.0
			perna = 5.0
		"dano":
			braco = 25.0
	_definir("PivoBracoE", braco)
	_definir("PivoBracoD", -braco)
	_definir("PivoPernaE", perna)
	_definir("PivoPernaD", -perna)


func _definir(nome: String, graus: float) -> void:
	var pivo: Node3D = _pivos.get(nome)
	if pivo:
		pivo.rotation_degrees.z = graus
