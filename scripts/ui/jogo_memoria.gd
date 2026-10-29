extends Control
## Jogo da memória da história de Horizonte: cada fato combina com a sua data.
## Vire duas cartas; se formarem um par (fato + data), elas ficam visíveis.

const PARES := [
	["Canal do Trabalhador", "1993"],
	["Lei nº 11.300 da emancipação", "1987"],
	["Instalação do município", "1989"],
	["Nome Horizonte", "1938"],
	["Alto Alegre reconhecido", "2005"],
	["Parque das Águas", "2022"],
]
const MENU := "res://scenes/ui/menu_inicial.tscn"

var _cartas: Array[Button] = []
var _valores: Array[String] = []
var _virada: Array[int] = []
var _acertos := 0
var _aviso: Label
var _bloqueado := false


func _ready() -> void:
	var fundo := ColorRect.new()
	fundo.color = Color(0.12, 0.08, 0.05)
	fundo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(fundo)

	var tema := Theme.new()
	tema.default_font_size = 8
	theme = tema

	var coluna := VBoxContainer.new()
	coluna.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	coluna.offset_left = 8
	coluna.offset_right = -8
	coluna.offset_top = 6
	coluna.offset_bottom = -6
	add_child(coluna)

	var titulo := Label.new()
	titulo.text = "JOGO DA MEMÓRIA"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.add_theme_color_override("font_color", Color("f4c95d"))
	coluna.add_child(titulo)

	var grade := GridContainer.new()
	grade.columns = 4
	grade.add_theme_constant_override("h_separation", 4)
	grade.add_theme_constant_override("v_separation", 4)
	coluna.add_child(grade)

	var valores: Array[String] = []
	for par in PARES:
		valores.append(par[0])
		valores.append(par[1])
	valores.shuffle()
	for i in valores.size():
		var carta := Button.new()
		carta.text = "?"
		carta.custom_minimum_size = Vector2(70, 30)
		carta.pressed.connect(_virar.bind(i))
		grade.add_child(carta)
		_cartas.append(carta)
		_valores.append(valores[i])

	_aviso = Label.new()
	_aviso.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_aviso.add_theme_color_override("font_color", Color("f0e2b6"))
	coluna.add_child(_aviso)

	var voltar := Button.new()
	voltar.text = "VOLTAR"
	voltar.pressed.connect(func() -> void: get_tree().change_scene_to_file(MENU))
	coluna.add_child(voltar)


func _virar(i: int) -> void:
	if _bloqueado or _virada.has(i) or _cartas[i].text != "?":
		return
	_cartas[i].text = _valores[i]
	_virada.append(i)
	if _virada.size() < 2:
		return
	var a := _virada[0]
	var b := _virada[1]
	if _par(_valores[a], _valores[b]):
		_acertos += 1
		_virada.clear()
		_aviso.text = "Par encontrado! (%d/%d)" % [_acertos, PARES.size()]
		if _acertos == PARES.size():
			_aviso.text = "Você encontrou todos os pares! Ganhou 5 sementes."
			GameState.adicionar_sementes(5)
	else:
		_bloqueado = true
		_aviso.text = "Não combinam. Tente de novo."
		await get_tree().create_timer(1.0).timeout
		_cartas[a].text = "?"
		_cartas[b].text = "?"
		_virada.clear()
		_bloqueado = false


## Um fato e a sua data formam um par.
func _par(x: String, y: String) -> bool:
	for par in PARES:
		if (par[0] == x and par[1] == y) or (par[0] == y and par[1] == x):
			return true
	return false
