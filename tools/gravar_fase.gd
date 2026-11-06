extends SceneTree
## Joga a fase 1 sozinha, com entradas simuladas, para gravar o vídeo de divulgação.
## Uso: godot --path . --write-movie <saida.avi> --fixed-fps 30 --script res://tools/gravar_fase.gd
## Precisa de janela (não roda em modo headless).

const QUADROS := 900  # 30 s a 30 fps


func _initialize() -> void:
	change_scene_to_file("res://scenes/levels/fase_teste.tscn")
	_gravar()


func _gravar() -> void:
	for i in 90:
		await process_frame
	var caixa = root.get_node("/root/DialogueBox")
	if caixa.ativo:
		caixa._encerrar()
	for quadro in QUADROS:
		await process_frame
		_comandar(quadro)
	for acao in ["mover_direita", "mover_esquerda", "pular"]:
		Input.action_release(acao)
	quit(0)


## Sequência: anda para a direita, pula, volta um pouco e segue para a frente.
func _comandar(quadro: int) -> void:
	var direita := quadro < 480 or quadro >= 660
	Input.action_press("mover_direita" if direita else "mover_esquerda")
	Input.action_release("mover_esquerda" if direita else "mover_direita")
	if quadro % 75 == 0:
		Input.action_press("pular")
	elif quadro % 75 == 10:
		Input.action_release("pular")
