--[[
    ESPACE X UI LIBRARY  -  v1.0.0
    Biblioteca de interface para Roblox (Luau)

    Componentes: Window, Tab, Section, Toggle, Slider, Dropdown (simples e multi),
                 Input, Button, Keybind, Label, Divider, Stats, Notify

    Uso:
        local EspaceX = loadstring(game:HttpGet("URL_DO_RAW_DESTE_ARQUIVO"))()
        local Window  = EspaceX:CreateWindow({ Title = "ESPACE X HUB" })
]]

local Players             = game:GetService("Players")
local TweenService        = game:GetService("TweenService")
local UserInputService    = game:GetService("UserInputService")
local RunService          = game:GetService("RunService")
local StatsService        = game:GetService("Stats")
local LocalizationService = game:GetService("LocalizationService")

local LocalPlayer = Players.LocalPlayer

local EspaceX = {
    Version = "1.0.0",
    Options = {},   -- componentes acessíveis pelo nome (flag): EspaceX.Options["Autofarm"].Value
}

----------------------------------------------------------------
-- Tema padrão (pode ser sobrescrito em CreateWindow({ Theme = {...} }))
----------------------------------------------------------------
local DefaultTheme = {
    Background = Color3.fromRGB(10, 15, 30),
    Panel      = Color3.fromRGB(16, 24, 44),
    Card       = Color3.fromRGB(13, 20, 38),
    Item       = Color3.fromRGB(24, 34, 58),
    ItemHover  = Color3.fromRGB(34, 48, 80),
    Border     = Color3.fromRGB(44, 58, 92),
    Text       = Color3.fromRGB(240, 244, 255),
    SubText    = Color3.fromRGB(148, 163, 190),
    Accent     = Color3.fromRGB(94, 226, 240),
    Purple     = Color3.fromRGB(150, 98, 246),
    Success    = Color3.fromRGB(74, 222, 128),
    Warning    = Color3.fromRGB(255, 169, 77),
    Danger     = Color3.fromRGB(248, 90, 90),
    Info       = Color3.fromRGB(96, 165, 250),
    Off        = Color3.fromRGB(52, 60, 88),
}

local REGION_NAMES = {
    BR = "Brazil", US = "United States", PT = "Portugal", AR = "Argentina",
    MX = "Mexico", CL = "Chile", CO = "Colombia", ES = "Spain", FR = "France",
    DE = "Germany", GB = "United Kingdom", CA = "Canada", JP = "Japan",
    KR = "South Korea", IN = "India", PH = "Philippines", ID = "Indonesia",
    RU = "Russia", TR = "Turkey", AU = "Australia", IT = "Italy", PL = "Poland",
}

----------------------------------------------------------------
-- Utilidades
----------------------------------------------------------------
local function Create(class, props, children)
    local inst = Instance.new(class)
    local parent
    for k, v in pairs(props or {}) do
        if k == "Parent" then parent = v else inst[k] = v end
    end
    for _, child in ipairs(children or {}) do child.Parent = inst end
    if parent then inst.Parent = parent end
    return inst
end

local function Tween(obj, time, props, style, dir)
    local tw = TweenService:Create(obj,
        TweenInfo.new(time, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
        props)
    tw:Play()
    return tw
end

local function Corner(r)
    return Create("UICorner", { CornerRadius = UDim.new(0, r) })
end

local function Stroke(color, thickness, transparency)
    return Create("UIStroke", {
        Color = color,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    })
end

local function Esc(s)
    s = tostring(s)
    s = s:gsub("&", "&amp;")
    s = s:gsub("<", "&lt;")
    s = s:gsub(">", "&gt;")
    return s
end

local function Colored(text, color)
    return string.format('<font color="#%s">%s</font>', color:ToHex(), text)
end

local function RoundTo(v, decimals)
    local m = 10 ^ decimals
    return math.floor(v * m + 0.5) / m
end

local function GetGuiParent()
    if gethui then
        local ok, ui = pcall(gethui)
        if ok and ui then return ui end
    end
    local ok = pcall(function() return game:GetService("CoreGui"):GetChildren() end)
    if ok then return game:GetService("CoreGui") end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local function Viewport(gui)
    local s = gui.AbsoluteSize
    if s.X < 10 then s = workspace.CurrentCamera.ViewportSize end
    return s
end

-- Seta (chevron) desenhada com duas barras
local function Chevron(parent, color)
    local holder = Create("Frame", {
        Parent = parent,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.fromOffset(14, 14),
        BackgroundTransparency = 1
    })
    for _, b in ipairs({ { x = 4, rot = 45 }, { x = 10, rot = -45 } }) do
        Create("Frame", {
            Parent = holder,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0, b.x, 0.5, 1),
            Size = UDim2.fromOffset(9, 2),
            Rotation = b.rot,
            BackgroundColor3 = color,
            BorderSizePixel = 0
        }, { Corner(1) })
    end
    return holder
end

-- Ícone: aceita "rbxassetid://123", número (id) ou texto/emoji
local function MakeIcon(parent, icon, size, color)
    icon = tostring(icon or "")
    local isId = icon:match("^%d+$") ~= nil
    if isId or icon:sub(1, 13) == "rbxassetid://" then
        if isId then icon = "rbxassetid://" .. icon end
        local img = Create("ImageLabel", {
            Parent = parent,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(size, size),
            BackgroundTransparency = 1,
            Image = icon,
            ImageColor3 = color or Color3.new(1, 1, 1)
        })
        return img, "ImageTransparency"
    end
    local txt = Create("TextLabel", {
        Parent = parent,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(size + 10, size + 10),
        BackgroundTransparency = 1,
        Text = icon,
        Font = Enum.Font.GothamBold,
        TextSize = size,
        TextColor3 = color or Color3.new(1, 1, 1)
    })
    return txt, "TextTransparency"
