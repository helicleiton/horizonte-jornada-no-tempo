extends "res://scripts/levels/fase_teste.gd"
## Fase 2 — "A emancipação" (1987). Usa a mesma base da Fase 1 (fundo, terreno,
## jogador, NPCs, diálogos), mas com outro cenário, outra trilha e os cajus
## restaurados ao começar.


func _ready() -> void:
	GameState.restaurar_cajus()
	super._ready()


func _colocar_cenario() -> void:
	# Ruas do distrito: casas de taipa, cercas e árvores da beira da estrada.
	for x in [40, 420, 760, 1120]:
		_prop("cajueiro", x, CHAO_Y + 1, -6)
	for x in [250, 610, 980]:
		_prop("casa_taipa", x, CHAO_Y + 1, -8)
	_prop("casa_taipa2", 1290, CHAO_Y + 1, -8, true)
	for x in [520, 900]:
		_prop("cerca", x, CHAO_Y + 1, -4)
	for x in [120, 330, 700, 1050, 1440]:
		_prop("arbusto", x, CHAO_Y + 1, -3, x % 2 == 0)
	for x in [470, 1230]:
		_prop("mandacaru", x, CHAO_Y + 1, -6)
	_prop("carnauba", 680, CHAO_Y + 1, -7)
	_prop("palma", 1000, CHAO_Y + 1, -5)
	_prop("pedra", 800, CHAO_Y + 2, -3)
	_prop("pedra_grande", 1478, CHAO_Y + 2, -4)


func _iniciar_audio() -> void:
	AudioManager.tocar_musica(HINO if ResourceLoader.exists(HINO) else MUSICA, -9.0)
	AudioManager.tocar_ambiente(AMBIENTE, -15.0)


func _tom_luz() -> Color:
	return Color(1.0, 0.78, 0.5, 0.14)
