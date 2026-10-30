extends Node
## Teste de fumaça da Fase 9 (2020 a 2026): conversas, quiz e fim de fase.
## Rodar: godot --headless --path . res://tests/smoke_fase9.tscn

var falhas := 0

func check(cond: bool, msg: String) -> void:
	print(("OK   " if cond else "FALHA ") + msg)
	if not cond:
		falhas += 1

func frames(n: int) -> void:
	for i in n:
		await get_tree().physics_frame

func _ready() -> void:
	var fase: Node = load("res://scenes/levels/fase9.tscn").instantiate()
	get_tree().root.add_child.call_deferred(fase)
	await frames(30)
	var gs: Node = get_tree().root.get_node("GameState")
	var db: Node = get_tree().root.get_node("DialogueBox")
	var p: Player = fase.get_node("Jogador")

	check(p.is_on_floor(), "jogador pousa na fase 9")
	check(db.ativo and db._id == "abertura", "abertura da fase 9 inicia")
	for i in 3:
		db._terminar_fala()
		db._ir_para(db._no_atual.get("proximo"))

	var rosa: NPC = fase.get_node("Rosa")
	rosa.interagir(p)
	db._terminar_fala()
	db._ir_para("i2")
	db._terminar_fala()
	db._escolher(db._no_atual["opcoes"][1])
	check(gs.get_flag("falou_rosa"), "Dona Rosa conta sobre a pandemia")
	db._encerrar()

	var lauro: NPC = fase.get_node("Lauro")
	lauro.interagir(p)
	db._terminar_fala()
	db._ir_para("i2")
	db._terminar_fala()
	db._escolher(db._no_atual["opcoes"][1])
	check(gs.get_flag("falou_lauro") and "anos_2020_2026" in gs.paginas, "Seu Lauro conta sobre o polo e libera a página")
	db._encerrar()

	var lia: NPC = fase.get_node("Lia")
	lia.interagir(p)
	db._terminar_fala()
	db._ir_para("q1")
	db._terminar_fala()
	db._escolher(db._no_atual["opcoes"][0])
	db._terminar_fala()
	db._ir_para("q2")
	db._terminar_fala()
	db._escolher(db._no_atual["opcoes"][0])
	db._terminar_fala()
	db._ir_para("q3")
	db._terminar_fala()
	db._escolher(db._no_atual["opcoes"][0])
	check(gs.get_flag("quiz_recente_ok"), "quiz dos anos recentes marca o objetivo")
	db._encerrar()

	await frames(5)
	var hud: Node = fase.get_node("HUD")
	check(hud._tela_fim.visible and get_tree().paused, "fim da fase 9 aparece com o jogo pausado")
	check(hud._tela_fim.proxima_cena == "", "fase 9 é a última do protótipo")
	hud._tela_fim._continuar()

	print("---- falhas: %d" % falhas)
	get_tree().quit(falhas)
