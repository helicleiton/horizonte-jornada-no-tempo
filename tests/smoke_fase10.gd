extends Node
## Teste de fumaça da Fase 10 (quem faz a cidade): guardiã, quiz e fim de fase.
## Rodar: godot --headless --path . res://tests/smoke_fase10.tscn

var falhas := 0

func check(cond: bool, msg: String) -> void:
	print(("OK   " if cond else "FALHA ") + msg)
	if not cond:
		falhas += 1

func frames(n: int) -> void:
	for i in n:
		await get_tree().physics_frame

func _ready() -> void:
	var gs: Node = get_tree().root.get_node("GameState")
	var db: Node = get_tree().root.get_node("DialogueBox")
	var fase: Node = load("res://scenes/levels/fase10.tscn").instantiate()
	get_tree().root.add_child.call_deferred(fase)
	await frames(30)
	var p: Player = fase.get_node("Jogador")
	check(p.is_on_floor(), "jogador pousa na fase 10")
	check(db.ativo and db._id == "abertura", "abertura da fase 10 inicia")
	for i in 3:
		db._terminar_fala()
		db._ir_para(db._no_atual.get("proximo"))
	var guardia: NPC = fase.get_node("Guardia")
	guardia.interagir(p)
	db._terminar_fala()
	db._ir_para("i2")
	db._terminar_fala()
	db._escolher(db._no_atual["opcoes"][2])
	check(gs.get_flag("falou_guardia") and "liderancas" in gs.paginas, "guardiã libera a página das lideranças")
	db._encerrar()
	var prof: NPC = fase.get_node("Professor")
	prof.interagir(p)
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
	check(gs.get_flag("quiz_lideres_ok"), "quiz das lideranças marca o objetivo")
	db._encerrar()
	var ana: NPC = fase.get_node("Ana")
	ana.interagir(p)
	for i in 5:
		db._terminar_fala()
		db._ir_para("pf%d" % i)
		db._terminar_fala()
		var certa := 2 if i != 1 and i != 2 else (2 if i == 1 else 1)
		db._escolher(db._no_atual["opcoes"][[2, 2, 1, 1, 1][i]])
	check(gs.get_flag("quiz_perfil_ok"), "quiz do perfil do IPECE marca o acerto")
	db._encerrar()
	await frames(5)
	var hud: Node = fase.get_node("HUD")
	check(hud._tela_fim.visible and get_tree().paused, "fim da fase 10 aparece com o jogo pausado")
	hud._tela_fim._continuar()
	print("---- falhas: %d" % falhas)
	get_tree().quit(falhas)
