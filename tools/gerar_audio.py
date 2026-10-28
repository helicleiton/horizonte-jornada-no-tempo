"""Sintetiza os efeitos sonoros, a trilha e os ambientes do jogo (áudio original).

Uso:  python tools/gerar_audio.py        (requer numpy e ffmpeg no PATH)
Saída: assets/audio/{sfx,musica,ambiente}/*.ogg

A trilha da Fase 1 é um baião original em sol mixolídio, 96 BPM, compasso 2/4:
sanfona (melodia), violão (baixo e batida), zabumba e triângulo.
"""
import math
import os
import subprocess
import tempfile
import wave

import numpy as np

SR = 22050
RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SAIDA = os.path.join(RAIZ, "assets", "audio")
TMP = tempfile.mkdtemp(prefix="horizonte_audio_")
RNG = np.random.default_rng(1987)


def tempo(dur):
    return np.arange(int(dur * SR)) / SR


def midi(n):
    return 440.0 * 2 ** ((n - 69) / 12)


def exp_env(t, taxa):
    return np.exp(-t * taxa)


def fade(sig, ataque=0.005, soltar=0.02):
    n = len(sig)
    a, r = max(1, int(ataque * SR)), max(1, int(soltar * SR))
    env = np.ones(n)
    env[:a] = np.linspace(0, 1, a)
    env[-r:] = np.minimum(env[-r:], np.linspace(1, 0, r))
    return sig * env


def filtrar(x, baixo=None, alto=None):
    """Passa-faixa por FFT com bordas suaves."""
    X = np.fft.rfft(x)
    f = np.fft.rfftfreq(len(x), 1 / SR)
    m = np.ones_like(f)
    if baixo:
        m *= 1 / (1 + (baixo / np.maximum(f, 1)) ** 4)
    if alto:
        m *= 1 / (1 + (f / alto) ** 4)
    return np.fft.irfft(X * m, len(x))


def ruido(dur):
    return RNG.standard_normal(int(dur * SR))


