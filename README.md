# Siga e Repita

Jogo de puzzle 2D infantil para Android, feito em **Godot 4.x (GDScript)**.
Objetivo: partir do **Início**, percorrer **todas as posições válidas** do mapa
seguindo a **sequência de imagens** e chegar ao **Fim**. O visual é lúdico, cheio
de formas orgânicas, cantos arredondados e **nunca** usa fundo branco, preto ou
cinza (apenas cores vivas).

---

## 1. Requisitos

- **Godot Engine 4.3+** (versão standard, sem .NET).
- Para exportar para Android: Android SDK + JDK 17 configurados no editor
  (`Editor > Gerenciar Templates de Exportação > Android`).

## 2. Como rodar

1. Abra o Godot, clique em **Importar** e selecione `project.godot`.
2. Pressione **F5** para rodar no desktop (teclas direcionais/WASD já funcionam).
3. Para Android: `Projeto > Exportar... > Adicionar... > Android`, configure o
   keystore e exporte (o `.apk`/`.aab` fica em `/build`, já ignorado pelo Git).

## 3. Controles

O método de controle é escolhido na **Tela de Configurações**:

- **Toque / Deslizar (Swipe):** arraste o dedo na direção desejada.
- **Setas direcionais:** use o D-pad que aparece na parte inferior.

No desktop, as setas do teclado e **WASD** funcionam sempre. O movimento é
**ortogonal estrito** (sem diagonais e sem pular casas) e é bloqueado ao tentar
entrar numa célula vazia, inválida ou cujo token não seja o próximo da sequência.

Botões na tela de jogo:

- **Desfazer:** volta um movimento, restaurando posição, sequência e visitas.
- **Reiniciar:** recomeça a fase atual do zero.

## 4. Formato de fase (matriz alfanumérica)

Cada fase é um arquivo JSON em `levels/`. O campo `matrix` é a matriz lida
**linha a linha** (cada string = uma linha). Cada linha pode ser escrita como
**tokens separados por espaço** (permite tokens com mais de um caractere, ex.:
`10`, `K`, `P`) ou como caracteres colados (ex.: `XXX43XXXX`). As quebras de
linha definem as linhas. A anotação `br` também pode ser usada como marcador de
quebra de linha no final de cada linha.

| Símbolo | Significado |
|---------|-------------|
| `X` ou `.` | Posição vazia / inválida (bloqueada) |
| `&` | Início (posição inicial do jogador). `A` também é aceito como início |
| `B` / `F` / `§` | Fim (objetivo). `B` e `F` também são aceitos; `§` é o marcador alternativo |
| `E` | Posição Especial: transição para a próxima sequência |
| qualquer token | Item da sequência: números e/ou letras, fora de ordem |

As fases **não têm nome**; são identificadas pelo número (`id`).

### Regras

- O jogador só avança para uma célula adjacente se o token dela for
  **exatamente** o próximo item da sequência atual.
- A sequência é **cíclica** (depois do último item volta ao primeiro) e deve ter
  **no mínimo 4 elementos**.
- Uma sequência pode **misturar números e letras, fora de ordem**.
  Exemplos válidos: `1, 3, F, 9` · `K, 2, 5, 3` · `10, 9, P, 7`.
- **Posição Especial `E`:** só pode ser usada **depois de usar o último item da
  sequência atual**. Ao entrar nela, o jogo ativa o próximo conjunto de regras
  (`sequences[i+1]`).
- **Vitória:** visitar **todas as posições válidas** (exceto o Fim) e só então
  entrar no **Fim**.

> Dica: não use `A`, `B`, `E`, `F`, `X` ou `.` como itens de sequência, pois são
> reservados para início, fim, posição especial e vazios.

### Exemplos

Fase 1 (uma sequência):

```json
{
  "id": 1,
  "sequences": [["1", "2", "3", "4"]],
  "matrix": [
	"XXX43XXXX",
	"XXX12XXXX",
	"XXX21XXXX",
	"A1234XXXX",
	"XXX41234B"
  ]
}
```

Fase 3 (múltiplas sequências + posição especial, com letras):

```json
{
  "id": 3,
  "sequences": [["1", "3", "K", "9"], ["2", "P", "5", "7", "8"]],
  "matrix": [
	"A13K",
	"P2E9",
	"578B"
  ]
}
```

## 5. Estrutura do projeto

```
siga-e-repita/
├── project.godot            # config do projeto/autoloads
├── icon.svg
├── levels/                  # fases em JSON (matriz alfanumerica)
├── scenes/
│   ├── ui/                  # MainMenu, LevelSelect, Settings
│   └── game/                # Game (Board + HUD)
└── scripts/
	├── autoload/            # GameState, Levels, Settings
	├── board/               # LevelMatrix, PuzzleRules, Tile, TrailLayer, Player, Board
	├── game/                # Game (wiring Board <-> HUD)
	├── ui/                  # Hud, Background, LevelTrail, telas
	└── util/                # StyleFactory (formas organicas / paleta)
```

## 6. Versionamento com Git

O repositório já está inicializado. Para iniciar do zero:

```bash
git init
git add .
git commit -m "chore: estrutura inicial do projeto Siga e Repita"
git branch -M main
# opcional: enviar para um remoto
git remote add origin <url-do-repositorio>
git push -u origin main
```

Sugestão de fluxo de branches:

- `main` — versões estáveis.
- `dev` — integração de novas fases/features.
- `feat/<nome>` — uma feature por branch (ex.: `feat/fase-10`).

O `.gitignore` já exclui cache do Godot (`.godot/`), builds (`/build`), APKs e
**keystores** (nunca versionar chaves de assinatura).
