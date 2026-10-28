extends Node2D
## Fase de teste — protótipo da Fase 1: "O Olho d'Água do Venâncio" (c. 1930).

@export var limite_direito := 1500
@export var limite_queda := 260.0
@export var dialogo_abertura := "abertura"
@export_file("*.json") var arquivo_dialogos := "res://data/dialogos_fase1.json"

@onready var _jogador: Player = $Jogador
@onready var _ponto_inicio: Marker2D = $PontoInicio


func _ready() -> void:
	var camera: Camera2D = _jogador.get_node("Camera2D")
	camera.limit_left = 0
	camera.limit_right = limite_direito
	camera.limit_bottom = 200
	GameState.jogador_morreu.connect(_on_jogador_morreu)
	if dialogo_abertura != "":
		DialogueBox.iniciar.call_deferred(arquivo_dialogos, dialogo_abertura, _jogador)


func _physics_process(_delta: float) -> void:
	# Caiu num buraco: perde um caju e volta ao início da fase.
	if _jogador.global_position.y > limite_queda and _jogador.estado != Player.Estado.MORTO:
		GameState.perder_caju()
		if GameState.cajus > 0:
			_jogador.reaparecer(_ponto_inicio.global_position)


func _on_jogador_morreu() -> void:
	await get_tree().create_timer(1.2).timeout
	GameState.restaurar_cajus()
	_jogador.reaparecer(_ponto_inicio.global_position)
