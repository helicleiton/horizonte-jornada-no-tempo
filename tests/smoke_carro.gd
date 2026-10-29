extends Node
## Teste de fumaça da fase de carro: diálogos disparam ao passar pelos agentes.
## Rodar: godot --headless --path . res://tests/smoke_carro.tscn

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
	var fase: Node = load("res://scenes/levels/fase_carro.tscn").instantiate()
	get_tree().root.add_child.call_deferred(fase)
	await frames(10)
	check(db.ativo and db._id == "abertura", "abertura do carro inicia")
	for i in 2:
		db._terminar_fala()
		db._ir_para(db._no_atual.get("proximo"))
	check(not db.ativo, "abertura termina")
	fase._x = 301.0
	await frames(3)
	check(db.ativo and db._id == "agente_demutran", "agente do Demutran conversa ao passar")
	db._encerrar()
	fase._x = 761.0
	await frames(3)
	check(db.ativo and db._id == "quiz_transito", "quiz de trânsito começa ao passar")
	db._encerrar()
	fase._x = 1499.0
	await frames(3)
	check(gs.get_flag("chegou_destino"), "chegar ao fim da rua marca o objetivo")

	print("---- falhas: %d" % falhas)
	get_tree().quit(falhas)
