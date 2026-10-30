extends SceneTree
## Tira fotos da tela de cada fase para montar o vídeo de divulgação.
## Uso: godot --path . --script res://tools/capturar_cenas.gd -- <pasta_de_saida>
## Precisa de janela (não roda em modo headless).

const CENAS := {
	"menu": "res://scenes/ui/menu_inicial.tscn",
	"fase1": "res://scenes/levels/fase_teste.tscn",
	"fase2": "res://scenes/levels/fase2.tscn",
	"fase3": "res://scenes/levels/fase3.tscn",
	"fase4": "res://scenes/levels/fase4.tscn",
	"carro": "res://scenes/levels/fase_carro.tscn",
	"fase10": "res://scenes/levels/fase10.tscn",
	"memoria": "res://scenes/ui/memoria.tscn",
}

var _pasta := ""


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	_pasta = args[0] if args.size() > 0 else "user://cenas"
	DirAccess.make_dir_recursive_absolute(_pasta)
	_capturar()


func _capturar() -> void:
	for nome in CENAS:
		change_scene_to_file(CENAS[nome])
		# Espera a cena montar e o jogador entrar em quadro.
		for i in 150:
			await process_frame
		# Fecha a caixa de diálogo da abertura, para a foto mostrar só a cena.
		var caixa = root.get_node("/root/DialogueBox")
		if caixa.ativo:
			caixa._encerrar()
		for i in 5:
			await process_frame
		var imagem := root.get_texture().get_image()
		imagem.save_png(_pasta.path_join(nome + ".png"))
		print("salvo ", nome)
	quit(0)
