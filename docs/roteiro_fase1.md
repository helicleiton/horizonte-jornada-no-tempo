# Roteiro de diálogos: Fase 1 — O Olho d'Água do Venâncio (c. 1932)

Fonte de verdade para o jogo: [`data/dialogos_fase1.json`](../data/dialogos_fase1.json).
Este arquivo é a versão legível para revisão por professores/historiadores.
`{nome}` = Chico ou Luzia.

**Cenário:** estrada de terra, cajueiros, carnaúbas, casas de taipa, nascente (olho d'água).
**Missão principal:** devolver as 5 mudas de algodão à Dona Mariinha, escutar o Seu Venâncio e passar no desafio da Vó Bastiana → *Fragmento de Memória 1*.
**Colecionáveis:** sementes de carnaúba, mudas de algodão (item de missão), página "Casa de taipa e carnaúba", caju (vida).

> **Aviso de método.** Venâncio Raimundo de Sousa e Cazuza são personagens reais/da tradição oral;
> Zeca, Mariinha, Tonho e Vó Bastiana são **fictícios**, criados para transmitir fatos documentados.
> Todo fato dito nos diálogos tem fonte em `data/almanaque.json`.

---

## Abertura (Biblioteca Pública → 1932)

| Quem | Fala |
|---|---|
| Narrador | Biblioteca Pública de Horizonte, dias de hoje. Tarde quente, ventilador rangendo no teto. |
| {nome} | Trabalho de História pra amanhã: "As origens de Horizonte". E eu sem saber nem por onde começar... |
| {nome} | Ué... que livro velho é esse escondido atrás da estante? "Livro do Tempo de Horizonte"? |
| Livro do Tempo | Finalmente alguém me encontrou! Minhas páginas se espalharam pelos anos. Sem elas, a memória desta terra se apaga. |
| Livro do Tempo | Encontre os Fragmentos de Memória e me restaure. Vamos começar... pelo começo! |
| {nome} | Pelo começo? Peraí, que luz é essa?! AAAAH! |
| {nome} | Cadê os prédios? Cadê a BR-116? Só tem cajueiro, carnaúba e um caminho de terra... |
| Livro do Tempo | Estamos por volta de 1932. Este lugar é o Olho d'Água, um pequeno povoado que ainda pertence a Aquiraz. |
| Livro do Tempo | Converse com o povo daqui e escute com atenção. Quem guarda a memória deste lugar vai te testar no fim do caminho. |
| Livro do Tempo | [E] conversa. [Espaço] pula. [Tab] abre o Almanaque com tudo o que você descobrir. |

---

## 1. Seu Zeca — tropeiro (x≈100)

*Ensina: economia antes das rodovias; origem do nome; ponto de partida da missão.*

- **Primeira conversa:** estranha a roupa de {nome}; apresenta-se; leva carga em jumentos até Fortaleza e à serra de Pacoti.
- **Menu**
  - *O que você carrega?* → rapadura dos engenhos e farinha; volta com sal, querosene, tecido, ferramenta e notícias ("tropeiro é o jornal do sertão"). **Libera a página "Tropeiros e rapadura".**
  - *Que lugar é este?* → Olho d'Água do Venâncio, nome da nascente nas terras do Seu Venâncio; ponto de parada das tropas.
  - *Alguém precisa de ajuda?* → Dona Mariinha perdeu as mudas de algodão na ventania. **Recompensa: 3 sementes** (uma vez).
  - *Até mais* → "Vá com Deus! E beba água, que o sol daqui é quente que só."
- **Volta:** "Os bichos já beberam água. Daqui a pouco pego a estrada de novo."

## 2. Dona Mariinha — agricultora (x≈520)

*Ensina: trabalho "de a meia", culturas, algodão. Missão das 5 mudas.*

- **Primeira conversa:** as mudas se espalharam com a ventania.
- **Menu**
  - *Eu ajudo a procurar!* → aceita a missão (5 mudas, sobre pedras e galhos).
  - *Esse roçado é da senhora?* → não; planta "de a meia" (metade da colheita vai para o dono; na seca, o prejuízo é só de quem plantou). **Libera "O roçado e o trabalho de a meia".**
  - *O que mais a senhora planta?* → feijão, milho, mandioca; algodão ("ouro branco").
- **Lembrete** (missão aceita, sem as 5 mudas): "São cinco ao todo."
- **Entrega (5 mudas):** **+10 sementes, +1 caju**. Manda ir falar com o Seu Venâncio e depois com a Vó Bastiana.
- **Depois:** "As mudas já tão na terra. Agora é pedir a Deus que chova no tempo certo."

## 3. Seu Venâncio (x≈700)

*Ensina: o que é um olho d'água; origem do nome do lugar.*

- **Primeira conversa:** a nascente brota sozinha, sem cavar poço, e nunca secou; como fica em suas terras, o lugar virou "Olho d'Água do Venâncio". **Libera a página "Olho d'Água do Venâncio".** (Flag `falou_venancio`.)
- **Menu**
  - *Por que a água é tão importante?* → onde tem água tem gente; nascentes, riachos e o Pacoti fixaram o povo.
  - *O que o senhor produz?* → engenho de rapadura e cal. **+5 sementes** (uma vez).
  - *Obrigado* → "Respeite a nascente: água limpa é herança pros que vêm depois."

## 4. Tonho — menino (x≈920)

*Ensina: casa de farinha; o fóssil da preguiça-gigante.*

- **Primeira conversa:** espera a mãe na farinhada. **+3 sementes.**
- **Menu**
  - *Que novidade?* → Seu Chico Moreira, da Lagoa do Ipu, achou ossos enormes ao cavar um poço. **Libera "A preguiça-gigante".**
  - *Viu alguma coisa brilhando?* → luz azul perto da casa da Vó Bastiana.

## 5. Vó Bastiana — Alto Alegre (x≈1380)

*Ensina: Cazuza, os Paiacus e a origem da comunidade quilombola; desafio final.*

- **Antes das missões** (sem entregar as mudas ou sem falar com Venâncio): "Chegou cedo demais, criança..."
- **História de Cazuza** (libera "Os Paiacus" e "Cazuza e o Alto Alegre"):
  1. Um navio trouxe gente escravizada até a Barra do Ceará; Cazuza fugiu do porão.
  2. Andou dias até as terras de Pacajus; foi capturado e castigado.
  3. Foi acolhido pelos índios Paiacus, aprendeu a cuidar da terra e formou família.
  4. Seus descendentes formaram o povo do Alto Alegre. "Porque ele resistiu, a gente resiste também."
- **Desafio (3 perguntas; errar repete a pergunta com uma dica):**
  1. *Por que este lugar se chama Olho d'Água do Venâncio?* → **a nascente fica nas terras do Seu Venâncio**
  2. *Como o Zeca leva rapadura e farinha até Fortaleza?* → **no lombo dos jumentos**
  3. *Quem acolheu Cazuza?* → **os índios Paiacus**
- **Final:** **Fragmento de Memória 1 + 15 sementes.** O Livro do Tempo anuncia que em 1938 o distrito vai ganhar o nome Horizonte, sugerido pela professora Raimunda Duarte Teixeira. **Libera "De Olho d'Água a Horizonte".**
- **Depois:** "Vá, criança! O futuro tá te esperando. E não esqueça do Cazuza."

---

## Páginas do Almanaque desta fase (8)

| id | Título | Como ganha |
|---|---|---|
| `tropeiros` | Tropeiros e rapadura | Zeca |
| `roca` | O roçado e o trabalho de a meia | Mariinha |
| `olho_dagua` | Olho d'Água do Venâncio | Venâncio |
| `preguica_gigante` | A preguiça-gigante | Tonho |
| `taipa_carnauba` | Casa de taipa e carnaúba | Coletável no cenário |
| `paiacus` | Os Paiacus | Vó Bastiana |
| `cazuza` | Cazuza e o Alto Alegre | Vó Bastiana |
| `nome_horizonte` | De Olho d'Água a Horizonte | Final da fase |

## Pontos a validar com historiadores locais

- A data aproximada (c. 1932) é uma escolha de enredo: o fóssil foi achado "no início dos anos 1930" e o distrito virou Horizonte em 1938.
- Tropeiros de farinha do Alto Alegre estão documentados para as décadas de 1960–1990 (dissertação, p. 89); na Fase 1 a farinha aparece como mercadoria genérica da região. Se quiser rigor máximo, troque por rapadura apenas.
- O fato de Cazuza ter fugido na Barra do Ceará é **tradição oral** da comunidade; o jogo o apresenta como "história que os mais velhos contam".
