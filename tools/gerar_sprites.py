"""Gera toda a pixel art do jogo (arte original, sem dependências externas além do Pillow).

Uso:  python tools/gerar_sprites.py
Saída: assets/sprites/*.png

Personagens: tiras horizontais de quadros 24x36 (pés na linha 34, contorno na 35).
Ordem dos quadros: 0-1 parado | 2-5 correr | 6 pular | 7 cair | 8 dano
"""
import math
import os
import random

from PIL import Image, ImageDraw

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SAIDA = os.path.join(RAIZ, "assets", "sprites")
os.makedirs(SAIDA, exist_ok=True)

FW, FH = 24, 36
CONTORNO = (43, 26, 18, 255)
CLARO = (0, 0, 0, 0)


def c(r, g, b, a=255):
    return (r, g, b, a)


def sh(cor, f):
    return tuple(max(0, min(255, int(v * f))) for v in cor[:3]) + (255,)


def contorno(img, cor=CONTORNO):
    """Contorno de 1 px em volta de tudo que não é transparente."""
    w, h = img.size
    src = img.load()
    out = img.copy()
    dst = out.load()
    for y in range(h):
        for x in range(w):
            if src[x, y][3] == 0:
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    nx, ny = x + dx, y + dy
                    if 0 <= nx < w and 0 <= ny < h and src[nx, ny][3] > 0:
                        dst[x, y] = cor
                        break
    return out


def margem(img, n=1):
    novo = Image.new("RGBA", (img.width + 2 * n, img.height + 2 * n), CLARO)
    novo.paste(img, (n, n))
    return novo


def salvar(img, nome):
    img.save(os.path.join(SAIDA, nome))


# ----------------------------------------------------------------------------
# Personagens
# ----------------------------------------------------------------------------

POSES = [
    # pernas (dxA, elevA, dxB, elevB) | braços (dx_tras, dy_tras, dx_frente, dy_frente) | extras
    dict(pernas=(0, 0, 0, 0), bracos=(0, 0, 0, 0)),
    dict(pernas=(0, 0, 0, 0), bracos=(0, 1, 0, 1), cabeca=1),
    dict(pernas=(-2, 0, 2, 2), bracos=(-1, 0, 1, 0)),
    dict(pernas=(-1, 0, 0, 3), bracos=(0, 0, 0, 0), cabeca=1),
    dict(pernas=(2, 2, -2, 0), bracos=(1, 0, -1, 0)),
    dict(pernas=(0, 3, -1, 0), bracos=(0, 0, 0, 0), cabeca=1),
    dict(pernas=(-2, 2, 2, 0), bracos=(0, -4, 0, -4)),
    dict(pernas=(-1, 0, 1, 1), bracos=(-1, -2, 1, -2)),
    dict(pernas=(-1, 0, 1, 0), bracos=(0, -3, 0, -3), olhos="fechados"),
]


