extends Node
## Teste de fumaça da Fase 1. Rodar: godot --headless --path . res://tests/smoke_test.tscn

var falhas := 0

func check(cond: bool, msg: String) -> void:
	print(("OK   " if cond else "FALHA ") + msg)
	if not cond:
		falhas += 1

func frames(n: int) -> void:
	for i in n:
		await get_tree().physics_frame

func _ready() -> void:
	var fase: Node = load("res://scenes/levels/fase_teste.tscn").instantiate()
	get_tree().root.add_child.call_deferred(fase)
	await frames(30)
	var gs: Node = get_tree().root.get_node("GameState")
	var db: Node = get_tree().root.get_node("DialogueBox")
	var p: Player = fase.get_node("Jogador")

	check(p.is_on_floor(), "jogador pousa no chão")
	check(db.ativo, "diálogo de abertura iniciou")
	for i in 12:
		db._terminar_fala()
		db._ir_para(db._no_atual.get("proximo"))
	check(not db.ativo and p.estado == Player.Estado.NORMAL, "abertura termina e devolve controle")

	# pulo (após fechar diálogo há 0,2 s de bloqueio de entrada)
	await frames(20)
	Input.action_press("pular")
	await frames(3)
	check(p.velocity.y < 0.0, "pulo sobe")
	Input.action_release("pular")
	await frames(60)

	# NPC Zeca: pergunta de ajuda dá sementes
	var zeca: NPC = fase.get_node("Zeca")
	zeca.interagir(p)
	for n in ["z1", "z2", "z3"]:
		db._terminar_fala(); db._ir_para(db._no_atual.get("proximo"))
	db._terminar_fala()
	check(db._no_atual.has("opcoes"), "menu do Zeca aparece")
	db._escolher(db._no_atual["opcoes"][2])
	db._ir_para("ajuda2")
	check(gs.sementes == 3, "Zeca dá 3 sementes (tem %d)" % gs.sementes)
	db._encerrar()

	# Mariinha: aceitar, coletar 5 mudas, entregar
	var m: NPC = fase.get_node("Mariinha")
	m.interagir(p)
	db._terminar_fala(); db._ir_para("menu"); db._terminar_fala()
	db._escolher(db._no_atual["opcoes"][0])
	check(gs.get_flag("missao_mudas"), "missão das mudas aceita")
	db._encerrar()
	for i in range(1, 6):
		var c: Area2D = fase.get_node("Muda%d" % i)
		c.body_entered.emit(p)
	check(gs.quantidade_item("muda_algodao") == 5, "5 mudas coletadas")
	m.interagir(p)
	check(db._id == "agricultora_mariinha" and db._no_atual.get("fala", "").begins_with("Olha elas"), "Mariinha reconhece as mudas")
	db._terminar_fala(); db._ir_para("entrega2")
	check(gs.get_flag("mudas_entregues") and gs.quantidade_item("muda_algodao") == 0, "entrega consome as mudas")
	db._encerrar()

	# Venâncio
	fase.get_node("Venancio").interagir(p)
	db._terminar_fala(); db._ir_para("v2"); db._ir_para("v3"); db._ir_para("v4")
	check(gs.get_flag("falou_venancio") and "olho_dagua" in gs.paginas, "Venâncio libera página do almanaque")
	db._encerrar()

	# Vó Bastiana: quiz até o fragmento
	fase.get_node("Bastiana").interagir(p)
	check(db._no_atual.get("fala", "").begins_with("Senta"), "Bastiana libera o quiz após as missões")
	for no in ["b2","b3","b4","h1","h2","h3","h4","b5","q1"]:
		db._ir_para(no)
	check("cazuza" in gs.paginas and "paiacus" in gs.paginas, "história de Cazuza libera páginas")
	db._escolher(db._no_atual["opcoes"][0]); check(db._no_atual.has("fala") and db._id == "vo_bastiana", "resposta errada volta à pergunta")
	db._ir_para("q1"); db._escolher(db._no_atual["opcoes"][1])
	db._escolher(db._no_atual["opcoes"][0])
	db._escolher(db._no_atual["opcoes"][2])
	check(1 in gs.fragmentos, "acertar o quiz restaura o Fragmento 1")
	db._encerrar()

	# dano e morte
	p.receber_dano(p.global_position.x + 5)
	check(gs.cajus == 4, "espinho tira 1 caju")
	check(p.estado == Player.Estado.ATORDOADO, "jogador fica atordoado")

	# HUD / almanaque
	var hud: Node = fase.get_node("HUD")
	hud._preencher_almanaque()
	check(hud._texto_almanaque.text.contains("Cazuza"), "almanaque lista páginas coletadas")

	# fim de fase: com as 4 missões concluídas, a tela oferece a Fase 2
	await frames(3)
	check(hud._tela_fim.visible and hud._tela_fim.proxima_cena == "res://scenes/levels/fase2.tscn", "fim da Fase 1 oferece a Fase 2")

	print("---- falhas: %d" % falhas)
	get_tree().quit(falhas)
