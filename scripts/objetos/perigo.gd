extends Area2D
## Obstáculo que machuca ao toque (xique-xique, mandacaru, espinhos...).

@export var dano := 1


func _physics_process(_delta: float) -> void:
	for corpo in get_overlapping_bodies():
		if corpo is Player:
			corpo.receber_dano(global_position.x, dano)


func _draw() -> void:
	draw_rect(Rect2(-7, -9, 14, 9), Color("5f7f3a"))
	for x in [-6, -2, 2, 6]:
		draw_line(Vector2(x, -9), Vector2(x, -12), Color("e8dcb0"))
