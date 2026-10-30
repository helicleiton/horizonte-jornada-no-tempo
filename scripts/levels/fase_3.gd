extends "res://scripts/levels/fase_teste.gd"
## Fase 3 — "O polo industrial" (anos 1990). Mesma base das outras fases (terreno,
## jogador, NPCs, diálogos), mas com céu de fumaça, silhueta de fábricas, postes
## e chão cinza de pátio.

func _ready() -> void:
	GameState.restaurar_cajus()
	super._ready()
	# Chão de pátio: os tiles de terra ficam mais frios e acinzentados.
	for corpo in $Terreno.get_children():
		corpo.modulate = Color(0.72, 0.7, 0.7)


func _montar_fundo() -> void:
	var fundo: CanvasLayer = $Fundo
	for filho in fundo.get_children():
		filho.queue_free()

	var ceu := ColorRect.new()
	ceu.color = Color("d9a46a")
	ceu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fundo.add_child(ceu)

	var cidade := Parallax2D.new()
	cidade.scroll_scale = Vector2(0.35, 1.0)
	cidade.repeat_size = Vector2(Perfil.LARGURA, 0)
	cidade.repeat_times = 4
	cidade.z_index = -30
	cidade.add_child(Perfil.new())
	add_child(cidade)


func _colocar_cenario() -> void:
	# Pátio da fábrica: cercas, pedras e carnaúbas entre os postes.
	for x in [40, 560, 1100]:
		_prop("cajueiro", x, CHAO_Y + 1, -6)
	for x in [300, 700, 980, 1380]:
		_prop("cerca", x, CHAO_Y + 1, -4)
	for x in [120, 470, 830, 1240]:
		_prop("arbusto", x, CHAO_Y + 1, -3, x % 2 == 0)
	_prop("carnauba", 380, CHAO_Y + 1, -7)
	_prop("carnauba", 1180, CHAO_Y + 1, -7, true)
	_prop("pedra_grande", 740, CHAO_Y + 2, -4)
	_prop("pedra", 1460, CHAO_Y + 2, -3)
	for x in [90, 260, 430, 610, 790, 960, 1130, 1310, 1470]:
		_poste(x)


func _iniciar_audio() -> void:
	AudioManager.tocar_musica(HINO if ResourceLoader.exists(HINO) else MUSICA, -9.0)
	AudioManager.tocar_ambiente(AMBIENTE, -15.0)


## Poste de iluminação com lâmpada amarela, desenhado em código.
func _poste(x: float) -> void:
	var haste := ColorRect.new()
	haste.color = Color("3a3431")
	haste.position = Vector2(x - 1.0, CHAO_Y - 36.0)
	haste.size = Vector2(2.0, 36.0)
	haste.z_index = -4
	add_child(haste)
	var lampada := ColorRect.new()
	lampada.color = Color("f4c95d")
	lampada.position = Vector2(x - 4.0, CHAO_Y - 38.0)
	lampada.size = Vector2(8.0, 3.0)
	lampada.z_index = -4
	add_child(lampada)


## Silhueta de fábricas e prédios ao fundo, com janelas acesas e chaminés.
class Perfil extends Node2D:
	const LARGURA := 320.0
	const SEMENTE := 7
	const BASE_Y := 128.0
	var _tempo := 0.0

	func _process(delta: float) -> void:
		_tempo += delta
		queue_redraw()

	func _draw() -> void:
		var sorteio := RandomNumberGenerator.new()
		sorteio.seed = SEMENTE
		var x := 0.0
		while x < LARGURA:
			# Horizonte é uma cidade baixa: galpões largos e poucos andares.
			var largura := sorteio.randf_range(22.0, 44.0)
			var altura := sorteio.randf_range(16.0, 40.0)
			var topo := BASE_Y - altura
			draw_rect(Rect2(x, topo, largura, altura), Color("6e5f5a"))
			_desenhar_janelas(x, largura, topo, sorteio)
			if sorteio.randf() < 0.4:
				_desenhar_chamine(x + largura * 0.7, topo, sorteio)
			x += largura + 2.0

	func _desenhar_janelas(x: float, largura: float, topo: float, sorteio: RandomNumberGenerator) -> void:
		var linha := topo + 4.0
		while linha < BASE_Y - 6.0:
			var coluna := x + 3.0
			while coluna < x + largura - 4.0:
				var acesa := sorteio.randf() < 0.3
				draw_rect(Rect2(coluna, linha, 3.0, 4.0), Color("f4c95d") if acesa else Color("4a3e3b"))
				coluna += 6.0
			linha += 9.0

	func _desenhar_chamine(x: float, topo: float, sorteio: RandomNumberGenerator) -> void:
		var altura := sorteio.randf_range(8.0, 14.0)
		draw_rect(Rect2(x, topo - altura, 4.0, altura), Color("5a4c48"))
		for i in 3:
			var raio := 2.0 + i * 1.5 + sin(_tempo * 2.0 + x) * 0.4
			var deriva := sin(_tempo + i) * 1.5
			draw_circle(Vector2(x + 2.0 - i * 3.0 + deriva, topo - altura - 3.0 - i * 4.0 - fmod(_tempo * 3.0, 6.0)), raio, Color(0.8, 0.78, 0.76, 0.5))


func _tom_luz() -> Color:
	return Color(0.6, 0.6, 0.62, 0.22)
