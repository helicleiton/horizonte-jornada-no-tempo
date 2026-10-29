extends "res://scripts/levels/fase_teste.gd"
## Fase 4 — "Plantar o futuro" (hoje). Mesma base das outras fases, com um
## cenário verde de praça e escola, onde as mudas são plantadas.


func _ready() -> void:
	GameState.restaurar_cajus()
	super._ready()
	# Chão de praça: um pouco mais verde que o das outras fases.
	for corpo in $Terreno.get_children():
		corpo.modulate = Color(0.85, 1.0, 0.85)


func _colocar_cenario() -> void:
	# Praça com árvores plantadas, cercas e a escola ao fundo.
	for x in [60, 470, 900, 1330]:
		_prop("cajueiro", x, CHAO_Y + 1, -6)
	for x in [260, 640, 1050]:
		_prop("palma", x, CHAO_Y + 1, -5)
	_prop("casa_taipa", 170, CHAO_Y + 1, -8)
	_prop("casa_taipa2", 1140, CHAO_Y + 1, -8, true)
	for x in [340, 780, 1220]:
		_prop("cerca", x, CHAO_Y + 1, -4)
	for x in [120, 420, 690, 960, 1280, 1460]:
		_prop("arbusto", x, CHAO_Y + 1, -3, x % 2 == 0)
	_prop("carnauba", 560, CHAO_Y + 1, -7)
	_prop("pedra", 830, CHAO_Y + 2, -3)


func _iniciar_audio() -> void:
	AudioManager.tocar_musica(HINO if ResourceLoader.exists(HINO) else MUSICA, -9.0)
	AudioManager.tocar_ambiente(AMBIENTE, -15.0)