end

-- Efeito de hover e clique
local function Feedback(btn, normal, hover)
    local sc = Create("UIScale", { Parent = btn })
    btn.MouseEnter:Connect(function()
        Tween(btn, 0.15, { BackgroundColor3 = hover })
    end)
    btn.MouseLeave:Connect(function()
        Tween(btn, 0.15, { BackgroundColor3 = normal })
        Tween(sc, 0.12, { Scale = 1 })
    end)
    btn.MouseButton1Down:Connect(function()
        Tween(sc, 0.08, { Scale = 0.97 })
    end)
    btn.MouseButton1Up:Connect(function()
        Tween(sc, 0.15, { Scale = 1 }, Enum.EasingStyle.Back)
    end)
    return sc
end

-- Arrastar (mouse e toque). onClick só dispara se NÃO arrastou.
local function MakeDraggable(win, handle, target, onClick, onStart)
    local dragging, moved = false, false
    local dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging, moved = true, false
            dragStart, startPos = input.Position, target.Position

            local conn
            conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    conn:Disconnect()
                    dragging = false
                    if not moved and onClick then onClick() end
                end
            end)
        end
    end)

    local move = UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            if not moved and delta.Magnitude > 6 then
                moved = true
                if onStart then onStart() end
            end
            if moved then
                local vp   = Viewport(win.Gui)
                local half = target.AbsoluteSize / 2
                local x = math.clamp(startPos.X.Offset + delta.X, half.X, vp.X - half.X)
                local y = math.clamp(startPos.Y.Offset + delta.Y, half.Y, vp.Y - half.Y)
                target.Position = UDim2.fromOffset(x, y)
            end
        end
    end)
    win:_track(move)
    target.Destroying:Connect(function() move:Disconnect() end)
end

-- Registro de componentes e disparo de callbacks
local function Register(flag, obj)
    obj._changed = {}
    function obj:OnChanged(fn)
        table.insert(self._changed, fn)
    end
    if flag and flag ~= "" then
        EspaceX.Options[flag] = obj
    end
    return obj
end

local function Fire(obj, callback)
    if callback then task.spawn(callback, obj.Value) end
    for _, fn in ipairs(obj._changed) do task.spawn(fn, obj.Value) end
end

local function NewRow(tab, height, clickable)
    tab._order = tab._order + 1
    local props = {
        Parent = tab.Page,
        Size = UDim2.new(1, 0, 0, height),
        BackgroundTransparency = 1,
        LayoutOrder = tab._order
    }
    if clickable then
        props.Text = ""
        props.AutoButtonColor = false
    end
    return Create(clickable and "TextButton" or "Frame", props)
end

----------------------------------------------------------------
-- COMPONENTES (disponíveis em Tab)
----------------------------------------------------------------
local Components = {}

-- Título de seção (centralizado, ciano)
function Components:AddSection(title)
    local T = self.Window.Theme
    self._order = self._order + 1
    Create("TextLabel", {
        Parent = self.Page,
        Size = UDim2.new(1, 0, 0, 30),
        LayoutOrder = self._order,
        BackgroundTransparency = 1,
        Text = string.upper(tostring(title)),
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextColor3 = T.Accent
    })
    return self
end

-- Linha divisória
function Components:AddDivider()
    local T = self.Window.Theme
    self._order = self._order + 1
    Create("Frame", {
        Parent = self.Page,
        Size = UDim2.new(1, 0, 0, 1),
        LayoutOrder = self._order,
        BackgroundColor3 = T.Border,
        BorderSizePixel = 0
    })
end

-- Texto informativo (opts: { Title, Text } ou string)
function Components:AddLabel(opts)
    local T = self.Window.Theme
    if type(opts) == "string" then opts = { Text = opts } end
    opts = opts or {}
    self._order = self._order + 1

    local function build()
        local text = Esc(opts.Text or "")
        if opts.Title then
            text = "<b>" .. Esc(opts.Title) .. "</b>\n" .. text
        end
        return text
    end

    local label = Create("TextLabel", {
        Parent = self.Page,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = self._order,
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = T.SubText,
        TextWrapped = true,
        RichText = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Text = build()
    })

    local obj = {}
    function obj:SetText(text)
        opts.Text = text
        label.Text = build()
    end
    return obj
end

-- Botão (opts: { Title, Style = "Success"|"Accent"|"Danger"|"Default", Callback })
function Components:AddButton(opts)
    opts = opts or {}
    local T = self.Window.Theme
    local row = NewRow(self, 46)

    local styles = {
        Success = { bg = Color3.fromRGB(26, 86, 62),  hover = Color3.fromRGB(34, 112, 80),  stroke = T.Success },
        Accent  = { bg = Color3.fromRGB(22, 66, 88),  hover = Color3.fromRGB(30, 90, 118),  stroke = T.Accent },
        Danger  = { bg = Color3.fromRGB(88, 32, 38),  hover = Color3.fromRGB(116, 42, 50),  stroke = T.Danger },
        Default = { bg = T.Item,                      hover = T.ItemHover,                  stroke = T.Border },
    }
    local s = styles[opts.Style or "Success"] or styles.Success

    local btn = Create("TextButton", {
        Parent = row,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = s.bg,
        AutoButtonColor = false,
        Text = opts.Title or "Button",
        Font = Enum.Font.GothamBold,
        TextSize = 17,
        TextColor3 = T.Text
    }, { Corner(20), Stroke(s.stroke, 1.6, 0.1) })
    Feedback(btn, s.bg, s.hover)

    btn.MouseButton1Click:Connect(function()
        if opts.Callback then task.spawn(opts.Callback) end
    end)

    local obj = { Type = "Button", Instance = btn }
    function obj:SetTitle(text) btn.Text = text end
    return obj
