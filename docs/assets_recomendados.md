# Assets recomendados

Hoje o jogo roda com formas coloridas (placeholders). Esta lista diz o que trocar por arte e som reais.
Prefira licenças **CC0 / CC-BY** e anote a autoria em `CREDITOS.md` antes de publicar.

## Visuais (pixel art 16-bit, tela base 320×180)

### Personagens
| Asset | Detalhe | Onde ligar |
|---|---|---|
| Chico e Luzia | 16×32 px; animações `parado`, `correr`, `pular`, `cair`, `dano`, `derrota` | `AnimatedSprite2D` filho do `Jogador` (o script já escolhe as animações pelo nome) |
| NPCs da Fase 1 | Zeca (chapéu de couro, jumentos), Mariinha (lenço, enxada), Venâncio (chapéu de palha), Tonho (menino descalço), Vó Bastiana (cabelo branco, xale) | `AnimatedSprite2D` filho do NPC |
| Livro do Tempo | Livro flutuante com brilho azul | Cena de abertura e HUD |

### Cenário por fase
| Fase | Tiles e props |
|---|---|
| 1 — Povoado (c. 1932) | Chão de terra batida, casas de taipa com telhado de palha, cajueiros, carnaúbas, xique-xique, mandacaru, cercas de varas, nascente (olho d'água) com pedras, casa de farinha com forno de barro, engenho de rapadura, jumentos com cangalha |
| 2 — Emancipação (1987) | Ruas de paralelepípedo, praça, cartazes e faixas ("Horizonte Livre"), urna do plebiscito, Fusca e Brasília dos anos 80 |
| 3 — Polo industrial (1990–2000) | Galpões, esteiras, engrenagens, caixas de calçado e tecido, BR-116, Centro Cultural Tasso Jereissati |
| 4 — Futuro | Parque verde, lixeiras de coleta seletiva, mudas e árvores, painéis solares, escola |

### Interface
- Ícone de caju (cheio/vazio), semente de carnaúba, página do almanaque, fragmento de memória (losango azul).
- Moldura da caixa de diálogo (papel e couro) e retratos dos NPCs (48×48).
- Fonte pixel com acentos (Á Ã Ç Õ): **Press Start 2P**, **Pixelify Sans** ou **m5x7** (verificar suporte a português).
- Ilustração/borda do Almanaque: bordado em ponto cruz, em homenagem às Bordadeiras do Alto Alegre (projeto Bordando Memórias). Peça autorização ao Clic Horizonte antes de usar imagens deles.

### Onde buscar (grátis)
- Kenney.nl (CC0) — plataformas, UI e props genéricos
- OpenGameArt.org — filtrar por CC0/CC-BY
- itch.io → Game Assets → Free → Pixel Art (ler a licença de cada pacote)
- Aseprite ou LibreSprite para criar o que faltar

## Sons

### Efeitos
| Efeito | Uso |
|---|---|
| Passos em terra e em pedra | Corrida (variar por tipo de chão) |
| Pulo, aterrissagem | `Player.pulou` / `Player.aterrissou` |
| Coleta de semente (som de "tec" de madeira/cabaça) | Semente |
| Página virando | Página do Almanaque |
| Acorde cristalino curto | Fragmento de Memória |
| Dano (espinho) + grito curto | `Player.dano_recebido` |
| Blip de texto por caractere (3 tons) | Caixa de diálogo, uma por NPC |
| Cigarra, grilos, vento seco | Ambiente da Fase 1 (dia) |
| Pássaros da caatinga (sabiá, bem-te-vi, carcará, galo-de-campina) | Ambiente |
| Água correndo / borbulhando | Perto do olho d'água |
| Relinchar e passos de jumento, guizos de cangalha | Zeca |
| Pilão, raspa de mandioca, forno de farinha | Casa de farinha |
| Sino de igreja | Fases 2 e 4 |
| Máquinas, esteira, apitos | Fase 3 |

### Trilha (regional, a compor ou licenciar)
| Faixa | Estilo e instrumentos |
|---|---|
| Menu | Viola e sanfona suaves, andamento lento de toada |
| Fase 1 | Baião lento em modo mixolídio: sanfona (acordeão), triângulo, zabumba leve, violão |
| Fase 2 | Forró pé-de-serra mais animado, estilo comício: sanfona, zabumba, triângulo |
| Fase 3 | Forró eletrônico/baião com bateria e teclados, ritmo industrial |
| Fase 4 | Instrumental esperançoso: violão, flauta, percussão leve, sintetizador suave |
| Desafio / quiz | Pizzicato de viola, tensão curta |
| Almanaque | Acordeão solo, calmo |
| Festa de São João (extra) | Quadrilha junina; **São João Batista é o padroeiro de Horizonte** (24/06) |

> **Direitos autorais:** não use gravações nem melodias de Luiz Gonzaga, Gilvan Chaves etc. Componha trilhas originais ou use bibliotecas livres
> (OpenGameArt "folk/accordion", Pixabay Music, Free Music Archive CC-BY). **Hino de Horizonte** (letra e música de Miriam Carlos Moreira de Souza):
> peça autorização à Prefeitura/à autora antes de gravá-lo.

Ferramentas: LMMS, Bosca Ceoil ou BeepBox (trilhas), sfxr/jsfxr (efeitos), Freesound.org (filtrar CC0), Audacity (editar).

## Formato para o Godot
- Imagens: PNG com fundo transparente, escala inteira (sem suavização — já configurado).
- Sons: **OGG Vorbis** (efeitos e músicas), mono para efeitos; fica menor no build Web.
- Mantenha o build Web abaixo de ~50 MB para carregar rápido em celular.
