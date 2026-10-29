extends CanvasLayer
## Caixa de diálogo global (autoload "DialogueBox").
##
## Lê diálogos em JSON. Cada diálogo tem "nome", "inicio", "condicoes"
## (opcional) e "nos". Cada nó pode ter: "quem", "fala", "proximo",
## "opcoes", "flag", "recompensa" e "remover_item". Veja data/dialogos_fase1.json.

signal dialogo_iniciado(id: String)
signal dialogo_terminado(id: String)

const CARACTERES_POR_SEGUNDO := 45.0

var ativo := false

var _cache := {}
var _dados := {}
var _id := ""
var _no_atual := {}
var _jogador: Node = null
var _digitando := false
var _caracteres := 0.0
var _ultimo_blip := 0

var _painel: PanelContainer
var _nome: Label
var _texto: RichTextLabel
var _opcoes: VBoxContainer
var _continuar: Label


func _ready() -> void:
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS
	_construir_interface()
	_painel.hide()


func iniciar(arquivo: String, id: String, jogador: Node = null) -> void:
	if ativo:
		return
	var todos := _carregar(arquivo)
	if not todos.has(id):
		push_warning("Diálogo '%s' não encontrado em %s" % [id, arquivo])
		return
	_dados = todos[id]
	_id = id
	_jogador = jogador
	ativo = true
	if _jogador and _jogador.has_method("entrar_dialogo"):
		_jogador.entrar_dialogo()
	_painel.show()
	dialogo_iniciado.emit(id)
	_ir_para(_escolher_inicio())


func _process(delta: float) -> void:
	if not (ativo and _digitando):
		return
	_caracteres += CARACTERES_POR_SEGUNDO * delta
	_texto.visible_characters = int(_caracteres)
	# Um "blip" a cada 2 letras, com timbre próprio de cada personagem.
	var visiveis := _texto.visible_characters
	# Enquanto a voz narra, não tocam os blips para não competir com ela.
	if visiveis - _ultimo_blip >= 2 and not Narracao.falando():
		_ultimo_blip = visiveis
		var letra := _texto.get_parsed_text().substr(maxi(visiveis - 1, 0), 1)
		if letra.strip_edges() != "":
			AudioManager.tocar("blip%d" % (1 + absi(_nome.text.hash()) % 3), randf_range(0.95, 1.06), -9.0)
	if _texto.visible_characters >= _texto.get_total_character_count():
		_terminar_fala()


func _unhandled_input(event: InputEvent) -> void:
	if not ativo:
		return
	if event.is_action_pressed("interagir") or event.is_action_pressed("pular"):
		get_viewport().set_input_as_handled()
		_avancar()


## Tocar (ou clicar) na caixa de texto também avança: é assim que se joga no celular.
func _on_painel_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_painel.accept_event()
		_avancar()


func _avancar() -> void:
	if _digitando:
		_terminar_fala()
	elif _opcoes.get_child_count() == 0:
		_ir_para(_no_atual.get("proximo"))


func _escolher_inicio() -> String:
	for condicao: Dictionary in _dados.get("condicoes", []):
		if _condicao_ok(condicao):
			return condicao["no"]
	return _dados.get("inicio", "inicio")


func _condicao_ok(condicao: Dictionary) -> bool:
	for flag: String in condicao.get("flags", []):
		if not GameState.get_flag(flag):
			return false
	if condicao.has("flag") and not GameState.get_flag(condicao["flag"]):
		return false
	if condicao.has("sem_flag") and GameState.get_flag(condicao["sem_flag"]):
		return false
	if condicao.has("item") and GameState.quantidade_item(condicao["item"]) < int(condicao.get("min", 1)):
		return false
	return true


func _ir_para(chave: Variant) -> void:
	var nos: Dictionary = _dados.get("nos", {})
	if chave == null or not nos.has(chave):
		if chave != null:
			push_warning("Nó '%s' não existe no diálogo '%s'" % [chave, _id])
		_encerrar()
		return
	_no_atual = nos[chave]
	_aplicar_efeitos(_no_atual)
	_nome.text = _formatar(_no_atual.get("quem", _dados.get("nome", "")))
	var fala: String = _no_atual.get("fala", "")
	if GameState.toque:
		fala = _no_atual.get("fala_toque", fala)
	_texto.text = _formatar(fala)
	Narracao.falar(_texto.text, _nome.text)
	_texto.visible_characters = 0
	_caracteres = 0.0
	_ultimo_blip = 0
	_digitando = true
	_limpar_opcoes()
	_continuar.hide()


