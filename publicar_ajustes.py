"""Ajusta a página do jogo copiada para o site: caminho base e contagem de visitas da Vercel."""
import sys

caminho = sys.argv[1]
with open(caminho, encoding="utf-8") as f:
    s = f.read()
if "<base" not in s:
    s = s.replace("<head>", '<head>\n<base href="/historiadehorizonte/">', 1)
if "/_vercel/insights/script.js" not in s:
    s = s.replace("</head>", '<script defer src="/_vercel/insights/script.js"></script>\n</head>', 1)
with open(caminho, "w", encoding="utf-8") as f:
    f.write(s)
print("ajustes aplicados")
