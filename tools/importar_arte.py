"""Importa pixel art de terceiros (CC0) e ajusta ao estilo do jogo.

Uso:  python tools/importar_arte.py
      (rode DEPOIS de tools/gerar_sprites.py, que define o contorno usado aqui)
Saída: assets/sprites/*.png
Cache dos downloads: tools/.cache_sons/ (fora do git)

Fonte: "Desert Level Decorations (Pixel-Art)", de ScratchIO, OpenGameArt, CC0.
Só aproveitamos plantas e pedras que existem no sertão cearense: palma,
coroa-de-frade, agave e pedras. Cada recorte ganha o contorno escuro de 1 px
dos sprites gerados, para não destoar.
Requer Pillow.
"""
import os
import urllib.request

from PIL import Image

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SAIDA = os.path.join(RAIZ, "assets", "sprites")
CACHE = os.path.join(RAIZ, "tools", ".cache_sons")
URL = "https://opengameart.org/sites/default/files/desert_decorations.png"
CONTORNO = (43, 26, 18, 255)

# nome no jogo -> retângulo (x0, y0, x1, y1) inclusivo na folha original
RECORTES = {
    "palma": (219, 8, 243, 31),
    "palma_pequena": (256, 11, 278, 31),
    "coroa_de_frade": (223, 34, 239, 47),
    "coroa_de_frade_pequena": (242, 37, 254, 47),
    "agave": (213, 58, 250, 79),
    "pedra": (305, 27, 335, 47),
    "pedra_grande": (304, 58, 335, 79),
}


def contorno(img):
    """Margem de 1 px e contorno em volta de tudo que não é transparente."""
    base = Image.new("RGBA", (img.width + 2, img.height + 2), (0, 0, 0, 0))
    base.paste(img, (1, 1))
    src = base.load()
    out = base.copy()
    dst = out.load()
    for y in range(base.height):
        for x in range(base.width):
            if src[x, y][3] > 0:
                continue
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                nx, ny = x + dx, y + dy
                if 0 <= nx < base.width and 0 <= ny < base.height and src[nx, ny][3] > 0:
                    dst[x, y] = CONTORNO
                    break
    return out


def main():
    os.makedirs(CACHE, exist_ok=True)
    folha = os.path.join(CACHE, "desert_decorations.png")
    if not os.path.exists(folha):
        print("baixando", URL)
        pedido = urllib.request.Request(URL, headers={"User-Agent": "Mozilla/5.0"})
        with urllib.request.urlopen(pedido) as resposta, open(folha, "wb") as f:
            f.write(resposta.read())
    src = Image.open(folha).convert("RGBA")
    for nome, (x0, y0, x1, y1) in RECORTES.items():
        contorno(src.crop((x0, y0, x1 + 1, y1 + 1))).save(os.path.join(SAIDA, nome + ".png"))
        print("ok", nome)


if __name__ == "__main__":
    main()
