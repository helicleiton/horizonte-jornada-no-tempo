class_name LuzDoDia
extends CanvasLayer
## Luz do dia sobre o cenário: começa com um tom quente de amanhecer, com uma névoa
## leve no horizonte, e vai clareando até o meio-dia em poucos minutos.

## Tempo, em segundos, para a luz chegar ao meio-dia.
@export var duracao := 150.0
## Cor e força do tom de luz da fase (o alfa diminui até o meio-dia).
var tom := Color(1.0, 0.7, 0.45, 0.2)
## Desenho do sol no céu da fase, que a luz move ao longo do dia (opcional).
var sol: Control = null

var _tempo := 0.0
var _brilho: TextureRect
var _tinta: ColorRect
var _nevoa: Array[ColorRect] = []


func _ready() -> void:
	layer = 2
	_tinta = ColorRect.new()
	_tinta.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_tinta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_tinta)
	# Brilho do sol: um halo suave que pulsa devagar em volta do sol.
	var degrade := Gradient.new()
	degrade.set_color(0, Color(1.0, 0.95, 0.7, 0.9))
	degrade.set_color(1, Color(1.0, 0.95, 0.7, 0.0))
	var radial := GradientTexture2D.new()
	radial.gradient = degrade
	radial.fill = GradientTexture2D.FILL_RADIAL
	radial.fill_from = Vector2(0.5, 0.5)
	radial.fill_to = Vector2(1.0, 0.5)
	_brilho = TextureRect.new()
	_brilho.texture = radial
	_brilho.size = Vector2(96, 96)
	_brilho.position = Vector2(200, -10)
	_brilho.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_brilho)
	# Faixas finas no horizonte, mais fortes no meio, para a névoa não ter bordas duras.
	for i in 10:
		var faixa := ColorRect.new()
		faixa.color = Color(0.96, 0.9, 0.82, 0.0)
		faixa.position = Vector2(0, 92 + i * 4)
		faixa.size = Vector2(320, 4)
		faixa.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(faixa)
		_nevoa.append(faixa)


func _process(delta: float) -> void:
	_tempo += delta
	_brilho.modulate.a = 0.75 + sin(_tempo * 1.2) * 0.15
	var t := clampf(_tempo / duracao, 0.0, 1.0)
	# O sol nasce à direita, baixo, e sobe até o meio-dia; o halo acompanha o sol.
	if sol:
		sol.position = Vector2(lerpf(252.0, 200.0, t), lerpf(60.0, 8.0, sin(t * PI * 0.5)))
		_brilho.position = sol.position + sol.size / 2.0 - Vector2(48, 48)
	_tinta.color = Color(tom.r, tom.g, tom.b, tom.a * (1.0 - t))
	for i in _nevoa.size():
		var pico := 1.0 - absf((i - 4.5) / 5.0)
		_nevoa[i].color.a = 0.35 * pico * (1.0 - t)
