extends CanvasLayer
## HUD: cajus (vida), sementes de carnaúba, páginas do almanaque e
## fragmentos de memória. A tecla do Almanaque abre as páginas coletadas
## e pausa o jogo.

const ARQUIVO_ALMANAQUE := "res://data/almanaque.json"
const ICONES := "res://assets/sprites/"
## Texto do fim de cada fase. A fase 2b (primeira eleição) não tem fragmento.
const TEXTO_FIM := {
	1: "Você restaurou o Fragmento de Memória 1. A próxima parada é 1987: a emancipação de Horizonte.",
	2: "Você restaurou o Fragmento de Memória 2. A próxima parada é a primeira eleição, em 1988.",
	3: "Você restaurou o Fragmento de Memória 3. A próxima parada é o presente: plantar o futuro.",
	4: "Você restaurou o último Fragmento de Memória. A próxima parada é a cidade de hoje.",
	6: "Você viu como Horizonte se reinventou no século XXI. A próxima parada são as águas de Horizonte.",
	7: "Você conheceu as águas de Horizonte. A próxima parada é a festa de São João.",
	8: "Você viveu a festa de São João de Horizonte. Esta é a última fase do protótipo.",
	5: "Você viu como nasceu a primeira eleição de Horizonte. A próxima parada são os anos 1990.",
}
const ROTULO_FASE := {5: "2b", 6: "5", 7: "6", 8: "7"}

var _paginas := {}
var _barra_cajus: BarraCajus
var _rotulo_sementes: Label
var _rotulo_paginas: Label
var _rotulo_fragmentos: Label
var _aviso: Label
var _painel_almanaque: PanelContainer
var _texto_almanaque: RichTextLabel
var _tela_fim: TelaFimFase
var _menu_pausa: MenuPausa

## Número da fase exibida nos objetivos e no fim de fase.
@export var fase := 1
## Cena da próxima fase, mostrada no fim desta. Vazio = sem próxima fase.
@export_file("*.tscn") var proxima_cena := ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var dados: Variant = JSON.parse_string(FileAccess.get_file_as_string(ARQUIVO_ALMANAQUE))
	if typeof(dados) == TYPE_DICTIONARY:
		_paginas = dados
	_construir()
	GameState.sementes_mudou.connect(func(_total: int) -> void: _atualizar())
	GameState.cajus_mudou.connect(func(_atual: int, _maximo: int) -> void: _atualizar())
	GameState.pagina_coletada.connect(_on_pagina_coletada)
	GameState.fragmento_coletado.connect(_on_fragmento_coletado)
	_atualizar()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("almanaque") and not DialogueBox.ativo:
		_alternar_almanaque()
		get_viewport().set_input_as_handled()
	elif _painel_almanaque.visible and event.is_action_pressed("ui_cancel"):
		_alternar_almanaque()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel") and not DialogueBox.ativo and not _tela_fim.visible:
		if _menu_pausa.visible:
			_menu_pausa.fechar()
		else:
			_menu_pausa.abrir()
		get_viewport().set_input_as_handled()


func _atualizar() -> void:
	_barra_cajus.atual = GameState.cajus
	_barra_cajus.maximo = GameState.CAJUS_MAX
	_barra_cajus.custom_minimum_size = Vector2(GameState.CAJUS_MAX * 14, 13)
	_barra_cajus.queue_redraw()
	_rotulo_sementes.text = str(GameState.sementes)
	_rotulo_paginas.text = "%d/%d" % [GameState.paginas.size(), _paginas.size()]
	_rotulo_fragmentos.text = "%d/%d" % [GameState.fragmentos.size(), GameState.TOTAL_FRAGMENTOS]


func _on_pagina_coletada(id: String) -> void:
	_atualizar()
	var titulo: String = _paginas.get(id, {}).get("titulo", id)
	_mostrar_aviso("Nova página do Almanaque: %s  %s" % [titulo, GameState.dica("[Tab]", "")])


func _on_fragmento_coletado(_fase: int) -> void:
	_atualizar()
	_mostrar_aviso("Fragmento de Memória restaurado!")


## Espera a conversa em curso terminar, para o fim de fase não cobrir o diálogo.
func _mostrar_fim_de_fase() -> void:
	if DialogueBox.ativo:
		DialogueBox.dialogo_terminado.connect(_ao_terminar_dialogo, CONNECT_ONE_SHOT)
		return
	var rotulo: String = ROTULO_FASE.get(fase, str(fase))
	_tela_fim.mostrar("Fase %s concluída!" % rotulo, TEXTO_FIM.get(fase, ""))


func _ao_terminar_dialogo(_id: String) -> void:
	_mostrar_fim_de_fase()


func _mostrar_aviso(texto: String) -> void:
	_aviso.text = texto
	_aviso.modulate.a = 1.0
	var tween := create_tween()
	tween.tween_interval(2.5)
	tween.tween_property(_aviso, "modulate:a", 0.0, 0.5)


func _alternar_almanaque() -> void:
	var abrir := not _painel_almanaque.visible
	if abrir:
		_preencher_almanaque()
	_painel_almanaque.visible = abrir
	get_tree().paused = abrir
	AudioManager.tocar("almanaque_abrir" if abrir else "almanaque_fechar", 1.0, -4.0)
	if abrir:
		_texto_almanaque.grab_focus()