end

-- Toggle (opts: { Title, Default, ShowState, Callback })
function Components:AddToggle(flag, opts)
    opts = opts or {}
    local T = self.Window.Theme
    local row = NewRow(self, 42, true)
    local title = Esc(opts.Title or flag or "Toggle")
    local showState = opts.ShowState ~= false

    local label = Create("TextLabel", {
        Parent = row,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -64, 1, 0),
        Font = Enum.Font.GothamMedium,
        TextSize = 17,
        TextColor3 = T.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        RichText = true,
        Text = title
    })

    local switch = Create("Frame", {
        Parent = row,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(50, 27),
        BackgroundColor3 = T.Off
    }, { Corner(14) })

    local knob = Create("Frame", {
        Parent = switch,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0, 14, 0.5, 0),
        Size = UDim2.fromOffset(21, 21),
        BackgroundColor3 = Color3.new(1, 1, 1)
    }, { Corner(11) })

    local obj = Register(flag, { Type = "Toggle", Value = false })

    local function render(animate)
        local on = obj.Value
        local t = animate and 0.2 or 0
        Tween(switch, t, { BackgroundColor3 = on and T.Success or T.Off })
        Tween(knob, t, { Position = on and UDim2.new(1, -14, 0.5, 0) or UDim2.new(0, 14, 0.5, 0) },
            Enum.EasingStyle.Back)
        if showState then
            label.Text = title .. ": " .. Colored(on and "ON" or "OFF", on and T.Success or T.SubText)
        else
            label.Text = title
        end
    end

    function obj:SetValue(v, silent)
        self.Value = v and true or false
        render(true)
        if not silent then Fire(self, opts.Callback) end
    end

    row.MouseButton1Click:Connect(function()
        obj:SetValue(not obj.Value)
    end)

    obj.Value = opts.Default and true or false
    render(false)
    return obj
end

-- Slider (opts: { Title, Min, Max, Default, Rounding, Suffix, Callback })
function Components:AddSlider(flag, opts)
    opts = opts or {}
    local win = self.Window
    local T = win.Theme
    local min, max = opts.Min or 0, opts.Max or 100
    local rounding = opts.Rounding or 0
    local suffix = opts.Suffix or ""
    local title = Esc(opts.Title or flag or "Slider")
    local row = NewRow(self, 44)

    local label = Create("TextLabel", {
        Parent = row,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.5, -6, 1, 0),
        Font = Enum.Font.GothamMedium,
        TextSize = 17,
        TextColor3 = T.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        RichText = true,
        Text = title
    })

    local track = Create("Frame", {
        Parent = row,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.new(0.5, -26, 0, 9),
        BackgroundColor3 = T.Off
    }, { Corner(5) })

    local fill = Create("Frame", {
        Parent = track,
        Size = UDim2.fromScale(0, 1),
        BackgroundColor3 = Color3.new(1, 1, 1)
    }, {
        Corner(5),
        Create("UIGradient", {
            Color = ColorSequence.new(Color3.fromRGB(56, 189, 248), T.Accent)
        })
    })

    local knob = Create("Frame", {
        Parent = track,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0, 0.5),
        Size = UDim2.fromOffset(20, 20),
        BackgroundColor3 = Color3.new(1, 1, 1)
    }, { Corner(10), Stroke(T.Accent, 2, 0.15) })
    local knobScale = Create("UIScale", { Parent = knob })

    local hit = Create("TextButton", {
        Parent = row,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0.5, -6, 0, 34),
        BackgroundTransparency = 1,
        Text = ""
    })

    local obj = Register(flag, { Type = "Slider", Value = min })

    local function render()
        local a = (obj.Value - min) / math.max(max - min, 1e-9)
        a = math.clamp(a, 0, 1)
        fill.Size = UDim2.fromScale(a, 1)
        knob.Position = UDim2.fromScale(a, 0.5)
        label.Text = title .. ": " .. Colored(tostring(obj.Value) .. Esc(suffix), T.Accent)
    end

    function obj:SetValue(v, silent)
        v = math.clamp(tonumber(v) or min, min, max)
        v = RoundTo(v, rounding)
        local changed = (v ~= self.Value)
        self.Value = v
        render()
        if changed and not silent then Fire(self, opts.Callback) end
    end

    local sliding = false
    local function fromInput(input)
        local rel = (input.Position.X - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1)
        obj:SetValue(min + math.clamp(rel, 0, 1) * (max - min))
    end

    hit.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            self.Page.ScrollingEnabled = false
            Tween(knobScale, 0.12, { Scale = 1.2 }, Enum.EasingStyle.Back)
            fromInput(input)
        end
    end)
    win:_track(UserInputService.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            fromInput(input)
        end
    end))
    win:_track(UserInputService.InputEnded:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch) then
            sliding = false
            self.Page.ScrollingEnabled = true
            Tween(knobScale, 0.15, { Scale = 1 })
        end
    end))

    obj.Value = RoundTo(math.clamp(opts.Default or min, min, max), rounding)
    render()
    return obj
end

