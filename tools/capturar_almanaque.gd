extends SceneTree
## Desenha uma página do almanaque (com as fotos) e salva como imagem, para conferir o resultado.
## Uso: godot --path . --script res://tools/capturar_almanaque.gd -- <pasta_de_saida> <id_da_pagina>

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var pasta: String = args[0]
	var id: String = args[1] if args.size() > 1 else "prefeitos_horizonte"
	DirAccess.make_dir_recursive_absolute(pasta)
	_capturar(pasta, id)


func _capturar(pasta: String, id: String) -> void:
	var dados: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/almanaque.json"))
	var pagina: Dictionary = dados[id]
	var fundo := ColorRect.new()
	fundo.color = Color("2b1a12")
	fundo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(fundo)
	var texto := RichTextLabel.new()
	texto.bbcode_enabled = true
	texto.scroll_active = false
	texto.add_theme_font_size_override("normal_font_size", 14)
	texto.position = Vector2(12, 8)
	texto.size = Vector2(936, 700)
	texto.text = "[b]%s[/b]\n%s\n[i]Fonte: %s[/i]" % [pagina["titulo"], pagina["texto"], pagina.get("fonte", "")]
	root.add_child(texto)
	for i in 120:
		await process_frame
	root.get_texture().get_image().save_png(pasta.path_join(id + ".png"))
	print("salvo ", id)
	quit(0)
