class_name Narracao
extends RefCounted
## Lê as falas dos diálogos em voz alta, com a voz do aparelho (DisplayServer.tts).
## Na versão web usa a síntese de voz do navegador. Se não houver voz em
## português, fica em silêncio e o jogo continua com os blips de texto.

static var ligada := true
static var _voz := ""


static func falar(texto: String, quem: String) -> void:
	if not ligada or AudioManager.mudo or texto.strip_edges().is_empty():
		return
	var voz := _escolher_voz()
	if voz.is_empty():
		return
	# Cada personagem tem um tom um pouco diferente, para não soar tudo igual.
	var tom := 0.85 + float(absi(quem.hash()) % 5) * 0.08
	DisplayServer.tts_speak(texto, voz, 80, tom, 1.05, 0, true)


static func calar() -> void:
	if DisplayServer.tts_is_speaking():
		DisplayServer.tts_stop()


static func falando() -> bool:
	return ligada and DisplayServer.tts_is_speaking()


static func _escolher_voz() -> String:
	if _voz.is_empty():
		for voz: Dictionary in DisplayServer.tts_get_voices():
			if String(voz.get("language", "")).begins_with("pt"):
				_voz = voz["id"]
				break
	return _voz
