extends Node2D
## Fase de teste — protótipo da Fase 1: "O Olho d'Água do Venâncio" (c. 1932).
## Monta por código o cenário (chão em tiles, parallax, casas, árvores) e o áudio.

const SPR := "res://assets/sprites/"
const MUSICA := "res://assets/audio/musica/fase1_baiao.ogg"
const AMBIENTE := "res://assets/audio/ambiente/dia_sertao.ogg"
const NASCENTE := "res://assets/audio/ambiente/nascente.ogg"
const CHAO_Y := 160.0

@export var limite_direito := 1500
@export var limite_queda := 260.0
@export var dialogo_abertura := "abertura"
@export_file("*.json") var arquivo_dialogos := "res://data/dialogos_fase1.json"

@onready var _jogador: Player = $Jogador
@onready var _ponto_inicio: Marker2D = $PontoInicio


func _ready() -> void:
	var camera: Camera2D = _jogador.get_node("Camera2D")
	camera.limit_left = 0
	camera.limit_right = limite_direito
	camera.limit_bottom = 200
	GameState.jogador_morreu.connect(_on_jogador_morreu)
	_montar_fundo()
	_decorar_terreno()
	_colocar_cenario()
	_iniciar_audio()
	if dialogo_abertura != "":
		DialogueBox.iniciar.call_deferred(arquivo_dialogos, dialogo_abertura, _jogador)


func _physics_process(_delta: float) -> void:
	# Caiu num buraco: perde um caju e volta ao início da fase.
	if _jogador.global_position.y > limite_queda and _jogador.estado != Player.Estado.MORTO:
		GameState.perder_caju()
		if GameState.cajus > 0:
			_jogador.reaparecer(_ponto_inicio.global_position)


func _on_jogador_morreu() -> void:
	await get_tree().create_timer(1.2).timeout
	GameState.restaurar_cajus()
	_jogador.reaparecer(_ponto_inicio.global_position)


# --- Textura ------------------------------------------------------------------

func _tex(nome: String) -> Texture2D:
	var caminho := "%s%s.png" % [SPR, nome]
	return load(caminho) if ResourceLoader.exists(caminho) else null


func _tira(textura: Texture2D, retangulo: Rect2, pai: Node) -> void:
	var tira := TextureRect.new()
	tira.texture = textura
	tira.stretch_mode = TextureRect.STRETCH_TILE
	tira.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tira.position = retangulo.position
	tira.size = retangulo.size
	pai.add_child(tira)


# --- Fundo e parallax -------------------------------------------------------------

func _montar_fundo() -> void:
	var fundo: CanvasLayer = $Fundo
	if not _tex("ceu"):
		return
	for filho in fundo.get_children():
		filho.queue_free()
	var ceu := TextureRect.new()
	ceu.texture = _tex("ceu")
	fundo.add_child(ceu)
	var sol := TextureRect.new()
	sol.texture = _tex("sol")
	sol.position = Vector2(232, 22)
	fundo.add_child(sol)

	_camada_parallax("serras_longe", 0.25, 88.0, -30)
	_camada_parallax("serras_perto", 0.5, 110.0, -25)

	var nuvens := Parallax2D.new()
	nuvens.scroll_scale = Vector2(0.12, 1.0)
	nuvens.repeat_size = Vector2(640, 0)
	nuvens.repeat_times = 4
	nuvens.autoscroll = Vector2(-3, 0)
	nuvens.z_index = -35
	for item in [["nuvem1", 40, 52], ["nuvem2", 220, 38], ["nuvem3", 400, 68], ["nuvem1", 520, 44]]:
		var s := Sprite2D.new()
		s.texture = _tex(item[0])
		s.centered = false
		s.position = Vector2(item[1], item[2])
		nuvens.add_child(s)
	add_child(nuvens)


