extends Node
## Efeitos sonoros, música e ambiente (autoload "AudioManager").
## Os arquivos vêm de tools/gerar_audio.py (sintetizados) e de
## tools/importar_sons.py (gravações CC0), em assets/audio/.

const EFEITOS := [
	"pulo", "aterrissa", "passo1", "passo2", "semente", "item", "pagina", "caju", "fragmento",
	"dano", "blip1", "blip2", "blip3", "escolha", "almanaque_abrir", "almanaque_fechar",
]

var _efeitos := {}
var _vozes: Array[AudioStreamPlayer] = []
var _musica: AudioStreamPlayer
var _ambiente: AudioStreamPlayer
var _cajus_antes := GameState.CAJUS_MAX
var _itens_antes := {}
## Som desligado pelo jogador (tecla M ou botão SOM no menu).
var mudo := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for nome: String in EFEITOS:
		var caminho := "res://assets/audio/sfx/%s.ogg" % nome
		if ResourceLoader.exists(caminho):
			_efeitos[nome] = load(caminho)
	for i in 8:
		var voz := AudioStreamPlayer.new()
		add_child(voz)
		_vozes.append(voz)
	_musica = AudioStreamPlayer.new()
	_ambiente = AudioStreamPlayer.new()
	add_child(_musica)
	add_child(_ambiente)

	GameState.sementes_mudou.connect(func(_total: int) -> void: tocar("semente"))
	GameState.pagina_coletada.connect(func(_id: String) -> void: tocar("pagina"))
	GameState.fragmento_coletado.connect(func(_fase: int) -> void: tocar("fragmento"))
	GameState.cajus_mudou.connect(_on_cajus_mudou)
	GameState.itens_mudou.connect(_on_itens_mudou)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("mudo"):
		alternar_mudo()
		get_viewport().set_input_as_handled()


## Liga ou desliga todo o som do jogo, inclusive a narração.
func alternar_mudo() -> void:
	mudo = not mudo
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), mudo)
	if mudo:
		Narracao.calar()


func tocar(nome: String, tom := 1.0, volume_db := 0.0) -> void:
	if not _efeitos.has(nome):
		return
	var voz: AudioStreamPlayer = null
	for candidata in _vozes:
		if not candidata.playing:
			voz = candidata
			break
	if voz == null:
		voz = _vozes[0]
	voz.stream = _efeitos[nome]
	voz.pitch_scale = tom
	voz.volume_db = volume_db - 2.0
	voz.play()


func tocar_musica(caminho: String, volume_db := -9.0) -> void:
	_tocar_em_loop(_musica, caminho, volume_db)


func tocar_ambiente(caminho: String, volume_db := -14.0) -> void:
	_tocar_em_loop(_ambiente, caminho, volume_db)


func parar_musica() -> void:
	_musica.stop()
	_ambiente.stop()


func carregar_em_loop(caminho: String) -> AudioStream:
	if not ResourceLoader.exists(caminho):
		return null
	var fluxo: AudioStream = load(caminho)
	if fluxo is AudioStreamOggVorbis:
		fluxo.loop = true
	return fluxo


func _tocar_em_loop(voz: AudioStreamPlayer, caminho: String, volume_db: float) -> void:
	var fluxo := carregar_em_loop(caminho)
	if fluxo == null:
		return
	if voz.stream == fluxo and voz.playing:
		return
	voz.stream = fluxo
	voz.volume_db = volume_db
	voz.play()


func _on_cajus_mudou(atual: int, _maximo: int) -> void:
	if atual > _cajus_antes:
		tocar("caju")
	elif atual < _cajus_antes:
		tocar("dano")
	_cajus_antes = atual


func _on_itens_mudou(id: String, quantidade: int) -> void:
	if quantidade > _itens_antes.get(id, 0):
		tocar("item")
	_itens_antes[id] = quantidade
