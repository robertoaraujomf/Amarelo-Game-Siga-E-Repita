# Siga e Repita

Jogo de puzzle 2D infantil para Android, feito em **Godot 4.x (GDScript)**.
Objetivo: partir do **Início**, percorrer **todas as posições válidas** do mapa
seguindo a **sequência de imagens** e chegar ao **Fim**. O visual é lúdico, cheio
de formas orgânicas, cantos arredondados e nada de linhas retas/secas.

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
- **Setas direcionais:** use o D-pad orgânico que aparece na parte inferior.

No desktop, as setas do teclado e **WASD** funcionam sempre (útil para testar).
O movimento é **ortogonal estrito** (sem diagonais e sem pular casas) e é
bloqueado automaticamente ao tentar entrar numa célula vazia, inválida ou cujo
símbolo não seja o próximo da sequência.

## 4. Formato de fase (matriz alfanumérica)

Cada fase é um arquivo JSON em `levels/`. O campo `matrix` é uma matriz de
**caracteres**, lida linha a linha (cada string = uma linha de colunas).

| Símbolo | Significado |
|---------|-------------|
| `X` ou `.` | Posição vazia / inválida (bloqueada) |
| `A` | Início (posição inicial do jogador) |
| `B` ou `F` | Fim (objetivo) |
| `E` | Posição Especial: alterna para a próxima sequência |
| `1` `2` `3` `4` | Itens sequenciais das imagens animadas |

Exemplo (Fase 1):

```json
{
  "id": 1,
  "name": "Vai e Volta",
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

O código lê essa matriz e monta o tabuleiro dinamicamente (tiles, início, fim,
posições especiais). Para criar uma fase nova, basta copiar um JSON, ajustar a
matriz e a lista `sequences`.

### Regras

- O jogador só avança para uma célula adjacente se o símbolo dela for
  **exatamente** o próximo item da sequência atual.
- A sequência é **cíclica** (depois do último item volta ao primeiro).
- Objetivo: visitar **todas as posições válidas** (exceto o Fim) e só então
  entrar no **Fim**.
- Com **múltiplas sequências**, ao pisar numa posição `E` o jogo alterna para o
  próximo conjunto de regras (`sequences[i+1]`).

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
    ├── ui/                  # Hud, Background, telas
    └── util/                # StyleFactory (formas organicas)
```

## 6. Versionamento com Git

O repositório já está pronto para uso. Para iniciar do zero:

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
- `feat/<nome>` — uma feature por branch (ex.: `feat/fase-02`).

O `.gitignore` já exclui cache do Godot (`.godot/`), builds (`/build`), APKs e
**keystores** (nunca versionar chaves de assinatura).
