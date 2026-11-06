extends Node
## Teste de fumaça do quiz do almanaque: perguntas só de páginas encontradas e pontuação.
## Rodar: godot --headless --path . res://tests/smoke_quiz.tscn

var falhas := 0

func check(cond: bool, msg: String) -> void:
	print(("OK   " if cond else "FALHA ") + msg)
	if not cond:
		falhas += 1

func _ready() -> void:
	var gs: Node = get_tree().root.get_node("GameState")
	gs.paginas.clear()
	check(QuizAlmanaque.disponiveis() == 0, "sem páginas encontradas não há perguntas")
	gs.paginas.assign(["vila_1933", "vulcabras", "emancipacao"])
	check(QuizAlmanaque.disponiveis() == 3, "três páginas com pergunta geram três perguntas disponíveis")
	var quiz := QuizAlmanaque.new()
	get_tree().root.add_child.call_deferred(quiz)
	await get_tree().process_frame
	await get_tree().process_frame
	check(quiz._perguntas.size() == 3, "o quiz carrega as três perguntas")
	quiz._responder(int(quiz._perguntas[0]["correta"]))
	check(quiz._acertos == 1, "resposta certa soma um acerto")
	quiz._avancar()
	quiz._responder((int(quiz._perguntas[1]["correta"]) + 1) % 3)
	check(quiz._acertos == 1, "resposta errada não soma")
	quiz._avancar()
	quiz._avancar()
	check(quiz._rotulo_pergunta.text == "Você acertou 1 de 3 perguntas.", "resultado final mostra a pontuação")
	print("---- falhas: ", falhas)
	get_tree().quit(falhas)
