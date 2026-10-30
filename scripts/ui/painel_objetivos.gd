class_name PainelObjetivos
extends Control
## Lista de objetivos da fase no canto superior esquerdo, logo abaixo dos cajus.
## O cabeçalho recolhe e expande a lista. Ao concluir um objetivo, emite "concluiu"
## (o HUD mostra o aviso e toca um som); ao concluir todos, emite "fase_concluida".

signal concluiu(texto: String)
signal fase_concluida

## Número da fase (1 ou 2): define quais objetivos aparecem.
var fase := 1

var _cabecalho: Button
var _lista: Label
var _feitos: Array[bool] = []
var _terminada := false


func _ready() -> void:
	position = Vector2(6, 20)

	var painel := PanelContainer.new()
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color("2b1a12f2")
	estilo.border_color = Color("e8b04a")
	estilo.set_border_width_all(1)
	estilo.set_content_margin_all(4)
	painel.add_theme_stylebox_override("panel", estilo)
	add_child(painel)

	var coluna := VBoxContainer.new()
	coluna.add_theme_constant_override("separation", 2)
	painel.add_child(coluna)

	_cabecalho = Button.new()
	_cabecalho.flat = true
	_cabecalho.alignment = HORIZONTAL_ALIGNMENT_LEFT
	_cabecalho.add_theme_font_size_override("font_size", 8)
	_cabecalho.add_theme_color_override("font_color", Color("f4c95d"))
	_cabecalho.add_theme_color_override("font_outline_color", Color("2b1a12"))
	_cabecalho.add_theme_constant_override("outline_size", 3)
	_cabecalho.pressed.connect(_alternar_lista)
	coluna.add_child(_cabecalho)

	_lista = Label.new()
	_lista.add_theme_font_size_override("font_size", 8)
	_lista.add_theme_color_override("font_color", Color("fff3c4"))
	_lista.add_theme_color_override("font_outline_color", Color("2b1a12"))
	_lista.add_theme_constant_override("outline_size", 3)
	_lista.autowrap_mode = TextServer.AUTOWRAP_WORD
	_lista.custom_minimum_size = Vector2(190, 0)
	coluna.add_child(_lista)

	_feitos.resize(_avaliar().size())
	_feitos.fill(false)


func _process(_delta: float) -> void:
	var agora := _avaliar()
	for i in agora.size():
		if agora[i].feito and not _feitos[i]:
			concluiu.emit("Objetivo concluído: " + agora[i].texto)
			AudioManager.tocar("fragmento")
		_feitos[i] = agora[i].feito
	if not _terminada and agora.all(func(o: Dictionary) -> bool: return o.feito):
		_terminada = true
		fase_concluida.emit()
	_atualizar_texto(agora)


func _alternar_lista() -> void:
	_lista.visible = not _lista.visible
	_atualizar_texto(_avaliar())


## Cada objetivo: texto para o jogador e se já foi concluído.
func _avaliar() -> Array[Dictionary]:
	match fase:
		2:
			return _objetivos_fase2()
		3:
			return _objetivos_fase3()
		4:
			return _objetivos_fase4()
		5:
			return _objetivos_fase2b()
		6:
			return _objetivos_fase5()
		7:
			return _objetivos_fase6()
		8:
			return _objetivos_fase7()
		9:
			return _objetivos_fase8()
		10:
			return _objetivos_fase9()
		11:
			return _objetivos_fase10()
	return _objetivos_fase1()


func _objetivos_fase6() -> Array[Dictionary]:
	return [
		{"texto": "Converse com o guarda do parque", "feito": GameState.get_flag("falou_guarda")},
		{"texto": "Ouça a comunidade do Alto Alegre", "feito": GameState.get_flag("falou_alto_alegre")},
		{"texto": "Responda ao quiz das águas", "feito": GameState.get_flag("quiz_parque_ok")},
	]


func _objetivos_fase7() -> Array[Dictionary]:
	var bandeirinhas := GameState.quantidade_item("bandeirinha")
	return [
		{"texto": "Converse com o mestre da quadrilha", "feito": GameState.get_flag("falou_mestre")},
		{"texto": "Junte 5 bandeirinhas (%d/5)" % mini(bandeirinhas, 5), "feito": GameState.get_flag("entregou_bandeirinhas")},
		{"texto": "Fale com Seu Antônio sobre a procissão", "feito": GameState.get_flag("falou_antonio")},
	]


func _objetivos_fase8() -> Array[Dictionary]:
	return [
		{"texto": "Converse com o agente do Demutran", "feito": GameState.get_flag("falou_agente")},
		{"texto": "Responda às perguntas de trânsito", "feito": GameState.get_flag("quiz_transito_ok")},
		{"texto": "Chegue ao fim da rua", "feito": GameState.get_flag("chegou_destino")},
	]