def salvar(sig, caminho_rel, pico=0.7):
    sig = np.asarray(sig, dtype=np.float64)
    m = np.max(np.abs(sig)) or 1.0
    sig = sig / m * pico
    pcm = (np.clip(sig, -1, 1) * 32767).astype(np.int16)
    wav = os.path.join(TMP, os.path.basename(caminho_rel) + ".wav")
    with wave.open(wav, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(pcm.tobytes())
    destino = os.path.join(SAIDA, caminho_rel + ".ogg")
    os.makedirs(os.path.dirname(destino), exist_ok=True)
    subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", wav, "-c:a", "libvorbis", "-q:a", "3", destino], check=True)
    return os.path.getsize(destino)


def misturar(buf, sig, inicio, ganho=1.0, circular=True):
    """Soma sig em buf a partir de inicio; o que passar do fim volta ao começo (loop contínuo)."""
    n = len(buf)
    inicio %= n
    fim = inicio + len(sig)
    if fim <= n:
        buf[inicio:fim] += sig * ganho
    elif circular:
        corte = n - inicio
        buf[inicio:] += sig[:corte] * ganho
        resto = sig[corte:] * ganho
        buf[: min(len(resto), n)] += resto[:n]
    else:
        buf[inicio:] += sig[: n - inicio] * ganho


def tornar_loop(buf, xf=1.0):
    """Costura o fim no começo com crossfade (para texturas de ruído)."""
    k = int(xf * SR)
    saida = buf[:-k].copy()
    saida[:k] = buf[:k] * np.linspace(0, 1, k) + buf[-k:] * np.linspace(1, 0, k)
    return saida


# ----------------------------------------------------------------------------
# Instrumentos
# ----------------------------------------------------------------------------

def acordeao(freq, dur, vel=1.0):
    t = tempo(dur)
    sig = np.zeros_like(t)
    for det in (0.9965, 1.0, 1.0035):
        fase = 2 * math.pi * freq * det * t + 0.035 * np.sin(2 * math.pi * 5.2 * t)
        for h in range(1, 8):
            sig += np.sin(h * fase) * (1.0 / h) * (1.0 if h % 2 else 0.55)
    env = np.minimum(1, t / 0.03) * (0.85 + 0.15 * np.exp(-t * 4))
    return fade(sig * env, 0.01, 0.05) * 0.055 * vel


def violao_nota(freq, dur=0.5, vel=1.0):
    t = tempo(dur)
    sig = np.zeros_like(t)
    for h in range(1, 9):
        sig += np.sin(2 * math.pi * freq * h * t) / h * np.exp(-t * (3.5 + 2.2 * h))
    return fade(sig, 0.002, 0.03) * 0.16 * vel


def bumbo(vel=1.0):
    t = tempo(0.26)
    fase = 2 * math.pi * (52 * t + 70 * (1 - np.exp(-28 * t)) / 28)
    sig = np.sin(fase) * exp_env(t, 13) + filtrar(ruido(0.26), 800, 3000) * exp_env(t, 90) * 0.35
    return fade(sig, 0.001, 0.02) * 0.9 * vel


def tapa(vel=1.0):
    t = tempo(0.1)
    sig = filtrar(ruido(0.1), 1400, 4200) * exp_env(t, 48) + np.sin(2 * math.pi * 240 * t) * exp_env(t, 60) * 0.5
    return fade(sig, 0.001, 0.01) * 0.5 * vel


def triangulo(vel=1.0, aberto=False):
    t = tempo(0.45 if aberto else 0.16)
    sig = np.zeros_like(t)
    for f, g in ((3520, 1.0), (5290, 0.7), (7480, 0.5), (9100, 0.3)):
        sig += np.sin(2 * math.pi * f * t) * g
    return fade(sig * exp_env(t, 7 if aberto else 22), 0.001, 0.01) * 0.07 * vel


def sino(freq, dur=0.6, vel=1.0):
    t = tempo(dur)
    sig = np.sin(2 * math.pi * freq * t) + 0.5 * np.sin(2 * math.pi * freq * 2.76 * t) * np.exp(-t * 6) + 0.25 * np.sin(2 * math.pi * freq * 5.4 * t) * np.exp(-t * 10)
    return fade(sig * exp_env(t, 5), 0.002, 0.03) * 0.3 * vel


# ----------------------------------------------------------------------------
# Efeitos sonoros
# ----------------------------------------------------------------------------

def sfx_pulo():
    t = tempo(0.2)
    fase = 2 * math.pi * (260 * t + 480 * t ** 2 / (2 * 0.2))
    return fade(np.sign(np.sin(fase)) * 0.4 + np.sin(fase) * 0.6, 0.003, 0.05) * exp_env(t, 6)


def sfx_aterrissa():
    t = tempo(0.12)
    return filtrar(ruido(0.12), 60, 700) * exp_env(t, 32)


def sfx_passo(i):
    t = tempo(0.07)
    return filtrar(ruido(0.07), 300 + 120 * i, 1800) * exp_env(t, 55) * 0.5


def sfx_semente():
    return np.concatenate([fade(np.sign(np.sin(2 * math.pi * f * tempo(0.07))) * 0.5 * exp_env(tempo(0.07), 8), 0.002, 0.01) for f in (988, 1319)])


def sfx_item():
    return np.concatenate([sino(midi(n), 0.14) for n in (72, 76, 79)])


def sfx_pagina():
    t = tempo(0.28)
    farfalhar = filtrar(ruido(0.28), 1500, 6500) * np.sin(math.pi * t / 0.28) ** 2
    return farfalhar * 0.6 + np.pad(sino(midi(88), 0.25), (int(0.12 * SR), 0))[: len(t)] * 0.7


def sfx_caju():
    return np.concatenate([sino(midi(n), 0.13) for n in (67, 71, 74, 79)])


def sfx_fragmento():
    n = [67, 71, 74, 79, 83, 86, 91]
    sig = np.zeros(int(1.6 * SR))
    for i, nota in enumerate(n):
        misturar(sig, sino(midi(nota), 0.9), int(i * 0.09 * SR), 0.8 if i < 6 else 1.2, circular=False)
    for nota in (55 + 12, 59 + 12, 62 + 12):
        misturar(sig, sino(midi(nota), 1.2, 0.8), int(0.62 * SR), 0.5, circular=False)
    return sig


def sfx_dano():
    t = tempo(0.32)
    fase = 2 * math.pi * (420 * t - 700 * t ** 2 / 2)
    sig = (np.sign(np.sin(fase)) * 0.5 + np.sin(fase) * 0.5) * exp_env(t, 6) + filtrar(ruido(0.32), 200, 3000) * exp_env(t, 14) * 0.5
    return fade(sig, 0.002, 0.04)


def sfx_blip(freq):
    t = tempo(0.045)
    return fade(np.sign(np.sin(2 * math.pi * freq * t)) * 0.45 + np.sin(2 * math.pi * freq * t) * 0.3, 0.002, 0.012)


def sfx_escolha():
    return np.concatenate([sfx_blip(660), sfx_blip(990)])


def sfx_almanaque(abrir):
    t = tempo(0.3)
    farfalhar = filtrar(ruido(0.3), 900, 5000) * np.sin(math.pi * t / 0.3) ** 2
    nota = sino(midi(76 if abrir else 69), 0.3)
    return farfalhar * 0.5 + np.pad(nota, (0, 0))[: len(t)] * 0.5


# ----------------------------------------------------------------------------
# Trilha da Fase 1: baião em sol mixolídio
# ----------------------------------------------------------------------------

BPM = 96
PASSO = 60.0 / BPM / 4  # semicolcheia
PASSOS_COMPASSO = 8

ACORDES = {
    "G": (43, [55, 59, 62]),
    "F": (41, [53, 57, 60]),
    "C": (48, [52, 55, 60]),
}
PROGRESSAO = ["G", "G", "F", "F", "C", "C", "G", "G", "C", "C", "F", "F", "G", "G", "G", "G"]

MELODIA = [
    [(0, 3, 74), (3, 1, 71), (4, 2, 74), (6, 2, 76)],
    [(0, 4, 79), (4, 2, 76), (6, 2, 74)],
    [(0, 3, 72), (3, 1, 69), (4, 2, 72), (6, 2, 74)],
    [(0, 4, 77), (4, 2, 74), (6, 2, 72)],
    [(0, 3, 76), (3, 1, 72), (4, 2, 76), (6, 2, 79)],
    [(0, 4, 76), (4, 2, 74), (6, 2, 72)],
    [(0, 3, 71), (3, 1, 74), (4, 2, 71), (6, 2, 69)],
    [(0, 6, 67)],
    [(0, 2, 79), (2, 2, 76), (4, 2, 79), (6, 2, 84)],
    [(0, 4, 79), (4, 2, 76), (6, 2, 72)],
    [(0, 2, 77), (2, 2, 74), (4, 2, 72), (6, 2, 69)],
    [(0, 4, 72)],
    [(0, 3, 74), (3, 1, 71), (4, 2, 74), (6, 2, 77)],
    [(0, 2, 79), (2, 2, 77), (4, 2, 76), (6, 2, 74)],
    [(0, 3, 71), (3, 1, 69), (4, 4, 67)],
    [(0, 2, 74), (2, 2, 71), (4, 2, 67)],
]


def trilha_fase1():
    compassos = len(PROGRESSAO)
    n = int(compassos * PASSOS_COMPASSO * PASSO * SR)
    buf = np.zeros(n)

    def pos(compasso, passo):
        return int((compasso * PASSOS_COMPASSO + passo) * PASSO * SR)

    bumbo_f, tapa_f = bumbo(), tapa()
    for c, acorde in enumerate(PROGRESSAO):
        raiz, triade = ACORDES[acorde]
        # zabumba (baião): bumbo no 1 e no "e" do 2, tapa no 2 e na última semicolcheia
        misturar(buf, bumbo_f, pos(c, 0), 1.0)
        misturar(buf, bumbo_f, pos(c, 3), 0.55)
        misturar(buf, tapa_f, pos(c, 4), 0.8)
        misturar(buf, bumbo_f, pos(c, 6), 0.7)
        misturar(buf, tapa_f, pos(c, 7), 0.45)
        # triângulo
        for p in (0, 2, 3, 4, 6):
            misturar(buf, triangulo(1.0 if p in (0, 4) else 0.6, aberto=(p == 3)), pos(c, p), 1.0)
        # baixo no violão
        misturar(buf, violao_nota(midi(raiz), 0.55, 1.2), pos(c, 0))
        misturar(buf, violao_nota(midi(raiz + 7), 0.5, 0.9), pos(c, 4))
        misturar(buf, violao_nota(midi(raiz + 12), 0.4, 0.7), pos(c, 6))
        # batida do violão nos contratempos
        for p in (2, 5):
            for i, nota in enumerate(triade):
                misturar(buf, violao_nota(midi(nota + 12), 0.28, 0.5), pos(c, p) + int(i * 0.012 * SR))
        # melodia na sanfona
        for passo, dur, nota in MELODIA[c]:
            misturar(buf, acordeao(midi(nota), dur * PASSO * 0.97), pos(c, passo), 1.0)
    return buf


# ----------------------------------------------------------------------------
# Ambientes
# ----------------------------------------------------------------------------

def ambiente_dia():
    dur = 14.0
    n = int(dur * SR)
    t = np.arange(n) / SR
    vento = filtrar(ruido(dur), 120, 900) * (0.55 + 0.45 * np.sin(2 * math.pi * 0.11 * t + 1.0))
    cigarra_base = filtrar(ruido(dur), 4200, 7200)
    cigarra = cigarra_base * (0.5 + 0.5 * np.sin(2 * math.pi * 36 * t)) * (0.35 + 0.65 * np.sin(math.pi * ((t / 7.0) % 1.0)) ** 2)
    sig = vento * 0.8 + cigarra * 0.22
    for inicio in (1.2, 3.9, 6.5, 9.8, 12.1):
        nota = tempo(0.11)
        f0 = RNG.uniform(2300, 3200)
        trino = np.sin(2 * math.pi * (f0 * nota + 900 * nota ** 2 / (2 * 0.11))) * np.sin(math.pi * nota / 0.11)
        misturar(sig, trino * 0.05, int(inicio * SR))
        misturar(sig, trino * 0.035, int((inicio + 0.16) * SR))
    return tornar_loop(sig, 1.5)


def ambiente_agua():
    dur = 7.0
    n = int(dur * SR)
    sig = filtrar(ruido(dur), 500, 2600) * 0.4
    for _ in range(46):
        d = RNG.uniform(0.04, 0.09)
        t = tempo(d)
        f0 = RNG.uniform(500, 1100)
        bolha = np.sin(2 * math.pi * (f0 * t + 2400 * t ** 2 / 2)) * np.sin(math.pi * t / d)
        misturar(sig, bolha * 0.09, int(RNG.uniform(0, dur - 0.1) * SR))
    return tornar_loop(sig, 1.2)


def main():
    efeitos = {
        "pulo": sfx_pulo(), "aterrissa": sfx_aterrissa(), "passo1": sfx_passo(0), "passo2": sfx_passo(1),
        "semente": sfx_semente(), "item": sfx_item(), "pagina": sfx_pagina(), "caju": sfx_caju(),
        "fragmento": sfx_fragmento(), "dano": sfx_dano(), "blip1": sfx_blip(300), "blip2": sfx_blip(360),
        "blip3": sfx_blip(430), "escolha": sfx_escolha(), "almanaque_abrir": sfx_almanaque(True),
        "almanaque_fechar": sfx_almanaque(False),
    }
    total = 0
    for nome, sig in efeitos.items():
        total += salvar(sig, "sfx/" + nome, 0.8)
    total += salvar(trilha_fase1(), "musica/fase1_baiao", 0.75)
    total += salvar(ambiente_dia(), "ambiente/dia_sertao", 0.7)
    total += salvar(ambiente_agua(), "ambiente/nascente", 0.7)
    print("ok: %d arquivos, %.0f KB no total" % (len(efeitos) + 3, total / 1024))


if __name__ == "__main__":
    main()