func _camada_parallax(nome: String, escala: float, y: float, z: int) -> void:
	var textura := _tex(nome)
	if textura == null:
		return
	var camada := Parallax2D.new()
	camada.scroll_scale = Vector2(escala, 1.0)
	camada.repeat_size = Vector2(textura.get_width(), 0)
	camada.repeat_times = 4
	camada.z_index = z
	var s := Sprite2D.new()
	s.texture = textura
	s.centered = false
	s.position = Vector2(0, y)
	camada.add_child(s)
	add_child(camada)


# --- Terreno -------------------------------------------------------------------------

## Troca os retângulos coloridos do chão e das plataformas por tiles de pixel art.
func _decorar_terreno() -> void:
	var topo := _tex("chao_topo")
	if topo == null:
		return
	for corpo in $Terreno.get_children():
		var forma: CollisionShape2D = corpo.get_node("CollisionShape2D")
		var tamanho: Vector2 = (forma.shape as RectangleShape2D).size
		var esquerda: Vector2 = forma.position - tamanho / 2.0
		var visual := corpo.get_node_or_null("Visual")
		if visual:
			visual.queue_free()
		if tamanho.y > 12.0:
			_tira(topo, Rect2(esquerda, Vector2(tamanho.x, 16)), corpo)
			_tira(_tex("chao_fundo"), Rect2(esquerda + Vector2(0, 16), Vector2(tamanho.x, 60)), corpo)
		else:
			_tira(_tex("plataforma"), Rect2(esquerda, Vector2(tamanho.x, 8)), corpo)


# --- Cenário -----------------------------------------------------------------------------

func _prop(nome: String, x: float, base_y := CHAO_Y, z := -5, espelhar := false) -> void:
	var textura := _tex(nome)
	if textura == null:
		return
	var s := Sprite2D.new()
	s.texture = textura
	s.centered = false
	s.position = Vector2(x - textura.get_width() / 2.0, base_y - textura.get_height())
	s.flip_h = espelhar
	s.z_index = z
	add_child(s)


func _colocar_cenario() -> void:
	for x in [60, 250, 640, 990, 1180]:
		_prop("cajueiro", x, CHAO_Y + 1, -6)
	for x in [700, 1100, 1450]:
		_prop("carnauba", x, CHAO_Y + 1, -7)
	_prop("carnauba", 728, CHAO_Y + 1, -7, true)
	_prop("casa_taipa", 470, CHAO_Y + 1, -8)
	_prop("casa_taipa2", 1320, CHAO_Y + 1, -8, true)
	for x in [200, 330, 890, 1230]:
		_prop("mandacaru", x, CHAO_Y + 1, -6)
	for x in [545, 1045]:
		_prop("cerca", x, CHAO_Y + 1, -4)
	for x in [20, 160, 580, 820, 960, 1290, 1430]:
		_prop("arbusto", x, CHAO_Y + 1, -3, x % 2 == 0)
	# Nascente (o olho d'água do Seu Venâncio)
	_prop("nascente", 752, CHAO_Y + 4, -2)

	# Jumento do Seu Zeca
	var jumento := SpriteFactory.animado(SPR + "jumento.png", 40, SpriteFactory.ANIMACOES_PARADO, Vector2(138, CHAO_Y - 14))
	if jumento:
		jumento.flip_h = true
		jumento.z_index = -1
		add_child(jumento)


# --- Áudio ----------------------------------------------------------------------------------

func _iniciar_audio() -> void:
	AudioManager.tocar_musica(MUSICA, -9.0)
	AudioManager.tocar_ambiente(AMBIENTE, -15.0)
	var fluxo := AudioManager.carregar_em_loop(NASCENTE)
	if fluxo == null:
		return
	var agua := AudioStreamPlayer2D.new()
	agua.stream = fluxo
	agua.position = Vector2(752, CHAO_Y - 6)
	agua.max_distance = 240.0
	agua.attenuation = 1.5
	agua.volume_db = -4.0
	add_child(agua)
	agua.play()
