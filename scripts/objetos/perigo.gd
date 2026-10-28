extends Area2D
## Obstáculo que machuca ao toque (xique-xique, espinhos...).

@export var dano := 1
@export_file("*.png") var sprite := "res://assets/sprites/xique_xique.png"


func _ready() -> void:
	if ResourceLoader.exists(sprite):
		var s := Sprite2D.new()
		s.texture = load(sprite)
		s.centered = false
		s.position = Vector2(-s.texture.get_width() / 2.0, -s.texture.get_height() + 1.0)
		add_child(s)


func _physics_process(_delta: float) -> void:
	for corpo in get_overlapping_bodies():
		if corpo is Player:
			corpo.receber_dano(global_position.x, dano)
