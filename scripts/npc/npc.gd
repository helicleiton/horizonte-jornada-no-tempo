class_name NPC
extends Area2D
## Personagem não jogável. Quando o jogador se aproxima, mostra o nome e
## a tecla de interação, vira para ele; ao interagir, abre o diálogo do JSON.

@export var nome_exibido := "Morador"
@export var id_dialogo := ""
@export_file("*.json") var arquivo_dialogos := "res://data/dialogos_fase1.json"
## Tira de sprites (quadros 24x36; 0-1 = parado). Vazio = placeholder colorido.
@export_file("*.png") var sprite_sheet := ""
@export var olhar_esquerda := false
## Cor do placeholder (usada só se não houver sprite).
@export var cor := Color("8a5a3c")

var _indicador: Label
var _sprite: AnimatedSprite2D


func _ready() -> void:
	add_to_group("interagivel")
	if sprite_sheet != "":
		_sprite = SpriteFactory.animado(sprite_sheet, 24, SpriteFactory.ANIMACOES_PARADO, Vector2(0, -17))
		if _sprite:
			_sprite.flip_h = olhar_esquerda
			add_child(_sprite)
	_indicador = Label.new()
	_indicador.text = GameState.dica("%s [E]", "%s") % nome_exibido
	_indicador.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_indicador.add_theme_font_size_override("font_size", 8)
	_indicador.add_theme_color_override("font_outline_color", Color("2b1a12"))
	_indicador.add_theme_constant_override("outline_size", 4)
	_indicador.size = Vector2(120, 10)
	_indicador.position = Vector2(-60, -50)
	_indicador.z_index = 20
	_indicador.hide()
	add_child(_indicador)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func interagir(jogador: Node) -> void:
	DialogueBox.iniciar(arquivo_dialogos, id_dialogo, jogador)


func _on_body_entered(corpo: Node2D) -> void:
	if corpo is Player:
		_indicador.show()
		if _sprite:
			_sprite.flip_h = corpo.global_position.x < global_position.x


func _on_body_exited(corpo: Node2D) -> void:
	if corpo is Player:
		_indicador.hide()


func _draw() -> void:
	if sprite_sheet != "":
		return
	draw_rect(Rect2(-6, -28, 12, 28), cor)
	draw_rect(Rect2(-6, -28, 12, 10), Color("c68b59"))
