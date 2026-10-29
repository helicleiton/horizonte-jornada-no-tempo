extends Node
## Teste de fumaça das fases 6 e 7 e do jogo da memória.
## Rodar: godot --headless --path . res://tests/smoke_fase67.tscn

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

	# Fase 6: quiz das águas e conversa com a comunidade
	var f6: Node = load("res://scenes/levels/fase6.tscn").instantiate()
	get_tree().root.add_child.call_deferred(f6)
	await frames(30)
	var p: Player = f6.get_node("Jogador")
	check(p.is_on_floor(), "jogador pousa na fase 6")
	check(db.ativo and db._id == "abertura", "abertura da fase 6 inicia")
	for i in 3:
		db._terminar_fala()
		db._ir_para(db._no_atual.get("proximo"))
	var guarda: NPC = f6.get_node("Guarda")
	guarda.interagir(p)
	db._terminar_fala()
	db._ir_para("q1")
	db._terminar_fala()
	db._escolher(db._no_atual["opcoes"][1])
	db._terminar_fala()
	db._ir_para("q2")
	db._terminar_fala()
	db._escolher(db._no_atual["opcoes"][0])
	check(gs.get_flag("quiz_parque_ok"), "quiz das águas marca o objetivo")
	db._encerrar()
	f6.queue_free()
	await frames(5)

	# Fase 7: bandeirinhas e festa
	var f7: Node = load("res://scenes/levels/fase7.tscn").instantiate()
	get_tree().root.add_child.call_deferred(f7)
	await frames(30)
	p = f7.get_node("Jogador")
	check(p.is_on_floor(), "jogador pousa na fase 7")
	check(db.ativo and db._id == "abertura", "abertura da fase 7 inicia")
	for i in 3:
		db._terminar_fala()
		db._ir_para(db._no_atual.get("proximo"))
	for i in range(1, 6):
		var b: Area2D = f7.get_node("Bandeirinha%d" % i)
		b.body_entered.emit(p)
	check(gs.quantidade_item("bandeirinha") == 5, "cinco bandeirinhas coletadas")
	var filo: NPC = f7.get_node("Filo")
	filo.interagir(p)
	check(gs.get_flag("entregou_bandeirinhas"), "Dona Filó recebe as bandeirinhas")
	db._encerrar()
	f7.queue_free()
	await frames(5)

	# Jogo da memória: 12 cartas
	var mem: Node = load("res://scenes/ui/memoria.tscn").instantiate()
	get_tree().root.add_child.call_deferred(mem)
	await frames(10)
	check(mem._cartas.size() == 12, "jogo da memória tem 12 cartas")

	print("---- falhas: %d" % falhas)
	get_tree().quit(falhas)
