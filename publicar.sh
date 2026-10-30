#!/usr/bin/env bash
# Publica o jogo: exporta a versão web, atualiza o site, faz commit e push nos dois repositórios.
# Uso: bash publicar.sh ["mensagem do commit"]
set -e
JOGO="$(cd "$(dirname "$0")" && pwd)"
SITE="/c/DADOS/MEUS APPS/site-helicleiton"
MSG="${1:-Atualização do jogo}"
ATRIBUICAO="Co-Authored-By: Claude Haiku 5.5 <noreply@anthropic.com>"

echo "== 1/5 Exportando a versão web"
godot --headless --path "$JOGO" --export-release "Web" "$JOGO/build/web/index.html" >/dev/null 2>&1 || true
test -f "$JOGO/build/web/index.pck" || { echo "Falhou: exportação não gerou index.pck"; exit 1; }

echo "== 2/5 Commit e push do jogo"
cd "$JOGO"
git add -A
if ! git diff --cached --quiet; then
  git commit -q -m "$MSG" -m "$ATRIBUICAO"
fi
git push -q origin main

echo "== 3/5 Atualizando a cópia do jogo no site"
cd "$SITE"
rm -rf public/historiadehorizonte
mkdir public/historiadehorizonte
cp -r "$JOGO/build/web/." public/historiadehorizonte/
python "$JOGO/publicar_ajustes.py" public/historiadehorizonte/index.html

echo "== 4/5 Conferindo o build do site"
npx next build >/dev/null 2>&1 || { echo "Falhou: build do site"; exit 1; }

echo "== 5/5 Commit e push do site"
git add public/historiadehorizonte
if ! git diff --cached --quiet; then
  git commit -q -m "Jogo Horizonte: atualização" -m "$ATRIBUICAO"
fi
git push -q origin HEAD
echo "Pronto. A Vercel publica o site em alguns minutos."
