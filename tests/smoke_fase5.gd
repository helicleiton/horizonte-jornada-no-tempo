extends Node
## Teste de fumaça da Fase 5: conversas, quiz da estudante Bia e fim de fase.
## Rodar: godot --headless --path . res://tests/smoke_fase5.tscn

var falhas := 0

func check(cond: bool, msg: String) -> void:
	print(("OK   " if cond else "FALHA ") + msg)
	if not cond:
		falhas += 1

func frames(n: int) -> void:
	for i in n:
		await get_tree().physics_frame

func _ready() -> void:
	var fase: Node = load("res://scenes/levels/fase5.tscn").instantiate()
	get_tree().root.add_child.call_deferred(fase)
	await frames(30)
	var gs: Node = get_tree().root.get_node("GameState")
	var db: Node = get_tree().root.get_node("DialogueBox")
	var p: Player = fase.get_node("Jogador")

	check(p.is_on_floor(), "jogador pousa no chão")
	check(db.ativo and db._id == "abertura", "abertura da Fase 5 inicia")
	for i in 3:
		db._terminar_fala()
		db._ir_para(db._no_atual.get("proximo"))
	check(not db.ativo, "abertura termina")

	var raimundo: NPC = fase.get_node("Raimundo")
	raimundo.interagir(p)
	db._terminar_fala()
	db._ir_para("i2")
	db._terminar_fala()
	db._escolher(db._no_atual["opcoes"][1])
	check(gs.get_flag("falou_raimundo"), "Seu Raimundo conta a história da Troller")
	db._encerrar()

	var terezinha: NPC = fase.get_node("Terezinha")
	terezinha.interagir(p)
	db._terminar_fala()
	db._ir_para("i2")
	db._terminar_fala()
	db._escolher(db._no_atual["opcoes"][2])
	check(gs.get_flag("falou_terezinha"), "Dona Terezinha explica o polo")
	db._encerrar()

	var bia: NPC = fase.get_node("Bia")
	bia.interagir(p)
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
	check(gs.get_flag("quiz_crescimento_ok"), "a estudante Bia marca o quiz como respondido")
	db._encerrar()

	await frames(5)
	var hud: Node = fase.get_node("HUD")
	check(hud._tela_fim.visible and get_tree().paused, "fim da Fase 5 aparece com o jogo pausado")
	check(hud._tela_fim.proxima_cena == "res://scenes/levels/fase6.tscn", "Fase 5 leva às águas de Horizonte")
	hud._tela_fim._continuar()

	print("---- falhas: %d" % falhas)
	get_tree().quit(falhas)
