# Horizonte: Jornada Através do Tempo

Plataforma 2D educativo em pixel art sobre a história e a cultura de Horizonte (CE). Engine: **Godot 4** (renderer *Compatibility*, para rodar no navegador). Resolução base 320×180, escala inteira.

**Estado atual:** protótipo jogável da **Fase 1** (movimentação, NPCs com diálogo ramificado, coletáveis, HUD, Almanaque, perigos) com **pixel art e áudio originais** (gerados por código, veja `CREDITOS.md`). Fases 2–4 ainda não existem.

**Jogar online:** https://helicleiton.github.io/horizonte-jornada-no-tempo/

## Como jogar

| Ação | Teclado | Controle |
|---|---|---|
| Mover | A/D ou ←/→ | direcional / analógico |
| Pular (segure = mais alto) | Espaço, W ou ↑ | A |
| Conversar / avançar | E ou Enter (Espaço também avança) | X |
| Almanaque | Tab ou Q (Esc fecha) | Back |

### Rodar no Godot
```bash
godot --path .
```
Ou abra a pasta no editor e aperte F5. A cena principal é `scenes/levels/fase_teste.tscn`.

### Versão Web
1. No Godot: **Editor → Gerenciar Templates de Exportação → Baixar** (versão 4.7.2).
2. Rode `exportar_web.bat` (gera `build/web/`).
3. Rode `servir_web.bat` e abra http://localhost:8060.

O preset `Web` (`export_presets.cfg`) está **sem threads**, por isso funciona em qualquer hospedagem estática (GitHub Pages, itch.io, Netlify) sem cabeçalhos especiais. Abrir `index.html` direto do disco não funciona (limite do navegador).

### Testes
```bash
godot --headless --path . res://tests/smoke_test.tscn
```
Simula pouso, pulo, todas as conversas, a missão das mudas, o desafio da Vó Bastiana, dano e Almanaque. Resultado esperado: `---- falhas: 0`. (As mensagens "Unreferenced static string" no fim são ruído de encerramento do Godot headless.)

## Estrutura

```
project.godot            configuração (autoloads GameState e DialogueBox)
scenes/                  jogador, npc, objetos (coletavel, perigo), levels/fase_teste
scripts/player/player.gd movimentação (coyote time, buffer, pulo variável, dano)
scripts/autoload/        game_state.gd (sementes, cajus, itens, flags) e dialogue_box.gd
scripts/npc, objetos, ui, levels
data/dialogos_fase1.json diálogos (editáveis sem tocar no código)
data/almanaque.json      páginas do Almanaque, com fonte de cada fato
assets/                  sprites e áudio gerados (não edite à mão: rode as ferramentas)
tools/                   gerar_sprites.py e gerar_audio.py
docs/                    roteiro da Fase 1, lista de assets
tests/                   teste de fumaça
```

### Movimentação (`player.gd`)
Os valores se ajustam no Inspetor por **altura** e **tempo** do pulo (`altura_pulo`, `tempo_subida`, `tempo_descida`), não por constantes de física. Há aceleração e atrito separados para chão e ar, gravidade maior na queda, queda máxima, *coyote time* (0,1 s), *buffer* de pulo (0,12 s), invencibilidade com recuo após dano e bloqueio de entrada de 0,2 s ao sair de um diálogo. Para usar sprites, adicione um `AnimatedSprite2D` ao `Jogador` com as animações `parado`, `correr`, `pular`, `cair`, `dano`, `derrota`.

### Diálogos (formato JSON)
Cada diálogo tem `nos` (`quem`, `fala`, `proximo`, `opcoes`, `flag`, `recompensa`, `remover_item`) e `condicoes` que escolhem o nó inicial conforme flags/itens. `{nome}` vira Chico ou Luzia (`GameState.nome_protagonista`). Recompensas: `sementes`, `caju`, `pagina`, `fragmento`.

## Fatos históricos usados (e correções ao briefing)

Fontes: livro *Horizonte: Do Olho d'Água do Venâncio ao Horizonte das Indústrias* (PDF), site da Prefeitura, IBGE Cidades, dissertação de Marlene P. dos Santos (UFC, 2012), projeto *Bordando Memórias* (Clic Horizonte) e o *Mapa Mental da História de Horizonte*.

- **Nome antigo: "Olho d'Água do Venâncio"** (não "do Chibata", como no briefing). Vem da nascente nas terras de Venâncio Raimundo de Sousa.
- Pertenceu a Aquiraz; em 1935 passou a Guarani (hoje Pacajus). **20/12/1938**: o distrito passa a se chamar Horizonte, nome sugerido pela professora Raimunda Duarte Teixeira.
- Emancipação: 1ª lei em 1963 (Virgílio Távora), derrubada em 1964/65 pela ditadura. Plebiscito liderado pela **Sahori** (Sociedade dos Amigos de Horizonte): **2.273 votos a favor, 182 contra**. **Lei nº 11.300, de 06/03/1987** (governador Gonzaga Mota). Instalação em **01/01/1989**, com o 1º prefeito, Francisco César de Sousa.
- A Prefeitura (omunicipio.php) diz que a mudança para Horizonte foi oficializada pelo Decreto-Lei nº 1.114 de 30/12/1943; o IBGE mostra que esse decreto renomeou **Guarani → Pacajus** e que o distrito virou Horizonte em **1938**. O jogo segue o IBGE.
- Distrito Industrial: Companhia de Desenvolvimento Industrial de Horizonte, Lei nº 032 de 09/02/1990 (livro, p. 112). Mais de 40 indústrias (têxtil, calçados, granito, automotivo) e ~20 mil empregos diretos.
- Quilombo **Alto Alegre**: reconhecido pela Fundação Palmares em maio de 2005. Origem na tradição oral de **Cazuza**.
- **Não confirmado em nenhuma fonte da pasta:** "Parque das Aves" (Fase 4) e "Centro Cultural Tasso Jereissati" como cenário do final dos anos 90 (o Mapa Mental só o cita como patrimônio atual). Valide antes de usar como fato.
- Outros ganchos documentados: São João Batista, padroeiro (24/06) e quadrilhas juninas; rendeiras; Zilmar do Horizonte (cordelista); Patativa do Assaré (citado no livro); preguiça-gigante achada por Chico Moreira; Paiacus e a Guerra dos Bárbaros.

## Próximos passos
1. Tela de título com escolha Chico/Luzia (o sprite da Luzia já existe), fonte pixel com acentos e retratos nos diálogos.
2. **Fase 2 (1987):** votos de apoio, desvio de obstáculos urbanos, enigma sobre 06/03/1987 e o plebiscito da Sahori.
3. **Fase 3 (1990–2000):** plataformas-esteira, engrenagens, símbolos de progresso, Distrito Industrial.
4. **Fase 4:** puzzles de reciclagem e plantio.
5. Salvar progresso (`GameState` já concentra todo o estado) e versão para celular (controles na tela).