-- Dropdown (opts: { Title, Values, Default, Multi, Width, Callback })
function Components:AddDropdown(flag, opts)
    opts = opts or {}
    local win = self.Window
    local T = win.Theme
    local multi = opts.Multi == true
    local selW = opts.Width or 170
    local row = NewRow(self, 48)

    Create("TextLabel", {
        Parent = row,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -(selW + 10), 1, 0),
        Font = Enum.Font.GothamMedium,
        TextSize = 17,
        TextColor3 = T.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Text = opts.Title or flag or "Dropdown"
    })

    local selector = Create("TextButton", {
        Parent = row,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(selW, 38),
        BackgroundColor3 = T.Item,
        AutoButtonColor = false,
        Text = ""
    }, { Corner(10), Stroke(T.Border, 1, 0) })
    Feedback(selector, T.Item, T.ItemHover)

    local valueLabel = Create("TextLabel", {
        Parent = selector,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(14, 0),
        Size = UDim2.new(1, -40, 1, 0),
        Font = Enum.Font.GothamMedium,
        TextSize = 16,
        TextColor3 = T.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Text = ""
    })
    local chevron = Chevron(selector, T.Text)

    local obj = Register(flag, {
        Type = "Dropdown",
        Values = opts.Values or {},
        Multi = multi,
        Value = multi and {} or nil
    })

    local function display()
        if multi then
            local names = {}
            for _, v in ipairs(obj.Values) do
                if obj.Value[v] then table.insert(names, tostring(v)) end
            end
            valueLabel.Text = (#names > 0) and table.concat(names, ", ") or "None"
        else
            valueLabel.Text = (obj.Value ~= nil) and tostring(obj.Value) or "Select..."
        end
    end

    function obj:SetValue(v, silent)
        if multi then
            local set = {}
            if type(v) == "table" then
                for k, val in pairs(v) do
                    if type(k) == "number" then set[val] = true
                    elseif val then set[k] = true end
                end
            end
            self.Value = set
        else
            if type(v) == "number" then v = self.Values[v] end
            self.Value = v
        end
        display()
        if not silent then Fire(self, opts.Callback) end
    end

    function obj:SetValues(list)
        self.Values = list or {}
        if not multi and self.Value ~= nil and not table.find(self.Values, self.Value) then
            self.Value = nil
        end
        display()
    end

    local function closePopup()
        if win._popup then win._popup.close() end
    end

    local function openPopup()
        closePopup()

        local blocker = Create("TextButton", {
            Parent = win.Gui,
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 190
        })

        local itemH = 32
        local count = #obj.Values
        local height = math.min(count * (itemH + 2) + 8, 5 * (itemH + 2) + 8)
        if count == 0 then height = 40 end

        local abs, size = selector.AbsolutePosition, selector.AbsoluteSize
        local vpH = Viewport(win.Gui).Y
        local y = abs.Y + size.Y + 4
        if y + height > vpH - 6 then y = abs.Y - height - 4 end

        local popup = Create("Frame", {
            Parent = win.Gui,
            Position = UDim2.fromOffset(abs.X, y),
            Size = UDim2.fromOffset(size.X, 0),
            BackgroundColor3 = T.Panel,
            ClipsDescendants = true,
            ZIndex = 200
        }, { Corner(10), Stroke(T.Accent, 1, 0.45) })

        local scroll = Create("ScrollingFrame", {
            Parent = popup,
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = T.Accent,
            CanvasSize = UDim2.new(),
            AutomaticCanvasSize = Enum.AutomaticSize.Y
        }, {
            Create("UIListLayout", { Padding = UDim.new(0, 2) }),
            Create("UIPadding", {
                PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4),
                PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4)
            })
        })

        local closed = false
        local function close()
            if closed then return end
            closed = true
            win._popup = nil
            Tween(chevron, 0.15, { Rotation = 0 })
            Tween(popup, 0.15, { Size = UDim2.fromOffset(size.X, 0) })
            blocker:Destroy()
            task.delay(0.16, function() popup:Destroy() end)
        end

        local buttons = {}
        local function isSelected(v)
            if multi then return obj.Value[v] == true end
            return obj.Value == v
        end
        local function refreshColors()
            for v, b in pairs(buttons) do
                b.TextColor3 = isSelected(v) and T.Accent or T.Text
            end
        end

        for _, v in ipairs(obj.Values) do
            local b = Create("TextButton", {
                Parent = scroll,
                Size = UDim2.new(1, 0, 0, itemH),
                BackgroundColor3 = T.Panel,
                AutoButtonColor = false,
                Text = tostring(v),
                Font = Enum.Font.GothamMedium,
                TextSize = 15,
                TextColor3 = T.Text
            }, { Corner(7) })
            Feedback(b, T.Panel, T.ItemHover)
            buttons[v] = b

            b.MouseButton1Click:Connect(function()
                if multi then
                    local set = {}
                    for k, val in pairs(obj.Value) do set[k] = val end
                    set[v] = (not set[v]) or nil
                    obj:SetValue(set)
                    refreshColors()
                else
                    obj:SetValue(v)
                    close()
                end
            end)
        end
        refreshColors()

        if count == 0 then
            Create("TextLabel", {
                Parent = scroll,
                Size = UDim2.new(1, 0, 0, itemH),
                BackgroundTransparency = 1,
                Text = "(vazio)",
                Font = Enum.Font.Gotham,
                TextSize = 14,
                TextColor3 = T.SubText
            })
        end

        blocker.MouseButton1Click:Connect(close)
        win._popup = { close = close }

        Tween(chevron, 0.2, { Rotation = 180 })
        Tween(popup, 0.2, { Size = UDim2.fromOffset(size.X, height) }, Enum.EasingStyle.Back)
    end

    selector.MouseButton1Click:Connect(function()
        if win._popup then closePopup() else openPopup() end
    end)

    local default = opts.Default
    if default == nil and not multi then default = 1 end
    obj:SetValue(default, true)
    return obj
