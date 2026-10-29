extends "res://scripts/levels/fase_teste.gd"
## Fase 2b — "A primeira eleição" (1988). Mesma base das outras fases, com o
## pátio de uma escola e a praça onde a campanha acontece.


func _ready() -> void:
	GameState.restaurar_cajus()
	super._ready()


func _colocar_cenario() -> void:
	# Praça da escola: casas de taipa, cercas e árvores.
	for x in [60, 520, 1000]:
		_prop("cajueiro", x, CHAO_Y + 1, -6)
	_prop("casa_taipa", 250, CHAO_Y + 1, -8)
	_prop("casa_taipa2", 1260, CHAO_Y + 1, -8, true)
	for x in [400, 700, 1120]:
		_prop("cerca", x, CHAO_Y + 1, -4)
	for x in [140, 330, 880, 1400]:
		_prop("arbusto", x, CHAO_Y + 1, -3, x % 2 == 0)
	_prop("palma", 620, CHAO_Y + 1, -5)
	_prop("mandacaru", 1180, CHAO_Y + 1, -6)
	_prop("pedra", 780, CHAO_Y + 2, -3)


func _iniciar_audio() -> void:
	AudioManager.tocar_musica(HINO if ResourceLoader.exists(HINO) else MUSICA, -9.0)
	AudioManager.tocar_ambiente(AMBIENTE, -15.0)
