extends SceneTree


func _initialize() -> void:
	var chico: Node3D = load("res://assets/3d/chico.glb").instantiate()
	root.add_child(chico)
	_listar(chico, 0)
	var anim: AnimationPlayer = chico.find_child("AnimationPlayer", true, false)
	anim.play("andar")
	anim.seek(0.4, true)
	var esq: Skeleton3D = chico.find_child("Skeleton3D", true, false)
	if esq:
		for i in esq.get_bone_count():
			print("osso ", esq.get_bone_name(i), " rot ", esq.get_bone_pose_rotation(i))
	quit(0)


func _listar(no: Node, nivel: int) -> void:
	print("  ".repeat(nivel), no.name, " (", no.get_class(), ")")
	for filho in no.get_children():
		_listar(filho, nivel + 1)