end

-- Input (opts: { Title, Default, Placeholder, Numeric, Finished, Width, Callback })
function Components:AddInput(flag, opts)
    opts = opts or {}
    local T = self.Window.Theme
    local width = opts.Width or 170
    local row = NewRow(self, 48)

    Create("TextLabel", {
        Parent = row,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -(width + 10), 1, 0),
        Font = Enum.Font.GothamMedium,
        TextSize = 17,
        TextColor3 = T.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Text = opts.Title or flag or "Input"
    })

    local boxStroke = Stroke(T.Border, 1, 0)
    local frame = Create("Frame", {
        Parent = row,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(width, 38),
        BackgroundColor3 = T.Item
    }, { Corner(10), boxStroke })

    local box = Create("TextBox", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(14, 0),
        Size = UDim2.new(1, -28, 1, 0),
        Font = Enum.Font.GothamMedium,
        TextSize = 16,
        TextColor3 = T.Text,
        PlaceholderText = opts.Placeholder or "",
        PlaceholderColor3 = T.SubText,
        Text = tostring(opts.Default or ""),
        ClearTextOnFocus = false,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd
    })

    local obj = Register(flag, { Type = "Input", Value = box.Text })

    function obj:SetValue(v, silent)
        box.Text = tostring(v or "")
        self.Value = box.Text
        if not silent then Fire(self, opts.Callback) end
    end

    box:GetPropertyChangedSignal("Text"):Connect(function()
        if opts.Numeric then
            local filtered = box.Text:gsub("[^%d%.%-]", "")
            if filtered ~= box.Text then box.Text = filtered end
        end
        if opts.Finished == false then
            obj.Value = box.Text
            Fire(obj, opts.Callback)
        end
    end)

    box.Focused:Connect(function()
        Tween(boxStroke, 0.2, { Color = T.Accent })
    end)
    box.FocusLost:Connect(function()
        Tween(boxStroke, 0.2, { Color = T.Border })
        obj.Value = box.Text
        if opts.Finished ~= false then Fire(obj, opts.Callback) end
    end)

    return obj
end

-- Keybind (opts: { Title, Default, Callback, ChangedCallback })
function Components:AddKeybind(flag, opts)
    opts = opts or {}
    local win = self.Window
    local T = win.Theme
    local row = NewRow(self, 48)

    Create("TextLabel", {
        Parent = row,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -120, 1, 0),
        Font = Enum.Font.GothamMedium,
        TextSize = 17,
        TextColor3 = T.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Text = opts.Title or flag or "Keybind"
    })

    local btn = Create("TextButton", {
        Parent = row,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(104, 36),
        BackgroundColor3 = T.Item,
        AutoButtonColor = false,
        Text = "",
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextColor3 = T.Accent
    }, { Corner(10), Stroke(T.Border, 1, 0) })
    Feedback(btn, T.Item, T.ItemHover)

    local default = opts.Default
    if typeof(default) == "EnumItem" then default = default.Name end

    local obj = Register(flag, { Type = "Keybind", Value = default or "None" })
    local listening = false

    local function render()
        btn.Text = listening and "..." or tostring(obj.Value)
    end

    function obj:SetValue(v, silent)
        if typeof(v) == "EnumItem" then v = v.Name end
        self.Value = v or "None"
        render()
        if not silent then
            if opts.ChangedCallback then task.spawn(opts.ChangedCallback, self.Value) end
            for _, fn in ipairs(self._changed) do task.spawn(fn, self.Value) end
        end
    end

    btn.MouseButton1Click:Connect(function()
        listening = true
        render()
    end)

    win:_track(UserInputService.InputBegan:Connect(function(input, processed)
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        if listening then
            listening = false
            if input.KeyCode ~= Enum.KeyCode.Escape then
                obj:SetValue(input.KeyCode.Name)
            else
                render()
            end
        elseif not processed and input.KeyCode.Name == obj.Value then
            if opts.Callback then task.spawn(opts.Callback) end
        end
    end))

    render()
    return obj
end

