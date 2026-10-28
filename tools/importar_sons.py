"""Importa gravações reais (CC0) do Freesound e da Kenney para o jogo.

Uso:  python tools/importar_sons.py
      (rode DEPOIS de tools/gerar_audio.py: este script sobrescreve parte dos arquivos gerados)
Saída: assets/audio/sfx/*.ogg e assets/audio/ambiente/*.ogg
Cache dos downloads: tools/.cache_sons/ (fora do git)

Todas as fontes são Creative Commons 0 (domínio público). Os autores estão
listados em CREDITOS.md mesmo assim, por cortesia.
Requer numpy e ffmpeg.
"""
import os
import subprocess
import urllib.request
import zipfile

import numpy as np

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
AUDIO = os.path.join(RAIZ, "assets", "audio")
CACHE = os.path.join(RAIZ, "tools", ".cache_sons")
SR = 44100

FREESOUND = "https://cdn.freesound.org/previews/"
KENNEY_ZIP = ("https://github.com/Calinou/kenney-interface-sounds/archive/"
              "ad144fc2dd079cdd728bc8c7fcf9c4e64a7a7f83.zip")

# id -> (caminho da prévia HQ no Freesound, autor, título)
FONTES = {
    "jumento": ("560/560692_10936067-hq.ogg", "StarNinjas37", "Donkey Bray"),
    "triangulo": ("609/609773_7096110-hq.ogg", "Ilson_Junior", "Triângulo brasileiro pequeno"),
    "pagina": ("397/397548_6142149-hq.ogg", "LilMati", "Page Turn 01"),
    "livro": ("164/164806_1460963-hq.ogg", "exterminat", "Page turns and book close/open"),
    "passos": ("264/264469_1042839-hq.ogg", "aglinder", "Footsteps Dirt 01"),
    "roca": ("478/478790_9726487-hq.ogg", "Cristiano_Scherer", "Ambience Countryside Day, crickets, Atlantic Forest Brazil"),
    "riacho": ("264/264180_4965426-hq.ogg", "easy_thunder", "Creek - Moderate Flow"),
}

# arquivo do jogo -> (fonte, início s, duração s, pico dB)
EFEITOS = {
    "sfx/passo1": ("passos", 0.84, 0.20, -2.0),
    "sfx/passo2": ("passos", 1.23, 0.20, -2.0),
    "sfx/pagina": ("pagina", 0.0, 0.50, -1.0),
    "sfx/almanaque_abrir": ("livro", 15.86, 0.48, -1.0),
    "sfx/almanaque_fechar": ("livro", 21.46, 0.36, -1.0),
    "sfx/semente": ("triangulo", 0.0, 0.24, -1.0),
    "sfx/jumento": ("jumento", 0.0, 1.81, -1.0),
}

# arquivo do jogo -> (fonte, início s, duração do loop s, média dB)
AMBIENTES = {
    "ambiente/dia_sertao": ("roca", 20.0, 30.0, -20.0),
    "ambiente/nascente": ("riacho", 10.0, 12.0, -17.0),
}


def baixar(url, destino):
    if not os.path.exists(destino):
        print("baixando", url)
        pedido = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
        with urllib.request.urlopen(pedido) as resposta, open(destino, "wb") as f:
            f.write(resposta.read())
    return destino


def ler(caminho):
    bruto = subprocess.run(
        ["ffmpeg", "-v", "error", "-i", caminho, "-ac", "1", "-ar", str(SR), "-f", "f32le", "-"],
        capture_output=True, check=True).stdout
    return np.frombuffer(bruto, np.float32).copy()


def gravar(x, nome):
    destino = os.path.join(AUDIO, nome + ".ogg")
    subprocess.run(
        ["ffmpeg", "-v", "error", "-y", "-f", "f32le", "-ar", str(SR), "-ac", "1", "-i", "-",
         "-c:a", "libvorbis", "-q:a", "5", destino],
        input=np.clip(x, -1, 1).astype(np.float32).tobytes(), check=True)
    print("ok", nome)


def recortar(x, inicio, duracao):
    return x[int(inicio * SR):int((inicio + duracao) * SR)].copy()


def bordas(x, entrada=0.004, saida=0.03):
    """Rampa curta no começo e no fim para não estalar."""
    a, b = int(entrada * SR), int(saida * SR)
    x[:a] *= np.linspace(0, 1, a)
    x[-b:] *= np.linspace(1, 0, b)
    return x


def pico(x, db):
    return x * (10 ** (db / 20) / (np.abs(x).max() + 1e-9))


def media(x, db):
    rms = np.sqrt(np.mean(x ** 2)) + 1e-9
    x = x * (10 ** (db / 20) / rms)
    return np.clip(x, -0.95, 0.95)


def loop(x, duracao, fade=1.5):
    """Funde o fim no começo: o arquivo repete sem emenda audível."""
    n, f = int(duracao * SR), int(fade * SR)
    corpo = x[:n].copy()
    cauda = x[n:n + f]
    rampa = np.linspace(0, 1, f)
    corpo[:f] = corpo[:f] * rampa + cauda * (1 - rampa)
    return corpo


def kenney_escolha():
    zip_local = baixar(KENNEY_ZIP, os.path.join(CACHE, "kenney_interface.zip"))
    with zipfile.ZipFile(zip_local) as z:
        nome = next(n for n in z.namelist() if n.endswith("select_001.wav"))
        destino = os.path.join(CACHE, "kenney_select_001.wav")
        with open(destino, "wb") as f:
            f.write(z.read(nome))
    gravar(bordas(pico(ler(destino), -1.0)), "sfx/escolha")


def main():
    os.makedirs(CACHE, exist_ok=True)
    sons = {}
    for chave, (caminho, _autor, _titulo) in FONTES.items():
        arquivo = baixar(FREESOUND + caminho, os.path.join(CACHE, chave + ".ogg"))
        sons[chave] = ler(arquivo)

    for nome, (fonte, inicio, duracao, db) in EFEITOS.items():
        gravar(bordas(pico(recortar(sons[fonte], inicio, duracao), db)), nome)

    for nome, (fonte, inicio, duracao, db) in AMBIENTES.items():
        trecho = recortar(sons[fonte], inicio, duracao + 2.0)
        gravar(media(loop(trecho, duracao), db), nome)

    kenney_escolha()


if __name__ == "__main__":
    main()
