extends "res://scripts/levels/fase_teste.gd"
## Fase 5 — "A cidade que se reinventa" (2000 até hoje). Mesma base das outras
## fases, com o pátio da antiga fábrica e a praça da cidade que cresceu.


func _ready() -> void:
	GameState.restaurar_cajus()
	super._ready()


func _colocar_cenario() -> void:
	# Pátio do polo: cercas, postes e árvores novas ao lado dos prédios.
	for x in [50, 600, 1120]:
		_prop("cajueiro", x, CHAO_Y + 1, -6)
	for x in [260, 720, 1000]:
		_prop("cerca", x, CHAO_Y + 1, -4)
	for x in [120, 400, 880, 1260]:
		_prop("arbusto", x, CHAO_Y + 1, -3, x % 2 == 0)
	_prop("casa_taipa2", 1360, CHAO_Y + 1, -8, true)
	_prop("palma", 480, CHAO_Y + 1, -5)
	_prop("pedra_grande", 800, CHAO_Y + 2, -4)


func _iniciar_audio() -> void:
	AudioManager.tocar_musica(HINO if ResourceLoader.exists(HINO) else MUSICA, -9.0)
	AudioManager.tocar_ambiente(AMBIENTE, -15.0)


func _tom_luz() -> Color:
	return Color(0.85, 0.9, 1.0, 0.1)
