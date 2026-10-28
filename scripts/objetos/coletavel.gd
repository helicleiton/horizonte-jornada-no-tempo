extends Area2D
## Item coletável: sementes de carnaúba, itens de missão (mudas de algodão),
## páginas do almanaque, cajus (vida) e fragmentos de memória.

enum Tipo { SEMENTE, ITEM, PAGINA, CAJU, FRAGMENTO }

@export var tipo := Tipo.SEMENTE
@export var quantidade := 1
## Id do item (tipo ITEM) ou da página do almanaque (tipo PAGINA).
@export var id := ""
## Número da fase (tipo FRAGMENTO).
@export var fase := 1
@export var flutuar := true

var _tempo := 0.0
var _y_inicial := 0.0


func _ready() -> void:
	_y_inicial = position.y
	_tempo = randf() * TAU
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	if flutuar:
		_tempo += delta * 3.0
		position.y = _y_inicial + sin(_tempo) * 2.0


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

	flutuar = false
	set_deferred("monitoring", false)
	var tween := create_tween().set_parallel()
	tween.tween_property(self, "position:y", position.y - 12.0, 0.25)
	tween.tween_property(self, "modulate:a", 0.0, 0.25)
	tween.chain().tween_callback(queue_free)


func _draw() -> void:
	match tipo:
		Tipo.SEMENTE:
			draw_circle(Vector2.ZERO, 3.0, Color("5a3a22"))
			draw_circle(Vector2(-1, -1), 1.0, Color("a0754f"))
		Tipo.ITEM:
			draw_line(Vector2(0, 5), Vector2(0, -1), Color("4f7d2f"), 1.0)
			draw_circle(Vector2(0, -3), 3.0, Color("f4f1e8"))
		Tipo.PAGINA:
			draw_rect(Rect2(-4, -5, 8, 10), Color("f0e2b6"))
			for linha in 3:
				draw_line(Vector2(-3, -3 + linha * 3), Vector2(3, -3 + linha * 3), Color("8a6a3c"))
		Tipo.CAJU:
			draw_circle(Vector2(0, -1), 4.0, Color("f28c28"))
			draw_circle(Vector2(0, 4), 2.0, Color("7a5230"))
		Tipo.FRAGMENTO:
			draw_colored_polygon(PackedVector2Array([Vector2(0, -6), Vector2(4, 0), Vector2(0, 6), Vector2(-4, 0)]), Color("4fc3f7"))
