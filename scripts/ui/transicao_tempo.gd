class_name TransicaoTempo
extends CanvasLayer
## Animação de teletransporte entre as fases: o viajante do tempo (Chico ou Luzia)
## surge em ondas de luz, aparece o ano do novo cenário e então a fase começa.

## Ano e lugar mostrados ao chegar em cada fase.
const DESTINOS := {
	"res://scenes/levels/fase_teste.tscn": "1932 · O Olho d'Água",
	"res://scenes/levels/fase2.tscn": "1987 · A emancipação",
	"res://scenes/levels/fase2b.tscn": "1988 · A primeira eleição",
	"res://scenes/levels/fase3.tscn": "1990 · O polo industrial",
	"res://scenes/levels/fase4.tscn": "Hoje · Plantar o futuro",
	"res://scenes/levels/fase5.tscn": "2000 · A cidade que se reinventa",
	"res://scenes/levels/fase6.tscn": "Hoje · As águas de Horizonte",
	"res://scenes/levels/fase7.tscn": "Hoje · A festa de São João",
	"res://scenes/levels/fase_carro.tscn": "Hoje · Dirigindo pela cidade",
	"res://scenes/levels/fase9.tscn": "2020 a 2026 · Os anos recentes",
}

var caminho := ""
var _progresso := 0.0
var _viajante: TextureRect
var _legenda: Label
var _veu: ColorRect
var _flash: ColorRect
var _aneis: Aneis


func _ready() -> void:
	layer = 40
	process_mode = Node.PROCESS_MODE_ALWAYS

	_veu = ColorRect.new()
	_veu.color = Color(0.04, 0.05, 0.14, 0.0)
	_veu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_veu)

	var protagonista := "luzia" if GameState.nome_protagonista == "Luzia" else "chico"
	var folha: Texture2D = load("res://assets/sprites/%s.png" % protagonista)
	_viajante = TextureRect.new()
	var quadro := AtlasTexture.new()
	quadro.atlas = folha
	quadro.region = Rect2(0, 0, 24, 36)
	_viajante.texture = quadro
	_viajante.stretch_mode = TextureRect.STRETCH_SCALE
	_viajante.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_viajante.size = Vector2(96, 144)
	_viajante.position = Vector2(112, 18)
	_viajante.pivot_offset = Vector2(48, 72)
	_viajante.modulate.a = 0.0
	_viajante.scale = Vector2(0.1, 0.1)
	add_child(_viajante)

	_legenda = Label.new()
	_legenda.text = DESTINOS.get(caminho, "")
	_legenda.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_legenda.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_legenda.offset_top = 150
	_legenda.add_theme_font_size_override("font_size", 16)
	_legenda.add_theme_color_override("font_color", Color("f4c95d"))
	_legenda.modulate.a = 0.0
	add_child(_legenda)

	_aneis = Aneis.new()
	_aneis.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_aneis)

	_flash = ColorRect.new()
	_flash.color = Color(1, 1, 1, 0.0)
	_flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_flash)

	var sequencia := create_tween()
	sequencia.tween_property(_veu, "color:a", 0.85, 0.5)
	sequencia.tween_property(self, "_progresso", 1.0, 1.4)
	sequencia.parallel().tween_property(_viajante, "modulate:a", 1.0, 0.5)
	sequencia.parallel().tween_property(_viajante, "scale", Vector2(1, 1), 0.9).set_trans(Tween.TRANS_BACK)
	sequencia.tween_property(_legenda, "modulate:a", 1.0, 0.4)
	sequencia.tween_interval(0.5)
	sequencia.tween_property(_flash, "color:a", 1.0, 0.25)
	sequencia.tween_callback(_trocar)


func _process(_delta: float) -> void:
	# O viajante treme enquanto a energia do teletransporte cresce.
	_viajante.position.x = 112.0 + sin(Time.get_ticks_msec() * 0.05) * 2.0 * _progresso
	_aneis.progresso = _progresso
	_aneis.queue_redraw()


## Anéis de luz que se expandem a partir do viajante.
class Aneis extends Control:
	var progresso := 0.0

	func _draw() -> void:
		var centro := Vector2(160, 90)
		for i in 3:
			var fase := fmod(progresso + i * 0.33, 1.0)
			var raio := 10.0 + fase * 120.0
			var alfa := (1.0 - fase) * 0.7
			draw_arc(centro, raio, 0.0, TAU, 48, Color(0.6, 0.85, 1.0, alfa), 2.0)


func _trocar() -> void:
	get_tree().change_scene_to_file(caminho)
	queue_free()
