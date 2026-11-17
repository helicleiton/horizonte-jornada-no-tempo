extends Node3D
## Fatia 2.5D da fase 1 em 3D: o Chico anda de lado num cenário 3D com câmera fixa de perfil.
## Controles: mover_esquerda / mover_direita para andar, pular para pular, interagir para conversar.

const VELOCIDADE := 4.0
const PULO := 7.0
const GRAVIDADE := 20.0
const DIALOGOS := "res://data/dialogos_fase1.json"

var _jogador: CharacterBody3D
var _chico: Chico3D
var _camera: Camera3D
var _tempo := 0.0
var _estado := "parado"
var _npc_perto := ""


func _ready() -> void:
	_montar_ambiente()
	_jogador = _criar_jogador(Vector3(-2, 1, 0))
	add_child(_jogador)
	_criar_morador("tropeiro_zeca", Vector3(4, 1, 0))
	_criar_morador("agricultora_mariinha", Vector3(10, 1, 0))
	DialogueBox.iniciar.call_deferred(DIALOGOS, "abertura", _jogador)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://scenes/ui/menu_inicial.tscn")


func _physics_process(delta: float) -> void:
	_tempo += delta
	var direcao := Input.get_axis("mover_esquerda", "mover_direita")
	_jogador.velocity.x = direcao * VELOCIDADE
	if not _jogador.is_on_floor():
		_jogador.velocity.y -= GRAVIDADE * delta
	elif Input.is_action_just_pressed("pular"):
		_jogador.velocity.y = PULO
	_jogador.move_and_slide()
	if direcao != 0.0:
		_chico.rotation_degrees.y = 0.0 if direcao > 0.0 else 180.0
	_estado = _estado_atual(direcao)
	_chico.animar(_estado, _tempo)
	_camera.position.x = lerpf(_camera.position.x, _jogador.position.x, 0.1)
	if Input.is_action_just_pressed("interagir") and not DialogueBox.ativo and _npc_perto != "":
		DialogueBox.iniciar(DIALOGOS, _npc_perto, _jogador)


func _estado_atual(direcao: float) -> String:
	if not _jogador.is_on_floor():
		return "pular" if _jogador.velocity.y > 0.0 else "cair"
	if absf(direcao) > 0.1:
		return "andar"
	return "parado"


func _montar_ambiente() -> void:
	var ambiente := WorldEnvironment.new()
	ambiente.environment = Environment.new()
	ambiente.environment.background_mode = Environment.BG_COLOR
	ambiente.environment.background_color = Color("e8c9a0")
	ambiente.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	ambiente.environment.ambient_light_color = Color("f2dcb8")
	ambiente.environment.ambient_light_energy = 0.35
	ambiente.environment.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	add_child(ambiente)
	var sol := DirectionalLight3D.new()
	sol.rotation_degrees = Vector3(-60, -25, 0)
	sol.shadow_enabled = true
	sol.light_color = Color("fff1d6")
	sol.light_energy = 0.6
	add_child(sol)
	_camera = Camera3D.new()
	_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	_camera.size = 4.6
	_camera.position = Vector3(0, 1.8, 12)
	add_child(_camera)
	_camera.look_at_from_position(_camera.position, Vector3(0, 1.8, 0))
	_criar_chao(Vector3(0, -0.5, 0), Vector3(60, 1, 4), Color("7a4f2e"))
	_colocar_objeto("res://assets/3d/casataipa.glb", Vector3(-6, 0, -1.5))
	_colocar_objeto("res://assets/3d/cajueiro.glb", Vector3(-2.5, 0, -1.5))
	_colocar_objeto("res://assets/3d/palmeira.glb", Vector3(1.5, 0, -1.5))
	_colocar_objeto("res://assets/3d/cajueiro.glb", Vector3(9, 0, -1.5))
	_colocar_objeto("res://assets/3d/casataipa.glb", Vector3(14, 0, -1.5))


func _colocar_objeto(caminho: String, posicao: Vector3) -> void:
	var objeto: Node3D = load(caminho).instantiate()
	objeto.position = posicao
	add_child(objeto)


func _criar_chao(posicao: Vector3, tamanho: Vector3, cor: Color) -> void:
	var corpo := StaticBody3D.new()
	corpo.position = posicao
	var forma := CollisionShape3D.new()
	forma.shape = BoxShape3D.new()
	forma.shape.size = tamanho
	corpo.add_child(forma)
	var visual := MeshInstance3D.new()
	visual.mesh = BoxMesh.new()
	visual.mesh.size = tamanho
	var material := StandardMaterial3D.new()
	material.albedo_color = cor
	visual.material_override = material
	corpo.add_child(visual)
	add_child(corpo)


func _criar_jogador(posicao: Vector3) -> CharacterBody3D:
	var jogador := CharacterBody3D.new()
	jogador.position = posicao
	var forma := CollisionShape3D.new()
	forma.shape = CapsuleShape3D.new()
	forma.shape.radius = 0.25
	forma.shape.height = 1.7
	forma.position.y = 0.85
	jogador.add_child(forma)
	_chico = Chico3D.new()
	jogador.add_child(_chico)
	return jogador


func _criar_morador(id: String, posicao: Vector3) -> void:
	var morador := Node3D.new()
	morador.position = posicao
	var chico := Chico3D.new()
	morador.add_child(chico)
	chico.rotation_degrees.y = 180.0
	add_child(morador)
	var area := Area3D.new()
	area.position = Vector3(0, 1, 0)
	var forma := CollisionShape3D.new()
	forma.shape = SphereShape3D.new()
	forma.shape.radius = 1.6
	area.add_child(forma)
	morador.add_child(area)
	area.body_entered.connect(func(corpo: Node3D) -> void:
		if corpo == _jogador:
			_npc_perto = id)
	area.body_exited.connect(func(corpo: Node3D) -> void:
		if corpo == _jogador and _npc_perto == id:
			_npc_perto = "")
