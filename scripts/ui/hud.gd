extends CanvasLayer
## HUD: cajus (vida), sementes de carnaúba, páginas do almanaque e
## fragmentos de memória. A tecla do Almanaque abre as páginas coletadas
## e pausa o jogo.

const ARQUIVO_ALMANAQUE := "res://data/almanaque.json"

var _paginas := {}
var _barra_cajus: BarraCajus
var _rotulo_sementes: Label
var _rotulo_paginas: Label
var _rotulo_fragmentos: Label
var _aviso: Label
var _painel_almanaque: PanelContainer
var _texto_almanaque: RichTextLabel


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


func _atualizar() -> void:
	_barra_cajus.atual = GameState.cajus
	_barra_cajus.maximo = GameState.CAJUS_MAX
	_barra_cajus.custom_minimum_size = Vector2(GameState.CAJUS_MAX * 10, 12)
	_barra_cajus.queue_redraw()
	_rotulo_sementes.text = "Sementes: %d" % GameState.sementes
	_rotulo_paginas.text = "Páginas: %d/%d" % [GameState.paginas.size(), _paginas.size()]
	_rotulo_fragmentos.text = "Fragmentos: %d/%d" % [GameState.fragmentos.size(), GameState.TOTAL_FRAGMENTOS]


func _on_pagina_coletada(id: String) -> void:
	_atualizar()
	var titulo: String = _paginas.get(id, {}).get("titulo", id)
	_mostrar_aviso("Nova página do Almanaque: %s  [Tab]" % titulo)


func _on_fragmento_coletado(_fase: int) -> void:
	_atualizar()
	_mostrar_aviso("Fragmento de Memória restaurado!")


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
	texto += "[center][Tab] ou [Esc] para fechar[/center]"
	_texto_almanaque.text = texto


func _construir() -> void:
	var margem := MarginContainer.new()
	margem.add_theme_constant_override("margin_left", 6)
	margem.add_theme_constant_override("margin_top", 4)
	add_child(margem)

	var linha := HBoxContainer.new()
	linha.add_theme_constant_override("separation", 10)
	margem.add_child(linha)

	_barra_cajus = BarraCajus.new()
	linha.add_child(_barra_cajus)
	_rotulo_sementes = _criar_rotulo(linha)
	_rotulo_paginas = _criar_rotulo(linha)
	_rotulo_fragmentos = _criar_rotulo(linha)

	_aviso = Label.new()
	_aviso.add_theme_font_size_override("font_size", 8)
	_aviso.add_theme_color_override("font_color", Color("f4c95d"))
	_aviso.add_theme_color_override("font_outline_color", Color("2b1a12"))
	_aviso.add_theme_constant_override("outline_size", 3)
	_aviso.anchor_right = 1.0
	_aviso.offset_top = 18
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
	_painel_almanaque.add_child(_texto_almanaque)


func _criar_rotulo(pai: Node) -> Label:
	var rotulo := Label.new()
	rotulo.add_theme_font_size_override("font_size", 8)
	rotulo.add_theme_color_override("font_outline_color", Color("2b1a12"))
	rotulo.add_theme_constant_override("outline_size", 3)
	pai.add_child(rotulo)
	return rotulo


## Vida desenhada como cajus: a fruta laranja com a castanha embaixo.
class BarraCajus extends Control:
	var atual := 5
	var maximo := 5

	func _draw() -> void:
		for i in maximo:
			var cheio := i < atual
			var x := i * 10.0 + 4.0
			draw_circle(Vector2(x, 4), 4.0, Color("f28c28") if cheio else Color("5a4a40"))
			draw_circle(Vector2(x, 9), 2.0, Color("7a5230") if cheio else Color("3a302a"))
