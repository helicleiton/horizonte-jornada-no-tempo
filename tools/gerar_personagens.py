"""Gera as folhas de sprites dos personagens (24x36, 9 quadros) desenhadas por código.

Layout dos quadros (igual ao usado pelo jogo, ver scripts/util/sprite_factory.gd):
0-1 parado, 2-5 correr, 6 pular, 7 cair, 8 dano.
Uso: python tools/gerar_personagens.py
"""
from PIL import Image, ImageDraw
import os

LARG, ALT, QUADROS = 24, 36, 9
SAIDA = os.path.join(os.path.dirname(__file__), "..", "assets", "sprites")

def hex_cor(h, a=255):
    h = h.lstrip("#")
    return (int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16), a)

def sombra(cor, f):
    return tuple(max(0, min(255, int(c * f))) for c in cor[:3]) + (255,)

def pessoa(p, quadro):
    """Desenha um quadro do personagem p (dicionário de cores e enfeites)."""
    im = Image.new("RGBA", (LARG, ALT), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    pele = hex_cor(p["pele"]); pele_s = sombra(pele, 0.82)
    cabelo = hex_cor(p["cabelo"]); cabelo_s = sombra(cabelo, 0.7)
    camisa = hex_cor(p["camisa"]); camisa_s = sombra(camisa, 0.78)
    calca = hex_cor(p["calca"]); calca_s = sombra(calca, 0.78)
    sapato = hex_cor("3b2716")
    olho = hex_cor("1d1410")

    # Movimento por quadro
    balanco = 0
    perna_e = (0, 0); perna_d = (0, 0); braco_e = 0; braco_d = 0
    corpo_dy = 0
    if quadro in (0, 1):                       # parado: respiração
        corpo_dy = 1 if quadro == 1 else 0
    elif quadro in (2, 3, 4, 5):               # correr: 4 passos
        passo = [(-2, 1), (0, 0), (2, -1), (0, 0)][quadro - 2]
        perna_e = (passo[0], -passo[1])
        perna_d = (-passo[0], passo[1])
        braco_e = -passo[0]; braco_d = passo[0]
        corpo_dy = 1 if quadro in (3, 5) else 0
    elif quadro == 6:                          # pular: pernas dobradas
        perna_e = (-1, -3); perna_d = (1, -2)
        braco_e = -4; braco_d = -4
    elif quadro == 7:                          # cair: braços para cima
        perna_e = (0, 1); perna_d = (1, 0)
        braco_e = -5; braco_d = -5
    elif quadro == 8:                          # dano: inclinado
        balanco = 1; corpo_dy = 1
        braco_e = 2; braco_d = 2

    cx = 12 + balanco
    # Cabeça (rosto de 10x10)
    cab_x0, cab_y0 = cx - 5, 4 + corpo_dy
    d.rectangle([cab_x0, cab_y0, cab_x0 + 9, cab_y0 + 9], fill=pele, outline=None)
    d.rectangle([cab_x0 + 8, cab_y0 + 1, cab_x0 + 9, cab_y0 + 9], fill=pele_s)
    # Olhos e boca
    d.point([(cx - 2, cab_y0 + 4), (cx + 2, cab_y0 + 4)], fill=olho)
    d.point([(cx - 1, cab_y0 + 7), (cx, cab_y0 + 7), (cx + 1, cab_y0 + 7)], fill=sombra(pele, 0.55))
    # Cabelo
    if p["cabelo_longo"]:
        d.rectangle([cab_x0 - 1, cab_y0 - 1, cab_x0 + 10, cab_y0 + 2], fill=cabelo)
        d.rectangle([cab_x0 - 1, cab_y0 + 2, cab_x0, cab_y0 + 11], fill=cabelo)
        d.rectangle([cab_x0 + 9, cab_y0 + 2, cab_x0 + 10, cab_y0 + 11], fill=cabelo_s)
    else:
        d.rectangle([cab_x0, cab_y0 - 1, cab_x0 + 9, cab_y0 + 2], fill=cabelo)
        d.point([(cab_x0 + 9, cab_y0 + 3)], fill=cabelo_s)
    # Chapéu de palha
    if p["chapeu"]:
        palha = hex_cor("e6c27a"); palha_s = sombra(palha, 0.75)
        d.rectangle([cx - 9, cab_y0 + 1, cx + 9, cab_y0 + 2], fill=palha)
        d.rectangle([cx - 9, cab_y0 + 3, cx + 9, cab_y0 + 3], fill=palha_s)
        d.rectangle([cx - 4, cab_y0 - 3, cx + 4, cab_y0], fill=palha)
        d.rectangle([cx - 4, cab_y0 - 1, cx + 4, cab_y0], fill=palha_s)
        d.rectangle([cx - 4, cab_y0 - 1, cx + 4, cab_y0 - 1], fill=hex_cor("8a5a2b"))

    # Tronco (camisa)
    tr_y0 = 14 + corpo_dy
    d.rectangle([cx - 4, tr_y0, cx + 3, tr_y0 + 9], fill=camisa)
    d.rectangle([cx + 2, tr_y0, cx + 3, tr_y0 + 9], fill=camisa_s)
    if p["colete"]:
        colete = hex_cor(p["colete"])
        d.rectangle([cx - 4, tr_y0 + 1, cx + 3, tr_y0 + 9], fill=colete)
        d.rectangle([cx + 2, tr_y0 + 1, cx + 3, tr_y0 + 9], fill=sombra(colete, 0.75))
    if p["saia"]:
        d.polygon([(cx - 5, tr_y0 + 10), (cx + 4, tr_y0 + 10), (cx + 6, tr_y0 + 17), (cx - 7, tr_y0 + 17)], fill=calca)
    # Cinto
    d.rectangle([cx - 4, tr_y0 + 9, cx + 3, tr_y0 + 9], fill=hex_cor("4a2e18"))

    # Braços
    ombro_y = tr_y0 + 1
    for lado, dx, dyb in (("e", -5, braco_e), ("d", 4, braco_d)):
        x0 = cx + dx
        y0 = ombro_y + (dyb if lado == "e" else dyb)
        d.rectangle([x0, y0, x0 + 1, y0 + 7], fill=camisa if lado == "d" else camisa_s)
        d.rectangle([x0, y0 + 7, x0 + 1, y0 + 8], fill=pele)

    # Pernas e sapatos
    perna_y0 = tr_y0 + 10
    for (ox, oy), x_base, cor, cor_s in ((perna_e, cx - 4, calca, calca_s), (perna_d, cx, calca, calca_s)):
        d.rectangle([x_base + ox, perna_y0 + oy, x_base + ox + 3, perna_y0 + oy + 6], fill=cor)
        d.rectangle([x_base + ox + 2, perna_y0 + oy, x_base + ox + 3, perna_y0 + oy + 6], fill=cor_s)
        d.rectangle([x_base + ox - 1, perna_y0 + oy + 7, x_base + ox + 4, perna_y0 + oy + 8], fill=sapato)

    # Contorno escuro de 1 px ao redor do desenho
    masca = im.split()[3]
    borda = Image.new("L", im.size, 0)
    dm = ImageDraw.Draw(borda)
    for x in range(LARG):
        for y in range(ALT):
            if masca.getpixel((x, y)) == 0:
                viz = [(x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)]
                if any(0 <= a < LARG and 0 <= b < ALT and masca.getpixel((a, b)) > 0 for a, b in viz):
                    dm.point((x, y), fill=255)
    contorno = Image.new("RGBA", im.size, hex_cor("1d1410"))
    im.paste(contorno, (0, 0), borda)
    return im

def folha(p):
    out = Image.new("RGBA", (LARG * QUADROS, ALT), (0, 0, 0, 0))
    for q in range(QUADROS):
        out.paste(pessoa(p, q), (q * LARG, 0))
    return out

PERSONAGENS = {
    "chico": dict(pele="e0a96d", cabelo="3b2a1f", camisa="3b6ea5", calca="5b4a3a", chapeu=True, cabelo_longo=False, colete=None, saia=False),
    "luzia": dict(pele="e7b184", cabelo="2a1d16", camisa="c95a5a", calca="6b4f8c", chapeu=False, cabelo_longo=True, colete=None, saia=True),
    "zeca": dict(pele="c68a5a", cabelo="5a3b25", camisa="7a5230", calca="4d3a2a", chapeu=True, cabelo_longo=False, colete="8b5a2b", saia=False),
    "mariinha": dict(pele="e0b08a", cabelo="6b3a2a", camisa="b8506c", calca="3f4f6b", chapeu=True, cabelo_longo=True, colete=None, saia=True),
    "venancio": dict(pele="d9a77a", cabelo="c9c9c9", camisa="f0ecd8", calca="4f5b68", chapeu=True, cabelo_longo=False, colete=None, saia=False),
    "tonho": dict(pele="d9a77a", cabelo="2b1d14", camisa="4f9a4f", calca="3a5c8a", chapeu=False, cabelo_longo=False, colete=None, saia=False),
    "bastiana": dict(pele="eadbc8", cabelo="ece8df", camisa="7a4f8c", calca="4e3a58", chapeu=False, cabelo_longo=True, colete=None, saia=True),
}

if __name__ == "__main__":
    for nome, p in PERSONAGENS.items():
        folha(p).save(os.path.join(SAIDA, f"{nome}.png"))
        print("gerado", nome)
