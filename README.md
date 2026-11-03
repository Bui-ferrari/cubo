# Cubo

Gadget para jogos de tabuleiro com ESP32-S3: tela de 240 × 320, pads de toque, sensor de movimento e alto-falante. Os apps são escritos em Lua e rodam primeiro neste simulador web, depois no aparelho.

**Estado:** em desenvolvimento. Ainda sem licença definida.

## Simulador
- Endereço HTTPS (GitHub Pages): ver "Settings → Pages" deste repositório.
- Código-fonte em `simulador/`. Para gerar a página: `python3 simulador/build.py <caminho-ou-url-do-fengari> docs/index.html` (rode dentro de `simulador/`).

## Pastas
- `simulador/sys/` — Menu, Ajustes, Loja e o SDK em Lua (`sdk.lua`).
- `simulador/apps/` — apps (dados, timer, placar, etc.). Cada app começa com `-- name:` e `-- icon:`.
- `simulador/packs/<jogo>/` — pacote de jogo: `pack.txt`, mini-apps `.lua` e `regras.txt` (slides separados por `---`).
- `docs/` — página publicada.

## Limites que o simulador respeita
Tela 240 × 320 em 16 bits, 30 quadros por segundo, app de até 32 KB, 512 bytes salvos por valor, quadro abortado acima de 200 ms.
