class_name NPC
extends Area2D
## Personagem não jogável. Quando o jogador se aproxima, mostra o nome e
## a tecla de interação; ao interagir, abre o diálogo indicado no JSON.

@export var nome_exibido := "Morador"
@export var id_dialogo := ""
@export_file("*.json") var arquivo_dialogos := "res://data/dialogos_fase1.json"
## Cor do placeholder (enquanto não houver sprite).
@export var cor := Color("8a5a3c")

var _indicador: Label


func _ready() -> void:
	add_to_group("interagivel")
	_indicador = Label.new()
	_indicador.text = "%s [E]" % nome_exibido
	_indicador.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_indicador.add_theme_font_size_override("font_size", 8)
	_indicador.size = Vector2(120, 10)
	_indicador.position = Vector2(-60, -42)
	_indicador.hide()
	add_child(_indicador)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func interagir(jogador: Node) -> void:
	DialogueBox.iniciar(arquivo_dialogos, id_dialogo, jogador)


func _on_body_entered(corpo: Node2D) -> void:
	if corpo is Player:
		_indicador.show()


func _on_body_exited(corpo: Node2D) -> void:
	if corpo is Player:
		_indicador.hide()


func _draw() -> void:
	if get_node_or_null("AnimatedSprite2D"):
		return
	draw_rect(Rect2(-6, -28, 12, 28), cor)
	draw_rect(Rect2(-6, -28, 12, 10), Color("c68b59"))
