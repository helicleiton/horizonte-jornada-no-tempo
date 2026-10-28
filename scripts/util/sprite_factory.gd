class_name SpriteFactory
extends RefCounted
## Monta SpriteFrames a partir de tiras horizontais de quadros do mesmo tamanho.
## Cada animação é [quadro_inicial, quantidade, fps, repetir].

const ANIMACOES_PERSONAGEM := {
	"parado": [0, 2, 2.5, true],
	"correr": [2, 4, 10.0, true],
	"pular": [6, 1, 1.0, false],
	"cair": [7, 1, 1.0, false],
	"dano": [8, 1, 1.0, false],
	"derrota": [8, 1, 1.0, false],
}

const ANIMACOES_PARADO := {
	"parado": [0, 2, 2.0, true],
}


static func frames_de_tira(caminho: String, largura: int, animacoes: Dictionary) -> SpriteFrames:
	var textura: Texture2D = load(caminho)
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	for nome: String in animacoes:
		var cfg: Array = animacoes[nome]
		frames.add_animation(nome)
		frames.set_animation_speed(nome, cfg[2])
		frames.set_animation_loop(nome, cfg[3])
		for i in int(cfg[1]):
			var quadro := AtlasTexture.new()
			quadro.atlas = textura
			quadro.region = Rect2((int(cfg[0]) + i) * largura, 0, largura, textura.get_height())
			frames.add_frame(nome, quadro)
	return frames


static func animado(caminho: String, largura: int, animacoes: Dictionary, deslocamento: Vector2) -> AnimatedSprite2D:
	if not ResourceLoader.exists(caminho):
		return null
	var sprite := AnimatedSprite2D.new()
	sprite.sprite_frames = frames_de_tira(caminho, largura, animacoes)
	sprite.position = deslocamento
	sprite.play(animacoes.keys()[0])
	return sprite
