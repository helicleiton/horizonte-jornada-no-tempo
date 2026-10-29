extends Control
## Tela de abertura: título, JOGAR, opções (tela cheia e narração) e créditos.

var _botao_tela_cheia: Button
var _botao_som: Button
var _botao_narracao: Button
var _painel_creditos: Control
var _selecao_personagem: Control
var _selecao_fases: Control
var _botao_instalar: Button
var _tempo_instalar := 0.0
var _proxima_fase := FASE_1

const CONTATO := "https://wa.me/5585994252561"
const SITE := "https://helicleiton.com"
const FASE_1 := "res://scenes/levels/fase_teste.tscn"
const FASE_2 := "res://scenes/levels/fase2.tscn"
const FASE_2B := "res://scenes/levels/fase2b.tscn"
const FASE_3 := "res://scenes/levels/fase3.tscn"
const FASE_4 := "res://scenes/levels/fase4.tscn"
const FASE_5 := "res://scenes/levels/fase5.tscn"
const FASE_6 := "res://scenes/levels/fase6.tscn"
const FASE_7 := "res://scenes/levels/fase7.tscn"
const FASE_CARRO := "res://scenes/levels/fase_carro.tscn"

## Nome de cada fase, como aparece na lista de fases do menu.
const FASES := [
	[FASE_1, "Fase 1 · Onde tudo começou (1932)"],
	[FASE_2, "Fase 2 · A luta pela cidade (1987)"],
	[FASE_2B, "Fase 2b · A primeira eleição (1988)"],
	[FASE_3, "Fase 3 · Fábricas e trabalho (1990)"],
	[FASE_4, "Fase 4 · Plantar o futuro (hoje)"],
	[FASE_5, "Fase 5 · A cidade que se reinventa"],
	[FASE_6, "Fase 6 · As águas de Horizonte"],
	[FASE_7, "Fase 7 · Festa de São João"],
	[FASE_CARRO, "Fase 8 · Dirigindo pela cidade"],
]


func _ready() -> void:
	# Letras pequenas, no mesmo tamanho do HUD, para a tela caber em 320×180.
	var tema := Theme.new()
	tema.default_font_size = 8
	theme = tema

	var fundo := ColorRect.new()
	fundo.color = Color(0.12, 0.08, 0.05) # marrom escuro sertanejo
	fundo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(fundo)

	# Bandeira de Horizonte em pixel art, no canto da tela de abertura.
	var bandeira := TextureRect.new()
	bandeira.texture = load("res://assets/sprites/bandeira_horizonte.png")
	bandeira.position = Vector2(6, 6)
	bandeira.size = Vector2(48, 36)
	bandeira.stretch_mode = TextureRect.STRETCH_SCALE
	bandeira.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(bandeira)

	var vbox := _coluna_centralizada(self)
	var titulo := _rotulo(vbox, "HORIZONTE", Color(1.0, 0.85, 0.3), HORIZONTAL_ALIGNMENT_CENTER)
	titulo.add_theme_font_size_override("font_size", 16)
	_rotulo(vbox, "Jornada Através do Tempo · em desenvolvimento", Color(0.9, 0.9, 0.9), HORIZONTAL_ALIGNMENT_CENTER)
	_espaco(vbox, 6)
	_botao(vbox, "JOGAR (FASE 1)", _on_jogar_pressed)
	_botao(vbox, "ESCOLHER FASE", _mostrar_fases)
	_botao(vbox, "CRÉDITO & FONTES", _on_creditos_pressed)
	var linha_opcoes := HBoxContainer.new()
	vbox.add_child(linha_opcoes)
	_botao_tela_cheia = _botao_atalho_livre(linha_opcoes, GameState.alternar_tela_cheia)
	_botao_som = _botao_atalho_livre(linha_opcoes, _alternar_som)
	var linha_narracao := HBoxContainer.new()
	vbox.add_child(linha_narracao)
	_botao_narracao = _botao_atalho_livre(linha_narracao, _alternar_narracao)
	_botao_atalho_livre(linha_narracao, _sair_do_jogo).text = "SAIR"
	_atualizar_opcoes()

	if OS.has_feature("web"):
		# Guarda o convite de instalação do navegador, para o botão do menu usar.
		JavaScriptBridge.eval("window.addEventListener('beforeinstallprompt', function (e) { e.preventDefault(); window.deferredPrompt = e; });")
		_botao_instalar = Button.new()
		_botao_instalar.text = "INSTALAR APP"
		_botao_instalar.custom_minimum_size = Vector2(92, 16)
		_botao_instalar.position = Vector2(214, 158)
		_botao_instalar.visible = false
		_botao_instalar.pressed.connect(_instalar_app)
		add_child(_botao_instalar)

	if OS.has_feature("web") and JavaScriptBridge.eval("/iPhone|iPad|iPod/.test(navigator.userAgent) && !window.navigator.standalone"):
		_construir_dica_iphone()

	_construir_selecao()
	_construir_fases()
	_construir_creditos()


