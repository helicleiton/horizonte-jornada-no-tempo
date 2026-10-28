# Créditos

## Arte e som
Toda a pixel art e todo o áudio do jogo são **originais**, gerados por código neste repositório:

- `tools/gerar_sprites.py` → `assets/sprites/` (personagens, cenário, itens, ícones)
- `tools/gerar_audio.py` → `assets/audio/` (efeitos, trilha de baião, sons ambiente)

Para regenerar: `python tools/gerar_sprites.py` e `python tools/gerar_audio.py` (requer Pillow, numpy e ffmpeg).

## Pixel art de terceiros (CC0)
`palma`, `palma_pequena`, `coroa_de_frade`, `coroa_de_frade_pequena`, `agave`, `pedra` e `pedra_grande` foram recortados de [Desert Level Decorations (Pixel-Art)](https://opengameart.org/content/desert-level-decorations-pixel-art), de ScratchIO (OpenGameArt, CC0). O script `tools/importar_arte.py` baixa a folha, recorta só as plantas que existem no sertão e acrescenta o contorno escuro dos nossos sprites. Rode-o depois de `gerar_sprites.py`.

## Gravações reais (CC0, domínio público)
Parte dos sons vem de gravações de terceiros, todas **Creative Commons 0**. Elas são baixadas, recortadas e normalizadas por `tools/importar_sons.py`. Rode esse script **depois** de `gerar_audio.py`, porque ele sobrescreve alguns arquivos. A licença CC0 não exige crédito; os autores estão listados por cortesia.

| Arquivo no jogo | Origem | Autor |
|---|---|---|
| `sfx/passo1`, `sfx/passo2` | [Footsteps Dirt 01](https://freesound.org/s/264469/) | aglinder (Freesound) |
| `sfx/pagina` | [Page Turn 01](https://freesound.org/s/397548/) | LilMati (Freesound) |
| `sfx/almanaque_abrir`, `sfx/almanaque_fechar` | [Page turns and book close/open](https://freesound.org/s/164806/) | exterminat (Freesound) |
| `sfx/semente` | [Triângulo brasileiro pequeno](https://freesound.org/s/609773/) | Ilson_Junior (Freesound) |
| `sfx/jumento` | [Donkey Bray](https://freesound.org/s/560692/) | StarNinjas37 (Freesound) |
| `sfx/escolha` | [Interface Sounds](https://kenney.nl/assets/interface-sounds) (`select_001`) | Kenney |
| `ambiente/dia_sertao` | [Ambience Countryside Day, crickets, Atlantic Forest Brazil](https://freesound.org/s/478790/) | Cristiano_Scherer (Freesound) |
| `ambiente/nascente` | [Creek - Moderate Flow](https://freesound.org/s/264180/) | easy_thunder (Freesound) |

Os demais sons (pulo, aterrissagem, dano, caju, item, fragmento, blips do diálogo e a trilha de baião) continuam sintetizados.

## Conteúdo histórico
Fatos e textos do Almanaque foram elaborados a partir de:

- *Horizonte: Do Olho d'Água do Venâncio ao Horizonte das Indústrias* (livro didático municipal)
- Prefeitura Municipal de Horizonte, página "O Município"
- IBGE Cidades, "História & Fotos" de Horizonte
- SANTOS, Marlene Pereira dos. *Incursões na história e memória da comunidade de quilombo de Alto-Alegre – município de Horizonte – CE*. Dissertação (Mestrado), UFC, 2012
- Clic Horizonte, projeto *Bordando Memórias* (Coletivo Bordando Resistência)
- *Mapa Mental da História de Horizonte*

Os PDFs usados como referência não são distribuídos neste repositório.

## Ferramentas
Godot Engine 4 (licença MIT).