----------------------------------------------------------------
-- JANELA
----------------------------------------------------------------
function EspaceX:CreateWindow(config)
    config = config or {}

    local T = {}
    for k, v in pairs(DefaultTheme) do T[k] = v end
    for k, v in pairs(config.Theme or {}) do T[k] = v end

    local Window = { Theme = T, Tabs = {}, Stats = {}, Visible = false, _conns = {} }

    local function track(c)
        table.insert(Window._conns, c)
        return c
    end
    function Window:_track(c) return track(c) end

    -- ScreenGui
    local guiParent = GetGuiParent()
    for _, p in ipairs({ guiParent, LocalPlayer:FindFirstChild("PlayerGui") }) do
        local old = p and p:FindFirstChild("EspaceXLib")
        if old then old:Destroy() end
    end

    local gui = Create("ScreenGui", {
        Name = "EspaceXLib",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999
    })
    if syn and syn.protect_gui then pcall(syn.protect_gui, gui) end
    gui.Parent = guiParent
    Window.Gui = gui

    local spinners = {}

    -- Tamanho (limitado à tela)
    local vp = Viewport(gui)
    local req = config.Size or UDim2.fromOffset(580, 420)
    local W = math.min(req.X.Offset, vp.X - 20)
    local H = math.min(req.Y.Offset, vp.Y - 20)

    local window = Create("CanvasGroup", {
        Parent = gui,
        Name = "Window",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromOffset(vp.X / 2, vp.Y / 2),
        Size = UDim2.fromOffset(W, H),
        BackgroundColor3 = T.Background,
        Visible = false,
        GroupTransparency = 1
    }, { Corner(16) })
    local windowScale = Create("UIScale", { Parent = window, Scale = 0.85 })

    Create("UIGradient", {
        Parent = window,
        Rotation = 60,
        Color = ColorSequence.new(Color3.fromRGB(20, 22, 52), Color3.fromRGB(8, 13, 26))
    })

    -- Borda com gradiente (roxo -> azul -> verde)
    local borderStroke = Stroke(Color3.new(1, 1, 1), 2.6, 0)
    borderStroke.Parent = window
    local borderGradient = Create("UIGradient", {
        Parent = borderStroke,
        Rotation = 25,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, T.Purple),
            ColorSequenceKeypoint.new(0.55, T.Info),
            ColorSequenceKeypoint.new(1, T.Success)
        })
    })
    if config.AnimatedBorder then table.insert(spinners, borderGradient) end

    -- Barra do título (arrasta a janela)
    local titleBar = Create("Frame", {
        Parent = window,
        Size = UDim2.new(1, 0, 0, 56),
        BackgroundTransparency = 1
    })

    local titleText = Esc(config.Title or "ESPACE X HUB")
    titleText = titleText:gsub(" X ", " " .. Colored("X", T.Accent) .. " ")
    Create("TextLabel", {
        Parent = titleBar,
        Position = UDim2.fromOffset(18, 0),
        Size = UDim2.new(0.62, 0, 1, 0),
        BackgroundTransparency = 1,
        RichText = true,
        Text = "<i>" .. titleText .. "</i>",
        Font = Enum.Font.GothamBlack,
        TextSize = 27,
        TextColor3 = Color3.new(1, 1, 1),
        TextXAlignment = Enum.TextXAlignment.Left
    })

    Create("TextLabel", {
        Parent = titleBar,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -18, 0.5, 0),
        Size = UDim2.new(0.38, -10, 1, 0),
        BackgroundTransparency = 1,
        Text = string.upper(config.SubTitle or ""),
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = T.SubText,
        TextXAlignment = Enum.TextXAlignment.Right,
        TextTruncate = Enum.TextTruncate.AtEnd
    })

    ------------------------------------------------------------
    -- Barra de estatísticas
    ------------------------------------------------------------
    local statsBar = Create("Frame", {
        Parent = window,
        Position = UDim2.fromOffset(12, 58),
        Size = UDim2.new(1, -24, 0, 38),
        BackgroundColor3 = T.Panel,
        Visible = config.ShowStats ~= false
    }, { Corner(10), Stroke(T.Border, 1, 0.2) })

    local statusLabel = Create("TextLabel", {
        Parent = statsBar,
        Position = UDim2.fromOffset(14, 0),
        Size = UDim2.new(0.27, -14, 1, 0),
        BackgroundTransparency = 1,
        Text = "GAME STATUS",
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = T.Text,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local function layoutStats()
        local n = math.max(#Window.Stats, 1)
        local first = 0.27
        local share = (1 - first) / n
        for i, s in ipairs(Window.Stats) do
            s.label.Position = UDim2.new(first + share * (i - 1), 0, 0, 0)
            s.label.Size = UDim2.new(share, 0, 1, 0)
        end
    end

    local function refreshStat(s)
        local ok, value = pcall(s.getter)
        if not ok or value == nil then value = "N/A" end
        local color = T.Text
        if typeof(s.color) == "Color3" then
            color = s.color
        elseif type(s.color) == "function" then
            local ok2, c = pcall(s.color, value)
            if ok2 and typeof(c) == "Color3" then color = c end
        end
        s.label.Text = Esc(s.name) .. ": " .. Colored(Esc(tostring(value)), color)
    end

    -- Adiciona uma estatística personalizada
    -- getter: função que retorna o valor | color: Color3 ou função(valor) -> Color3
    function Window:AddStat(name, getter, color)
        local label = Create("TextLabel", {
            Parent = statsBar,
            BackgroundTransparency = 1,
            RichText = true,
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextColor3 = T.Text,
            Text = "",
            TextTruncate = Enum.TextTruncate.AtEnd
        })
        local s = { name = name, getter = getter, color = color, label = label }
        table.insert(self.Stats, s)
        layoutStats()
        refreshStat(s)
        return s
    end

    -- FPS / Ping / Região padrão
    local fpsValue, frames, lastT = 60, 0, os.clock()
    track(RunService.RenderStepped:Connect(function()
        frames = frames + 1
        local now = os.clock()
        if now - lastT >= 0.5 then
            fpsValue = math.floor(frames / (now - lastT) + 0.5)
            frames, lastT = 0, now
        end
    end))

    local regionValue = "..."
    task.spawn(function()
        local ok, code = pcall(function()
            return LocalizationService:GetCountryRegionForPlayerAsync(LocalPlayer)
        end)
        if ok and code then
            regionValue = REGION_NAMES[code] or code
        else
            regionValue = "N/A"
        end
    end)

    if config.ShowStats ~= false then
        Window:AddStat("FPS", function() return fpsValue end, T.Warning)
        Window:AddStat("PING", function()
            local item = StatsService.Network.ServerStatsItem["Data Ping"]
            return math.floor(item:GetValue() + 0.5) .. " ms"
        end, T.Info)
        Window:AddStat("REGION", function() return regionValue end, T.Success)
    end

    task.spawn(function()
        while gui.Parent do
            for _, s in ipairs(Window.Stats) do refreshStat(s) end
            task.wait(0.5)
        end
    end)

    ------------------------------------------------------------
    -- Corpo: barra lateral + cartão de conteúdo
    ------------------------------------------------------------
    local bodyTop = 106

    local sidebar = Create("Frame", {
        Parent = window,
        Position = UDim2.fromOffset(12, bodyTop),
        Size = UDim2.new(0, 66, 1, -(bodyTop + 12)),
        BackgroundColor3 = T.Panel
    }, {
        Corner(12),
        Stroke(T.Border, 1, 0.2),
        Create("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
        Create("UIPadding", {
            PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)
        })
    })

    local card = Create("Frame", {
        Parent = window,
        Position = UDim2.fromOffset(88, bodyTop),
        Size = UDim2.new(1, -100, 1, -(bodyTop + 12)),
        BackgroundColor3 = T.Card
    }, { Corner(12), Stroke(T.Border, 1, 0.2) })

    local cardTitle = Create("TextLabel", {
        Parent = card,
        Position = UDim2.fromOffset(18, 10),
        Size = UDim2.new(1, -70, 0, 26),
        BackgroundTransparency = 1,
        Text = "",
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextColor3 = T.Accent,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local headerIcon = Create("Frame", {
        Parent = card,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -16, 0, 10),
        Size = UDim2.fromOffset(28, 28),
        BackgroundTransparency = 1
    })

    local pageHolder = Create("Frame", {
        Parent = card,
        Position = UDim2.fromOffset(0, 44),
        Size = UDim2.new(1, 0, 1, -50),
        BackgroundTransparency = 1
    })

    ------------------------------------------------------------
    -- Abas
    ------------------------------------------------------------
    function Window:SelectTab(tab)
        if type(tab) == "number" then tab = self.Tabs[tab] end
        if not tab or self.CurrentTab == tab then return end
        self.CurrentTab = tab
        if self._popup then self._popup.close() end

        for _, t in ipairs(self.Tabs) do
            local active = (t == tab)
            Tween(t._button, 0.2, { BackgroundTransparency = active and 0 or 1 })
            Tween(t._bar, 0.2, { BackgroundTransparency = active and 0 or 1 })
            Tween(t._icon, 0.2, { [t._iconProp] = active and 0 or 0.5 })
            if active then
                t._holder.Visible = true
                t._holder.Position = UDim2.new(0, 0, 0, 14)
                t._holder.GroupTransparency = 1
                Tween(t._holder, 0.3, { Position = UDim2.new(0, 0, 0, 0), GroupTransparency = 0 })
            else
                t._holder.Visible = false
            end
        end

        cardTitle.Text = string.upper(tab.Title)
        for _, c in ipairs(headerIcon:GetChildren()) do c:Destroy() end
        MakeIcon(headerIcon, tab.IconName, 22, T.Accent)
    end

    -- opts: { Title, Icon }  (Icon: emoji, texto ou rbxassetid://)
    function Window:AddTab(opts)
        opts = opts or {}
        local index = #self.Tabs + 1

        local btn = Create("TextButton", {
            Parent = sidebar,
            Size = UDim2.new(1, 0, 0, 56),
            BackgroundColor3 = T.Item,
            BackgroundTransparency = 1,
            AutoButtonColor = false,
            Text = "",
            LayoutOrder = index
        }, { Corner(10) })

        local bar = Create("Frame", {
            Parent = btn,
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, -8, 0.5, 0),
            Size = UDim2.fromOffset(3, 30),
            BackgroundColor3 = T.Accent,
            BackgroundTransparency = 1,
            BorderSizePixel = 0
        }, { Corner(2) })

        local icon, iconProp = MakeIcon(btn, opts.Icon or string.sub(opts.Title or "?", 1, 1), 24, T.Accent)
        icon[iconProp] = 0.5

        local holder = Create("CanvasGroup", {
            Parent = pageHolder,
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Visible = false
        })

        local page = Create("ScrollingFrame", {
            Parent = holder,
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = T.Accent,
            ScrollBarImageTransparency = 0.3,
            CanvasSize = UDim2.new(),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollingDirection = Enum.ScrollingDirection.Y
        }, {
            Create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }),
            Create("UIPadding", {
                PaddingLeft = UDim.new(0, 18), PaddingRight = UDim.new(0, 16),
                PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 12)
            })
        })

        local tab = {
            Window = self,
            Title = opts.Title or "Tab",
            IconName = opts.Icon or string.sub(opts.Title or "?", 1, 1),
            Page = page,
            _order = 0,
            _button = btn, _bar = bar, _icon = icon, _iconProp = iconProp, _holder = holder
        }
        for name, fn in pairs(Components) do tab[name] = fn end

        table.insert(self.Tabs, tab)

        btn.MouseEnter:Connect(function()
            if self.CurrentTab ~= tab then Tween(icon, 0.15, { [iconProp] = 0.15 }) end
        end)
        btn.MouseLeave:Connect(function()
            if self.CurrentTab ~= tab then Tween(icon, 0.15, { [iconProp] = 0.5 }) end
        end)
        btn.MouseButton1Click:Connect(function() self:SelectTab(tab) end)

        if index == 1 then self:SelectTab(tab) end
        return tab
    end

    ------------------------------------------------------------
    -- Notificações
    ------------------------------------------------------------
    local notifyHolder = Create("Frame", {
        Parent = gui,
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -16, 1, -16),
        Size = UDim2.new(0, 270, 1, -32),
        BackgroundTransparency = 1,
        ZIndex = 150
    }, {
        Create("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Bottom
        })
    })

    -- opts: { Title, Content, Duration, Type = "Success"|"Warning"|"Danger" }
    function Window:Notify(opts)
        opts = opts or {}
        local colors = { Success = T.Success, Warning = T.Warning, Danger = T.Danger }
        local color = colors[opts.Type or ""] or T.Accent

        local toast = Create("CanvasGroup", {
            Parent = notifyHolder,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = T.Panel,
            GroupTransparency = 1
        }, {
            Corner(12),
            Stroke(color, 1.4, 0.35),
            Create("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }),
            Create("UIPadding", {
                PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10),
                PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14)
            })
        })
        local sc = Create("UIScale", { Parent = toast, Scale = 0.9 })

        Create("TextLabel", {
            Parent = toast,
            Size = UDim2.new(1, 0, 0, 18),
            BackgroundTransparency = 1,
            Text = opts.Title or "Notificação",
            Font = Enum.Font.GothamBold,
            TextSize = 15,
            TextColor3 = color,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = 1
        })
        if opts.Content then
            Create("TextLabel", {
                Parent = toast,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Text = opts.Content,
                Font = Enum.Font.Gotham,
                TextSize = 13,
                TextColor3 = T.Text,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                LayoutOrder = 2
            })
        end

        Tween(toast, 0.3, { GroupTransparency = 0 })
        Tween(sc, 0.35, { Scale = 1 }, Enum.EasingStyle.Back)
        task.delay(opts.Duration or 4, function()
            Tween(toast, 0.3, { GroupTransparency = 1 })
            Tween(sc, 0.3, { Scale = 0.9 })
            task.delay(0.32, function() toast:Destroy() end)
        end)
    end

    ------------------------------------------------------------
    -- Abrir / fechar
    ------------------------------------------------------------
    function Window:Toggle(state)
        if state == nil then state = not self.Visible end
        self.Visible = state
        if state then
            window.Visible = true
            Tween(windowScale, 0.4, { Scale = 1 }, Enum.EasingStyle.Back)
            Tween(window, 0.25, { GroupTransparency = 0 })
        else
            if self._popup then self._popup.close() end
            Tween(windowScale, 0.22, { Scale = 0.85 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            Tween(window, 0.22, { GroupTransparency = 1 })
            task.delay(0.23, function()
                if not self.Visible then window.Visible = false end
            end)
        end
    end

    function Window:Destroy()
        for _, c in ipairs(self._conns) do c:Disconnect() end
        gui:Destroy()
    end

    MakeDraggable(Window, titleBar, window, nil, function()
        if Window._popup then Window._popup.close() end
    end)

    -- Botão flutuante "X" (abre/fecha, arrastável)
    if config.Launcher ~= false then
        local launcher = Create("Frame", {
            Parent = gui,
            Name = "Launcher",
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromOffset(vp.X - 46, 58),
            Size = UDim2.fromOffset(52, 52),
            BackgroundTransparency = 1,
            ZIndex = 60
        })
        local launcherScale = Create("UIScale", { Parent = launcher, Scale = 0 })

        local ring = Create("Frame", {
            Parent = launcher,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(52, 52),
            BackgroundTransparency = 1
        }, { Corner(30) })
        local ringStroke = Stroke(T.Accent, 2, 0.3)
        ringStroke.Parent = ring
        TweenService:Create(ring,
            TweenInfo.new(1.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, -1),
            { Size = UDim2.fromOffset(84, 84) }):Play()
        TweenService:Create(ringStroke,
            TweenInfo.new(1.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, -1),
            { Transparency = 1 }):Play()

        local launcherBtn = Create("TextButton", {
            Parent = launcher,
            Size = UDim2.fromScale(1, 1),
            BackgroundColor3 = T.Panel,
            AutoButtonColor = false,
            Text = config.LauncherText or "X",
            Font = Enum.Font.GothamBlack,
            TextSize = 24,
            TextColor3 = Color3.new(1, 1, 1),
            ZIndex = 61
        }, { Corner(26) })

        local lStroke = Stroke(Color3.new(1, 1, 1), 2.6, 0)
        lStroke.Parent = launcherBtn
        Create("UIGradient", {
            Parent = lStroke,
            Rotation = 30,
            Color = ColorSequence.new(T.Purple, T.Accent)
        })

        launcherBtn.MouseEnter:Connect(function()
            Tween(launcherScale, 0.2, { Scale = 1.1 }, Enum.EasingStyle.Back)
        end)
        launcherBtn.MouseLeave:Connect(function()
            Tween(launcherScale, 0.2, { Scale = 1 })
        end)

        MakeDraggable(Window, launcherBtn, launcher, function()
            Tween(launcherScale, 0.08, { Scale = 0.88 }).Completed:Connect(function()
                Tween(launcherScale, 0.2, { Scale = 1 }, Enum.EasingStyle.Back)
            end)
            Window:Toggle()
        end)

        Tween(launcherScale, 0.5, { Scale = 1 }, Enum.EasingStyle.Back)
    end

    -- Tecla para abrir/fechar
    local toggleKey = config.ToggleKey or Enum.KeyCode.RightControl
    track(UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == toggleKey then
            Window:Toggle()
        end
    end))

    -- Borda animada (opcional)
    track(RunService.RenderStepped:Connect(function()
        local r = (os.clock() * 60) % 360
        for _, g in ipairs(spinners) do
            if g.Parent then g.Rotation = r end
        end
    end))

    gui.Destroying:Connect(function()
        for _, c in ipairs(Window._conns) do c:Disconnect() end
    end)

    if config.AutoOpen ~= false then
        task.delay(0.3, function() Window:Toggle(true) end)
    end

    return Window
end

return EspaceX
