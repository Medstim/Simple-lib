--[[
    PanelLib.lua
    A lightweight Roblox Lua library for building clean, dark floating panels.
    
    Usage:
        local PanelLib = loadstring(game:HttpGet("YOUR_RAW_URL"))()
        
        local Panel = PanelLib:CreatePanel({
            Title    = "My Panel",
            Position = "topright",   -- topleft | topright | bottomleft | bottomright
            Width    = 220,
        })
        
        Panel:Label("── Section ──")
        local myStat = Panel:Stat("Throws", "-")
        local myToggle = Panel:Toggle("Speed", false, function(state) print(state) end)
        Panel:Button("Click Me", function() print("clicked") end)
        
        myStat:Set(1234)
        myToggle:Set(true)
        Panel:Show()
        Panel:Hide()
        Panel:Destroy()
]]

----------------------------------------------------------------------
-- Services
----------------------------------------------------------------------
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

----------------------------------------------------------------------
-- Theme
----------------------------------------------------------------------
local Theme = {
    Background = Color3.fromRGB(14, 14, 14),
    Surface    = Color3.fromRGB(22, 22, 22),
    Row        = Color3.fromRGB(28, 28, 28),
    Stroke     = Color3.fromRGB(50, 50, 50),
    Text       = Color3.fromRGB(230, 230, 230),
    SubText    = Color3.fromRGB(120, 120, 120),
    Accent     = Color3.fromRGB(100, 160, 255),
    Off        = Color3.fromRGB(55, 55, 55),
    Warning    = Color3.fromRGB(255, 190, 70),
}

----------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------
local FONT_BOLD   = Font.new("rbxasset://fonts/families/Jura.json", Enum.FontWeight.Bold)
local FONT_MED    = Font.new("rbxasset://fonts/families/Jura.json", Enum.FontWeight.Medium)
local PADDING     = 10
local ROW_HEIGHT  = 28
local ROW_GAP     = 3
local TI          = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TI_S        = TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

----------------------------------------------------------------------
-- Helpers
----------------------------------------------------------------------
local function getGui()
    if gethui then return gethui() end
    local ok, cg = pcall(function()
        return (cloneref and cloneref(game:GetService("CoreGui"))) or game:GetService("CoreGui")
    end)
    return ok and cg or game:GetService("CoreGui")
end

local function tween(obj, info, props)
    TweenService:Create(obj, info or TI, props):Play()
end

local function corner(inst, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 6)
    c.Parent = inst
end

local function uistroke(inst, color, alpha, thick)
    local s = Instance.new("UIStroke")
    s.Color        = color or Theme.Stroke
    s.Transparency = alpha or 0
    s.Thickness    = thick or 1
    s.Parent       = inst
end

local function label(parent, text, size, color, bold, xalign, order)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Text           = text or ""
    l.FontFace       = bold and FONT_BOLD or FONT_MED
    l.TextColor3     = color or Theme.Text
    l.TextSize       = size or 12
    l.TextXAlignment = xalign or Enum.TextXAlignment.Left
    l.TextTruncate   = Enum.TextTruncate.AtEnd
    l.Size           = UDim2.new(1, 0, 1, 0)
    l.BackgroundTransparency = 1
    if order then l.LayoutOrder = order end
    l.Parent = parent
    return l
end

local function anchorPosition(position, width, height)
    local pad = 16
    local positions = {
        topright     = UDim2.new(1, -(width + pad), 0,  pad),
        topleft      = UDim2.new(0,  pad,            0,  pad),
        bottomright  = UDim2.new(1, -(width + pad), 1, -(height + pad)),
        bottomleft   = UDim2.new(0,  pad,            1, -(height + pad)),
    }
    return positions[position] or positions["topright"]
end

----------------------------------------------------------------------
-- PanelLib
----------------------------------------------------------------------
local PanelLib = {}
PanelLib.__index = PanelLib

