extends Node
## Estado global da partida (autoload "GameState").
##
## Guarda colecionáveis, vida (cajus), itens de missão, flags de diálogo
## e registra os controles do jogo caso não tenham sido definidos no editor.

signal sementes_mudou(total: int)
signal cajus_mudou(atual: int, maximo: int)
signal itens_mudou(id: String, quantidade: int)
signal pagina_coletada(id: String)
signal fragmento_coletado(fase: int)
signal jogador_morreu

const CAJUS_MAX := 5
const TOTAL_FRAGMENTOS := 4

## "Chico" ou "Luzia" — usado nos diálogos através de {nome}.
var nome_protagonista := "Chico"
## Celular/tablet: mostra os controles na tela e troca as dicas de teclado.
var toque := DisplayServer.is_touchscreen_available()
var sementes := 0
var cajus := CAJUS_MAX
var itens := {}
var paginas: Array[String] = []
var fragmentos: Array[int] = []
var flags := {}


func _ready() -> void:
	_registrar_controles()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("tela_cheia"):
		alternar_tela_cheia()
		get_viewport().set_input_as_handled()


# --- Tela cheia --------------------------------------------------------------

func tela_cheia_ativa() -> bool:
	return DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN


func alternar_tela_cheia() -> void:
	var modo := DisplayServer.WINDOW_MODE_WINDOWED if tela_cheia_ativa() else DisplayServer.WINDOW_MODE_FULLSCREEN
	DisplayServer.window_set_mode(modo)


# --- Sementes de carnaúba (moeda) -------------------------------------------

func adicionar_sementes(quantidade: int) -> void:
	sementes += quantidade
	sementes_mudou.emit(sementes)


# --- Vida (cajus) ------------------------------------------------------------

func perder_caju(quantidade := 1) -> void:
	if cajus <= 0:
		return
	cajus = maxi(cajus - quantidade, 0)
	cajus_mudou.emit(cajus, CAJUS_MAX)
	if cajus == 0:
		jogador_morreu.emit()


func curar(quantidade := 1) -> void:
	cajus = mini(cajus + quantidade, CAJUS_MAX)
	cajus_mudou.emit(cajus, CAJUS_MAX)


func restaurar_cajus() -> void:
	cajus = CAJUS_MAX
	cajus_mudou.emit(cajus, CAJUS_MAX)


# --- Itens de missão (ex.: mudas de algodão) --------------------------------

func adicionar_item(id: String, quantidade := 1) -> void:
	itens[id] = quantidade_item(id) + quantidade
	itens_mudou.emit(id, itens[id])


func remover_item(id: String, quantidade := 1) -> void:
	itens[id] = maxi(quantidade_item(id) - quantidade, 0)
	itens_mudou.emit(id, itens[id])


func quantidade_item(id: String) -> int:
	return itens.get(id, 0)


# --- Almanaque e Livro do Tempo ---------------------------------------------

func coletar_pagina(id: String) -> void:
	if id in paginas:
		return
	paginas.append(id)
	pagina_coletada.emit(id)


func coletar_fragmento(fase: int) -> void:
	if fase in fragmentos:
		return
	fragmentos.append(fase)
	fragmento_coletado.emit(fase)


# --- Flags de diálogo/missão -------------------------------------------------

func set_flag(nome: String, valor := true) -> void:
	flags[nome] = valor


func get_flag(nome: String) -> bool:
	return flags.get(nome, false)


## Escolhe a dica certa para o aparelho: teclado ou tela de toque.
func dica(teclado: String, tela: String) -> String:
	return tela if toque else teclado


# --- Controles -----------------------------------------------------------------

## Cria as ações de entrada por código para o projeto rodar sem configurar
## nada no editor. Ações já definidas em Projeto > Mapa de Entrada são mantidas.
func _registrar_controles() -> void:
	var teclas := {
		"mover_esquerda": [KEY_A, KEY_LEFT],
		"mover_direita": [KEY_D, KEY_RIGHT],
		"pular": [KEY_SPACE, KEY_W, KEY_UP],
		"interagir": [KEY_E, KEY_ENTER],
		"almanaque": [KEY_TAB, KEY_Q],
		"tela_cheia": [KEY_F11, KEY_F],
		"mudo": [KEY_M],
	}
	var botoes := {
		"mover_esquerda": [JOY_BUTTON_DPAD_LEFT],
		"mover_direita": [JOY_BUTTON_DPAD_RIGHT],
		"pular": [JOY_BUTTON_A],
		"interagir": [JOY_BUTTON_X],
		"almanaque": [JOY_BUTTON_BACK],
		"tela_cheia": [JOY_BUTTON_START],
		"mudo": [],
	}
	var eixos := {"mover_esquerda": -1.0, "mover_direita": 1.0}

	for acao: String in teclas:
		if InputMap.has_action(acao):
			continue
		InputMap.add_action(acao, 0.3)
		for tecla: Key in teclas[acao]:
			var evento := InputEventKey.new()
			evento.physical_keycode = tecla
			InputMap.action_add_event(acao, evento)
		for botao: JoyButton in botoes[acao]:
			var evento := InputEventJoypadButton.new()
			evento.button_index = botao
			InputMap.action_add_event(acao, evento)
		if eixos.has(acao):
			var evento := InputEventJoypadMotion.new()
			evento.axis = JOY_AXIS_LEFT_X
			evento.axis_value = eixos[acao]
			InputMap.action_add_event(acao, evento)
