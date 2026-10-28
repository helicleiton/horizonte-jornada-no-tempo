extends CanvasLayer
## Controles na tela para celular e tablet (autoload "ControlesToque").
##
## Só aparece em aparelhos com tela de toque. Cada botão é um TouchScreenButton
## que dispara a mesma ação do teclado ("mover_esquerda", "pular" etc.), então
## o resto do jogo não precisa saber se a entrada veio do teclado ou do dedo.
## Em celular a escala deixa de ser inteira, para o jogo ocupar a tela toda.

const SPR := "res://assets/sprites/toque_%s.png"

var _movimento: Array[TouchScreenButton] = []
var _falar: TouchScreenButton
var _almanaque: TouchScreenButton
var _tela_cheia: TouchScreenButton


func _ready() -> void:
	layer = 20
	process_mode = Node.PROCESS_MODE_ALWAYS
	if not GameState.toque:
		return
	get_tree().root.content_scale_stretch = Window.CONTENT_SCALE_STRETCH_FRACTIONAL
	_movimento.append(_botao("esquerda", "mover_esquerda", Vector2(4, 146)))
	_movimento.append(_botao("direita", "mover_direita", Vector2(38, 146)))
	_movimento.append(_botao("pular", "pular", Vector2(286, 146)))
	_falar = _botao("falar", "interagir", Vector2(256, 152))
	_movimento.append(_falar)
	_almanaque = _botao("almanaque", "almanaque", Vector2(294, 3))
	_tela_cheia = _botao("tela_cheia", "", Vector2(274, 5))
	_tela_cheia.pressed.connect(_alternar_tela_cheia)
	# Esquerda e direita: dá para deslizar o dedo de um botão para o outro.
	_movimento[0].passby_press = true
	_movimento[1].passby_press = true


func _process(_delta: float) -> void:
	if not GameState.toque:
		return
	var em_dialogo: bool = DialogueBox.ativo
	var pausado := get_tree().paused
	for botao in _movimento:
		botao.visible = not (em_dialogo or pausado)
	# O diálogo avança tocando na própria caixa de texto.
	_almanaque.visible = not em_dialogo
	var jogador := get_tree().get_first_node_in_group("jogador")
	var perto: bool = jogador != null and jogador.has_method("pode_interagir") and jogador.pode_interagir()
	_falar.modulate.a = 1.0 if perto else 0.35


func _botao(nome: String, acao: String, posicao: Vector2) -> TouchScreenButton:
	var botao := TouchScreenButton.new()
	botao.texture_normal = load(SPR % nome)
	botao.texture_pressed = load(SPR % (nome + "_apertado"))
	botao.action = acao
	botao.position = posicao
	var forma := CircleShape2D.new()
	# Área de toque um pouco maior que o desenho: dedo é menos preciso que mouse.
	forma.radius = botao.texture_normal.get_width() * 0.6
	botao.shape = forma
	botao.shape_centered = true
	add_child(botao)
	return botao


func _alternar_tela_cheia() -> void:
	var cheia := DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if cheia else DisplayServer.WINDOW_MODE_FULLSCREEN)
