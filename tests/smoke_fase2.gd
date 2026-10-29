extends Node
## Teste de fumaça da Fase 2: abertura, conversas, votos, enigma e fim de fase.
## Rodar: godot --headless --path . res://tests/smoke_fase2.tscn

var falhas := 0

func check(cond: bool, msg: String) -> void:
	print(("OK   " if cond else "FALHA ") + msg)
	if not cond:
		falhas += 1

func frames(n: int) -> void:
	for i in n:
		await get_tree().physics_frame

func _ready() -> void:
	var fase: Node = load("res://scenes/levels/fase2.tscn").instantiate()
	get_tree().root.add_child.call_deferred(fase)
	await frames(30)
	var gs: Node = get_tree().root.get_node("GameState")
	var db: Node = get_tree().root.get_node("DialogueBox")
	var p: Player = fase.get_node("Jogador")

	check(p.is_on_floor(), "jogador pousa no chão")
	check(db.ativo and db._id == "abertura", "abertura da Fase 2 inicia")
	for i in 4:
		db._terminar_fala()
		db._ir_para(db._no_atual.get("proximo"))
	check(not db.ativo, "abertura termina e devolve controle")

	# Seu Expedito: conversa libera o objetivo
	var expedito: NPC = fase.get_node("Expedito")
	expedito.interagir(p)
	check(db._id == "expedito_sahori", "Expedito inicia a conversa")
	db._terminar_fala()
	db._ir_para("i2")
	db._terminar_fala()
	check(db._no_atual.has("opcoes"), "Expedito oferece opções")
	db._escolher(db._no_atual["opcoes"][1])
	check(gs.get_flag("falou_expedito"), "conversa com Expedito conta como objetivo")
	db._encerrar()

	# Dona Lúcia: erra uma vez, depois acerta a data da Lei 11.300
	var lucia: NPC = fase.get_node("Lucia")
	lucia.interagir(p)
	db._terminar_fala()
	db._ir_para("q")
	db._terminar_fala()
	db._escolher(db._no_atual["opcoes"][1])
	check(db._no_atual.get("fala", "").begins_with("Quase"), "resposta errada da professora volta com dica")
	db._terminar_fala()
	db._ir_para("q")
	db._terminar_fala()
	db._escolher(db._no_atual["opcoes"][0])
	check(gs.get_flag("enigma_lei_ok"), "acertar a data marca o enigma como resolvido")
	db._encerrar()

	# Votos de apoio pelo caminho
	for i in range(1, 4):
		var voto: Area2D = fase.get_node("Voto%d" % i)
		voto.body_entered.emit(p)
	check(gs.quantidade_item("voto_apoio") == 3, "três votos de apoio coletados")

	# Expedito recebe os votos e entrega o Fragmento 2
	expedito.interagir(p)
	check(db._no_atual.get("fala", "").begins_with("Você trouxe"), "Expedito reconhece os votos")
	check(2 in gs.fragmentos and "emancipacao" in gs.paginas, "fragmento 2 e página da emancipação")
	db._terminar_fala()
	db._encerrar()

	# Todos os objetivos concluídos: a tela de fim aparece e pausa o jogo
	await frames(5)
	var hud: Node = fase.get_node("HUD")
	check(hud._tela_fim.visible and get_tree().paused, "fim de fase aparece com o jogo pausado")
	check(hud._tela_fim.proxima_cena == "res://scenes/levels/fase2b.tscn", "Fase 2 leva à primeira eleição")
	hud._tela_fim._continuar()
	check(not get_tree().paused, "continuar explorando despausa o jogo")

	print("---- falhas: %d" % falhas)
	get_tree().quit(falhas)