func _process(delta: float) -> void:
	# A tela cheia também pode mudar pela tecla F11, então o texto é conferido sempre.
	_atualizar_opcoes()
	if _botao_instalar:
		_tempo_instalar += delta
		if _tempo_instalar > 1.0:
			_tempo_instalar = 0.0
			_botao_instalar.visible = JavaScriptBridge.eval("!!window.deferredPrompt")


## No iPhone o navegador não mostra o convite de instalação: a dica ensina como fazer.
func _construir_dica_iphone() -> void:
	var fundo := ColorRect.new()
	fundo.color = Color(0.08, 0.05, 0.03, 0.92)
	fundo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fundo.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(fundo)
	var centro := CenterContainer.new()
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(centro)
	var painel := PanelContainer.new()
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color("2b1a12")
	estilo.border_color = Color("e8b04a")
	estilo.set_border_width_all(2)
	estilo.set_content_margin_all(8)
	painel.add_theme_stylebox_override("panel", estilo)
	painel.custom_minimum_size = Vector2(230, 0)
	centro.add_child(painel)
	var coluna := VBoxContainer.new()
	coluna.add_theme_constant_override("separation", 6)
	painel.add_child(coluna)
	var texto := Label.new()
	texto.text = "Para jogar como app no iPhone:
1. Toque no botão Compartilhar (quadrado com seta para cima), na barra do Safari.
2. Role e toque em \"Adicionar à Tela de Início\".
3. Abra o jogo pelo ícone da Horizonte."
	texto.autowrap_mode = TextServer.AUTOWRAP_WORD
	texto.custom_minimum_size = Vector2(214, 0)
	texto.add_theme_color_override("font_color", Color("fff3c4"))
	coluna.add_child(texto)
	var ok := Button.new()
	ok.text = "ENTENDI"
	ok.custom_minimum_size = Vector2(120, 18)
	ok.pressed.connect(fundo.queue_free)
	ok.pressed.connect(centro.queue_free)
	coluna.add_child(ok)


## Abre o convite do navegador para instalar o jogo na tela inicial do celular.
func _instalar_app() -> void:
	JavaScriptBridge.eval("if (window.deferredPrompt) { window.deferredPrompt.prompt(); window.deferredPrompt = null; }")
	_botao_instalar.visible = false


func _on_jogar_pressed() -> void:
	AudioManager.tocar("escolha")
	_selecao_personagem.visible = true


## Lista de fases com nome, para o aluno escolher por onde começar.
func _construir_fases() -> void:
	_selecao_fases = _tela_cobrindo_tudo(Color(0.08, 0.05, 0.03))
	# Lista com rolagem: a tela de 320x180 não cabe todas as fases de uma vez.
	var rolagem := ScrollContainer.new()
	rolagem.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	rolagem.offset_left = 60
	rolagem.offset_right = -60
	rolagem.offset_top = 8
	rolagem.offset_bottom = -8
	_selecao_fases.add_child(rolagem)
	var vbox := VBoxContainer.new()
	vbox.custom_minimum_size = Vector2(200, 0)
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rolagem.add_child(vbox)
	_rotulo(vbox, "Qual parte da história você quer viver?", Color(1.0, 0.85, 0.3), HORIZONTAL_ALIGNMENT_CENTER)
	_espaco(vbox, 4)
	for fase in FASES:
		_botao(vbox, fase[1], _escolher_fase.bind(fase[0]))
	_botao(vbox, "Jogo da memória: teste o que sabe", func() -> void: get_tree().change_scene_to_file("res://scenes/ui/memoria.tscn"))
	_botao(vbox, "Voltar", func() -> void: _selecao_fases.visible = false)


func _mostrar_fases() -> void:
	AudioManager.tocar("escolha")
	_selecao_fases.visible = true


## Escolhida a fase, pede o protagonista e depois abre a fase.
func _escolher_fase(caminho: String) -> void:
	_selecao_fases.visible = false
	_proxima_fase = caminho
	_on_jogar_pressed()


func _on_creditos_pressed() -> void:
	AudioManager.tocar("escolha")
	_painel_creditos.visible = true


## Sai do jogo: no navegador volta ao site; no computador fecha o programa e abre o site.
func _sair_do_jogo() -> void:
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.location.href = '%s';" % SITE)
	else:
		OS.shell_open(SITE)
		get_tree().quit()


func _alternar_narracao() -> void:
	Narracao.ligada = not Narracao.ligada
	if not Narracao.ligada:
		Narracao.calar()
	_atualizar_opcoes()


func _alternar_som() -> void:
	AudioManager.alternar_mudo()
	_atualizar_opcoes()


## Botão de metade de linha, para ficar lado a lado com outro.
func _botao_atalho_livre(pai: Node, acao: Callable) -> Button:
	var botao := Button.new()
	botao.custom_minimum_size = Vector2(98, 18)
	botao.pressed.connect(acao)
	pai.add_child(botao)
	return botao


