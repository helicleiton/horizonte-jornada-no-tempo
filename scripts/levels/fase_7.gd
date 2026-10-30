extends "res://scripts/levels/fase_teste.gd"
## Fase 8 — "A festa de São João". Mesma base das outras fases, com a praça da
## Matriz enfeitada de bandeirinhas e a fogueira.


func _ready() -> void:
	GameState.restaurar_cajus()
	super._ready()


func _colocar_cenario() -> void:
	for x in [50, 540, 1000]:
		_prop("cajueiro", x, CHAO_Y + 1, -6)
	for x in [220, 700, 1180]:
		_prop("cerca", x, CHAO_Y + 1, -4)
	for x in [120, 380, 860, 1260]:
		_prop("arbusto", x, CHAO_Y + 1, -3, x % 2 == 0)
	_prop("palma", 460, CHAO_Y + 1, -5)
	_prop("mandacaru", 1100, CHAO_Y + 1, -6)
	_prop("casa_taipa", 780, CHAO_Y + 1, -8)


func _iniciar_audio() -> void:
	AudioManager.tocar_musica(HINO if ResourceLoader.exists(HINO) else MUSICA, -9.0)
	AudioManager.tocar_ambiente(AMBIENTE, -15.0)


func _tom_luz() -> Color:
	return Color(1.0, 0.55, 0.3, 0.22)
