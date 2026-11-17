extends SceneTree
## Mostra o Chico 3D em vista lateral, com poses dos pivôs, e salva imagens para conferir.
## Uso: godot --path . --script res://tools/ver_chico.gd -- <pasta_de_saida>

const POSES := {
	"braco_cima": {"PivoBracoE": 170.0, "PivoBracoD": 170.0},
	"braco_baixo": {"PivoBracoE": 0.0, "PivoBracoD": 0.0},
	"braco_frente": {"PivoBracoE": 40.0, "PivoBracoD": -40.0},
	"perna_frente": {"PivoPernaE": 35.0, "PivoPernaD": -35.0},
	"perna_tras": {"PivoPernaE": -35.0, "PivoPernaD": 35.0},
}


func _initialize() -> void:
	var pasta: String = OS.get_cmdline_user_args()[0]
	DirAccess.make_dir_recursive_absolute(pasta)
	_mostrar(pasta)


func _mostrar(pasta: String) -> void:
	var mundo := Node3D.new()
	root.add_child(mundo)
	var chico: Node3D = load("res://assets/3d/chico.glb").instantiate()
	mundo.add_child(chico)
	var camera := Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 2.0
	camera.position = Vector3(0, 0.9, 6)
	mundo.add_child(camera)
	camera.look_at_from_position(camera.position, Vector3(0, 0.9, 0))
	root.world_3d.environment = Environment.new()
	root.world_3d.environment.background_mode = Environment.BG_COLOR
	root.world_3d.environment.background_color = Color("e8c9a0")
	for nome in POSES:
		for nome_pivo in POSES[nome]:
			var pivo: Node3D = chico.find_child(nome_pivo, true, false)
			pivo.rotation_degrees.z = POSES[nome][nome_pivo]
		for i in 3:
			await process_frame
		root.get_texture().get_image().save_png(pasta.path_join(nome + ".png"))
		print("salvo ", nome)
	quit(0)
