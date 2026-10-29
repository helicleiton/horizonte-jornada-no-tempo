extends Node
## Teste de fumaça da Fase 4: mudas, plantio, coleta seletiva, último fragmento e fim.
## Rodar: godot --headless --path . res://tests/smoke_fase4.tscn

var falhas := 0

func check(cond: bool, msg: String) -> void:
	print(("OK   " if cond else "FALHA ") + msg)
	if not cond:
		falhas += 1

func frames(n: int) -> void:
	for i in n:
		await get_tree().physics_frame

func _ready() -> void:
	var fase: Node = load("res://scenes/levels/fase4.tscn").instantiate()
	get_tree().root.add_child.call_deferred(fase)
	await frames(30)
	var gs: Node = get_tree().root.get_node("GameState")
	var db: Node = get_tree().root.get_node("DialogueBox")
	var p: Player = fase.get_node("Jogador")

	check(p.is_on_floor(), "jogador pousa no chão")
	check(db.ativo and db._id == "abertura", "abertura da Fase 4 inicia")
	for i in 4:
		db._terminar_fala()
		db._ir_para(db._no_atual.get("proximo"))
	check(not db.ativo, "abertura termina e devolve controle")

	# Seu Tião: conversa, depois entrega de 4 mudas
	var tiao: NPC = fase.get_node("Tiao")
	tiao.interagir(p)
	db._terminar_fala()
	db._ir_para("i2")
	db._terminar_fala()
	db._escolher(db._no_atual["opcoes"][1])
	check(gs.get_flag("falou_tiao"), "conversa com Seu Tião conta como objetivo")
	db._encerrar()

	for i in range(1, 6):
		var muda: Area2D = fase.get_node("Muda%d" % i)
		muda.body_entered.emit(p)
	check(gs.quantidade_item("muda_plantio") == 5, "cinco mudas coletadas")
	tiao.interagir(p)
	check(db._no_atual.get("fala", "").begins_with("Quatro mudas"), "Seu Tião recebe as mudas")
	check(gs.get_flag("plantio_ok") and gs.quantidade_item("muda_plantio") == 1, "entrega consome quatro mudas")
	db._terminar_fala()
	db._encerrar()

	# Dona Marta: acerta o lixo certo
	var marta: NPC = fase.get_node("Marta")
	marta.interagir(p)
	db._terminar_fala()
	db._ir_para("q")
	db._terminar_fala()
	db._escolher(db._no_atual["opcoes"][1])
	check(db._no_atual.get("fala", "").begins_with("Não!"), "lixeira de orgânicos está errada")
	db._terminar_fala()
	db._ir_para("q")
	db._terminar_fala()
	db._escolher(db._no_atual["opcoes"][0])
	check(gs.get_flag("coleta_ok"), "garrafa na lixeira de plástico marca o objetivo")
	check("coleta_seletiva" in gs.paginas, "página da coleta seletiva entra no almanaque")
	db._encerrar()

	# Professora Helena: conversa e último fragmento
	var helena: NPC = fase.get_node("Helena")
	helena.interagir(p)
	db._terminar_fala()
	db._ir_para("i2")
	db._terminar_fala()
	db._escolher(db._no_atual["opcoes"][1])
	db._encerrar()
	helena.interagir(p)
	check(db._no_atual.get("fala", "").begins_with("Você plantou"), "professora entrega o fragmento 4")
	check(4 in gs.fragmentos, "fragmento 4 restaurado")
	db._terminar_fala()
	db._encerrar()

	# Todos os objetivos: fim de fase
	await frames(5)
	var hud: Node = fase.get_node("HUD")
	check(hud._tela_fim.visible and get_tree().paused, "fim da Fase 4 aparece com o jogo pausado")
	check(hud._tela_fim.proxima_cena == "", "Fase 4 é a última do protótipo")
	hud._tela_fim._continuar()
	check(not get_tree().paused, "continuar explorando despausa o jogo")

	print("---- falhas: %d" % falhas)
	get_tree().quit(falhas)
