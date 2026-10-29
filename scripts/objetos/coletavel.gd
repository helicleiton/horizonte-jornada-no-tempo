extends Area2D
## Item coletável: sementes de carnaúba, itens de missão (mudas de algodão e
## votos de apoio), páginas do almanaque, cajus (vida) e fragmentos de memória.

enum Tipo { SEMENTE, ITEM, PAGINA, CAJU, FRAGMENTO, VOTO, CAIXA, SANTINHO }

const SPRITES := {
	Tipo.SEMENTE: "semente",
	Tipo.ITEM: "muda_algodao",
	Tipo.PAGINA: "pagina",
	Tipo.CAJU: "caju",
	Tipo.FRAGMENTO: "fragmento",
	Tipo.VOTO: "pagina",
	Tipo.CAIXA: "pagina",
	Tipo.SANTINHO: "pagina",
}

@export var tipo := Tipo.SEMENTE
@export var quantidade := 1
## Id do item (tipo ITEM) ou da página do almanaque (tipo PAGINA).
@export var id := ""
## Número da fase (tipo FRAGMENTO).
@export var fase := 1
@export var flutuar := true
## Imagem própria (ex.: bandeirinha). Vazio = ícone padrão do tipo.
@export_file("*.png") var imagem := ""

var _tempo := 0.0
var _y_inicial := 0.0
var _sprite: Sprite2D


func _ready() -> void:
	_y_inicial = position.y
	_tempo = randf() * TAU
	var caminho := imagem if imagem != "" else "res://assets/sprites/%s.png" % SPRITES[tipo]
	if ResourceLoader.exists(caminho):
		_sprite = Sprite2D.new()
		_sprite.texture = load(caminho)
		add_child(_sprite)
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	if flutuar:
		_tempo += delta * 3.0
		position.y = _y_inicial + roundf(sin(_tempo) * 2.0)


func _on_body_entered(corpo: Node2D) -> void:
	if not corpo is Player:
		return
	match tipo:
		Tipo.SEMENTE:
			GameState.adicionar_sementes(quantidade)
		Tipo.ITEM:
			GameState.adicionar_item(id, quantidade)
		Tipo.PAGINA:
			GameState.coletar_pagina(id)
		Tipo.CAJU:
			GameState.curar(quantidade)
		Tipo.FRAGMENTO:
			GameState.coletar_fragmento(fase)
		Tipo.VOTO:
			GameState.adicionar_item("voto_apoio")
		Tipo.CAIXA:
			GameState.adicionar_item("caixa_calcado")
		Tipo.SANTINHO:
			GameState.adicionar_item("santinho")

	flutuar = false
	set_deferred("monitoring", false)
	var tween := create_tween().set_parallel()
	tween.tween_property(self, "position:y", position.y - 12.0, 0.25)
	tween.tween_property(self, "modulate:a", 0.0, 0.25)
	tween.chain().tween_callback(queue_free)


func _draw() -> void:
	if _sprite:
		return
	draw_circle(Vector2.ZERO, 3.0, Color("5a3a22"))
