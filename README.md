# Espace X UI Library

Biblioteca de interface (UI) para Roblox, escrita em Luau, com visual escuro estilo "glass", borda em gradiente, barra de estatísticas, abas com ícones e componentes animados. Funciona em PC e celular (mouse e toque).

> Esta biblioteca é **somente interface**: ela não contém nenhuma lógica de jogo. Você liga os componentes às suas próprias funções pelos callbacks.

## Recursos

- Janela arrastável com animação de abrir/fechar e botão flutuante **X** (também arrastável)
- Barra de **estatísticas** (FPS, Ping, Região) com suporte a estatísticas personalizadas
- Abas com ícones (emoji, texto ou `rbxassetid://`)
- Componentes: **Toggle, Slider, Dropdown (simples e múltiplo), Input, Button, Keybind, Label, Divider, Section**
- **Notificações**
- Tema personalizável
- Acesso aos valores por nome: `EspaceX.Options["Nome"].Value`

## Instalação

```lua
local EspaceX = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/SEU_USUARIO/SEU_REPOSITORIO/main/EspaceX.lua"
))()
```

Para testar localmente (executor com `readfile`):

```lua
local EspaceX = loadstring(readfile("EspaceX.lua"))()
```

## Uso rápido

```lua
local Window = EspaceX:CreateWindow({
    Title = "ESPACE X HUB",
    SubTitle = "Teleportation & Modules"
})

local Farm = Window:AddTab({ Title = "Farm", Icon = "🌾" })

Farm:AddSection("Modern Farming Module")

Farm:AddToggle("Autofarm", {
    Title = "Autofarm",
    Default = true,
    Callback = function(value) print(value) end
})

Farm:AddButton({
    Title = "Start Farm",
    Callback = function() print("Iniciado") end
})
```

O arquivo [`Example.lua`](Example.lua) tem um exemplo completo com todos os componentes.

## API

### `EspaceX:CreateWindow(config)`

| Opção | Tipo | Padrão | Descrição |
|---|---|---|---|
| `Title` | string | `"ESPACE X HUB"` | Título (a palavra isolada `X` fica colorida) |
| `SubTitle` | string | `""` | Texto à direita do título |
| `Size` | UDim2 | `580 x 420` | Tamanho (limitado ao tamanho da tela) |
| `ToggleKey` | Enum.KeyCode | `RightControl` | Tecla para abrir/fechar |
| `ShowStats` | boolean | `true` | Mostra a barra FPS / Ping / Região |
| `Launcher` | boolean | `true` | Botão flutuante para abrir/fechar |
| `LauncherText` | string | `"X"` | Texto do botão flutuante |
| `AutoOpen` | boolean | `true` | Abre a janela ao carregar |
| `AnimatedBorder` | boolean | `false` | Gradiente da borda girando |
| `Theme` | table | - | Sobrescreve cores do tema |

### Janela

| Método | Descrição |
|---|---|
| `Window:AddTab({ Title, Icon })` | Cria uma aba |
| `Window:AddStat(nome, getter, cor)` | Adiciona estatística. `getter` retorna o valor; `cor` é `Color3` ou função `(valor) -> Color3` |
| `Window:Notify({ Title, Content, Duration, Type })` | Notificação. `Type`: `"Success"`, `"Warning"`, `"Danger"` |
| `Window:Toggle(estado)` | Abre/fecha (sem argumento, alterna) |
| `Window:SelectTab(aba ou índice)` | Seleciona uma aba |
| `Window:Destroy()` | Remove a interface |

### Componentes (métodos de uma aba)

| Método | Opções principais |
|---|---|
| `Tab:AddSection(titulo)` | Título de seção |
| `Tab:AddLabel({ Title, Text })` ou `Tab:AddLabel("texto")` | Texto informativo (`:SetText(t)`) |
| `Tab:AddDivider()` | Linha divisória |
| `Tab:AddButton({ Title, Style, Callback })` | `Style`: `"Success"` (padrão), `"Accent"`, `"Danger"`, `"Default"` |
| `Tab:AddToggle(nome, { Title, Default, ShowState, Callback })` | `ShowState = false` esconde o `: ON/OFF` |
| `Tab:AddSlider(nome, { Title, Min, Max, Default, Rounding, Suffix, Callback })` | `Rounding` = casas decimais |
| `Tab:AddDropdown(nome, { Title, Values, Default, Multi, Width, Callback })` | No modo `Multi`, o valor é uma tabela `{ [opcao] = true }` |
| `Tab:AddInput(nome, { Title, Default, Placeholder, Numeric, Finished, Width, Callback })` | `Finished = false` dispara a cada letra |
| `Tab:AddKeybind(nome, { Title, Default, Callback, ChangedCallback })` | `Callback` roda ao apertar a tecla |

Todo componente com `nome` retorna um objeto e fica em `EspaceX.Options[nome]`:

```lua
local opt = EspaceX.Options["Autofarm"]
print(opt.Value)          -- valor atual
opt:SetValue(false)       -- altera (dispara o callback)
opt:SetValue(false, true) -- altera sem disparar o callback
opt:OnChanged(function(v) print(v) end)
```

`Dropdown` também tem `:SetValues({ ... })` para trocar a lista.

### Tema

```lua
EspaceX:CreateWindow({
    Theme = {
        Accent  = Color3.fromRGB(255, 120, 200),
        Success = Color3.fromRGB(120, 255, 160),
    }
})
```

Chaves disponíveis: `Background, Panel, Card, Item, ItemHover, Border, Text, SubText, Accent, Purple, Success, Warning, Danger, Info, Off`.

## Estrutura do repositório

```
EspaceX.lua   -> a biblioteca
Example.lua   -> exemplo completo com todos os componentes
README.md     -> esta documentação
```

## Observações

- Ícones em emoji aparecem com a cor do próprio emoji. Para ícones coloridos pelo tema, use um `rbxassetid://`.
- Região usa `LocalizationService`; se o jogo bloquear a chamada, mostra `N/A`.
- Ping usa `Stats.Network`; se não estiver disponível no ambiente, mostra `N/A`.