func _atualizar_opcoes() -> void:
	_botao_som.text = "SOM: " + ("NÃO" if AudioManager.mudo else "SIM")
	_botao_tela_cheia.text = "TELA CHEIA: " + ("SIM" if GameState.tela_cheia_ativa() else "NÃO")
	_botao_narracao.text = "NARRAÇÃO: " + ("SIM" if Narracao.ligada else "NÃO")


func _construir_selecao() -> void:
	_selecao_personagem = _tela_cobrindo_tudo(Color(0.08, 0.05, 0.03))
	var vbox := _coluna_centralizada(_selecao_personagem)

	_rotulo(vbox, "Escolha seu Protagonista:", Color(1.0, 0.85, 0.3), HORIZONTAL_ALIGNMENT_CENTER)
	_espaco(vbox, 10)
	_botao(vbox, "Chico (Pesquisador)", func() -> void: _iniciar_jogo("Chico"))
	_botao(vbox, "Luzia (Historiadora)", func() -> void: _iniciar_jogo("Luzia"))
	_botao(vbox, "Voltar", func() -> void: _selecao_personagem.visible = false)


func _construir_creditos() -> void:
	_painel_creditos = _tela_cobrindo_tudo(Color(0.05, 0.05, 0.05, 0.98))
	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 15
	vbox.offset_right = -15
	vbox.offset_top = 10
	vbox.offset_bottom = -10
	_painel_creditos.add_child(vbox)

	_rotulo(vbox, "CRÉDITOS & FONTES HISTÓRICAS", Color(1.0, 0.85, 0.3), HORIZONTAL_ALIGNMENT_CENTER)

	var rolagem := ScrollContainer.new()
	rolagem.custom_minimum_size = Vector2(290, 115)
	vbox.add_child(rolagem)

	var texto := Label.new()
	texto.text = """• Jogo educativo sobre a história e cultura de Horizonte (CE).
• Engine: Godot 4.7 (Renderer Compatibilidade).

ARTE E SOM:
• Pixel art original gerada por código (ferramentas internas).
• Plantas do sertão CC0 (OpenGameArt / ScratchIO).
• Gravações de áudio CC0 (Freesound / Kenney).
• Narração com a voz do próprio aparelho (síntese de voz).

CONTEÚDO HISTÓRICO E FONTES:
• Livro didático: "Horizonte: Do Olho d'Água do Venâncio ao Horizonte das Indústrias".
• Prefeitura Municipal de Horizonte e IBGE Cidades.
• Dissertação de Mestrado (UFC, 2012) - Marlene P. dos Santos (Comunidade Alto-Alegre).
• Projeto Bordando Memórias (Clic Horizonte) e Mapa Mental da História de Horizonte.

DESENVOLVIMENTO:
• Desenvolvido por @helicleiton.
• Criado para a comunidade e estudantes de Horizonte-CE.

EM DESENVOLVIMENTO:
• Novas fases e personagens estão sendo criados. Sugestões de tema ou personagem: WhatsApp 85 99425-2561."""
	texto.autowrap_mode = TextServer.AUTOWRAP_WORD
	texto.custom_minimum_size = Vector2(270, 0)
	texto.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	rolagem.add_child(texto)

	_espaco(vbox, 5)
	_botao(vbox, "SUGERIR TEMA OU PERSONAGEM", func() -> void:
		OS.shell_open(CONTATO))
	_botao(vbox, "VOLTAR", func() -> void:
		AudioManager.tocar("escolha")
		_painel_creditos.visible = false)


## Coluna de botões no centro da tela, com largura fixa para os botões.
func _coluna_centralizada(pai: Node) -> VBoxContainer:
	var centro := CenterContainer.new()
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pai.add_child(centro)
	var vbox := VBoxContainer.new()
	vbox.custom_minimum_size = Vector2(200, 0)
	centro.add_child(vbox)
	return vbox


func _tela_cobrindo_tudo(cor: Color) -> Control:
	var tela := Control.new()
	tela.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tela.visible = false
	add_child(tela)
	var fundo := ColorRect.new()
	fundo.color = cor
	fundo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tela.add_child(fundo)
	return tela


func _rotulo(pai: Node, texto: String, cor: Color, alinhamento: HorizontalAlignment) -> Label:
	var rotulo := Label.new()
	rotulo.text = texto
	rotulo.horizontal_alignment = alinhamento
	rotulo.add_theme_color_override("font_color", cor)
	pai.add_child(rotulo)
	return rotulo


func _espaco(pai: Node, altura: float) -> void:
	var espaco := Control.new()
	espaco.custom_minimum_size = Vector2(0, altura)
	pai.add_child(espaco)


func _botao(pai: Node, texto: String, acao: Callable) -> Button:
	var botao := Button.new()
	botao.text = texto
	botao.custom_minimum_size = Vector2(200, 18)
	botao.pressed.connect(acao)
	pai.add_child(botao)
	return botao


func _iniciar_jogo(nome: String) -> void:
	GameState.nome_protagonista = nome
	AudioManager.tocar("escolha")
	get_tree().change_scene_to_file(_proxima_fase)