function PanelLib:CreatePanel(cfg)
    cfg = cfg or {}

    local width    = cfg.Width    or 220
    local position = cfg.Position or "topright"
    local accent   = cfg.Accent   or Theme.Accent

    -- ScreenGui
    local gui = Instance.new("ScreenGui")
    gui.Name             = cfg.Title and (cfg.Title .. "Panel") or "PanelLibGui"
    gui.ResetOnSpawn     = false
    gui.IgnoreGuiInset   = true
    gui.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder     = 997
    gui.Enabled          = true
    gui.Parent           = getGui()

    -- Root frame
    local root = Instance.new("Frame")
    root.Name                  = "Root"
    root.BackgroundColor3      = Theme.Background
    root.BackgroundTransparency = 0.06
    root.BorderSizePixel       = 0
    root.Size                  = UDim2.new(0, width, 0, 0)
    root.AutomaticSize         = Enum.AutomaticSize.Y
    root.Position              = anchorPosition(position, width, 300)
    root.Parent                = gui
    corner(root, 8)
    uistroke(root, Theme.Stroke, 0.6, 1)

    -- Title bar
    local titleBar
    if cfg.Title then
        titleBar = Instance.new("Frame")
        titleBar.Name                  = "TitleBar"
        titleBar.BackgroundColor3      = Theme.Surface
        titleBar.BackgroundTransparency = 0.05
        titleBar.BorderSizePixel       = 0
        titleBar.Size                  = UDim2.new(1, 0, 0, 34)
        titleBar.ZIndex                = 2
        titleBar.Parent                = root
        corner(titleBar, 8)

        -- bottom square corners on title bar so it sits flush with body
        local squarer = Instance.new("Frame")
        squarer.BackgroundColor3      = Theme.Surface
        squarer.BackgroundTransparency = 0.05
        squarer.BorderSizePixel       = 0
        squarer.Position              = UDim2.new(0, 0, 0.5, 0)
        squarer.Size                  = UDim2.new(1, 0, 0.5, 0)
        squarer.ZIndex                = 2
        squarer.Parent                = titleBar

        local titleLbl = Instance.new("TextLabel")
        titleLbl.BackgroundTransparency = 1
        titleLbl.Text           = cfg.Title
        titleLbl.FontFace       = FONT_BOLD
        titleLbl.TextColor3     = Theme.Text
        titleLbl.TextSize       = 13
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left
        titleLbl.Position       = UDim2.new(0, PADDING, 0, 0)
        titleLbl.Size           = UDim2.new(1, -PADDING * 2, 1, 0)
        titleLbl.ZIndex         = 3
        titleLbl.Parent         = titleBar

        uistroke(titleBar, Theme.Stroke, 0.6, 1)
    end

    -- Body
    local body = Instance.new("Frame")
    body.Name                  = "Body"
    body.BackgroundTransparency = 1
    body.BorderSizePixel       = 0
    body.Position              = UDim2.new(0, 0, 0, cfg.Title and 34 or 0)
    body.Size                  = UDim2.new(1, 0, 0, 0)
    body.AutomaticSize         = Enum.AutomaticSize.Y
    body.Parent                = root

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding        = UDim.new(0, ROW_GAP)
    listLayout.SortOrder      = Enum.SortOrder.LayoutOrder
    listLayout.Parent         = body

    local padding = Instance.new("UIPadding")
    padding.PaddingTop    = UDim.new(0, PADDING)
    padding.PaddingBottom = UDim.new(0, PADDING)
    padding.PaddingLeft   = UDim.new(0, PADDING)
    padding.PaddingRight  = UDim.new(0, PADDING)
    padding.Parent        = body

    -- Panel API
    local Panel  = {}
    local _order = 0

    local function nextOrder()
        _order += 1
        return _order
    end

    local function newRow(height, transparent)
        local row = Instance.new("Frame")
        row.BackgroundColor3      = transparent and Color3.new() or Theme.Row
        row.BackgroundTransparency = transparent and 1 or 0
        row.BorderSizePixel       = 0
        row.Size                  = UDim2.new(1, 0, 0, height or ROW_HEIGHT)
        row.LayoutOrder           = nextOrder()
        row.Parent                = body
        if not transparent then corner(row, 5) end
        return row
    end

    ----------------------------------------------------------------
    -- Label
    ----------------------------------------------------------------
    function Panel:Label(text)
        local row = newRow(18, true)
        local lbl = Instance.new("TextLabel")
        lbl.BackgroundTransparency = 1
        lbl.Text           = text or ""
        lbl.FontFace       = FONT_MED
        lbl.TextColor3     = Theme.SubText
        lbl.TextSize       = 10
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Size           = UDim2.new(1, 0, 1, 0)
        lbl.Parent         = row
        return {
            Set      = function(_, t) lbl.Text = t end,
            Instance = row,
        }
    end

    ----------------------------------------------------------------
    -- Warning
    ----------------------------------------------------------------
    function Panel:Warning(text)
        local row = newRow(ROW_HEIGHT, true)
        row.AutomaticSize = Enum.AutomaticSize.Y
        row.BackgroundColor3      = Color3.fromRGB(36, 28, 14)
        row.BackgroundTransparency = 0
        corner(row, 5)
        uistroke(row, Theme.Warning, 0.5, 1)

        local pad = Instance.new("UIPadding", row)
        pad.PaddingLeft   = UDim.new(0, 8)
        pad.PaddingRight  = UDim.new(0, 8)
        pad.PaddingTop    = UDim.new(0, 6)
        pad.PaddingBottom = UDim.new(0, 6)

        local lbl = Instance.new("TextLabel", row)
        lbl.BackgroundTransparency = 1
        lbl.Text           = "⚠  " .. (text or "")
        lbl.FontFace       = FONT_MED
        lbl.TextColor3     = Theme.Warning
        lbl.TextSize       = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextWrapped    = true
        lbl.AutomaticSize  = Enum.AutomaticSize.Y
        lbl.Size           = UDim2.new(1, 0, 0, 0)

        return {
            Set      = function(_, t) lbl.Text = "⚠  " .. t end,
            Instance = row,
        }
    end

    ----------------------------------------------------------------
    -- Stat
    ----------------------------------------------------------------
    function Panel:Stat(name, value, accentColor)
        local row = newRow(ROW_HEIGHT)

        local nameLbl = Instance.new("TextLabel", row)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Text           = name or "Stat"
        nameLbl.FontFace       = FONT_MED
        nameLbl.TextColor3     = Theme.SubText
        nameLbl.TextSize       = 12
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left
        nameLbl.Position       = UDim2.new(0, 8, 0, 0)
        nameLbl.Size           = UDim2.new(0.55, -8, 1, 0)

        local valLbl = Instance.new("TextLabel", row)
        valLbl.BackgroundTransparency = 1
        valLbl.Text           = tostring(value or "-")
        valLbl.FontFace       = FONT_BOLD
        valLbl.TextColor3     = accentColor or accent
        valLbl.TextSize       = 12
        valLbl.TextXAlignment = Enum.TextXAlignment.Right
        valLbl.Position       = UDim2.new(0.45, 0, 0, 0)
        valLbl.Size           = UDim2.new(0.55, -8, 1, 0)

        return {
            Set      = function(_, v) valLbl.Text = tostring(v) end,
            Get      = function() return valLbl.Text end,
            Instance = row,
        }
    end

    ----------------------------------------------------------------
    -- Button
    ----------------------------------------------------------------
    function Panel:Button(name, callback)
        local btn = Instance.new("TextButton")
        btn.Name                  = "Button"
        btn.BackgroundColor3      = Theme.Row
        btn.AutoButtonColor       = false
        btn.BorderSizePixel       = 0
        btn.Text                  = name or "Button"
        btn.FontFace              = FONT_MED
        btn.TextColor3            = Theme.Text
        btn.TextSize              = 12
        btn.Size                  = UDim2.new(1, 0, 0, ROW_HEIGHT)
        btn.LayoutOrder           = nextOrder()
        btn.Parent                = body
        corner(btn, 5)

        btn.MouseEnter:Connect(function()
            tween(btn, TI, { BackgroundColor3 = Color3.fromRGB(38, 38, 38) })
        end)
        btn.MouseLeave:Connect(function()
            tween(btn, TI, { BackgroundColor3 = Theme.Row })
        end)
        btn.Activated:Connect(function()
            tween(btn, TI, { BackgroundColor3 = accent })
            task.wait(0.12)
            tween(btn, TI, { BackgroundColor3 = Theme.Row })
            if callback then task.spawn(callback) end
        end)

        return { Instance = btn }
    end

    ----------------------------------------------------------------
    -- Toggle
    ----------------------------------------------------------------
    function Panel:Toggle(name, default, callback)
        local state = default or false
        local row   = newRow(ROW_HEIGHT)

        local hitbox = Instance.new("TextButton", row)
        hitbox.BackgroundTransparency = 1
        hitbox.Text = ""
        hitbox.Size = UDim2.new(1, 0, 1, 0)

        local nameLbl = Instance.new("TextLabel", hitbox)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Text           = name or "Toggle"
        nameLbl.FontFace       = FONT_MED
        nameLbl.TextColor3     = Theme.Text
        nameLbl.TextSize       = 12
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left
        nameLbl.Position       = UDim2.new(0, 8, 0, 0)
        nameLbl.Size           = UDim2.new(1, -52, 1, 0)

        local track = Instance.new("Frame", hitbox)
        track.BackgroundColor3 = state and accent or Theme.Off
        track.AnchorPoint      = Vector2.new(1, 0.5)
        track.Position         = UDim2.new(1, -8, 0.5, 0)
        track.Size             = UDim2.fromOffset(34, 17)
        track.BorderSizePixel  = 0
        corner(track, 9)

        local knob = Instance.new("Frame", track)
        knob.BackgroundColor3 = Theme.Text
        knob.AnchorPoint      = Vector2.new(0, 0.5)
        knob.Position         = state and UDim2.new(1, -15, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
        knob.Size             = UDim2.fromOffset(13, 13)
        knob.BorderSizePixel  = 0
        corner(knob, 7)

        local api = {}

        function api:Set(v)
            state = v
            tween(track, TI, { BackgroundColor3 = state and accent or Theme.Off })
            tween(knob,  TI, { Position = state and UDim2.new(1, -15, 0.5, 0) or UDim2.new(0, 2, 0.5, 0) })
            if callback then task.spawn(callback, state) end
        end

        function api:Get() return state end

        hitbox.Activated:Connect(function() api:Set(not state) end)

        api.Instance = row
        return api
    end

    ----------------------------------------------------------------
    -- Slider
    ----------------------------------------------------------------
    function Panel:Slider(name, min, max, default, callback)
        min     = min     or 0
        max     = max     or 100
        default = math.clamp(default or min, min, max)

        local row = newRow(44)

        local nameLbl = Instance.new("TextLabel", row)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Text           = name or "Slider"
        nameLbl.FontFace       = FONT_MED
        nameLbl.TextColor3     = Theme.Text
        nameLbl.TextSize       = 12
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left
        nameLbl.Position       = UDim2.new(0, 8, 0, 4)
        nameLbl.Size           = UDim2.new(0.65, -8, 0, 16)

        local valLbl = Instance.new("TextLabel", row)
        valLbl.BackgroundTransparency = 1
        valLbl.Text           = tostring(default)
        valLbl.FontFace       = FONT_BOLD
        valLbl.TextColor3     = accent
        valLbl.TextSize       = 12
        valLbl.TextXAlignment = Enum.TextXAlignment.Right
        valLbl.AnchorPoint    = Vector2.new(1, 0)
        valLbl.Position       = UDim2.new(1, -8, 0, 4)
        valLbl.Size           = UDim2.new(0.35, -8, 0, 16)

        local track = Instance.new("Frame", row)
        track.BackgroundColor3 = Theme.Off
        track.Position         = UDim2.new(0, 8, 0, 30)
        track.Size             = UDim2.new(1, -16, 0, 5)
        track.BorderSizePixel  = 0
        corner(track, 3)

        local fill = Instance.new("Frame", track)
        fill.BackgroundColor3 = accent
        fill.Size             = UDim2.new((default - min) / (max - min), 0, 1, 0)
        fill.BorderSizePixel  = 0
        corner(fill, 3)

        local knob = Instance.new("Frame", track)
        knob.BackgroundColor3 = Theme.Text
        knob.AnchorPoint      = Vector2.new(0.5, 0.5)
        knob.Position         = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
        knob.Size             = UDim2.fromOffset(12, 12)
        knob.BorderSizePixel  = 0
        knob.ZIndex           = 2
        corner(knob, 6)

        local value   = default
        local dragging = false

        local function apply(alpha)
            local raw = min + (max - min) * alpha
            value = math.clamp(math.floor(raw + 0.5), min, max)
            local a = (max ~= min) and (value - min) / (max - min) or 0
            fill.Size     = UDim2.new(a, 0, 1, 0)
            knob.Position = UDim2.new(a, 0, 0.5, 0)
            valLbl.Text   = tostring(value)
            if callback then task.spawn(callback, value) end
        end

        local function getAlpha(inputX)
            local ap = track.AbsolutePosition.X
            local sz = track.AbsoluteSize.X
            return math.clamp((inputX - ap) / sz, 0, 1)
        end

        track.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or
               inp.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                apply(getAlpha(inp.Position.X))
            end
        end)
        track.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or
               inp.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        UserInputService.InputChanged:Connect(function(inp)
            if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or
               inp.UserInputType == Enum.UserInputType.Touch) then
                apply(getAlpha(inp.Position.X))
            end
        end)

        local api = {}
        function api:Set(v) apply((math.clamp(v, min, max) - min) / (max - min)) end
        function api:Get() return value end
        api.Instance = row
        return api
    end

    ----------------------------------------------------------------
    -- Divider
    ----------------------------------------------------------------
    function Panel:Divider()
        local row = newRow(1, true)
        local line = Instance.new("Frame", row)
        line.BackgroundColor3      = Theme.Stroke
        line.BackgroundTransparency = 0.5
        line.BorderSizePixel       = 0
        line.Size                  = UDim2.new(1, 0, 1, 0)
        return { Instance = row }
    end

    ----------------------------------------------------------------
    -- Panel controls
    ----------------------------------------------------------------
    function Panel:Show()
        gui.Enabled = true
        tween(root, TI_S, { GroupTransparency = 0 })
    end

    function Panel:Hide()
        tween(root, TI_S, { GroupTransparency = 1 })
        task.wait(0.22)
        gui.Enabled = false
    end

    function Panel:Toggle()
        if gui.Enabled then
            self:Hide()
        else
            self:Show()
        end
    end

    function Panel:Destroy()
        gui:Destroy()
    end

    function Panel:SetAccent(color)
        accent = color
    end

    return Panel
end

return PanelLib