def pessoa(pose, p):
    img = Image.new("RGBA", (FW, FH), CLARO)
    d = ImageDraw.Draw(img)
    crianca = p.get("crianca", False)
    perna = 5 if crianca else 7
    tronco = 7 if crianca else 9
    cabeca = 8 if crianca else 9
    pe = 34
    lt = pe - perna + 1
    tt = lt - tronco
    ht = tt - cabeca + pose.get("cabeca", 0)
    pele, camisa, calca = p["pele"], p["camisa"], p["calca"]
    sapato = p.get("sapato", sh(pele, 0.55))
    dxa, ea, dxb, eb = pose["pernas"]
    bdx, bdy, fdx, fdy = pose["bracos"]
    arm_len = 5 if crianca else 6
    cor_perna = p.get("cor_perna", calca)

    # braço de trás
    ya = tt + 1 + bdy
    d.rectangle([6 + bdx, ya, 7 + bdx, ya + arm_len - 3], fill=sh(camisa, 0.75))
    d.rectangle([6 + bdx, ya + arm_len - 2, 7 + bdx, ya + arm_len - 1], fill=sh(pele, 0.8))

    # pernas
    for x0, dx, el in ((8, dxa, ea), (13, dxb, eb)):
        x = x0 + dx
        base = pe - el
        d.rectangle([x, lt, x + 2, base], fill=cor_perna if x0 == 13 else sh(cor_perna, 0.8))
        d.rectangle([x, base, x + 2, base], fill=sapato)

    # tronco
    d.rectangle([8, tt, 15, lt - 1], fill=camisa)
    d.rectangle([8, tt, 8, lt - 1], fill=sh(camisa, 0.78))
    d.rectangle([15, tt, 15, lt - 2], fill=sh(camisa, 1.12))
    if p.get("colete"):
        d.rectangle([8, tt, 9, lt - 1], fill=p["colete"])
        d.rectangle([14, tt, 15, lt - 1], fill=sh(p["colete"], 1.1))
    if p.get("vestido"):
        v = p["vestido"]
        d.rectangle([8, tt, 15, lt - 1], fill=v)
        d.rectangle([8, tt, 8, lt - 1], fill=sh(v, 0.78))
        d.polygon([(7, lt + 3), (16, lt + 3), (15, lt - 1), (8, lt - 1)], fill=v)
        d.rectangle([7, lt + 3, 16, lt + 3], fill=sh(v, 0.7))
        d.rectangle([8, lt - 1, 15, lt - 1], fill=sh(v, 0.85))
    else:
        d.rectangle([8, lt - 1, 15, lt - 1], fill=sh(calca, 0.85))
    if p.get("xale"):
        x_ = p["xale"]
        d.polygon([(7, tt), (16, tt), (17, tt + 4), (6, tt + 4)], fill=x_)
        d.rectangle([7, tt + 4, 16, tt + 4], fill=sh(x_, 0.7))

    # cabeça
    d.rectangle([8, ht, 15, tt - 1], fill=pele)
    d.rectangle([8, ht, 8, tt - 1], fill=sh(pele, 0.8))
    d.point((16, ht + 5), fill=pele)  # nariz
    if pose.get("olhos") == "fechados":
        d.line([(12, ht + 4), (13, ht + 4)], fill=CONTORNO)
        d.point((14, ht + 7), fill=sh(pele, 0.55))
    else:
        d.point((13, ht + 4), fill=CONTORNO)
        d.point((14, ht + 7), fill=sh(pele, 0.6))
    if p.get("bigode"):
        d.line([(14, ht + 6), (16, ht + 6)], fill=p["bigode"])

    # cabelo
    cabelo = p.get("cabelo")
    if cabelo:
        d.rectangle([8, ht, 15, ht + 1], fill=cabelo)
        d.rectangle([8, ht, 9, ht + 5], fill=cabelo)
        if p.get("trança"):
            d.rectangle([7, ht + 2, 8, ht + 9], fill=cabelo)
            d.point((7, ht + 10), fill=p["trança"])
            d.point((7, ht + 11), fill=p["trança"])
    if p.get("coque"):
        d.rectangle([9, ht - 3, 12, ht - 1], fill=p["coque"])
        d.rectangle([9, ht - 3, 12, ht - 3], fill=sh(p["coque"], 0.8))
    if p.get("lenco"):
        l_ = p["lenco"]
        d.rectangle([8, ht - 1, 15, ht + 1], fill=l_)
        d.rectangle([8, ht + 2, 9, ht + 4], fill=l_)
        d.rectangle([6, ht + 2, 7, ht + 4], fill=sh(l_, 0.8))
        d.point((13, ht - 1), fill=sh(l_, 1.2))

    # chapéus
    chapeu = p.get("chapeu")
    if chapeu == "palha":
        pal = p.get("cor_chapeu", c(222, 190, 100))
        d.rectangle([8, ht - 4, 15, ht - 1], fill=pal)
        d.rectangle([8, ht - 2, 15, ht - 2], fill=sh(pal, 0.7))
        d.rectangle([5, ht, 18, ht + 1], fill=sh(pal, 0.92))
        d.rectangle([5, ht + 1, 18, ht + 1], fill=sh(pal, 0.72))
        d.point((10, ht - 3), fill=sh(pal, 1.15))
    elif chapeu == "couro":
        co = c(120, 74, 40)
        d.rectangle([8, ht - 5, 15, ht - 1], fill=co)
        d.rectangle([7, ht - 3, 16, ht - 1], fill=co)
        d.rectangle([4, ht, 19, ht], fill=sh(co, 0.8))
        d.rectangle([7, ht - 1, 16, ht - 1], fill=sh(co, 0.65))
        d.rectangle([9, ht - 4, 10, ht - 3], fill=sh(co, 1.25))
        d.point((17, ht - 2), fill=c(230, 190, 80))

    # braço da frente
    ya = tt + 1 + fdy
    d.rectangle([16 + fdx, ya, 17 + fdx, ya + arm_len - 3], fill=sh(camisa, 1.05))
    d.rectangle([16 + fdx, ya + arm_len - 2, 17 + fdx, ya + arm_len - 1], fill=pele)

    if p.get("bengala"):
        d.rectangle([20, tt + 3, 20, pe], fill=c(120, 80, 45))
        d.rectangle([19, tt + 2, 20, tt + 2], fill=c(120, 80, 45))

    return contorno(img)


def personagem(nome, p):
    tira = Image.new("RGBA", (FW * len(POSES), FH), CLARO)
    for i, pose in enumerate(POSES):
        tira.paste(pessoa(pose, p), (i * FW, 0))
    salvar(tira, nome + ".png")
    return tira


