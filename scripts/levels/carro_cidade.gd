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
## Duas faixas: 0 = de cima, 1 = de baixo. Cada cone fica em uma faixa.
const FAIXAS_Y := [138.0, 166.0]
var _faixa := 0
var _y_carro := FAIXAS_Y[0]
var _cones := [[220.0, 0], [480.0, 1], [640.0, 0], [930.0, 1], [1180.0, 0]]
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
	# Troca de faixa com a tecla de pular (Espaço, W ou seta para cima).
	if not DialogueBox.ativo and Input.is_action_just_pressed("pular"):
		_faixa = 1 - _faixa
	_y_carro = lerpf(_y_carro, FAIXAS_Y[_faixa], minf(1.0, delta * 12.0))
	_camera.position = Vector2(_x + 16.0, 90.0)
	_verificar_eventos()
	_piscar += delta
	queue_redraw()


## Batidas nos cones e gatilhos de conversa ao passar pelos agentes.
func _verificar_eventos() -> void:
	for cone in _cones:
		var pos: float = cone[0]
		var faixa: int = cone[1]
		if not _atingidos.has(pos) and faixa == _faixa and absf(_x - pos) < 10.0:
			_atingidos[pos] = true
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
	_desenhar_ceu_e_predios()
	_desenhar_rua()
	for cone in _cones:
		_desenhar_cone(cone[0], FAIXAS_Y[cone[1]])
	for pos in _gatilhos:
		_desenhar_agente(pos)
	_desenhar_destino()
	_desenhar_carro(_x, _y_carro)


func _desenhar_ceu_e_predios() -> void:
	draw_rect(Rect2(0, 0, LIMITE, 60), Color("f3c98b"))
	draw_rect(Rect2(0, 60, LIMITE, 50), Color("eab67a"))
	var cores := [Color("8a6f63"), Color("a08072"), Color("6f5a52"), Color("b58f7c")]
	for i in 30:
		var x := i * 52.0
		var largura := 38.0 + float((i * 13) % 12)
		var altura := 40.0 + float((i * 37) % 45)
		var cor: Color = cores[i % cores.size()]
		draw_rect(Rect2(x, 110 - altura, largura, altura), cor)
		draw_rect(Rect2(x, 110 - altura, largura, 3), cor.darkened(0.25))
		# janelas com caixilho, algumas acesas
		var linha := 110.0 - altura + 8.0
		while linha < 100.0:
			var coluna := x + 5.0
			while coluna < x + largura - 9.0:
				var acesa := (int(coluna) + int(linha)) % 3 == 0
				draw_rect(Rect2(coluna, linha, 6, 7), Color("3d3430"))
				draw_rect(Rect2(coluna + 1, linha + 1, 4, 5), Color("f4c95d") if acesa else Color("6e8fa3"))
				coluna += 10.0
			linha += 12.0
		# porta no térreo
		draw_rect(Rect2(x + largura * 0.5 - 4, 92, 8, 18), Color("4a3328"))


func _desenhar_rua() -> void:
	# calçada com pedras
	draw_rect(Rect2(0, 110, LIMITE, 14), Color("cdbba6"))
	for i in 60:
		draw_rect(Rect2(i * 26.0, 116, 24, 1), Color("b5a18b"))
	# meio-fio
	draw_rect(Rect2(0, 124, LIMITE, 3), Color("9a9a9a"))
	# asfalto com textura
	draw_rect(Rect2(0, 127, LIMITE, 55), Color("4a4644"))
	for i in 120:
		draw_rect(Rect2(i * 13.0 + float((i * 7) % 5), 140 + float((i * 3) % 30), 2, 1), Color("56504d"))
	# faixas centrais
	for i in 60:
		draw_rect(Rect2(i * 26.0, 150, 12, 3), Color("f4e7b0"))


func _desenhar_cone(x: float, base: float) -> void:
	draw_rect(Rect2(x - 4, base, 8, 2), Color("1a1a1a"))
	draw_colored_polygon(PackedVector2Array([Vector2(x - 3, base), Vector2(x + 3, base), Vector2(x + 1, base - 11), Vector2(x - 1, base - 11)]), Color("e8702a"))
	draw_rect(Rect2(x - 2, base - 7, 4, 2), Color("f5f5f0"))


func _desenhar_agente(x: float) -> void:
	# agente de trânsito de colete laranja, em pé na calçada
	var base := 124.0
	draw_rect(Rect2(x - 2, base - 3, 2, 3), Color("2b2b2b"))
	draw_rect(Rect2(x + 1, base - 3, 2, 3), Color("2b2b2b"))
	draw_rect(Rect2(x - 3, base - 12, 6, 9), Color("e8702a"))
	draw_rect(Rect2(x - 3, base - 9, 6, 2), Color("f5f5f0"))
	draw_rect(Rect2(x - 2.5, base - 17, 5, 5), Color("e0a96d"))
	draw_rect(Rect2(x - 4, base - 19, 8, 2), Color("1f3a5f"))


func _desenhar_destino() -> void:
	var x := LIMITE - 20.0
	draw_rect(Rect2(x, 102, 2, 26), Color("3b3b3b"))
	draw_rect(Rect2(x + 2, 102, 16, 8), Color("f5f5f0"))
	for i in 4:
		for j in 2:
			if (i + j) % 2 == 0:
				draw_rect(Rect2(x + 2 + i * 4, 102 + j * 4, 4, 4), Color("1a1a1a"))


func _desenhar_carro(x: float, y: float) -> void:
	# sombra no asfalto
	draw_rect(Rect2(x - 17, y + 6, 34, 3), Color(0, 0, 0, 0.35))
	# carroceria
	draw_rect(Rect2(x - 16, y - 9, 32, 11), Color("b8322a"))
	draw_rect(Rect2(x - 16, y - 9, 32, 2), Color("d9554b"))
	# cabine e vidros
	draw_rect(Rect2(x - 9, y - 16, 18, 8), Color("8e2a20"))
	draw_rect(Rect2(x - 7, y - 14, 6, 5), Color("9fd3ea"))
	draw_rect(Rect2(x + 1, y - 14, 6, 5), Color("9fd3ea"))
	# faróis e lanternas
	draw_rect(Rect2(x + 14, y - 6, 2, 3), Color("fff2a8"))
	draw_rect(Rect2(x - 16, y - 6, 2, 3), Color("d62a2a"))
	# rodas
	draw_circle(Vector2(x - 9, y + 3), 4, Color("1a1a1a"))
	draw_circle(Vector2(x + 9, y + 3), 4, Color("1a1a1a"))
	draw_circle(Vector2(x - 9, y + 3), 1.5, Color("9a9a9a"))
	draw_circle(Vector2(x + 9, y + 3), 1.5, Color("9a9a9a"))
	# piscas quando freia ou ao sair de uma batida
	if _velocidade < -1.0:
		draw_rect(Rect2(x - 16, y - 9, 2, 3), Color("ff3b3b"))
