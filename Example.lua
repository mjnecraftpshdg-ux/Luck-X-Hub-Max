--[[
    Espace X UI Library - Exemplo completo
    Reproduz a janela "Espace X Hub": stats, abas com ícones e todos os componentes.
    (É só uma demonstração visual: os callbacks apenas imprimem valores e mostram notificações.)

    Troque SEU_USUARIO/SEU_REPOSITORIO pelo seu repositório do GitHub.
    Para testar localmente, use a linha com readfile no lugar do loadstring/HttpGet.
]]

local EspaceX = loadstring(game:HttpGet(
    "https://github.com/mjnecraftpshdg-ux/Luck-X-Hub-Max"
))()
-- local EspaceX = loadstring(readfile("EspaceX.lua"))()

----------------------------------------------------------------
-- Janela
----------------------------------------------------------------
local Window = EspaceX:CreateWindow({
    Title = "ESPACE X HUB",
    SubTitle = "Teleportation & Modules",
    Size = UDim2.fromOffset(580, 420),
    ToggleKey = Enum.KeyCode.RightControl,   -- tecla para abrir/fechar
    ShowStats = true,                        -- FPS / Ping / Região
    Launcher = true,                         -- botão flutuante "X"
    AnimatedBorder = false                   -- true = borda com gradiente girando
})

-- Estatística personalizada (opcional)
Window:AddStat("PLAYERS", function()
    return #game:GetService("Players"):GetPlayers()
end, Color3.fromRGB(192, 132, 252))

----------------------------------------------------------------
-- Abas (Icon aceita emoji, texto ou rbxassetid://)
----------------------------------------------------------------
local Home     = Window:AddTab({ Title = "Home",     Icon = "🏠" })
local Farm     = Window:AddTab({ Title = "Farm",     Icon = "🌾" })
local Extras   = Window:AddTab({ Title = "Extras",   Icon = "⭐" })
local Settings = Window:AddTab({ Title = "Settings", Icon = "⚙️" })

----------------------------------------------------------------
-- HOME
----------------------------------------------------------------
Home:AddSection("Bem-vindo")
Home:AddLabel({
    Title = "Espace X UI Library",
    Text = "Biblioteca de interface com Toggle, Slider, Dropdown, Input, Button, Keybind, "
        .. "Label, Stats e Notificações. Veja as outras abas para testar cada componente."
})
Home:AddDivider()
Home:AddButton({
    Title = "Testar notificação",
    Style = "Accent",
    Callback = function()
        Window:Notify({
            Title = "Espace X Hub",
            Content = "Notificação funcionando!",
            Duration = 4,
            Type = "Success"
        })
    end
})

----------------------------------------------------------------
-- FARM (igual à imagem de referência)
----------------------------------------------------------------
Farm:AddSection("Modern Farming Module")

Farm:AddToggle("Autofarm", {
    Title = "Autofarm",
    Default = true,
    Callback = function(value)
        print("Autofarm:", value)
    end
})

Farm:AddDropdown("FarmType", {
    Title = "Farm Type:",
    Values = { "Wheat", "Corn", "Carrot", "Pumpkin" },
    Default = "Wheat",
    Callback = function(value)
        print("Farm Type:", value)
    end
})

Farm:AddSlider("FarmRadius", {
    Title = "Farm Radius",
    Min = 5,
    Max = 100,
    Default = 35,
    Rounding = 0,
    Callback = function(value)
        print("Farm Radius:", value)
    end
})

Farm:AddDropdown("CollectSpeed", {
    Title = "Collect Speed:",
    Values = { "Slow", "Normal", "Fast" },
    Default = "Fast",
    Callback = function(value)
        print("Collect Speed:", value)
    end
})

Farm:AddButton({
    Title = "Start Farm",
    Style = "Success",
    Callback = function()
        local o = EspaceX.Options
        Window:Notify({
            Title = "Start Farm",
            Content = string.format("%s | raio %d | velocidade %s",
                o.FarmType.Value, o.FarmRadius.Value, o.CollectSpeed.Value),
            Type = "Success"
        })
    end
})

----------------------------------------------------------------
-- EXTRAS (demais componentes)
----------------------------------------------------------------
Extras:AddSection("Componentes")

Extras:AddInput("TargetName", {
    Title = "Target Name:",
    Placeholder = "Digite aqui...",
    Callback = function(text)
        print("Input:", text)
    end
})

Extras:AddInput("Amount", {
    Title = "Amount:",
    Placeholder = "0",
    Numeric = true,
    Default = "10",
    Callback = function(text)
        print("Amount:", tonumber(text))
    end
})

Extras:AddDropdown("Tools", {
    Title = "Tools (multi):",
    Values = { "Axe", "Pickaxe", "Shovel", "Hoe" },
    Multi = true,
    Default = { "Axe" },
    Callback = function(selected)
        local names = {}
        for name in pairs(selected) do table.insert(names, name) end
        print("Tools:", table.concat(names, ", "))
    end
})

Extras:AddSlider("Delay", {
    Title = "Delay",
    Min = 0,
    Max = 2,
    Default = 0.5,
    Rounding = 1,
    Suffix = "s",
    Callback = function(value)
        print("Delay:", value)
    end
})

Extras:AddToggle("ShowState", {
    Title = "Sem texto de estado",
    ShowState = false,
    Default = false
})

Extras:AddKeybind("ActionKey", {
    Title = "Action Key:",
    Default = Enum.KeyCode.G,
    Callback = function()
        Window:Notify({ Title = "Keybind", Content = "Tecla pressionada!" })
    end
})

----------------------------------------------------------------
-- SETTINGS
----------------------------------------------------------------
Settings:AddSection("Interface")

Settings:AddKeybind("MenuKey", {
    Title = "Menu Key:",
    Default = Enum.KeyCode.RightControl,
    Callback = function() end
})
Settings:AddLabel("A tecla de abrir/fechar é definida em CreateWindow({ ToggleKey = ... }).")

Settings:AddDivider()
Settings:AddButton({
    Title = "Fechar interface",
    Style = "Danger",
    Callback = function()
        Window:Destroy()
    end
})

-- Ler/alterar valores por código:
-- EspaceX.Options["Autofarm"].Value
-- EspaceX.Options["Autofarm"]:SetValue(false)
-- EspaceX.Options["FarmRadius"]:OnChanged(function(v) print(v) end)