PERSONAGENS = {
    "chico": dict(pele=c(184, 120, 76), camisa=c(60, 110, 170), calca=c(110, 78, 50),
                  cabelo=c(40, 28, 22), chapeu="palha"),
    "luzia": dict(pele=c(176, 114, 74), camisa=c(200, 70, 70), calca=c(110, 78, 50),
                  vestido=c(205, 75, 75), cabelo=c(35, 25, 22), trança=c(240, 200, 70),
                  sapato=c(110, 70, 45), cor_perna=c(176, 114, 74)),
    "zeca": dict(pele=c(146, 96, 62), camisa=c(235, 225, 200), calca=c(70, 60, 55),
                 colete=c(120, 78, 45), chapeu="couro", bigode=c(45, 30, 22), sapato=c(60, 40, 30)),
    "mariinha": dict(pele=c(168, 108, 72), camisa=c(235, 160, 90), calca=c(120, 80, 50),
                     vestido=c(190, 75, 105), lenco=c(240, 205, 90), sapato=c(110, 70, 45),
                     cor_perna=c(168, 108, 72)),
    "venancio": dict(pele=c(218, 170, 130), camisa=c(240, 235, 220), calca=c(110, 86, 60),
                     colete=c(150, 150, 150), chapeu="palha", cor_chapeu=c(238, 224, 175),
                     bigode=c(200, 200, 200), sapato=c(70, 50, 38)),
    "tonho": dict(pele=c(172, 112, 72), camisa=c(215, 90, 70), calca=c(95, 120, 150),
                  cabelo=c(35, 25, 20), crianca=True, sapato=c(150, 98, 64)),
    "bastiana": dict(pele=c(120, 76, 52), camisa=c(235, 230, 235), calca=c(90, 60, 80),
                     vestido=c(120, 90, 150), xale=c(230, 200, 120), coque=c(238, 238, 240),
                     cabelo=c(236, 236, 238), bengala=True, sapato=c(80, 55, 40),
                     cor_perna=c(120, 76, 52)),
}


# ----------------------------------------------------------------------------
# Jumento (animal de carga do Zeca)
# ----------------------------------------------------------------------------

def jumento(quadro):
    img = Image.new("RGBA", (40, 30), CLARO)
    d = ImageDraw.Draw(img)
    pelo, escuro, claro = c(128, 112, 98), c(88, 74, 64), c(205, 190, 168)
    d.rectangle([6, 3 + quadro % 2, 7, 6], fill=pelo)  # rabo (cai)
    d.rectangle([6, 8 + quadro, 7, 14 + quadro], fill=escuro)
    d.rectangle([8, 9, 28, 19], fill=pelo)
    d.rectangle([8, 17, 28, 19], fill=claro)
    d.rectangle([8, 9, 9, 19], fill=sh(pelo, 0.85))
    for x in (9, 13, 22, 26):
        d.rectangle([x, 20, x + 2, 28], fill=pelo if x in (13, 26) else sh(pelo, 0.8))
        d.rectangle([x, 28, x + 2, 29], fill=escuro)
    d.polygon([(27, 8), (35, 8), (37, 16), (33, 19), (28, 17)], fill=pelo)
    d.rectangle([33, 13, 37, 18], fill=claro)
    d.polygon([(28, 7), (30, 0), (32, 7)], fill=pelo)
    d.polygon([(32, 7), (34 + quadro, 1), (35, 8)], fill=sh(pelo, 0.8))
    d.point((33, 11), fill=CONTORNO)
    d.rectangle([34, 14, 34, 14], fill=escuro)
    # cangalha e sacos
    d.rectangle([10, 7, 26, 9], fill=c(140, 88, 48))
    d.rectangle([11, 10, 17, 18], fill=c(206, 184, 130))
    d.rectangle([11, 10, 12, 18], fill=c(176, 154, 100))
    d.rectangle([19, 10, 25, 18], fill=c(206, 184, 130))
    d.rectangle([19, 10, 20, 18], fill=c(176, 154, 100))
    d.line([(11, 14), (17, 14)], fill=c(150, 126, 80))
    d.line([(19, 14), (25, 14)], fill=c(150, 126, 80))
    return contorno(img)


def salvar_jumento():
    tira = Image.new("RGBA", (80, 30), CLARO)
    for i in range(2):
        tira.paste(jumento(i), (i * 40, 0))
    salvar(tira, "jumento.png")


# ----------------------------------------------------------------------------
# Cenário
# ----------------------------------------------------------------------------

def elipse_pontilhada(d, caixa, base, rnd, luz=1.18, sombra=0.72):
    x0, y0, x1, y1 = caixa
    d.ellipse(caixa, fill=base)
    # sombra embaixo/direita e luz em cima/esquerda
    cx, cy = (x0 + x1) / 2, (y0 + y1) / 2
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            if ((x - cx) / ((x1 - x0) / 2 + 0.01)) ** 2 + ((y - cy) / ((y1 - y0) / 2 + 0.01)) ** 2 <= 1:
                t = ((x - cx) / (x1 - x0 + 1)) * 0.6 + ((y - cy) / (y1 - y0 + 1))
                if t > 0.22 and rnd.random() < 0.7:
                    d.point((x, y), fill=sh(base, sombra))
                elif t < -0.2 and rnd.random() < 0.35:
                    d.point((x, y), fill=sh(base, luz))


