extends "res://scripts/levels/fase_teste.gd"
## Fase 6 — "As águas de Horizonte". Mesma base das outras fases, com um cenário de
## mata ciliar, nascentes e a cerca do parque.


func _ready() -> void:
	GameState.restaurar_cajus()
	super._ready()


func _colocar_cenario() -> void:
	for x in [40, 520, 980, 1360]:
		_prop("cajueiro", x, CHAO_Y + 1, -6)
	for x in [240, 680, 1140]:
		_prop("carnauba", x, CHAO_Y + 1, -7)
	for x in [400, 820]:
		_prop("cerca", x, CHAO_Y + 1, -4)
	for x in [130, 330, 600, 900, 1240]:
		_prop("arbusto", x, CHAO_Y + 1, -3, x % 2 == 0)
	_prop("nascente", 760, CHAO_Y + 4, -2)
	_prop("pedra", 1080, CHAO_Y + 2, -3)


func _iniciar_audio() -> void:
	AudioManager.tocar_musica(HINO if ResourceLoader.exists(HINO) else MUSICA, -9.0)
	AudioManager.tocar_ambiente(AMBIENTE, -15.0)
	var fluxo := AudioManager.carregar_em_loop(NASCENTE)
	if fluxo:
		var agua := AudioStreamPlayer2D.new()
		agua.stream = fluxo
		agua.position = Vector2(760, CHAO_Y - 6)
		agua.max_distance = 240.0
		agua.volume_db = -4.0
		add_child(agua)
		agua.play()
