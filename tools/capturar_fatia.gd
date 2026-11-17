extends SceneTree
## Captura a fatia 3D: parado, andando, pulando e perto de um morador.
## Uso: godot --path . --script res://tools/capturar_fatia.gd -- <pasta_de_saida>

func _initialize() -> void:
	var pasta: String = OS.get_cmdline_user_args()[0]
	DirAccess.make_dir_recursive_absolute(pasta)
	change_scene_to_file("res://scenes/fatia_3d/fatia_3d.tscn")
	_capturar(pasta)


func _capturar(pasta: String) -> void:
	for i in 150:
		await process_frame
	var caixa = root.get_node("/root/DialogueBox")
	if caixa.ativo:
		caixa._encerrar()
	caixa.visible = false
	root.get_texture().get_image().save_png(pasta.path_join("parado.png"))
	Input.action_press("mover_direita")
	for i in 30:
		await process_frame
	root.get_texture().get_image().save_png(pasta.path_join("andando.png"))
	Input.action_press("pular")
	for i in 8:
		await process_frame
	root.get_texture().get_image().save_png(pasta.path_join("pulando.png"))
	Input.action_release("pular")
	Input.action_release("mover_direita")
	quit(0)
