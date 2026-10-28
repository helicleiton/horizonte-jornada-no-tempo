class_name Player
extends CharacterBody2D
## Movimentação de plataforma do(a) protagonista (Chico ou Luzia).
##
## - Aceleração e atrito separados para chão e ar (controle preciso).
## - Pulo definido por altura e tempo, com gravidade mais forte na queda.
## - Pulo de altura variável (soltar o botão cedo = pulo baixo).
## - "Coyote time" e buffer de pulo, para o controle parecer justo.
## - Dano com recuo, invencibilidade temporária e piscar.
## - Interação com NPCs e objetos do grupo "interagivel".
##
## Enquanto não houver pixel art, o personagem é desenhado como um retângulo.
## Para usar sprites, adicione um nó filho AnimatedSprite2D com as animações:
## "parado", "correr", "pular", "cair", "dano" e "derrota".

signal pulou
signal aterrissou
signal dano_recebido(cajus_restantes: int)

enum Estado { NORMAL, DIALOGO, ATORDOADO, MORTO }

@export_group("Corrida")
@export var velocidade_max := 110.0
@export var aceleracao_chao := 900.0
@export var atrito_chao := 1200.0
@export var aceleracao_ar := 650.0
@export var atrito_ar := 350.0

@export_group("Pulo")
## Altura máxima do pulo, em pixels (16 px = 1 bloco).
@export var altura_pulo := 52.0
## Tempo (s) para chegar ao ponto mais alto do pulo.
@export var tempo_subida := 0.36
## Tempo (s) para cair da altura máxima até o chão.
@export var tempo_descida := 0.3
## Fator aplicado à velocidade de subida quando o botão é solto cedo.
@export_range(0.0, 1.0) var corte_pulo := 0.45
@export var queda_max := 330.0
## Tempo (s) em que ainda dá para pular depois de sair da beirada.
@export var tempo_coyote := 0.1
## Tempo (s) em que um pulo apertado antes de tocar o chão é lembrado.
@export var tempo_buffer_pulo := 0.12

@export_group("Dano")
@export var tempo_invencivel := 1.2
@export var tempo_atordoado := 0.3
@export var recuo := Vector2(140.0, -150.0)

var estado := Estado.NORMAL
var olhando_direita := true

var _velocidade_pulo: float
var _gravidade_subida: float
var _gravidade_descida: float
var _timer_coyote := 0.0
var _timer_buffer := 0.0
var _timer_invencivel := 0.0
var _timer_atordoado := 0.0
var _timer_bloqueio_entrada := 0.0
var _no_chao_antes := false
var _tempo_no_ar := 0.0
var _timer_passo := 0.0
var _passo_alternado := false

@onready var _sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")
@onready var _area_interacao: Area2D = $AreaInteracao


func _ready() -> void:
	add_to_group("jogador")
	_calcular_fisica_do_pulo()
	GameState.jogador_morreu.connect(_on_jogador_morreu)
	_criar_sprite()
	pulou.connect(func() -> void: AudioManager.tocar("pulo"))
	aterrissou.connect(func() -> void: AudioManager.tocar("aterrissa", 1.0, -4.0))


## Usa a tira de sprites do(a) protagonista (chico.png ou luzia.png) quando
## não houver um AnimatedSprite2D já montado na cena.
func _criar_sprite() -> void:
	if _sprite:
		return
	var caminho := "res://assets/sprites/%s.png" % GameState.nome_protagonista.to_lower()
	_sprite = SpriteFactory.animado(caminho, 24, SpriteFactory.ANIMACOES_PERSONAGEM, Vector2(0, -17))
	if _sprite:
		add_child(_sprite)


## Converte altura e tempo do pulo em velocidade e gravidade. Assim o game
## designer ajusta "pula 3 blocos em 0,36 s" em vez de números de física.
func _calcular_fisica_do_pulo() -> void:
	_velocidade_pulo = -2.0 * altura_pulo / tempo_subida
	_gravidade_subida = 2.0 * altura_pulo / pow(tempo_subida, 2)
	_gravidade_descida = 2.0 * altura_pulo / pow(tempo_descida, 2)


func _physics_process(delta: float) -> void:
	_atualizar_timers(delta)

	match estado:
		Estado.NORMAL:
			_mover_horizontal(delta, Input.get_axis("mover_esquerda", "mover_direita"))
			if _timer_bloqueio_entrada <= 0.0:
				_processar_pulo()
				if Input.is_action_just_pressed("interagir"):
					_interagir()
		Estado.DIALOGO, Estado.MORTO:
			_mover_horizontal(delta, 0.0)
		Estado.ATORDOADO:
			if _timer_atordoado <= 0.0:
				estado = Estado.NORMAL

	_aplicar_gravidade(delta)
	move_and_slide()
	_verificar_aterrissagem(delta)
	_atualizar_passos(delta)
	_atualizar_visual()


func _atualizar_timers(delta: float) -> void:
	_timer_coyote = tempo_coyote if is_on_floor() else maxf(_timer_coyote - delta, 0.0)
	_timer_buffer = maxf(_timer_buffer - delta, 0.0)
	_timer_invencivel = maxf(_timer_invencivel - delta, 0.0)
	_timer_atordoado = maxf(_timer_atordoado - delta, 0.0)
	_timer_bloqueio_entrada = maxf(_timer_bloqueio_entrada - delta, 0.0)


