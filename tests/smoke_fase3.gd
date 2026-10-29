extends Node
## Teste de fumaça da Fase 3: abertura, conversas, caixas, fragmento 3 e fim de fase.
## Rodar: godot --headless --path . res://tests/smoke_fase3.tscn

var falhas := 0

func check(cond: bool, msg: String) -> void:
	print(("OK   " if cond else "FALHA ") + msg)
	if not cond:
		falhas += 1

func frames(n: int) -> void:
	for i in n:
		await get_tree().physics_frame

func _ready() -> void:
	var fase: Node = load("res://scenes/levels/fase3.tscn").instantiate()
	get_tree().root.add_child.call_deferred(fase)
	await frames(30)
	var gs: Node = get_tree().root.get_node("GameState")
	var db: Node = get_tree().root.get_node("DialogueBox")
	var p: Player = fase.get_node("Jogador")

	check(p.is_on_floor(), "jogador pousa no chão")
	check(db.ativo and db._id == "abertura", "abertura da Fase 3 inicia")
	for i in 4:
		db._terminar_fala()
		db._ir_para(db._no_atual.get("proximo"))
	check(not db.ativo, "abertura termina e devolve controle")

	# Dona Socorro: conversa libera o objetivo
	var socorro: NPC = fase.get_node("Socorro")
	socorro.interagir(p)
	db._terminar_fala()
	db._ir_para("i2")
	db._terminar_fala()
	db._escolher(db._no_atual["opcoes"][1])
	check(gs.get_flag("falou_socorro"), "conversa com Dona Socorro conta como objetivo")
	db._encerrar()

	# Engenheiro Paulo: conversa libera o objetivo
	var paulo: NPC = fase.get_node("Paulo")
	paulo.interagir(p)
	db._terminar_fala()
	db._ir_para("i2")
	db._terminar_fala()
	db._escolher(db._no_atual["opcoes"][1])
	check(gs.get_flag("falou_paulo"), "conversa com o engenheiro conta como objetivo")
	db._encerrar()

	# Caixas de calçado pelo caminho
	for i in range(1, 4):
		var caixa: Area2D = fase.get_node("Caixa%d" % i)
		caixa.body_entered.emit(p)
	check(gs.quantidade_item("caixa_calcado") == 3, "três caixas de calçado coletadas")

	# Dona Socorro recebe as caixas; depois o engenheiro entrega o Fragmento 3
	socorro.interagir(p)
	check(db._no_atual.get("fala", "").begins_with("Ah, as caixas"), "Dona Socorro recebe as caixas")
	db._terminar_fala()
	db._ir_para("recebe2")
	db._terminar_fala()
	db._encerrar()
	check(gs.get_flag("caixas_entregues") and gs.quantidade_item("caixa_calcado") == 0, "entrega consome as caixas")
	paulo.interagir(p)
	check(db._no_atual.get("fala", "").begins_with("Você trouxe"), "engenheiro reconhece a entrega")
	check(3 in gs.fragmentos and "distrito_industrial" in gs.paginas, "fragmento 3 e página do distrito industrial")
	db._terminar_fala()
	db._encerrar()

	# Todos os objetivos concluídos: a tela de fim aparece e pausa o jogo
	await frames(5)
	var hud: Node = fase.get_node("HUD")
	check(hud._tela_fim.visible and get_tree().paused, "fim da Fase 3 aparece com o jogo pausado")
	check(hud._tela_fim.proxima_cena == "res://scenes/levels/fase4.tscn", "Fase 3 leva à Fase 4")
	hud._tela_fim._continuar()
	check(not get_tree().paused, "continuar explorando despausa o jogo")

	print("---- falhas: %d" % falhas)
	get_tree().quit(falhas)
