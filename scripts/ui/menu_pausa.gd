class_name MenuPausa
extends CanvasLayer
## Menu de pausa, aberto com Esc durante a fase: continuar, som, tela cheia
## e voltar ao menu principal. Pausa o jogo enquanto está aberto.

const MENU := "res://scenes/ui/menu_inicial.tscn"

var _botao_som: Button
var _botao_tela_cheia: Button


func _ready() -> void:
	layer = 25
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

	var fundo := ColorRect.new()
	fundo.color = Color(0.08, 0.05, 0.03, 0.8)
	fundo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fundo.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(fundo)

	# Letras pequenas, no tamanho do HUD.
	var tema := Theme.new()
	tema.default_font_size = 8
	var centro := CenterContainer.new()
	centro.theme = tema
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(centro)

	var painel := PanelContainer.new()
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color("2b1a12")
	estilo.border_color = Color("e8b04a")
	estilo.set_border_width_all(2)
	estilo.set_content_margin_all(8)
	painel.add_theme_stylebox_override("panel", estilo)
	centro.add_child(painel)

	var coluna := VBoxContainer.new()
	coluna.add_theme_constant_override("separation", 4)
	painel.add_child(coluna)

	var titulo := Label.new()
	titulo.text = "PAUSA"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.add_theme_font_size_override("font_size", 12)
	titulo.add_theme_color_override("font_color", Color("f4c95d"))
	coluna.add_child(titulo)

	_botao(coluna, "CONTINUAR", fechar)
	_botao_som = _botao(coluna, "", _alternar_som)
	_botao_tela_cheia = _botao(coluna, "", GameState.alternar_tela_cheia)
	_botao(coluna, "MENU PRINCIPAL", _voltar_ao_menu)
	_atualizar_textos()


func _process(_delta: float) -> void:
	if visible:
		_atualizar_textos()


func abrir() -> void:
	visible = true
	get_tree().paused = true
	_atualizar_textos()


func fechar() -> void:
	visible = false
	get_tree().paused = false


func _alternar_som() -> void:
	AudioManager.alternar_mudo()
	_atualizar_textos()


func _voltar_ao_menu() -> void:
	Narracao.calar()
	get_tree().paused = false
	get_tree().change_scene_to_file(MENU)


func _atualizar_textos() -> void:
	_botao_som.text = "SOM: " + ("NÃO" if AudioManager.mudo else "SIM")
	_botao_tela_cheia.text = "TELA CHEIA: " + ("SIM" if GameState.tela_cheia_ativa() else "NÃO")


func _botao(pai: Node, texto: String, acao: Callable) -> Button:
	var botao := Button.new()
	botao.text = texto
	botao.custom_minimum_size = Vector2(180, 18)
	botao.pressed.connect(acao)
	pai.add_child(botao)
	return botao