func _preencher_almanaque() -> void:
	var texto := "[center][b]ALMANAQUE DE HORIZONTE[/b][/center]\n\n"
	for id: String in _paginas:
		var pagina: Dictionary = _paginas[id]
		if id in GameState.paginas:
			texto += "[b]%s[/b]\n%s\n[i]Fonte: %s[/i]\n\n" % [pagina["titulo"], pagina["texto"], pagina.get("fonte", "")]
		else:
			texto += "[color=#8a7a66]??? — página ainda não encontrada[/color]\n\n"
	texto += "[center]%s[/center]" % GameState.dica("[Tab] ou [Esc] para fechar", "Toque no livro para fechar")
	_texto_almanaque.text = texto


func _construir() -> void:
	var margem := MarginContainer.new()
	margem.add_theme_constant_override("margin_left", 6)
	margem.add_theme_constant_override("margin_top", 4)
	add_child(margem)

	var linha := HBoxContainer.new()
	linha.add_theme_constant_override("separation", 8)
	margem.add_child(linha)

	_barra_cajus = BarraCajus.new()
	_barra_cajus.cheio = load(ICONES + "hud_caju.png")
	_barra_cajus.vazio = load(ICONES + "hud_caju_vazio.png")
	linha.add_child(_barra_cajus)
	_rotulo_sementes = _criar_contador(linha, "hud_semente.png")
	_rotulo_paginas = _criar_contador(linha, "hud_pagina.png")
	_rotulo_fragmentos = _criar_contador(linha, "hud_fragmento.png")
	var objetivos := PainelObjetivos.new()
	objetivos.fase = fase
	objetivos.concluiu.connect(_mostrar_aviso)
	objetivos.fase_concluida.connect(_mostrar_fim_de_fase)
	add_child(objetivos)

	_tela_fim = TelaFimFase.new()
	_tela_fim.proxima_cena = proxima_cena
	add_child(_tela_fim)

	_menu_pausa = MenuPausa.new()
	add_child(_menu_pausa)

	_aviso = Label.new()
	_aviso.add_theme_font_size_override("font_size", 8)
	_aviso.add_theme_color_override("font_color", Color("f4c95d"))
	_aviso.add_theme_color_override("font_outline_color", Color("2b1a12"))
	_aviso.add_theme_constant_override("outline_size", 3)
	_aviso.anchor_right = 1.0
	_aviso.offset_top = 96
	_aviso.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_aviso.modulate.a = 0.0
	add_child(_aviso)

	_painel_almanaque = PanelContainer.new()
	_painel_almanaque.anchor_right = 1.0
	_painel_almanaque.anchor_bottom = 1.0
	_painel_almanaque.offset_left = 16
	_painel_almanaque.offset_top = 12
	_painel_almanaque.offset_right = -16
	_painel_almanaque.offset_bottom = -12
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color("f0e2b6")
	estilo.border_color = Color("7a4a2a")
	estilo.set_border_width_all(2)
	estilo.set_content_margin_all(6)
	_painel_almanaque.add_theme_stylebox_override("panel", estilo)
	_painel_almanaque.hide()
	add_child(_painel_almanaque)

	_texto_almanaque = RichTextLabel.new()
	_texto_almanaque.bbcode_enabled = true
	_texto_almanaque.focus_mode = Control.FOCUS_ALL
	_texto_almanaque.add_theme_color_override("default_color", Color("2b1a12"))
	for fonte in ["normal_font_size", "bold_font_size", "italics_font_size"]:
		_texto_almanaque.add_theme_font_size_override(fonte, 8)
	_texto_almanaque.gui_input.connect(_rolar_almanaque_com_dedo)
	_painel_almanaque.add_child(_texto_almanaque)


## No celular, arrastar o dedo sobre o texto rola as páginas do Almanaque.
func _rolar_almanaque_com_dedo(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		_texto_almanaque.get_v_scroll_bar().value -= event.relative.y


## Ícone + número, como "(semente) 12".
func _criar_contador(pai: Node, icone: String) -> Label:
	var caixa := HBoxContainer.new()
	caixa.add_theme_constant_override("separation", 3)
	pai.add_child(caixa)
	var imagem := TextureRect.new()
	imagem.texture = load(ICONES + icone)
	imagem.stretch_mode = TextureRect.STRETCH_KEEP
	imagem.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	caixa.add_child(imagem)
	var rotulo := Label.new()
	rotulo.add_theme_font_size_override("font_size", 8)
	rotulo.add_theme_color_override("font_outline_color", Color("2b1a12"))
	rotulo.add_theme_constant_override("outline_size", 4)
	caixa.add_child(rotulo)
	return rotulo


## Vida desenhada com ícones de caju: laranja = cheio, cinza = perdido.
class BarraCajus extends Control:
	var atual := 5
	var maximo := 5
	var cheio: Texture2D
	var vazio: Texture2D

	func _draw() -> void:
		for i in maximo:
			var textura := cheio if i < atual else vazio
			if textura:
				draw_texture(textura, Vector2(i * 14, 0))
