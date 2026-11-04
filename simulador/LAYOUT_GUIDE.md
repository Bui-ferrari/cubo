# Guia: apps nas duas orientações (vertical e horizontal)

A tela física do cubo é 240 x 320 (vertical) e nunca muda. O que muda é **para quem o texto está virado** (RV):
quando o aparelho é inclinado para o lado de um jogador, o sistema gira todo o conteúdo para ele.
Para os lados (jogador à esquerda ou à direita) o conteúdo fica **deitado**: o app enxerga uma tela de 320 x 240.

## Como o app declara suporte
- `-- layout: both` (logo depois de `-- icon:`): o app foi escrito para as duas formas e lê `W`, `H` a cada quadro.
- sem essa linha: app antigo (só vertical). Em 0° e 180° funciona normalmente; deitado, o sistema o reduz (70 %) e o centraliza.
- `-- orient: fixed`: o app NÃO gira (ex.: relógio com jogador de cima espelhado). Fica sempre vertical.

## Variáveis do SDK (atualizadas pelo sistema)
| | vertical (0°/180°) | horizontal (90°/270°) |
|---|---|---|
| `W, H` | 240, 320 | 320, 240 |
| `X0,Y0,X1,Y1` (área segura) | 26,26,214,294 | 26,26,294,214 |
| `CW, CH` | 188, 268 | 268, 188 |
| `ROT` | 0 ou 180 | 90 ou 270 |
`portrait()` e `landscape()` dizem o formato. Desenhe sempre como se o leitor estivesse embaixo da tela lógica:
texto em pé, sem espelhar (o sistema gira tudo). As plaquinhas dos pads ficam nas bordas fora da área segura (26 px).

## Regras
1. **Nunca** guarde W/H/X0/CW em variáveis no topo do arquivo (`local cx=W//2` no nível do arquivo fica errado após girar). Calcule dentro de `draw`, `update` ou `on_pad`, ou use funções.
2. Use só a área segura para conteúdo; fundos podem sangrar até a borda.
3. Estado do jogo (placar, tempo, rolagem) **não pode ser perdido** ao girar: a rotação só troca W/H, o app continua rodando.
4. Em formato deitado use o espaço: dados lado a lado, listas com menos itens e mais colunas, etc.
5. Os nomes dos pads (`up/down/left/right/ok`) e `labels()` não mudam: continuam ligados aos pads físicos.
6. Números de dado continuam com `numtext` (barra no 6 e 9).

## Testar
`python3 build.py node/node_modules/fengari-web/dist/fengari-web.js sim_<nome>.html`
`NODE_PATH=$(npm root -g) node t_rot.js sim_<nome>.html <prefixo> <chave> ...`
Chaves: `home`, `settings`, `store`, `app-dice`, `pk-dnd-1` (pacote-índice do micro-app, ordem alfabética dos arquivos).
Gera `<prefixo>_<chave>_{0,90,180,270}.png` (só a tela). Olhe as 4 imagens de cada app.