def cajueiro():
    rnd = random.Random(7)
    img = Image.new("RGBA", (64, 56), CLARO)
    d = ImageDraw.Draw(img)
    tronco = c(110, 72, 44)
    # tronco torto
    pts = [(30, 55, 6), (29, 48, 6), (27, 42, 5), (28, 36, 5), (31, 30, 4), (34, 26, 3)]
    for x, y, w in pts:
        d.rectangle([x - w // 2, y - 3, x + w // 2, y + 3], fill=tronco)
    d.line([(31, 36), (22, 28)], fill=tronco, width=3)
    d.line([(32, 34), (42, 27)], fill=tronco, width=3)
    d.rectangle([27, 40, 28, 55], fill=sh(tronco, 0.72))
    d.rectangle([24, 54, 36, 55], fill=sh(tronco, 0.8))
    verde = c(74, 132, 58)
    for caixa in [(2, 14, 30, 36), (22, 6, 52, 30), (34, 16, 62, 38), (12, 2, 40, 22), (16, 20, 46, 40)]:
        elipse_pontilhada(d, caixa, verde, rnd)
    for _ in range(9):
        x, y = rnd.randint(8, 56), rnd.randint(14, 36)
        d.rectangle([x, y, x + 2, y + 2], fill=rnd.choice([c(236, 120, 40), c(214, 70, 50), c(244, 170, 50)]))
        d.point((x + 1, y - 1), fill=c(80, 110, 50))
    return contorno(img, c(30, 60, 36, 255))


def carnauba():
    img = Image.new("RGBA", (40, 80), CLARO)
    d = ImageDraw.Draw(img)
    tronco = c(150, 120, 84)
    d.rectangle([18, 22, 21, 79], fill=tronco)
    d.rectangle([18, 22, 18, 79], fill=sh(tronco, 0.78))
    d.rectangle([21, 22, 21, 79], fill=sh(tronco, 1.12))
    for y in range(26, 79, 4):
        d.line([(18, y), (21, y)], fill=sh(tronco, 0.6))
    cx, cy = 20, 22
    verdes = [c(88, 138, 60), c(110, 160, 72), c(66, 112, 52)]
    for i, ang in enumerate(range(-20, 201, 24)):
        a = math.radians(ang)
        pts = []
        for t in range(0, 11):
            tt = t / 10
            x = cx + math.cos(a) * tt * 17
            y = cy - math.sin(a) * tt * 12 + (tt ** 2) * 14
            pts.append((x, y))
        d.line(pts, fill=verdes[i % 3], width=2)
        d.line(pts[:7], fill=sh(verdes[i % 3], 1.15), width=1)
    d.ellipse([17, 19, 23, 25], fill=c(196, 170, 90))
    return contorno(img, c(34, 58, 36, 255))


def casa_taipa(cor_parede=c(212, 164, 104), cor_palha=c(206, 170, 84)):
    rnd = random.Random(11)
    img = Image.new("RGBA", (72, 52), CLARO)
    d = ImageDraw.Draw(img)
    # parede
    d.rectangle([6, 22, 65, 50], fill=cor_parede)
    d.rectangle([6, 22, 9, 50], fill=sh(cor_parede, 0.85))
    d.rectangle([6, 48, 65, 50], fill=c(140, 120, 100))
    # reboco caído mostrando o pau a pique
    for (x, y, w, h) in [(12, 32, 12, 14), (46, 26, 14, 10), (50, 40, 10, 8)]:
        d.rectangle([x, y, x + w, y + h], fill=c(122, 82, 50))
        for gx in range(x + 2, x + w, 3):
            d.line([(gx, y), (gx, y + h)], fill=c(84, 56, 36))
        for gy in range(y + 2, y + h, 3):
            d.line([(x, gy), (x + w, gy)], fill=c(150, 104, 66))
    for _ in range(40):
        d.point((rnd.randint(8, 64), rnd.randint(24, 47)), fill=sh(cor_parede, rnd.choice([0.88, 1.08])))
    # porta e janela
    d.rectangle([30, 30, 41, 50], fill=c(96, 60, 38))
    d.rectangle([31, 31, 40, 50], fill=c(70, 42, 28))
    d.rectangle([30, 30, 41, 30], fill=c(140, 92, 56))
    d.point((38, 41), fill=c(230, 190, 80))
    d.rectangle([13, 25, 21, 30], fill=c(60, 40, 30))
    # telhado de palha (dois níveis de beiral)
    d.polygon([(0, 24), (36, 1), (71, 24)], fill=cor_palha)
    for i, y in enumerate(range(6, 24, 3)):
        meia = (y - 1) * 36 / 23
        d.line([(36 - meia * 1.5 + 2, y), (36 + meia * 1.5 - 2, y)], fill=sh(cor_palha, 0.78))
    for x in range(4, 68, 5):
        d.point((x, 22 + (x % 2)), fill=sh(cor_palha, 0.7))
    d.polygon([(36, 1), (71, 24), (68, 24), (36, 4)], fill=sh(cor_palha, 1.12))
    d.rectangle([0, 23, 71, 24], fill=sh(cor_palha, 0.75))
    return contorno(img)


def xique_xique():
    img = Image.new("RGBA", (18, 14), CLARO)
    d = ImageDraw.Draw(img)
    v, e = c(92, 140, 70), c(238, 226, 176)
    for (x0, y0, x1, y1) in [(2, 5, 7, 12), (6, 2, 12, 12), (11, 6, 16, 12), (4, 8, 14, 12)]:
        d.ellipse([x0, y0, x1, y1], fill=v)
    d.rectangle([6, 4, 7, 12], fill=sh(v, 0.8))
    for (x, y) in [(2, 4), (5, 2), (8, 1), (11, 2), (14, 5), (16, 8), (1, 8), (9, 11), (13, 10)]:
        d.point((x, y), fill=e)
        d.point((x, y + 1), fill=e)
    return contorno(img)


def mandacaru():
    img = Image.new("RGBA", (28, 56), CLARO)
    d = ImageDraw.Draw(img)
    v = c(76, 128, 78)
    d.rectangle([11, 8, 16, 55], fill=v)
    d.rectangle([11, 8, 12, 55], fill=sh(v, 0.78))
    d.rectangle([15, 8, 16, 55], fill=sh(v, 1.15))
    d.rectangle([3, 26, 10, 30], fill=v)
    d.rectangle([3, 12, 6, 30], fill=v)
    d.rectangle([17, 20, 24, 24], fill=v)
    d.rectangle([21, 8, 24, 24], fill=v)
    for y in range(10, 55, 4):
        d.point((13, y), fill=c(236, 226, 176))
    d.ellipse([11, 4, 16, 9], fill=c(220, 70, 100))
    d.point((13, 6), fill=c(250, 190, 200))
    return contorno(img, c(30, 58, 40, 255))


def nascente():
    rnd = random.Random(3)
    img = Image.new("RGBA", (56, 12), CLARO)
    d = ImageDraw.Draw(img)
    d.ellipse([4, 3, 51, 10], fill=c(80, 150, 190))
    d.ellipse([8, 4, 47, 9], fill=c(98, 176, 214))
    for _ in range(10):
        x = rnd.randint(10, 44)
        d.line([(x, rnd.randint(5, 8)), (x + 3, rnd.randint(5, 8))], fill=c(190, 232, 245))
    for (x, y, w) in [(2, 5, 4), (50, 5, 4), (12, 9, 5), (38, 9, 5), (24, 2, 5)]:
        d.rectangle([x, y, x + w, y + 2], fill=c(150, 140, 126))
        d.rectangle([x, y, x + w, y], fill=c(190, 180, 164))
    for x in (4, 6, 49, 51):
        d.line([(x, 4), (x, 0)], fill=c(88, 136, 64))
    return contorno(img, c(44, 70, 80, 255))


def cerca():
    img = Image.new("RGBA", (36, 18), CLARO)
    d = ImageDraw.Draw(img)
    m = c(142, 112, 82)
    for x in (2, 16, 30):
        d.rectangle([x, 2, x + 3, 17], fill=m)
        d.rectangle([x, 2, x, 17], fill=sh(m, 0.75))
    d.rectangle([0, 6, 35, 8], fill=sh(m, 1.12))
    d.rectangle([0, 12, 35, 14], fill=sh(m, 1.12))
    d.rectangle([0, 8, 35, 8], fill=sh(m, 0.8))
    d.rectangle([0, 14, 35, 14], fill=sh(m, 0.8))
    return contorno(img)


def arbusto():
    rnd = random.Random(5)
    img = Image.new("RGBA", (26, 14), CLARO)
    d = ImageDraw.Draw(img)
    base = c(128, 130, 70)
    for caixa in [(0, 5, 12, 13), (8, 2, 20, 13), (14, 6, 25, 13)]:
        elipse_pontilhada(d, caixa, base, rnd)
    for x in (3, 10, 17, 21):
        d.point((x, 4 + x % 3), fill=c(210, 190, 120))
    return contorno(img, c(50, 56, 34, 255))


def nuvem(seed, w):
    rnd = random.Random(seed)
    img = Image.new("RGBA", (w, 22), CLARO)
    d = ImageDraw.Draw(img)
    for i in range(5):
        cx = int(w * (0.18 + 0.16 * i))
        r = rnd.randint(5, 9)
        d.ellipse([cx - r, 14 - r, cx + r, 14 + r // 2], fill=c(255, 244, 228))
    d.rectangle([2, 14, w - 3, 19], fill=c(255, 244, 228))
    d.rectangle([2, 18, w - 3, 19], fill=c(238, 210, 190))
    return img


def sol():
    img = Image.new("RGBA", (44, 44), CLARO)
    d = ImageDraw.Draw(img)
    d.ellipse([0, 0, 43, 43], fill=c(255, 230, 150, 110))
    d.ellipse([5, 5, 38, 38], fill=c(255, 226, 120, 190))
    d.ellipse([10, 10, 33, 33], fill=c(255, 240, 160))
    return img


def serras(nome, largura, altura, base, ciclos, amplitude, seed, arvores=False):
    rnd = random.Random(seed)
    img = Image.new("RGBA", (largura, altura), CLARO)
    d = ImageDraw.Draw(img)
    fases = [rnd.random() * 6.28 for _ in ciclos]
    topos = []
    for x in range(largura):
        y = altura * 0.55
        for k, f, a in zip(ciclos, fases, amplitude):
            y += math.sin(2 * math.pi * k * x / largura + f) * a
        topos.append(int(y))
        d.line([(x, int(y)), (x, altura)], fill=base)
        d.point((x, int(y)), fill=sh(base, 1.12))
    if arvores:
        for _ in range(26):
            x = rnd.randint(2, largura - 3)
            y = topos[x]
            d.rectangle([x, y - 3, x + 2, y], fill=sh(base, 0.7))
            d.rectangle([x - 1, y - 6, x + 3, y - 3], fill=sh(base, 0.82))
    return img


def ceu():
    img = Image.new("RGBA", (320, 180), CLARO)
    d = ImageDraw.Draw(img)
    faixas = [(246, 184, 100), (248, 194, 108), (250, 204, 120), (251, 214, 134),
              (252, 224, 150), (252, 230, 168), (253, 236, 186), (253, 240, 200)]
    h = 180 // len(faixas) + 1
    for i, cor in enumerate(faixas):
        d.rectangle([0, i * h, 320, (i + 1) * h], fill=c(*cor))
        if i < len(faixas) - 1:  # transição pontilhada entre as faixas
            prox = faixas[i + 1]
            for x in range(0, 320, 2):
                for dy in (0, 1):
                    if (x // 2 + dy) % 2 == 0:
                        d.point((x, (i + 1) * h + dy), fill=c(*prox))
    return img


def tile_topo():
    rnd = random.Random(21)
    img = Image.new("RGBA", (16, 16), c(150, 100, 62))
    d = ImageDraw.Draw(img)
    d.rectangle([0, 0, 15, 2], fill=c(176, 160, 76))
    d.rectangle([0, 2, 15, 3], fill=c(122, 108, 54))
    for x in range(0, 16, 2):
        d.point((x, 0 if x % 4 else 1), fill=c(204, 186, 98))
    for _ in range(26):
        d.point((rnd.randint(0, 15), rnd.randint(4, 15)), fill=rnd.choice([c(128, 84, 52), c(170, 118, 74), c(112, 74, 46)]))
    for (x, y) in [(3, 9), (11, 12)]:
        d.rectangle([x, y, x + 2, y + 1], fill=c(190, 170, 140))
        d.point((x, y + 1), fill=c(120, 100, 84))
    return img


def tile_fundo():
    rnd = random.Random(22)
    img = Image.new("RGBA", (16, 16), c(134, 88, 54))
    d = ImageDraw.Draw(img)
    for _ in range(30):
        d.point((rnd.randint(0, 15), rnd.randint(0, 15)), fill=rnd.choice([c(112, 74, 46), c(154, 104, 66), c(98, 64, 40)]))
    for (x, y) in [(2, 4), (10, 9), (6, 13)]:
        d.rectangle([x, y, x + 2, y + 1], fill=c(176, 156, 128))
    return img


def tile_plataforma():
    img = Image.new("RGBA", (16, 8), c(160, 108, 64))
    d = ImageDraw.Draw(img)
    d.rectangle([0, 0, 15, 1], fill=c(196, 142, 84))
    d.rectangle([0, 6, 15, 7], fill=c(96, 62, 38))
    for x in (0, 8):
        d.line([(x, 2), (x, 5)], fill=c(110, 72, 44))
    d.line([(3, 3), (6, 3)], fill=c(132, 88, 52))
    d.point((1, 3), fill=c(70, 48, 34))
    d.point((9, 3), fill=c(70, 48, 34))
    return img


# ----------------------------------------------------------------------------
# Coletáveis e ícones
# ----------------------------------------------------------------------------

def semente():
    img = Image.new("RGBA", (10, 10), CLARO)
    d = ImageDraw.Draw(img)
    d.ellipse([1, 1, 8, 8], fill=c(98, 62, 36))
    d.ellipse([2, 2, 5, 5], fill=c(150, 104, 66))
    d.point((3, 3), fill=c(214, 172, 120))
    d.rectangle([6, 5, 7, 7], fill=c(70, 44, 28))
    return contorno(margem(img.crop((0, 0, 10, 10)), 1))


def muda_algodao():
    img = Image.new("RGBA", (14, 18), CLARO)
    d = ImageDraw.Draw(img)
    v = c(80, 140, 70)
    d.line([(7, 17), (7, 7)], fill=v, width=2)
    d.polygon([(7, 13), (2, 10), (3, 13)], fill=v)
    d.polygon([(8, 11), (12, 8), (11, 12)], fill=v)
    b = c(250, 248, 240)
    for (x, y) in [(4, 3), (7, 1), (9, 4), (6, 5)]:
        d.ellipse([x - 2, y - 2, x + 2, y + 2], fill=b)
    d.point((7, 2), fill=c(255, 255, 255))
    d.rectangle([5, 6, 8, 7], fill=c(150, 110, 70))
    d.point((3, 4), fill=c(214, 206, 196))
    d.point((10, 5), fill=c(214, 206, 196))
    return contorno(margem(img, 1), c(40, 56, 36, 255))


def pagina():
    img = Image.new("RGBA", (12, 14), CLARO)
    d = ImageDraw.Draw(img)
    d.rectangle([0, 0, 11, 13], fill=c(244, 228, 184))
    d.polygon([(8, 0), (11, 0), (11, 3)], fill=c(200, 170, 110))
    d.polygon([(8, 0), (11, 3), (8, 3)], fill=c(214, 186, 126))
    for y in (5, 7, 9, 11):
        d.line([(2, y), (9 if y != 11 else 6, y)], fill=c(140, 100, 60))
    d.rectangle([0, 0, 0, 13], fill=c(214, 190, 140))
    return contorno(margem(img, 1))


def caju():
    img = Image.new("RGBA", (14, 16), CLARO)
    d = ImageDraw.Draw(img)
    d.ellipse([1, 3, 11, 13], fill=c(244, 140, 44))
    d.ellipse([2, 4, 6, 8], fill=c(255, 190, 90))
    d.rectangle([9, 8, 11, 12], fill=c(218, 90, 40))
    d.point((3, 5), fill=c(255, 230, 160))
    # castanha
    d.ellipse([7, 0, 12, 5], fill=c(120, 92, 66))
    d.rectangle([8, 1, 9, 2], fill=c(158, 130, 100))
    d.point((6, 3), fill=c(80, 120, 50))
    return contorno(margem(img, 1))


def caju_vazio():
    img = caju()
    px = img.load()
    for y in range(img.height):
        for x in range(img.width):
            r, g, b, a = px[x, y]
            if a and (r, g, b) != CONTORNO[:3]:
                m = (r + g + b) // 3
                px[x, y] = (int(m * 0.6) + 50, int(m * 0.6) + 46, int(m * 0.6) + 46, 255)
    return img


def fragmento():
    img = Image.new("RGBA", (16, 18), CLARO)
    d = ImageDraw.Draw(img)
    d.polygon([(8, 0), (14, 8), (8, 16), (2, 8)], fill=c(70, 170, 235))
    d.polygon([(8, 0), (14, 8), (8, 8)], fill=c(140, 215, 250))
    d.polygon([(8, 8), (14, 8), (8, 16)], fill=c(40, 110, 190))
    d.line([(5, 6), (7, 3)], fill=c(230, 250, 255))
    d.point((8, 8), fill=c(255, 255, 255))
    return contorno(margem(img, 1), c(20, 50, 110, 255))


def hud_caju(cheio=True):
    img = Image.new("RGBA", (10, 11), CLARO)
    d = ImageDraw.Draw(img)
    corpo = c(244, 140, 44) if cheio else c(150, 142, 138)
    d.ellipse([0, 3, 7, 10], fill=corpo)
    d.point((2, 5), fill=c(255, 205, 120) if cheio else c(190, 184, 180))
    d.rectangle([5, 7, 7, 9], fill=sh(corpo, 0.8))
    d.ellipse([5, 0, 9, 4], fill=c(120, 92, 66) if cheio else c(100, 96, 94))
    return contorno(margem(img, 1))


def hud_semente():
    img = Image.new("RGBA", (7, 7), CLARO)
    d = ImageDraw.Draw(img)
    d.ellipse([0, 0, 6, 6], fill=c(98, 62, 36))
    d.point((2, 2), fill=c(190, 140, 90))
    return contorno(margem(img, 1))


def hud_pagina():
    img = Image.new("RGBA", (7, 9), CLARO)
    d = ImageDraw.Draw(img)
    d.rectangle([0, 0, 6, 8], fill=c(244, 228, 184))
    for y in (2, 4, 6):
        d.line([(1, y), (5, y)], fill=c(140, 100, 60))
    return contorno(margem(img, 1))


def hud_fragmento():
    img = Image.new("RGBA", (9, 11), CLARO)
    d = ImageDraw.Draw(img)
    d.polygon([(4, 0), (8, 5), (4, 10), (0, 5)], fill=c(70, 170, 235))
    d.polygon([(4, 0), (8, 5), (4, 5)], fill=c(140, 215, 250))
    d.point((3, 3), fill=c(255, 255, 255))
    return contorno(margem(img, 1), c(20, 50, 110, 255))


def livro():
    img = Image.new("RGBA", (24, 20), CLARO)
    d = ImageDraw.Draw(img)
    d.rectangle([1, 3, 22, 17], fill=c(122, 72, 40))
    d.rectangle([3, 4, 21, 15], fill=c(244, 228, 184))
    d.rectangle([11, 3, 12, 16], fill=c(180, 140, 90))
    for y in (6, 8, 10, 12):
        d.line([(4, y), (9, y)], fill=c(140, 100, 60))
        d.line([(14, y), (19, y)], fill=c(140, 100, 60))
    d.ellipse([9, 0, 14, 3], fill=c(120, 210, 255))
    return contorno(margem(img, 1))


def botao_toque(icone, apertado=False, tamanho=26):
    """Botão redondo dos controles de toque (celular): couro escuro e borda dourada."""
    img = Image.new("RGBA", (tamanho, tamanho), CLARO)
    d = ImageDraw.Draw(img)
    fundo = c(92, 58, 36, 230) if apertado else c(43, 26, 18, 170)
    borda = c(255, 214, 120) if apertado else c(232, 176, 74)
    d.ellipse([0, 0, tamanho - 1, tamanho - 1], fill=fundo, outline=borda)
    d.ellipse([1, 1, tamanho - 2, tamanho - 2], outline=sh(borda, 0.6))
    claro = c(255, 240, 200)
    m = tamanho // 2
    if icone == "esquerda":
        d.polygon([(m - 6, m), (m + 4, m - 7), (m + 4, m + 7)], fill=claro)
    elif icone == "direita":
        d.polygon([(m + 6, m), (m - 4, m - 7), (m - 4, m + 7)], fill=claro)
    elif icone == "pular":
        d.polygon([(m, m - 7), (m - 7, m + 1), (m + 7, m + 1)], fill=claro)
        d.rectangle([m - 3, m + 1, m + 3, m + 6], fill=claro)
    elif icone == "falar":
        d.rounded_rectangle([m - 8, m - 6, m + 8, m + 4], 3, fill=claro)
        d.polygon([(m - 4, m + 3), (m - 6, m + 8), (m + 1, m + 3)], fill=claro)
        for x in (m - 4, m, m + 4):
            d.rectangle([x - 1, m - 2, x, m - 1], fill=fundo)
    elif icone == "almanaque":
        d.rectangle([m - 8, m - 5, m + 7, m + 5], fill=c(122, 72, 40))
        d.rectangle([m - 7, m - 4, m + 6, m + 3], fill=c(244, 228, 184))
        d.line([(m - 1, m - 5), (m - 1, m + 4)], fill=c(180, 140, 90))
        d.ellipse([m - 3, m - 9, m + 1, m - 5], fill=c(120, 210, 255))
    elif icone == "tela_cheia":
        for sx, sy in ((-1, -1), (1, -1), (-1, 1), (1, 1)):
            x, y = m + sx * 6, m + sy * 6
            d.line([(x, y), (x - sx * 4, y)], fill=claro, width=2)
            d.line([(x, y), (x, y - sy * 4)], fill=claro, width=2)
    return img


def botoes_toque():
    for icone, tamanho in (("esquerda", 30), ("direita", 30), ("pular", 30), ("falar", 26),
                           ("almanaque", 22), ("tela_cheia", 18)):
        salvar(botao_toque(icone, False, tamanho), "toque_%s.png" % icone)
        salvar(botao_toque(icone, True, tamanho), "toque_%s_apertado.png" % icone)


# ----------------------------------------------------------------------------

def main():
    for nome, params in PERSONAGENS.items():
        personagem(nome, params)
    salvar_jumento()
    salvar(cajueiro(), "cajueiro.png")
    salvar(carnauba(), "carnauba.png")
    salvar(casa_taipa(), "casa_taipa.png")
    salvar(casa_taipa(c(224, 196, 150), c(176, 140, 76)), "casa_taipa2.png")
    salvar(xique_xique(), "xique_xique.png")
    salvar(mandacaru(), "mandacaru.png")
    salvar(nascente(), "nascente.png")
    salvar(cerca(), "cerca.png")
    salvar(arbusto(), "arbusto.png")
    for i, w in enumerate((48, 64, 40)):
        salvar(nuvem(i + 1, w), "nuvem%d.png" % (i + 1))
    salvar(sol(), "sol.png")
    salvar(serras("longe", 640, 78, c(222, 150, 108), (2, 5), (7, 3), 1), "serras_longe.png")
    salvar(serras("perto", 640, 56, c(190, 112, 76), (3, 7), (6, 3), 2, arvores=True), "serras_perto.png")
    salvar(ceu(), "ceu.png")
    salvar(tile_topo(), "chao_topo.png")
    salvar(tile_fundo(), "chao_fundo.png")
    salvar(tile_plataforma(), "plataforma.png")
    salvar(semente(), "semente.png")
    salvar(muda_algodao(), "muda_algodao.png")
    salvar(pagina(), "pagina.png")
    salvar(caju(), "caju.png")
    salvar(caju_vazio(), "caju_vazio.png")
    salvar(fragmento(), "fragmento.png")
    salvar(livro(), "livro.png")
    salvar(hud_caju(True), "hud_caju.png")
    salvar(hud_caju(False), "hud_caju_vazio.png")
    salvar(hud_semente(), "hud_semente.png")
    salvar(hud_pagina(), "hud_pagina.png")
    salvar(hud_fragmento(), "hud_fragmento.png")
    botoes_toque()
    print("ok:", len(os.listdir(SAIDA)), "arquivos em", SAIDA)


if __name__ == "__main__":
    main()