func _mover_horizontal(delta: float, direcao: float) -> void:
	var no_chao := is_on_floor()
	if direcao != 0.0:
		var aceleracao := aceleracao_chao if no_chao else aceleracao_ar
		# Virar de lado no chão soma o atrito: a troca de direção fica firme.
		if no_chao and velocity.x != 0.0 and signf(direcao) != signf(velocity.x):
			aceleracao += atrito_chao
		velocity.x = move_toward(velocity.x, direcao * velocidade_max, aceleracao * delta)
		olhando_direita = direcao > 0.0
	else:
		var atrito := atrito_chao if no_chao else atrito_ar
		velocity.x = move_toward(velocity.x, 0.0, atrito * delta)


func _processar_pulo() -> void:
	if Input.is_action_just_pressed("pular"):
		_timer_buffer = tempo_buffer_pulo

	if _timer_buffer > 0.0 and _timer_coyote > 0.0:
		velocity.y = _velocidade_pulo
		_timer_buffer = 0.0
		_timer_coyote = 0.0
		pulou.emit()

	if Input.is_action_just_released("pular") and velocity.y < 0.0:
		velocity.y *= corte_pulo


func _aplicar_gravidade(delta: float) -> void:
	if is_on_floor():
		return
	var gravidade := _gravidade_subida if velocity.y < 0.0 else _gravidade_descida
	velocity.y = minf(velocity.y + gravidade * delta, queda_max)


func _verificar_aterrissagem(delta: float) -> void:
	var no_chao := is_on_floor()
	# Só conta como aterrissagem depois de um tempo no ar (evita som ao nascer na fase).
	if no_chao and not _no_chao_antes and _tempo_no_ar > 0.12:
		aterrissou.emit()
	_tempo_no_ar = 0.0 if no_chao else _tempo_no_ar + delta
	_no_chao_antes = no_chao


func _atualizar_passos(delta: float) -> void:
	if not is_on_floor() or absf(velocity.x) < 40.0 or estado != Estado.NORMAL:
		_timer_passo = 0.0
		return
	_timer_passo -= delta
	if _timer_passo <= 0.0:
		_timer_passo = 0.27
		_passo_alternado = not _passo_alternado
		AudioManager.tocar("passo1" if _passo_alternado else "passo2", randf_range(0.92, 1.08), -8.0)


func _interagir() -> void:
	var alvo: Node2D = null
	var menor_distancia := INF
	for area in _area_interacao.get_overlapping_areas():
		if not (area.is_in_group("interagivel") and area.has_method("interagir")):
			continue
		var distancia := global_position.distance_squared_to(area.global_position)
		if distancia < menor_distancia:
			menor_distancia = distancia
			alvo = area
	if alvo:
		alvo.interagir(self)


# --- API usada por inimigos, fases e pela caixa de diálogo --------------------

func receber_dano(origem_x: float, quantidade := 1) -> void:
	if estado in [Estado.MORTO, Estado.DIALOGO] or _timer_invencivel > 0.0:
		return
	GameState.perder_caju(quantidade)
	dano_recebido.emit(GameState.cajus)
	if estado == Estado.MORTO:
		return

	var lado := signf(global_position.x - origem_x)
	if lado == 0.0:
		lado = -1.0 if olhando_direita else 1.0
	velocity = Vector2(recuo.x * lado, recuo.y)
	estado = Estado.ATORDOADO
	_timer_atordoado = tempo_atordoado
	_timer_invencivel = tempo_invencivel


func entrar_dialogo() -> void:
	if estado == Estado.NORMAL:
		estado = Estado.DIALOGO


func sair_dialogo() -> void:
	if estado == Estado.DIALOGO:
		estado = Estado.NORMAL
		# Evita que o mesmo botão que fechou o diálogo pule ou reabra a conversa.
		_timer_bloqueio_entrada = 0.2


func reaparecer(posicao: Vector2) -> void:
	global_position = posicao
	velocity = Vector2.ZERO
	estado = Estado.NORMAL
	_timer_invencivel = 1.0


func _on_jogador_morreu() -> void:
	estado = Estado.MORTO
	velocity.x = 0.0


# --- Visual ------------------------------------------------------------------

func _atualizar_visual() -> void:
	var piscando := _timer_invencivel > 0.0 and fmod(_timer_invencivel, 0.16) < 0.08
	modulate.a = 0.35 if piscando else 1.0
	if _sprite:
		_sprite.flip_h = not olhando_direita
		_tocar_animacao(_escolher_animacao())
		_sprite.speed_scale = clampf(absf(velocity.x) / velocidade_max, 0.6, 1.2) if _sprite.animation == "correr" else 1.0
	else:
		queue_redraw()


func _escolher_animacao() -> String:
	match estado:
		Estado.MORTO:
			return "derrota"
		Estado.ATORDOADO:
			return "dano"
	if not is_on_floor():
		return "pular" if velocity.y < 0.0 else "cair"
	if absf(velocity.x) > 10.0:
		return "correr"
	return "parado"


func _tocar_animacao(nome: String) -> void:
	if _sprite.sprite_frames and _sprite.sprite_frames.has_animation(nome) and _sprite.animation != nome:
		_sprite.play(nome)


func _draw() -> void:
	if _sprite:
		return
	draw_rect(Rect2(-6, -28, 12, 28), Color("3b5a8c"))
	draw_rect(Rect2(-6, -28, 12, 10), Color("e0a96d"))
	var olho_x := 2.0 if olhando_direita else -4.0
	draw_rect(Rect2(olho_x, -24, 2, 2), Color("1a1a1a"))
