extends Node2D
## Fase 9 — "Dirigindo pela cidade". O jogador dirige um carro numa rua de Horizonte.
## Acelerar e frear com as setas (ou A e D). Os cones são obstáculos; os agentes do
## Demutran aparecem pela pista e conversam quando o carro passa por eles.

const LIMITE := 1500.0
const VEL_MAX := 150.0
const DIALOGOS := "res://data/dialogos_fase8.json"

var _x := 40.0
var _velocidade := 0.0
var _camera: Camera2D
var _cones := [220.0, 480.0, 640.0, 930.0, 1180.0]
var _atingidos := {}
var _gatilhos := {
	300.0: ["agente_demutran"],
	760.0: ["quiz_transito"],
}
var _disparados := {}
var _destino_marcado := false
var _piscar := 0.0


func _ready() -> void:
	GameState.restaurar_cajus()
	_camera = Camera2D.new()
	_camera.limit_left = 0
	_camera.limit_right = int(LIMITE)
	_camera.limit_top = 0
	_camera.limit_bottom = 200
	add_child(_camera)
	_camera.make_current()
	AudioManager.tocar_musica(MusicaFase.caminho(), -9.0)
	AudioManager.tocar_ambiente("res://assets/audio/ambiente/dia_sertao.ogg", -15.0)
	DialogueBox.iniciar(DIALOGOS, "abertura")


func _physics_process(delta: float) -> void:
	if not DialogueBox.ativo:
		if Input.is_action_pressed("mover_direita"):
			_velocidade = minf(_velocidade + 220.0 * delta, VEL_MAX)
		elif Input.is_action_pressed("mover_esquerda"):
			_velocidade = maxf(_velocidade - 220.0 * delta, -40.0)
		else:
			_velocidade = move_toward(_velocidade, 0.0, 120.0 * delta)
	else:
		_velocidade = move_toward(_velocidade, 0.0, 300.0 * delta)
	_x = clampf(_x + _velocidade * delta, 0.0, LIMITE)
	_camera.position = Vector2(_x + 16.0, 90.0)
	_verificar_eventos()
	_piscar += delta
	queue_redraw()


## Batidas nos cones e gatilhos de conversa ao passar pelos agentes.
func _verificar_eventos() -> void:
	for cone in _cones:
		if not _atingidos.has(cone) and absf(_x - cone) < 10.0:
			_atingidos[cone] = true
			GameState.perder_caju()
			_velocidade = 0.0
	for pos in _gatilhos:
		if not _disparados.has(pos) and _x >= pos:
			_disparados[pos] = true
			var id: String = _gatilhos[pos][0]
			DialogueBox.iniciar(DIALOGOS, id)
	if not _destino_marcado and _x >= LIMITE - 20.0:
		_destino_marcado = true
		GameState.set_flag("chegou_destino")


func _draw() -> void:
	# Céu e casas ao fundo
	draw_rect(Rect2(0, 0, LIMITE, 110), Color("e9b77a"))
	for i in 30:
		var x := i * 52.0
		var altura := 30.0 + float((i * 37) % 40)
		draw_rect(Rect2(x, 110 - altura, 36, altura), Color("7a6258"))
		for j in 3:
			draw_rect(Rect2(x + 8, 110 - altura + 8 + j * 12, 4, 4), Color("f4c95d"))
	# Calçada e rua
	draw_rect(Rect2(0, 110, LIMITE, 14), Color("b9a08a"))
	draw_rect(Rect2(0, 124, LIMITE, 60), Color("4a4442"))
	for i in 60:
		draw_rect(Rect2(i * 26.0, 150, 12, 3), Color("f4c95d"))
	# Cones
	for cone in _cones:
		draw_rect(Rect2(cone - 3, 136, 6, 12), Color("e8702a"))
	# Gatilhos (agentes)
	for pos in _gatilhos:
		draw_rect(Rect2(pos - 4, 100, 8, 24), Color("2b6cb0"))
	# Destino
	draw_rect(Rect2(LIMITE - 20, 110, 6, 40), Color("f4f4f4"))
	# Carro
	var y := 124.0
	draw_rect(Rect2(_x - 16, y - 10, 32, 12), Color("c0392b"))
	draw_rect(Rect2(_x - 9, y - 16, 18, 7), Color("8e2a20"))
	draw_rect(Rect2(_x - 13, y + 1, 8, 6), Color("1a1a1a"))
	draw_rect(Rect2(_x + 5, y + 1, 8, 6), Color("1a1a1a"))
	if _velocidade < -1.0 or _piscar > 0.5:
		draw_rect(Rect2(_x - 17, y - 8, 2, 2), Color("ffe08a"))
