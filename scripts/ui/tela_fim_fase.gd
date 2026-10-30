class_name TelaFimFase
extends CanvasLayer
## Tela exibida quando todos os objetivos da fase são concluídos. Pausa o jogo e
## oferece seguir para a próxima fase, continuar explorando ou voltar ao menu.

const MENU := "res://scenes/ui/menu_inicial.tscn"

## Cena da próxima fase; vazio quando ainda não existe.
var proxima_cena := ""

var _painel: PanelContainer
var _titulo: Label
var _texto: Label
var _botoes: VBoxContainer


func _ready() -> void:
	layer = 30
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

	var fundo := ColorRect.new()
	fundo.color = Color(0.08, 0.05, 0.03, 0.85)
	fundo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fundo.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(fundo)

	var centro := CenterContainer.new()
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(centro)

	_painel = PanelContainer.new()
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color("2b1a12")
	estilo.border_color = Color("e8b04a")
	estilo.set_border_width_all(2)
	estilo.set_content_margin_all(10)
	_painel.add_theme_stylebox_override("panel", estilo)
	_painel.custom_minimum_size = Vector2(240, 0)
	centro.add_child(_painel)

	var coluna := VBoxContainer.new()
	coluna.add_theme_constant_override("separation", 6)
	_painel.add_child(coluna)

	_titulo = Label.new()
	_titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_titulo.add_theme_font_size_override("font_size", 12)
	_titulo.add_theme_color_override("font_color", Color("f4c95d"))
	coluna.add_child(_titulo)

	_texto = Label.new()
	_texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_texto.autowrap_mode = TextServer.AUTOWRAP_WORD
	_texto.custom_minimum_size = Vector2(220, 0)
	_texto.add_theme_font_size_override("font_size", 8)
	_texto.add_theme_color_override("font_color", Color("f0e2b6"))
	coluna.add_child(_texto)

	_botoes = VBoxContainer.new()
	_botoes.add_theme_constant_override("separation", 4)
	coluna.add_child(_botoes)


## Mostra a tela com o título e o texto da fase concluída.
func mostrar(titulo: String, texto: String) -> void:
	_titulo.text = titulo
	_texto.text = texto
	for filho in _botoes.get_children():
		filho.queue_free()
	if proxima_cena != "":
		_botao("IR PARA A PRÓXIMA FASE", func() -> void: _trocar_cena(proxima_cena))
	_botao("CONTINUAR EXPLORANDO", _continuar)
	_botao("MENU PRINCIPAL", func() -> void: _trocar_cena(MENU))
	visible = true
	get_tree().paused = true


func _continuar() -> void:
	visible = false
	get_tree().paused = false


func _trocar_cena(caminho: String) -> void:
	get_tree().paused = false
	var viagem := TransicaoTempo.new()
	viagem.caminho = caminho
	get_tree().root.add_child(viagem)


func _botao(texto: String, acao: Callable) -> void:
	var botao := Button.new()
	botao.text = texto
	botao.custom_minimum_size = Vector2(220, 18)
	botao.pressed.connect(acao)
	_botoes.add_child(botao)