func _objetivos_fase9() -> Array[Dictionary]:
	return [
		{"texto": "Converse com Dona Rosa sobre a pandemia", "feito": GameState.get_flag("falou_rosa")},
		{"texto": "Ouça Seu Lauro sobre o polo", "feito": GameState.get_flag("falou_lauro")},
		{"texto": "Responda ao quiz com a Professora Lia", "feito": GameState.get_flag("quiz_recente_ok")},
	]


func _objetivos_fase10() -> Array[Dictionary]:
	return [
		{"texto": "Ouça a guardiã da memória", "feito": GameState.get_flag("falou_guardia")},
		{"texto": "Responda ao quiz das lideranças", "feito": GameState.get_flag("quiz_lideres_ok")},
	]


func _objetivos_fase5() -> Array[Dictionary]:
	return [
		{"texto": "Ouça a história da Troller com Seu Raimundo", "feito": GameState.get_flag("falou_raimundo")},
		{"texto": "Conheça o polo com Dona Terezinha", "feito": GameState.get_flag("falou_terezinha")},
		{"texto": "Responda às perguntas da estudante Bia", "feito": GameState.get_flag("quiz_crescimento_ok")},
	]


func _objetivos_fase4() -> Array[Dictionary]:
	var mudas := GameState.quantidade_item("muda_plantio")
	return [
		{"texto": "Recolha 4 mudas para plantar (%d/4)" % mini(mudas, 4), "feito": mudas >= 4 or GameState.get_flag("plantio_ok")},
		{"texto": "Entregue as mudas ao Seu Tião", "feito": GameState.get_flag("plantio_ok")},
		{"texto": "Separe o lixo certo com a Dona Marta", "feito": GameState.get_flag("coleta_ok")},
		{"texto": "Receba o Fragmento de Memória 4 da professora Helena", "feito": GameState.fragmentos.has(4)},
	]


func _objetivos_fase2b() -> Array[Dictionary]:
	var santinhos := GameState.quantidade_item("santinho")
	return [
		{"texto": "Converse com Seu Expedito sobre a campanha", "feito": GameState.get_flag("falou_campanha")},
		{"texto": "Entregue 3 santinhos ao Seu Expedito (%d/3)" % mini(santinhos, 3),
			"feito": GameState.get_flag("santinhos_distribuidos")},
		{"texto": "Aprenda como se votava em 1988, com Dona Ilda", "feito": GameState.get_flag("votacao_ok")},
		{"texto": "Ouça o resultado com Seu Nonato", "feito": GameState.get_flag("resultado_ouvido")},
	]


func _objetivos_fase3() -> Array[Dictionary]:
	var caixas := GameState.quantidade_item("caixa_calcado")
	return [
		{"texto": "Converse com Dona Socorro, da fábrica", "feito": GameState.get_flag("falou_socorro")},
		{"texto": "Converse com o engenheiro Paulo", "feito": GameState.get_flag("falou_paulo")},
		{"texto": "Junte 3 caixas de calçado (%d/3)" % mini(caixas, 3),
			"feito": caixas >= 3 or GameState.get_flag("caixas_entregues")},
		{"texto": "Receba o Fragmento de Memória 3", "feito": GameState.fragmentos.has(3)},
	]


func _objetivos_fase1() -> Array[Dictionary]:
	var entregues := GameState.get_flag("mudas_entregues")
	var mudas := GameState.quantidade_item("muda_algodao")
	return [
		{"texto": "Ache as 5 mudas de algodão (%d/5)" % mudas, "feito": entregues or mudas >= 5},
		{"texto": "Entregue as mudas à Dona Mariinha", "feito": entregues},
		{"texto": "Converse com Seu Zeca e Seu Venâncio",
			"feito": GameState.get_flag("falou_zeca") and GameState.get_flag("falou_venancio")},
		{"texto": "Vença o desafio da Vó Bastiana", "feito": GameState.get_flag("fragmento_1")},
	]


func _objetivos_fase2() -> Array[Dictionary]:
	var votos := GameState.quantidade_item("voto_apoio")
	return [
		{"texto": "Recolha 3 votos de apoio (%d/3)" % mini(votos, 3), "feito": votos >= 3},
		{"texto": "Fale com Seu Expedito, da Sahori", "feito": GameState.get_flag("falou_expedito")},
		{"texto": "Responda à Dona Lúcia sobre a Lei 11.300", "feito": GameState.get_flag("enigma_lei_ok")},
		{"texto": "Receba o Fragmento de Memória 2", "feito": GameState.fragmentos.has(2)},
	]


func _atualizar_texto(objetivos: Array[Dictionary]) -> void:
	var seta := "[-]" if _lista.visible else "[+]"
	_cabecalho.text = "OBJETIVOS " + seta
	if not _lista.visible:
		return
	var linhas: Array[String] = []
	for objetivo in objetivos:
		linhas.append("[%s] %s" % ["x" if objetivo.feito else " ", objetivo.texto])
	_lista.text = "\n".join(linhas)
