extends SceneTree
## Testa a conversa na fatia 3D: vai até o Seu Zeca, aperta interagir e confere o diálogo.
## Uso: godot --path . --script res://tools/testar_conversa_3d.gd -- <pasta_de_saida>

func _initialize() -> void:
	var pasta: String = OS.get_cmdline_user_args()[0]
	DirAccess.make_dir_recursive_absolute(pasta)
	change_scene_to_file("res://scenes/fatia_3d/fatia_3d.tscn")
	_testar(pasta)


func _testar(pasta: String) -> void:
	for i in 60:
		await process_frame
	var caixa = root.get_node("/root/DialogueBox")
	if caixa.ativo:
		caixa._encerrar()
	var jogador: CharacterBody3D = null
	for filho in current_scene.get_children():
		if filho is CharacterBody3D:
			jogador = filho
	jogador.global_position = Vector3(3.2, 1.0, 0)
	for i in 20:
		await process_frame
	print("perto do Zeca: ", caixa.ativo, " id ", caixa._id)
	var evento := InputEventAction.new()
	evento.action = "interagir"
	evento.pressed = true
	Input.parse_input_event(evento)
	for i in 10:
		await process_frame
	print("dialogo ativo: ", caixa.ativo, " id ", caixa._id)
	root.get_texture().get_image().save_png(pasta.path_join("conversa.png"))
	quit(0)
