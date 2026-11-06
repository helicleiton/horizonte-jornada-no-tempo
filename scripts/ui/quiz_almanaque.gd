class_name QuizAlmanaque
extends CanvasLayer
## Quiz com perguntas sobre as páginas do almanaque que o jogador já encontrou.
## Funciona com o jogo pausado (fim de fase) e mostra até cinco perguntas por rodada.

const ARQUIVO_QUIZ := "res://data/quiz_almanaque.json"
const ARQUIVO_ALMANAQUE := "res://data/almanaque.json"
const MAXIMO_POR_RODADA := 5

var _perguntas: Array = []
var _titulos := {}
var _atual := 0
var _acertos := 0
var _rotulo_pergunta: Label
var _opcoes: VBoxContainer
var _retorno: Label
var _proximo: Button


## Quantas perguntas o jogador pode responder agora (páginas encontradas com pergunta).
static func disponiveis() -> int:
	return _filtrar().size()


static func _filtrar() -> Array:
	var dados: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(ARQUIVO_QUIZ))
	var encontradas: Array = []
	for pergunta: Dictionary in dados.get("perguntas", []):
		if pergunta["pagina"] in GameState.paginas:
			encontradas.append(pergunta)
	return encontradas


func _ready() -> void:
	layer = 20
	process_mode = Node.PROCESS_MODE_ALWAYS
	_perguntas = _filtrar()
	_perguntas.shuffle()
	_perguntas = _perguntas.slice(0, MAXIMO_POR_RODADA)
	var almanaque: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(ARQUIVO_ALMANAQUE))
	for id: String in almanaque:
		_titulos[id] = almanaque[id]["titulo"]
	_construir()
	_mostrar_pergunta()


func _construir() -> void:
	var fundo := ColorRect.new()
	fundo.color = Color(0.05, 0.03, 0.02, 0.9)
	fundo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(fundo)

	var painel := PanelContainer.new()
	painel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	painel.custom_minimum_size = Vector2(290, 0)
	painel.position = Vector2(-145, -88)
	add_child(painel)

	var coluna := VBoxContainer.new()
	coluna.add_theme_constant_override("separation", 5)
	painel.add_child(coluna)

	var titulo := Label.new()
	titulo.text = "QUIZ DO ALMANAQUE"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	coluna.add_child(titulo)

	_rotulo_pergunta = Label.new()
	_rotulo_pergunta.autowrap_mode = TextServer.AUTOWRAP_WORD
	_rotulo_pergunta.custom_minimum_size = Vector2(270, 0)
	coluna.add_child(_rotulo_pergunta)

	_opcoes = VBoxContainer.new()
	_opcoes.add_theme_constant_override("separation", 3)
	coluna.add_child(_opcoes)

	_retorno = Label.new()
	_retorno.autowrap_mode = TextServer.AUTOWRAP_WORD
	_retorno.custom_minimum_size = Vector2(270, 0)
	coluna.add_child(_retorno)

	_proximo = Button.new()
	_proximo.text = "PRÓXIMA"
	_proximo.pressed.connect(_avancar)
	coluna.add_child(_proximo)


func _mostrar_pergunta() -> void:
	_retorno.text = ""
	_proximo.visible = false
	for filho in _opcoes.get_children():
		filho.queue_free()
	if _atual >= _perguntas.size():
		_mostrar_resultado()
		return
	var pergunta: Dictionary = _perguntas[_atual]
	_rotulo_pergunta.text = "(%d/%d) Sobre \"%s\": %s" % [_atual + 1, _perguntas.size(), _titulos.get(pergunta["pagina"], ""), pergunta["pergunta"]]
	for i in (pergunta["opcoes"] as Array).size():
		var botao := Button.new()
		botao.text = pergunta["opcoes"][i]
		botao.pressed.connect(_responder.bind(i))
		_opcoes.add_child(botao)


func _responder(escolha: int) -> void:
	var pergunta: Dictionary = _perguntas[_atual]
	for botao: Button in _opcoes.get_children():
		botao.disabled = true
	var correta := int(pergunta["correta"])
	if escolha == correta:
		_acertos += 1
		_retorno.text = "Isso! " + pergunta["opcoes"][escolha]
		AudioManager.tocar("item", 1.0, -4.0)
	else:
		_retorno.text = "Quase. A resposta era: " + pergunta["opcoes"][correta]
		AudioManager.tocar("escolha", 1.0, -4.0)
	_proximo.visible = true
	_proximo.text = "PRÓXIMA" if _atual + 1 < _perguntas.size() else "VER RESULTADO"


func _avancar() -> void:
	_atual += 1
	_mostrar_pergunta()


func _mostrar_resultado() -> void:
	_rotulo_pergunta.text = "Você acertou %d de %d perguntas." % [_acertos, _perguntas.size()]
	_proximo.text = "FECHAR"
	_proximo.visible = true
	for filho in _proximo.pressed.get_connections():
		_proximo.pressed.disconnect(filho["callable"])
	_proximo.pressed.connect(queue_free)