func _terminar_fala() -> void:
	_digitando = false
	_texto.visible_characters = -1
	var opcoes: Array = _no_atual.get("opcoes", [])
	if opcoes.is_empty():
		_continuar.show()
		return
	for opcao: Dictionary in opcoes:
		if opcao.has("condicao") and not _condicao_ok(opcao["condicao"]):
			continue
		var botao := Button.new()
		botao.text = _formatar(opcao["texto"])
		botao.alignment = HORIZONTAL_ALIGNMENT_LEFT
		botao.add_theme_font_size_override("font_size", 8)
		botao.pressed.connect(_escolher.bind(opcao))
		_opcoes.add_child(botao)
	if _opcoes.get_child_count() > 0:
		(_opcoes.get_child(0) as Button).grab_focus()
	else:
		_continuar.show()


func _escolher(opcao: Dictionary) -> void:
	AudioManager.tocar("escolha", 1.0, -6.0)
	_aplicar_efeitos(opcao)
	_ir_para(opcao.get("proximo"))


func _aplicar_efeitos(dados: Dictionary) -> void:
	if dados.has("flag"):
		GameState.set_flag(dados["flag"])
	if dados.has("remover_item"):
		var item: Dictionary = dados["remover_item"]
		GameState.remover_item(item["id"], int(item.get("quantidade", 1)))
	var recompensa: Dictionary = dados.get("recompensa", {})
	if recompensa.has("sementes"):
		GameState.adicionar_sementes(int(recompensa["sementes"]))
	if recompensa.has("caju"):
		GameState.curar(int(recompensa["caju"]))
	if recompensa.has("pagina"):
		GameState.coletar_pagina(recompensa["pagina"])
	if recompensa.has("fragmento"):
		GameState.coletar_fragmento(int(recompensa["fragmento"]))


func _encerrar() -> void:
	ativo = false
	_digitando = false
	Narracao.calar()
	_limpar_opcoes()
	_painel.hide()
	if is_instance_valid(_jogador) and _jogador.has_method("sair_dialogo"):
		_jogador.sair_dialogo()
	dialogo_terminado.emit(_id)


func _limpar_opcoes() -> void:
	for filho in _opcoes.get_children():
		_opcoes.remove_child(filho)
		filho.queue_free()


func _formatar(texto: String) -> String:
	return texto.replace("{nome}", GameState.nome_protagonista)


func _carregar(arquivo: String) -> Dictionary:
	if not _cache.has(arquivo):
		var dados: Variant = JSON.parse_string(FileAccess.get_file_as_string(arquivo))
		if typeof(dados) != TYPE_DICTIONARY:
			push_error("Não foi possível ler os diálogos em %s" % arquivo)
			dados = {}
		_cache[arquivo] = dados
	return _cache[arquivo]


func _construir_interface() -> void:
	_painel = PanelContainer.new()
	_painel.anchor_left = 0.0
	_painel.anchor_right = 1.0
	_painel.anchor_top = 1.0
	_painel.anchor_bottom = 1.0
	_painel.offset_left = 8
	_painel.offset_right = -8
	_painel.offset_top = -58
	_painel.offset_bottom = -6
	_painel.grow_vertical = Control.GROW_DIRECTION_BEGIN

	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color("2b1a12e6")
	estilo.border_color = Color("e8b04a")
	estilo.set_border_width_all(1)
	estilo.set_content_margin_all(5)
	_painel.add_theme_stylebox_override("panel", estilo)
	_painel.mouse_filter = Control.MOUSE_FILTER_STOP
	_painel.gui_input.connect(_on_painel_gui_input)
	add_child(_painel)

	# Textos deixam o toque passar para o painel; só os botões de opção o seguram.
	var coluna := VBoxContainer.new()
	coluna.add_theme_constant_override("separation", 2)
	coluna.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_painel.add_child(coluna)

	_nome = Label.new()
	_nome.add_theme_font_size_override("font_size", 8)
	_nome.add_theme_color_override("font_color", Color("f4c95d"))
	coluna.add_child(_nome)

	_texto = RichTextLabel.new()
	_texto.bbcode_enabled = false
	_texto.fit_content = true
	_texto.scroll_active = false
	_texto.custom_minimum_size = Vector2(0, 22)
	_texto.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_texto.add_theme_font_size_override("normal_font_size", 8)
	coluna.add_child(_texto)

	_opcoes = VBoxContainer.new()
	_opcoes.add_theme_constant_override("separation", 1)
	_opcoes.mouse_filter = Control.MOUSE_FILTER_IGNORE
	coluna.add_child(_opcoes)

	_continuar = Label.new()
	_continuar.text = ">>"
	_continuar.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_continuar.add_theme_font_size_override("font_size", 8)
	_continuar.add_theme_color_override("font_color", Color("e8b04a"))
	coluna.add_child(_continuar)
