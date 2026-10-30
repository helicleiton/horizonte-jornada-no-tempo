extends "res://scripts/levels/fase_teste.gd"
## Fase 9 — "Os anos recentes (2020–2026)". Mesma base das outras fases, com a praça
## da cidade, a escola e o terminal rodoviário novo.


func _ready() -> void:
	GameState.restaurar_cajus()
	super._ready()


func _colocar_cenario() -> void:
	for x in [60, 500, 960, 1380]:
		_prop("cajueiro", x, CHAO_Y + 1, -6)
	for x in [260, 720, 1140]:
		_prop("cerca", x, CHAO_Y + 1, -4)
	for x in [120, 400, 860, 1240]:
		_prop("arbusto", x, CHAO_Y + 1, -3, x % 2 == 0)
	_prop("casa_taipa", 600, CHAO_Y + 1, -8)
	_prop("palma", 1060, CHAO_Y + 1, -5)


func _iniciar_audio() -> void:
	AudioManager.tocar_musica(HINO if ResourceLoader.exists(HINO) else MUSICA, -9.0)
	AudioManager.tocar_ambiente(AMBIENTE, -15.0)
