extends SceneTree
## Grava a fase 1 com conversas entre o personagem e os moradores, para o vídeo de divulgação.
## Uso: godot --path . --write-movie <saida.avi> --fixed-fps 30 --script res://tools/gravar_conversas.gd
## Precisa de janela (não roda em modo headless).

const QUADROS := 1800  # 60 s a 30 fps
## Posição x de cada morador da fase 1, com a ordem em que o personagem os visita.
const PARADAS := [100.0, 520.0, 700.0, 920.0, 1380.0]
const QUADROS_POR_PARADA := 340
const QUADROS_ENTRE_CLIQUES := 30

var _jogador: Node2D


func _initialize() -> void:
	change_scene_to_file("res://scenes/levels/fase_teste.tscn")
	_gravar()


func _gravar() -> void:
	for i in 90:
		await process_frame
	var caixa = root.get_node("/root/DialogueBox")
	if caixa.ativo:
		caixa._encerrar()
	_jogador = current_scene.get_node("Jogador")
	for quadro in QUADROS:
		await process_frame
		_comandar(quadro, caixa)
	_apertar("interagir", false)
	quit(0)


## Envia o evento como tecla de verdade, para a caixa de diálogo receber em _unhandled_input.
func _apertar(acao: String, pressionada: bool) -> void:
	var evento := InputEventAction.new()
	evento.action = acao
	evento.pressed = pressionada
	Input.parse_input_event(evento)


func _comandar(quadro: int, caixa) -> void:
	var parada := quadro / QUADROS_POR_PARADA
	if parada >= PARADAS.size():
		return
	var no_bloco := quadro % QUADROS_POR_PARADA
	if no_bloco == 0:
		# Fecha a conversa anterior e leva o personagem até o próximo morador, do lado esquerdo dele.
		if caixa.ativo:
			caixa._encerrar()
		_jogador.global_position = Vector2(PARADAS[parada] - 22.0, 160.0)
		_jogador.velocity = Vector2.ZERO
	if no_bloco == 30:
		_apertar("interagir", true)
	elif no_bloco == 31:
		_apertar("interagir", false)
	elif no_bloco > 60 and no_bloco % QUADROS_ENTRE_CLIQUES == 0 and caixa.ativo:
		# Com opções na tela, confirma a primeira; sem opções, avança a fala.
		var tecla := "ui_accept" if caixa._opcoes.get_child_count() > 0 else "interagir"
		_apertar(tecla, true)
	elif no_bloco > 60 and no_bloco % QUADROS_ENTRE_CLIQUES == 1:
		var tecla := "ui_accept" if caixa._opcoes.get_child_count() > 0 else "interagir"
		_apertar(tecla, false)
