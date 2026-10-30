extends "res://scripts/levels/fase_teste.gd"
## Fase 10 — "Quem faz a cidade". Mesma base das outras fases, com a praça da
## Câmara e as lideranças que lutaram pela emancipação.


func _ready() -> void:
	GameState.restaurar_cajus()
	super._ready()


func _colocar_cenario() -> void:
	for x in [60, 520, 980, 1380]:
		_prop("cajueiro", x, CHAO_Y + 1, -6)
	for x in [280, 760, 1180]:
		_prop("cerca", x, CHAO_Y + 1, -4)
	for x in [140, 420, 900, 1260]:
		_prop("arbusto", x, CHAO_Y + 1, -3, x % 2 == 0)
	_prop("casa_taipa", 640, CHAO_Y + 1, -8)
	_prop("palma", 1060, CHAO_Y + 1, -5)


func _iniciar_audio() -> void:
	AudioManager.tocar_musica(HINO if ResourceLoader.exists(HINO) else MUSICA, -9.0)
	AudioManager.tocar_ambiente(AMBIENTE, -15.0)


func _tom_luz() -> Color:
	return Color(0.95, 0.8, 0.6, 0.14)
