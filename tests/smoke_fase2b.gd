extends Node
## Teste de fumaça da Fase 2b (primeira eleição): campanha, votação, resultado e fim.
## Rodar: godot --headless --path . res://tests/smoke_fase2b.tscn

var falhas := 0

func check(cond: bool, msg: String) -> void:
	print(("OK   " if cond else "FALHA ") + msg)
	if not cond:
		falhas += 1

func frames(n: int) -> void:
	for i in n:
		await get_tree().physics_frame

func _ready() -> void:
	var fase: Node = load("res://scenes/levels/fase2b.tscn").instantiate()
	get_tree().root.add_child.call_deferred(fase)
	await frames(30)
	var gs: Node = get_tree().root.get_node("GameState")
	var db: Node = get_tree().root.get_node("DialogueBox")
	var p: Player = fase.get_node("Jogador")

	check(p.is_on_floor(), "jogador pousa no chão")
	check(db.ativo and db._id == "abertura", "abertura da fase 2b inicia")
	for i in 4:
		db._terminar_fala()
		db._ir_para(db._no_atual.get("proximo"))
	check(not db.ativo, "abertura termina e devolve controle")

	# Seu Expedito: campanha
	var expedito: NPC = fase.get_node("Expedito")
	expedito.interagir(p)
	db._terminar_fala()
	db._ir_para("i2")
	db._terminar_fala()
	db._escolher(db._no_atual["opcoes"][1])
	check(gs.get_flag("falou_campanha"), "conversa sobre a campanha conta como objetivo")
	db._encerrar()

	# Santinhos distribuídos
	for i in range(1, 6):
		var santinho: Area2D = fase.get_node("Santinho%d" % i)
		santinho.body_entered.emit(p)
	check(gs.quantidade_item("santinho") == 5, "santinhos coletados")
	expedito.interagir(p)
	check(db._no_atual.get("fala", "").begins_with("Esses santinhos"), "Expedito recebe os santinhos")
	check(gs.get_flag("santinhos_distribuidos"), "distribuição marca o objetivo")
	db._terminar_fala()
	db._encerrar()

	# Dona Ilda: errada, depois certa
	var ilda: NPC = fase.get_node("Ilda")
	ilda.interagir(p)
	db._terminar_fala()
	db._ir_para("q")
	db._terminar_fala()
	db._escolher(db._no_atual["opcoes"][0])
	check(db._no_atual.get("fala", "").begins_with("Ainda não"), "urna eletrônica não era o voto de 1988")
	db._terminar_fala()
	db._ir_para("q")
	db._terminar_fala()
	db._escolher(db._no_atual["opcoes"][1])
	check(gs.get_flag("votacao_ok"), "cédula de papel marca o objetivo")
	db._ir_para("a2")
	check("primeira_eleicao" in gs.paginas, "página da primeira eleição entra no almanaque")
	db._encerrar()

	# Seu Nonato: resultado
	var nonato: NPC = fase.get_node("Nonato")
	nonato.interagir(p)
	db._terminar_fala()
	db._ir_para("i2")
	db._terminar_fala()
	db._escolher(db._no_atual["opcoes"][1])
	check(gs.get_flag("resultado_ouvido"), "resultado ouvido marca o objetivo")
	check("personagens_emancipacao" in gs.paginas, "página dos personagens entra no almanaque")
	db._encerrar()

	# Todos os objetivos: fim de fase
	await frames(5)
	var hud: Node = fase.get_node("HUD")
	check(hud._tela_fim.visible and get_tree().paused, "fim da fase 2b aparece com o jogo pausado")
	check(hud._tela_fim.proxima_cena == "res://scenes/levels/fase3.tscn", "fase 2b leva à fase 3")
	hud._tela_fim._continuar()
	check(not get_tree().paused, "continuar explorando despausa o jogo")

	print("---- falhas: %d" % falhas)
	get_tree().quit(falhas)
