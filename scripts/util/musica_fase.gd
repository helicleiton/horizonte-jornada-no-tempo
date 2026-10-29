class_name MusicaFase
extends RefCounted
## Caminho da trilha da fase: o hino de Horizonte quando o arquivo existir.

const HINO := "res://assets/audio/musica/hino_horizonte.ogg"
const BAIAO := "res://assets/audio/musica/fase1_baiao.ogg"


static func caminho() -> String:
	return HINO if ResourceLoader.exists(HINO) else BAIAO
