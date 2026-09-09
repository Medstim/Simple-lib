local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

----------------------------------------------------------------------
-- Theme
----------------------------------------------------------------------
local Theme = {
    Background = Color3.fromRGB(12, 12, 12),
    Surface    = Color3.fromRGB(18, 18, 18),
    Row        = Color3.fromRGB(24, 24, 24),
    RowHover   = Color3.fromRGB(32, 32, 32),
    Stroke     = Color3.fromRGB(45, 45, 45),
    Text       = Color3.fromRGB(225, 225, 225),
    SubText    = Color3.fromRGB(110, 110, 110),
    Accent     = Color3.fromRGB(100, 160, 255),
    Off        = Color3.fromRGB(50, 50, 50),
    Warning    = Color3.fromRGB(255, 190, 70),
}

----------------------------------------------------------------------
-- Presets
----------------------------------------------------------------------
local Presets = {
    ["Default"]  = { Accent = Color3.fromRGB(100, 160, 255) },
    ["Pink"]     = { Accent = Color3.fromRGB(255, 100, 220) },
    ["Green"]    = { Accent = Color3.fromRGB(80,  200, 120) },
    ["Red"]      = { Accent = Color3.fromRGB(220, 70,  70)  },
    ["Purple"]   = { Accent = Color3.fromRGB(160, 100, 255) },
    ["Orange"]   = { Accent = Color3.fromRGB(255, 150, 60)  },
    ["Teal"]     = { Accent = Color3.fromRGB(60,  210, 190) },
    ["White"]    = { Accent = Color3.fromRGB(220, 220, 220) },
}

----------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------
local FONT_BOLD  = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
local FONT_MED   = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium)
local FONT_REG   = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular)
local PADDING    = 10
local ROW_HEIGHT = 30
local ROW_GAP    = 4
local TI         = TweenInfo.new(0.15, Enum.EasingStyle.Quad,  Enum.EasingDirection.Out)
local TI_S       = TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

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
    return c
end

local function stroke(inst, color, alpha, thick)
    local s = Instance.new("UIStroke")
    s.Color        = color or Theme.Stroke
    s.Transparency = alpha or 0
    s.Thickness    = thick or 1
    s.Parent       = inst
    return s
end

local function anchorPosition(position, width)
    local pad = 16
    local pos = {
        topright    = UDim2.new(1, -(width + pad), 0,  pad),
        topleft     = UDim2.new(0,  pad,            0,  pad),
        bottomright = UDim2.new(1, -(width + pad), 1, -(300 + pad)),
        bottomleft  = UDim2.new(0,  pad,            1, -(300 + pad)),
    }
    return pos[position] or pos["topright"]
end

local function makeDraggable(frame, handle)
    local dragging, startPos, startFrame
    handle.InputBegan:Connect(function(inp)
        local t = inp.UserInputType
        if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
            dragging   = true
            startPos   = inp.Position
            startFrame = frame.Position
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        local t = inp.UserInputType
        if dragging and (t == Enum.UserInputType.MouseMovement or t == Enum.UserInputType.Touch) then
            local delta = inp.Position - startPos
            frame.Position = UDim2.new(
                startFrame.X.Scale, startFrame.X.Offset + delta.X,
                startFrame.Y.Scale, startFrame.Y.Offset + delta.Y
            )
        end
    end)
end

----------------------------------------------------------------------
-- PanelLib
----------------------------------------------------------------------
local PanelLib = {}
PanelLib.__index = PanelLib

function PanelLib:CreatePanel(cfg)
    cfg = cfg or {}

    local width    = cfg.Width    or 230
    local position = cfg.Position or "topright"
    local accent   = cfg.Accent   or Theme.Accent
    local title    = cfg.Title

    local connections = {}
    local function track(conn) table.insert(connections, conn) end

    -- ScreenGui
    local gui = Instance.new("ScreenGui")
    gui.Name             = title and (title .. "Panel") or "PanelLib"
    gui.ResetOnSpawn     = false
    gui.IgnoreGuiInset   = true
    gui.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder     = 997
    gui.Enabled          = true
    gui.Parent           = getGui()

    -- Root
    local root = Instance.new("Frame")
    root.Name                   = "Root"
    root.BackgroundColor3       = Theme.Background
    root.BackgroundTransparency = 0.04
    root.BorderSizePixel        = 0
    root.Size                   = UDim2.new(0, width, 0, 0)
    root.AutomaticSize          = Enum.AutomaticSize.Y
    root.Position               = anchorPosition(position, width)
    root.Parent                 = gui
    corner(root, 10)
    stroke(root, Theme.Stroke, 0.5, 1)

    -- Settings overlay
    local settingsOverlay = Instance.new("Frame")
    settingsOverlay.Name                   = "SettingsOverlay"
    settingsOverlay.BackgroundColor3       = Theme.Background
    settingsOverlay.BackgroundTransparency = 0.04
    settingsOverlay.BorderSizePixel        = 0
    settingsOverlay.Size                   = UDim2.new(1, 0, 0, 0)
    settingsOverlay.AutomaticSize          = Enum.AutomaticSize.Y
    settingsOverlay.Position               = UDim2.new(0, 0, 0, 34)
    settingsOverlay.Visible                = false
    settingsOverlay.ZIndex                 = 10
    settingsOverlay.ClipsDescendants       = true
    settingsOverlay.Parent                 = root
    corner(settingsOverlay, 10)

    local overlayPad = Instance.new("UIPadding", settingsOverlay)
    overlayPad.PaddingTop    = UDim.new(0, PADDING)
    overlayPad.PaddingBottom = UDim.new(0, PADDING)
    overlayPad.PaddingLeft   = UDim.new(0, PADDING)
    overlayPad.PaddingRight  = UDim.new(0, PADDING)

    local overlayLayout = Instance.new("UIListLayout", settingsOverlay)
    overlayLayout.Padding   = UDim.new(0, 6)
    overlayLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local function makeOverlayLabel(text, order)
        local l = Instance.new("TextLabel", settingsOverlay)
        l.BackgroundTransparency = 1
        l.Text           = text
        l.FontFace       = FONT_MED
        l.TextColor3     = Theme.SubText
        l.TextSize       = 10
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Size           = UDim2.new(1, 0, 0, 16)
        l.LayoutOrder    = order
        return l
    end

    makeOverlayLabel("ACCENT COLOUR", 1)

    local colourGrid = Instance.new("Frame", settingsOverlay)
    colourGrid.BackgroundTransparency = 1
    colourGrid.Size                   = UDim2.new(1, 0, 0, 0)
    colourGrid.AutomaticSize          = Enum.AutomaticSize.Y
    colourGrid.LayoutOrder            = 2

    local colourGridLayout = Instance.new("UIGridLayout", colourGrid)
    colourGridLayout.CellSize            = UDim2.new(0, 26, 0, 26)
    colourGridLayout.CellPadding         = UDim2.new(0, 5, 0, 5)
    colourGridLayout.SortOrder           = Enum.SortOrder.LayoutOrder
    colourGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left

    local accentSwatches    = {}
    local activeSwatchStroke = nil
    local presetOrder       = { "Default", "Pink", "Green", "Red", "Purple", "Orange", "Teal", "White" }

    for i, name in presetOrder do
        local color  = Presets[name].Accent
        local swatch = Instance.new("TextButton", colourGrid)
        swatch.BackgroundColor3 = color
        swatch.BorderSizePixel  = 0
        swatch.Text             = ""
        swatch.AutoButtonColor  = false
        swatch.LayoutOrder      = i
        swatch.Size             = UDim2.new(0, 26, 0, 26)
        corner(swatch, 6)
        table.insert(accentSwatches, swatch)

        swatch.Activated:Connect(function()
            accent = color
            if activeSwatchStroke then
                activeSwatchStroke:Destroy()
                activeSwatchStroke = nil
            end
            local sel = Instance.new("UIStroke", swatch)
            sel.Color        = color
            sel.Transparency = 0
            sel.Thickness    = 2
            activeSwatchStroke = sel
        end)
    end

    makeOverlayLabel("OPACITY", 3)

    local opacityRow = Instance.new("Frame", settingsOverlay)
    opacityRow.BackgroundTransparency = 1
    opacityRow.Size                   = UDim2.new(1, 0, 0, 24)
    opacityRow.LayoutOrder            = 4

    local opacityTrack = Instance.new("Frame", opacityRow)
    opacityTrack.BackgroundColor3 = Theme.Off
    opacityTrack.Position         = UDim2.new(0, 0, 0.5, -3)
    opacityTrack.Size             = UDim2.new(1, -40, 0, 5)
    opacityTrack.BorderSizePixel  = 0
    corner(opacityTrack, 3)

    local opacityFill = Instance.new("Frame", opacityTrack)
    opacityFill.BackgroundColor3 = Theme.Accent
    opacityFill.Size             = UDim2.new(0.96, 0, 1, 0)
    opacityFill.BorderSizePixel  = 0
    corner(opacityFill, 3)

    local opacityKnob = Instance.new("Frame", opacityTrack)
    opacityKnob.BackgroundColor3 = Theme.Text
    opacityKnob.AnchorPoint      = Vector2.new(0.5, 0.5)
    opacityKnob.Position         = UDim2.new(0.96, 0, 0.5, 0)
    opacityKnob.Size             = UDim2.fromOffset(12, 12)
    opacityKnob.BorderSizePixel  = 0
    opacityKnob.ZIndex           = 2
    corner(opacityKnob, 6)

    local opacityLbl = Instance.new("TextLabel", opacityRow)
    opacityLbl.BackgroundTransparency = 1
    opacityLbl.Text           = "96%"
    opacityLbl.FontFace       = FONT_BOLD
    opacityLbl.TextColor3     = Theme.SubText
    opacityLbl.TextSize       = 11
    opacityLbl.TextXAlignment = Enum.TextXAlignment.Right
    opacityLbl.AnchorPoint    = Vector2.new(1, 0.5)
    opacityLbl.Position       = UDim2.new(1, 0, 0.5, 0)
    opacityLbl.Size           = UDim2.new(0, 34, 1, 0)

    local opacityDragging = false
    local function applyOpacity(alpha)
        local pct = math.clamp(math.floor(alpha * 100 + 0.5), 20, 100)
        alpha = pct / 100
        opacityFill.Size     = UDim2.new(alpha, 0, 1, 0)
        opacityKnob.Position = UDim2.new(alpha, 0, 0.5, 0)
        opacityLbl.Text      = pct .. "%"
        root.BackgroundTransparency = 1 - alpha
    end

    opacityTrack.InputBegan:Connect(function(inp)
        local t = inp.UserInputType
        if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
            opacityDragging = true
            local ap = opacityTrack.AbsolutePosition.X
            local sz = opacityTrack.AbsoluteSize.X
            applyOpacity(math.clamp((inp.Position.X - ap) / sz, 0, 1))
        end
    end)
    opacityTrack.InputEnded:Connect(function(inp)
        local t = inp.UserInputType
        if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
            opacityDragging = false
        end
    end)
    track(UserInputService.InputChanged:Connect(function(inp)
        local t = inp.UserInputType
        if opacityDragging and (t == Enum.UserInputType.MouseMovement or t == Enum.UserInputType.Touch) then
            local ap = opacityTrack.AbsolutePosition.X
            local sz = opacityTrack.AbsoluteSize.X
            applyOpacity(math.clamp((inp.Position.X - ap) / sz, 0, 1))
        end
    end))

    makeOverlayLabel("POSITION", 5)

    local posGrid = Instance.new("Frame", settingsOverlay)
    posGrid.BackgroundTransparency = 1
    posGrid.Size                   = UDim2.new(1, 0, 0, 0)
    posGrid.AutomaticSize          = Enum.AutomaticSize.Y
    posGrid.LayoutOrder            = 6

    local posGridLayout = Instance.new("UIGridLayout", posGrid)
    posGridLayout.CellSize    = UDim2.new(0.5, -3, 0, 26)
    posGridLayout.CellPadding = UDim2.new(0, 5, 0, 5)
    posGridLayout.SortOrder   = Enum.SortOrder.LayoutOrder

    local posLabels = { "Top Right", "Top Left", "Bottom Right", "Bottom Left" }
    local posKeys   = { "topright",  "topleft",  "bottomright",  "bottomleft"  }

    for i, lbl in posLabels do
        local pb = Instance.new("TextButton", posGrid)
        pb.BackgroundColor3 = Theme.Row
        pb.AutoButtonColor  = false
        pb.BorderSizePixel  = 0
        pb.Text             = lbl
        pb.FontFace         = FONT_MED
        pb.TextColor3       = Theme.SubText
        pb.TextSize         = 11
        pb.LayoutOrder      = i
        corner(pb, 5)

        pb.MouseEnter:Connect(function() tween(pb, TI, { BackgroundColor3 = Theme.RowHover }) end)
        pb.MouseLeave:Connect(function() tween(pb, TI, { BackgroundColor3 = Theme.Row }) end)
        pb.Activated:Connect(function()
            position = posKeys[i]
            root.Position = anchorPosition(posKeys[i], width)
            tween(pb, TI, { TextColor3 = accent })
            task.wait(0.3)
            tween(pb, TI, { TextColor3 = Theme.SubText })
        end)
    end

    -- Title bar
    local titleBar
    local settingsOpen = false
    local settingsBtn

    if title then
        titleBar = Instance.new("Frame")
        titleBar.Name                   = "TitleBar"
        titleBar.BackgroundColor3       = Theme.Surface
        titleBar.BackgroundTransparency = 0.02
        titleBar.BorderSizePixel        = 0
        titleBar.Size                   = UDim2.new(1, 0, 0, 34)
        titleBar.ZIndex                 = 5
        titleBar.Parent                 = root
        corner(titleBar, 10)

        local flush = Instance.new("Frame", titleBar)
        flush.BackgroundColor3       = Theme.Surface
        flush.BackgroundTransparency = 0.02
        flush.BorderSizePixel        = 0
        flush.Position               = UDim2.new(0, 0, 0.5, 0)
        flush.Size                   = UDim2.new(1, 0, 0.5, 0)
        flush.ZIndex                 = 5

        stroke(titleBar, Theme.Stroke, 0.55, 1)

        local accentBar = Instance.new("Frame", titleBar)
        accentBar.BackgroundColor3 = accent
        accentBar.BorderSizePixel  = 0
        accentBar.Position         = UDim2.new(0, 0, 0.2, 0)
        accentBar.Size             = UDim2.new(0, 2, 0.6, 0)
        accentBar.ZIndex           = 6
        corner(accentBar, 2)

        local titleLbl = Instance.new("TextLabel", titleBar)
        titleLbl.Name                   = "TitleLabel"
        titleLbl.BackgroundTransparency = 1
        titleLbl.Text           = title
        titleLbl.FontFace       = FONT_BOLD
        titleLbl.TextColor3     = Theme.Text
        titleLbl.TextSize       = 12
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left
        titleLbl.Position       = UDim2.new(0, 14, 0, 0)
        titleLbl.Size           = UDim2.new(1, -50, 1, 0)
        titleLbl.ZIndex         = 6

        settingsBtn = Instance.new("TextButton", titleBar)
        settingsBtn.BackgroundColor3       = Theme.Row
        settingsBtn.BackgroundTransparency = 1
        settingsBtn.AutoButtonColor        = false
        settingsBtn.BorderSizePixel        = 0
        settingsBtn.Text                   = "⚙"
        settingsBtn.FontFace               = FONT_MED
        settingsBtn.TextColor3             = Theme.SubText
        settingsBtn.TextSize               = 14
        settingsBtn.AnchorPoint            = Vector2.new(1, 0.5)
        settingsBtn.Position               = UDim2.new(1, -8, 0.5, 0)
        settingsBtn.Size                   = UDim2.fromOffset(24, 24)
        settingsBtn.ZIndex                 = 6
        corner(settingsBtn, 5)

        settingsBtn.MouseEnter:Connect(function()
            tween(settingsBtn, TI, { BackgroundTransparency = 0, TextColor3 = accent })
        end)
        settingsBtn.MouseLeave:Connect(function()
            tween(settingsBtn, TI, { BackgroundTransparency = 1, TextColor3 = Theme.SubText })
        end)
        settingsBtn.Activated:Connect(function()
            settingsOpen = not settingsOpen
            settingsOverlay.Visible = settingsOpen
            tween(settingsBtn, TI, { TextColor3 = settingsOpen and accent or Theme.SubText })
        end)

        makeDraggable(root, titleBar)
    end

    -- Body
    local body = Instance.new("Frame")
    body.Name                   = "Body"
    body.BackgroundTransparency = 1
    body.BorderSizePixel        = 0
    body.Position               = UDim2.new(0, 0, 0, title and 34 or 0)
    body.Size                   = UDim2.new(1, 0, 0, 0)
    body.AutomaticSize          = Enum.AutomaticSize.Y
    body.Parent                 = root

    local listLayout = Instance.new("UIListLayout", body)
    listLayout.Padding       = UDim.new(0, ROW_GAP)
    listLayout.SortOrder     = Enum.SortOrder.LayoutOrder

    local bodyPad = Instance.new("UIPadding", body)
    bodyPad.PaddingTop    = UDim.new(0, PADDING)
    bodyPad.PaddingBottom = UDim.new(0, PADDING)
    bodyPad.PaddingLeft   = UDim.new(0, PADDING)
    bodyPad.PaddingRight  = UDim.new(0, PADDING)

    --------------------------------------------------------------
    -- Panel API
    --------------------------------------------------------------
    local Panel  = {}
    local _order = 0

    local function nextOrder()
        _order += 1
        return _order
    end

    local function newRow(height, transparent)
        local row = Instance.new("Frame")
        row.BackgroundColor3       = transparent and Color3.new() or Theme.Row
        row.BackgroundTransparency = transparent and 1 or 0
        row.BorderSizePixel        = 0
        row.Size                   = UDim2.new(1, 0, 0, height or ROW_HEIGHT)
        row.LayoutOrder            = nextOrder()
        row.Parent                 = body
        if not transparent then corner(row, 6) end
        return row
    end

    ------------------------------------------------------------
    -- Label
    ------------------------------------------------------------
    function Panel:Label(text)
        local row = newRow(16, true)
        local lbl = Instance.new("TextLabel", row)
        lbl.BackgroundTransparency = 1
        lbl.Text           = text or ""
        lbl.FontFace       = FONT_MED
        lbl.TextColor3     = Theme.SubText
        lbl.TextSize       = 10
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Size           = UDim2.new(1, 0, 1, 0)
        return {
            Set      = function(_, t) lbl.Text = t end,
            Instance = row,
        }
    end

    ------------------------------------------------------------
    -- Warning
    ------------------------------------------------------------
    function Panel:Warning(text)
        local row = newRow(ROW_HEIGHT, true)
        row.AutomaticSize          = Enum.AutomaticSize.Y
        row.BackgroundColor3       = Color3.fromRGB(34, 26, 12)
        row.BackgroundTransparency = 0
        corner(row, 6)
        stroke(row, Theme.Warning, 0.5, 1)

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

    ------------------------------------------------------------
    -- Stat
    ------------------------------------------------------------
    function Panel:Stat(name, value, accentColor)
        local row = newRow(ROW_HEIGHT)

        local nameLbl = Instance.new("TextLabel", row)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Text           = name or "Stat"
        nameLbl.FontFace       = FONT_REG
        nameLbl.TextColor3     = Theme.SubText
        nameLbl.TextSize       = 11
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left
        nameLbl.Position       = UDim2.new(0, 8, 0, 0)
        nameLbl.Size           = UDim2.new(0.55, -8, 1, 0)

        local valLbl = Instance.new("TextLabel", row)
        valLbl.BackgroundTransparency = 1
        valLbl.Text           = tostring(value or "-")
        valLbl.FontFace       = FONT_BOLD
        valLbl.TextColor3     = accentColor or accent
        valLbl.TextSize       = 11
        valLbl.TextXAlignment = Enum.TextXAlignment.Right
        valLbl.Position       = UDim2.new(0.45, 0, 0, 0)
        valLbl.Size           = UDim2.new(0.55, -8, 1, 0)

        return {
            Set      = function(_, v) valLbl.Text = tostring(v) end,
            Get      = function() return valLbl.Text end,
            Instance = row,
        }
    end

    ------------------------------------------------------------
    -- Button
    ------------------------------------------------------------
    function Panel:Button(name, callback)
        local btn = Instance.new("TextButton")
        btn.BackgroundColor3 = Theme.Row
        btn.AutoButtonColor  = false
        btn.BorderSizePixel  = 0
        btn.Text             = name or "Button"
        btn.FontFace         = FONT_MED
        btn.TextColor3       = Theme.Text
        btn.TextSize         = 11
        btn.Size             = UDim2.new(1, 0, 0, ROW_HEIGHT)
        btn.LayoutOrder      = nextOrder()
        btn.Parent           = body
        corner(btn, 6)

        btn.MouseEnter:Connect(function() tween(btn, TI, { BackgroundColor3 = Theme.RowHover }) end)
        btn.MouseLeave:Connect(function() tween(btn, TI, { BackgroundColor3 = Theme.Row }) end)
        btn.Activated:Connect(function()
            tween(btn, TI, { BackgroundColor3 = accent })
            task.wait(0.12)
            tween(btn, TI, { BackgroundColor3 = Theme.Row })
            if callback then task.spawn(callback) end
        end)

        return { Instance = btn }
    end

    ------------------------------------------------------------
    -- Toggle
    ------------------------------------------------------------
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
        nameLbl.TextSize       = 11
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left
        nameLbl.Position       = UDim2.new(0, 8, 0, 0)
        nameLbl.Size           = UDim2.new(1, -52, 1, 0)

        local toggleTrack = Instance.new("Frame", hitbox)
        toggleTrack.BackgroundColor3 = state and accent or Theme.Off
        toggleTrack.AnchorPoint      = Vector2.new(1, 0.5)
        toggleTrack.Position         = UDim2.new(1, -8, 0.5, 0)
        toggleTrack.Size             = UDim2.fromOffset(34, 17)
        toggleTrack.BorderSizePixel  = 0
        corner(toggleTrack, 9)

        local knob = Instance.new("Frame", toggleTrack)
        knob.BackgroundColor3 = Theme.Text
        knob.AnchorPoint      = Vector2.new(0, 0.5)
        knob.Position         = state and UDim2.new(1, -15, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
        knob.Size             = UDim2.fromOffset(13, 13)
        knob.BorderSizePixel  = 0
        corner(knob, 7)

        local api = {}
        function api:Set(v)
            state = v
            tween(toggleTrack, TI, { BackgroundColor3 = state and accent or Theme.Off })
            tween(knob, TI, { Position = state and UDim2.new(1, -15, 0.5, 0) or UDim2.new(0, 2, 0.5, 0) })
            if callback then task.spawn(callback, state) end
        end
        function api:Get() return state end
        hitbox.Activated:Connect(function() api:Set(not state) end)
        api.Instance = row
        return api
    end

    ------------------------------------------------------------
    -- Slider
    ------------------------------------------------------------
    function Panel:Slider(name, min, max, default, callback)
        min     = min     or 0
        max     = max     or 100
        default = math.clamp(default or min, min, max)

        local row = newRow(46)

        local nameLbl = Instance.new("TextLabel", row)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Text           = name or "Slider"
        nameLbl.FontFace       = FONT_MED
        nameLbl.TextColor3     = Theme.Text
        nameLbl.TextSize       = 11
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left
        nameLbl.Position       = UDim2.new(0, 8, 0, 5)
        nameLbl.Size           = UDim2.new(0.65, -8, 0, 16)

        local valLbl = Instance.new("TextLabel", row)
        valLbl.BackgroundTransparency = 1
        valLbl.Text           = tostring(default)
        valLbl.FontFace       = FONT_BOLD
        valLbl.TextColor3     = accent
        valLbl.TextSize       = 11
        valLbl.TextXAlignment = Enum.TextXAlignment.Right
        valLbl.AnchorPoint    = Vector2.new(1, 0)
        valLbl.Position       = UDim2.new(1, -8, 0, 5)
        valLbl.Size           = UDim2.new(0.35, -8, 0, 16)

        local sliderTrack = Instance.new("Frame", row)
        sliderTrack.BackgroundColor3 = Theme.Off
        sliderTrack.Position         = UDim2.new(0, 8, 0, 32)
        sliderTrack.Size             = UDim2.new(1, -16, 0, 5)
        sliderTrack.BorderSizePixel  = 0
        corner(sliderTrack, 3)

        local fill = Instance.new("Frame", sliderTrack)
        fill.BackgroundColor3 = accent
        fill.Size             = UDim2.new((default - min) / (max - min), 0, 1, 0)
        fill.BorderSizePixel  = 0
        corner(fill, 3)

        local knob = Instance.new("Frame", sliderTrack)
        knob.BackgroundColor3 = Theme.Text
        knob.AnchorPoint      = Vector2.new(0.5, 0.5)
        knob.Position         = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
        knob.Size             = UDim2.fromOffset(12, 12)
        knob.BorderSizePixel  = 0
        knob.ZIndex           = 2
        corner(knob, 6)

        local value    = default
        local dragging = false

        local function apply(a)
            local raw = min + (max - min) * a
            value = math.clamp(math.floor(raw + 0.5), min, max)
            local fa = (max ~= min) and (value - min) / (max - min) or 0
            fill.Size     = UDim2.new(fa, 0, 1, 0)
            knob.Position = UDim2.new(fa, 0, 0.5, 0)
            valLbl.Text   = tostring(value)
            if callback then task.spawn(callback, value) end
        end

        local function getA(x)
            return math.clamp((x - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
        end

        sliderTrack.InputBegan:Connect(function(inp)
            local t = inp.UserInputType
            if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
                dragging = true; apply(getA(inp.Position.X))
            end
        end)
        sliderTrack.InputEnded:Connect(function(inp)
            local t = inp.UserInputType
            if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then dragging = false end
        end)
        track(UserInputService.InputChanged:Connect(function(inp)
            local t = inp.UserInputType
            if dragging and (t == Enum.UserInputType.MouseMovement or t == Enum.UserInputType.Touch) then
                apply(getA(inp.Position.X))
            end
        end))

        local api = {}
        function api:Set(v) apply((math.clamp(v, min, max) - min) / (max - min)) end
        function api:Get() return value end
        api.Instance = row
        return api
    end

    ------------------------------------------------------------
    -- ProgressBar
    ------------------------------------------------------------
    function Panel:ProgressBar(name, maxVal, accentColor)
        maxVal = maxVal or 100
        local value = 0
        local row   = newRow(46)

        local nameLbl = Instance.new("TextLabel", row)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Text           = name or "Progress"
        nameLbl.FontFace       = FONT_MED
        nameLbl.TextColor3     = Theme.Text
        nameLbl.TextSize       = 11
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left
        nameLbl.Position       = UDim2.new(0, 8, 0, 5)
        nameLbl.Size           = UDim2.new(0.65, 0, 0, 16)

        local valLbl = Instance.new("TextLabel", row)
        valLbl.BackgroundTransparency = 1
        valLbl.Text           = "0 / " .. maxVal
        valLbl.FontFace       = FONT_BOLD
        valLbl.TextColor3     = accentColor or accent
        valLbl.TextSize       = 11
        valLbl.TextXAlignment = Enum.TextXAlignment.Right
        valLbl.AnchorPoint    = Vector2.new(1, 0)
        valLbl.Position       = UDim2.new(1, -8, 0, 5)
        valLbl.Size           = UDim2.new(0.35, -8, 0, 16)

        local barBg = Instance.new("Frame", row)
        barBg.BackgroundColor3 = Theme.Off
        barBg.Position         = UDim2.new(0, 8, 0, 32)
        barBg.Size             = UDim2.new(1, -16, 0, 6)
        barBg.BorderSizePixel  = 0
        corner(barBg, 3)

        local barFill = Instance.new("Frame", barBg)
        barFill.BackgroundColor3 = accentColor or accent
        barFill.Size             = UDim2.new(0, 0, 1, 0)
        barFill.BorderSizePixel  = 0
        corner(barFill, 3)

        local api = {}
        function api:Set(v)
            value = math.clamp(v, 0, maxVal)
            local a = maxVal > 0 and value / maxVal or 0
            tween(barFill, TI, { Size = UDim2.new(a, 0, 1, 0) })
            valLbl.Text = value .. " / " .. maxVal
        end
        function api:Get() return value end
        api.Instance = row
        return api
    end

    ------------------------------------------------------------
    -- Dropdown
    ------------------------------------------------------------
    function Panel:Dropdown(name, options, default, callback)
        options = options or {}
        local selected = default or options[1] or ""
        local isOpen   = false

        local headerRow = newRow(ROW_HEIGHT)

        local nameLbl = Instance.new("TextLabel", headerRow)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Text           = name or "Select"
        nameLbl.FontFace       = FONT_MED
        nameLbl.TextColor3     = Theme.SubText
        nameLbl.TextSize       = 11
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left
        nameLbl.Position       = UDim2.new(0, 8, 0, 0)
        nameLbl.Size           = UDim2.new(0.45, -8, 1, 0)

        local selectedLbl = Instance.new("TextLabel", headerRow)
        selectedLbl.BackgroundTransparency = 1
        selectedLbl.Text           = selected
        selectedLbl.FontFace       = FONT_BOLD
        selectedLbl.TextColor3     = accent
        selectedLbl.TextSize       = 11
        selectedLbl.TextXAlignment = Enum.TextXAlignment.Right
        selectedLbl.Position       = UDim2.new(0.45, 0, 0, 0)
        selectedLbl.Size           = UDim2.new(0.55, -28, 1, 0)

        local chevron = Instance.new("TextLabel", headerRow)
        chevron.BackgroundTransparency = 1
        chevron.Text           = "▼"
        chevron.FontFace       = FONT_BOLD
        chevron.TextColor3     = Theme.SubText
        chevron.TextSize       = 9
        chevron.TextXAlignment = Enum.TextXAlignment.Center
        chevron.AnchorPoint    = Vector2.new(1, 0.5)
        chevron.Position       = UDim2.new(1, -8, 0.5, 0)
        chevron.Size           = UDim2.fromOffset(20, 20)

        -- List frame: sibling in body, hidden via Visible (collapses in UIListLayout)
        local listFrame = Instance.new("Frame")
        listFrame.BackgroundColor3       = Theme.Surface
        listFrame.BackgroundTransparency = 0
        listFrame.BorderSizePixel        = 0
        listFrame.Size                   = UDim2.new(1, 0, 0, 0)
        listFrame.AutomaticSize          = Enum.AutomaticSize.Y
        listFrame.LayoutOrder            = nextOrder()
        listFrame.Visible                = false
        listFrame.Parent                 = body
        corner(listFrame, 6)
        stroke(listFrame, Theme.Stroke, 0.5, 1)

        local listLayout = Instance.new("UIListLayout", listFrame)
        listLayout.Padding   = UDim.new(0, 2)
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder

        local listPad = Instance.new("UIPadding", listFrame)
        listPad.PaddingTop    = UDim.new(0, 4)
        listPad.PaddingBottom = UDim.new(0, 4)
        listPad.PaddingLeft   = UDim.new(0, 4)
        listPad.PaddingRight  = UDim.new(0, 4)

        local optionButtons = {}

        for i, opt in options do
            local optBtn = Instance.new("TextButton", listFrame)
            optBtn.BackgroundColor3       = Theme.Row
            optBtn.BackgroundTransparency = 1
            optBtn.AutoButtonColor        = false
            optBtn.BorderSizePixel        = 0
            optBtn.Text                   = opt
            optBtn.FontFace               = FONT_MED
            optBtn.TextColor3             = (opt == selected) and accent or Theme.Text
            optBtn.TextSize               = 11
            optBtn.TextXAlignment         = Enum.TextXAlignment.Left
            optBtn.Size                   = UDim2.new(1, 0, 0, 26)
            optBtn.LayoutOrder            = i
            corner(optBtn, 4)

            local optPad = Instance.new("UIPadding", optBtn)
            optPad.PaddingLeft  = UDim.new(0, 8)
            optPad.PaddingRight = UDim.new(0, 8)

            optBtn.MouseEnter:Connect(function()
                tween(optBtn, TI, { BackgroundTransparency = 0, BackgroundColor3 = Theme.Row })
            end)
            optBtn.MouseLeave:Connect(function()
                tween(optBtn, TI, { BackgroundTransparency = 1 })
            end)
            optBtn.Activated:Connect(function()
                for _, btn in optionButtons do
                    tween(btn, TI, { TextColor3 = Theme.Text })
                end
                tween(optBtn, TI, { TextColor3 = accent })
                selected          = opt
                selectedLbl.Text  = opt
                isOpen            = false
                listFrame.Visible = false
                chevron.Text      = "▼"
                tween(chevron, TI, { TextColor3 = Theme.SubText })
                if callback then task.spawn(callback, opt) end
            end)

            table.insert(optionButtons, optBtn)
        end

        local hitbox = Instance.new("TextButton", headerRow)
        hitbox.BackgroundTransparency = 1
        hitbox.Text   = ""
        hitbox.Size   = UDim2.new(1, 0, 1, 0)
        hitbox.ZIndex = 2

        hitbox.Activated:Connect(function()
            isOpen            = not isOpen
            listFrame.Visible = isOpen
            chevron.Text      = isOpen and "▲" or "▼"
            tween(chevron, TI, { TextColor3 = isOpen and accent or Theme.SubText })
        end)

        local api = {}
        function api:Set(v)
            selected         = v
            selectedLbl.Text = v
            for _, btn in optionButtons do
                btn.TextColor3 = btn.Text == v and accent or Theme.Text
            end
        end
        function api:Get() return selected end
        function api:Close()
            isOpen            = false
            listFrame.Visible = false
            chevron.Text      = "▼"
            tween(chevron, TI, { TextColor3 = Theme.SubText })
        end
        api.Instance = headerRow
        return api
    end

    ------------------------------------------------------------
    -- TextInput
    ------------------------------------------------------------
    function Panel:TextInput(name, placeholder, callback)
        local row = newRow(ROW_HEIGHT)

        local nameLbl = Instance.new("TextLabel", row)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Text           = name or "Input"
        nameLbl.FontFace       = FONT_MED
        nameLbl.TextColor3     = Theme.SubText
        nameLbl.TextSize       = 11
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left
        nameLbl.Position       = UDim2.new(0, 8, 0, 0)
        nameLbl.Size           = UDim2.new(0.38, -8, 1, 0)

        local box = Instance.new("TextBox", row)
        box.BackgroundColor3  = Theme.Background
        box.BorderSizePixel   = 0
        box.PlaceholderText   = placeholder or ""
        box.PlaceholderColor3 = Theme.SubText
        box.Text              = ""
        box.FontFace          = FONT_MED
        box.TextColor3        = Theme.Text
        box.TextSize          = 11
        box.TextXAlignment    = Enum.TextXAlignment.Left
        box.ClearTextOnFocus  = false
        box.AnchorPoint       = Vector2.new(1, 0.5)
        box.Position          = UDim2.new(1, -8, 0.5, 0)
        box.Size              = UDim2.new(0.62, -16, 0, 22)
        corner(box, 4)
        local boxStroke = stroke(box, Theme.Stroke, 0.3, 1)

        local boxPad = Instance.new("UIPadding", box)
        boxPad.PaddingLeft  = UDim.new(0, 6)
        boxPad.PaddingRight = UDim.new(0, 6)

        box.Focused:Connect(function()
            tween(box,       TI, { BackgroundColor3 = Theme.Surface })
            tween(boxStroke, TI, { Color = accent, Transparency = 0 })
        end)
        box.FocusLost:Connect(function(enterPressed)
            tween(box,       TI, { BackgroundColor3 = Theme.Background })
            tween(boxStroke, TI, { Color = Theme.Stroke, Transparency = 0.3 })
            if callback then task.spawn(callback, box.Text, enterPressed) end
        end)

        local api = {}
        function api:Set(v)   box.Text = tostring(v) end
        function api:Get()    return box.Text end
        function api:Clear()  box.Text = "" end
        api.Instance = row
        return api
    end

    ------------------------------------------------------------
    -- Section (collapsible)
    ------------------------------------------------------------
    function Panel:Section(name, defaultCollapsed)
        local collapsed = (defaultCollapsed == true)
        local sOrder    = 0

        -- Header row
        local headerRow = newRow(ROW_HEIGHT)
        headerRow.BackgroundColor3 = Theme.Surface

        local sAccentBar = Instance.new("Frame", headerRow)
        sAccentBar.BackgroundColor3 = accent
        sAccentBar.BorderSizePixel  = 0
        sAccentBar.Position         = UDim2.new(0, 0, 0.2, 0)
        sAccentBar.Size             = UDim2.new(0, 2, 0.6, 0)
        corner(sAccentBar, 2)

        local sNameLbl = Instance.new("TextLabel", headerRow)
        sNameLbl.BackgroundTransparency = 1
        sNameLbl.Text           = name or "Section"
        sNameLbl.FontFace       = FONT_BOLD
        sNameLbl.TextColor3     = Theme.Text
        sNameLbl.TextSize       = 11
        sNameLbl.TextXAlignment = Enum.TextXAlignment.Left
        sNameLbl.Position       = UDim2.new(0, 10, 0, 0)
        sNameLbl.Size           = UDim2.new(1, -32, 1, 0)

        local chevron = Instance.new("TextLabel", headerRow)
        chevron.BackgroundTransparency = 1
        chevron.Text           = collapsed and "▶" or "▼"
        chevron.FontFace       = FONT_BOLD
        chevron.TextColor3     = collapsed and Theme.SubText or accent
        chevron.TextSize       = 9
        chevron.TextXAlignment = Enum.TextXAlignment.Center
        chevron.AnchorPoint    = Vector2.new(1, 0.5)
        chevron.Position       = UDim2.new(1, -8, 0.5, 0)
        chevron.Size           = UDim2.fromOffset(16, 16)

        -- Content frame: collapses via Visible in UIListLayout
        local contentFrame = Instance.new("Frame")
        contentFrame.BackgroundTransparency = 1
        contentFrame.BorderSizePixel        = 0
        contentFrame.Size                   = UDim2.new(1, 0, 0, 0)
        contentFrame.AutomaticSize          = Enum.AutomaticSize.Y
        contentFrame.LayoutOrder            = nextOrder()
        contentFrame.Visible                = not collapsed
        contentFrame.Parent                 = body

        local cLayout = Instance.new("UIListLayout", contentFrame)
        cLayout.Padding   = UDim.new(0, ROW_GAP)
        cLayout.SortOrder = Enum.SortOrder.LayoutOrder

        -- Hitbox over header to toggle
        local hitbox = Instance.new("TextButton", headerRow)
        hitbox.BackgroundTransparency = 1
        hitbox.Text   = ""
        hitbox.Size   = UDim2.new(1, 0, 1, 0)
        hitbox.ZIndex = 2

        -- Section element builders (close over contentFrame)
        local function sNextOrder() sOrder += 1; return sOrder end
        local function sNewRow(h, t)
            local row = Instance.new("Frame")
            row.BackgroundColor3       = t and Color3.new() or Theme.Row
            row.BackgroundTransparency = t and 1 or 0
            row.BorderSizePixel        = 0
            row.Size                   = UDim2.new(1, 0, 0, h or ROW_HEIGHT)
            row.LayoutOrder            = sNextOrder()
            row.Parent                 = contentFrame
            if not t then corner(row, 6) end
            return row
        end

        local section = {}

        function section:Label(text)
            local row = sNewRow(16, true)
            local lbl = Instance.new("TextLabel", row)
            lbl.BackgroundTransparency = 1; lbl.Text = text or ""
            lbl.FontFace = FONT_MED; lbl.TextColor3 = Theme.SubText; lbl.TextSize = 10
            lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Size = UDim2.new(1, 0, 1, 0)
            return { Set = function(_, t) lbl.Text = t end, Instance = row }
        end

        function section:Warning(text)
            local row = sNewRow(ROW_HEIGHT, true)
            row.AutomaticSize = Enum.AutomaticSize.Y
            row.BackgroundColor3 = Color3.fromRGB(34, 26, 12); row.BackgroundTransparency = 0
            corner(row, 6); stroke(row, Theme.Warning, 0.5, 1)
            local pad = Instance.new("UIPadding", row)
            pad.PaddingLeft = UDim.new(0,8); pad.PaddingRight  = UDim.new(0,8)
            pad.PaddingTop  = UDim.new(0,6); pad.PaddingBottom = UDim.new(0,6)
            local lbl = Instance.new("TextLabel", row)
            lbl.BackgroundTransparency = 1; lbl.Text = "⚠  " .. (text or "")
            lbl.FontFace = FONT_MED; lbl.TextColor3 = Theme.Warning; lbl.TextSize = 11
            lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.TextWrapped = true
            lbl.AutomaticSize = Enum.AutomaticSize.Y; lbl.Size = UDim2.new(1, 0, 0, 0)
            return { Set = function(_, t) lbl.Text = "⚠  " .. t end, Instance = row }
        end

        function section:Stat(name, value, accentColor)
            local row = sNewRow(ROW_HEIGHT)
            local nl = Instance.new("TextLabel", row)
            nl.BackgroundTransparency = 1; nl.Text = name or "Stat"; nl.FontFace = FONT_REG
            nl.TextColor3 = Theme.SubText; nl.TextSize = 11
            nl.TextXAlignment = Enum.TextXAlignment.Left
            nl.Position = UDim2.new(0, 8, 0, 0); nl.Size = UDim2.new(0.55, -8, 1, 0)
            local vl = Instance.new("TextLabel", row)
            vl.BackgroundTransparency = 1; vl.Text = tostring(value or "-"); vl.FontFace = FONT_BOLD
            vl.TextColor3 = accentColor or accent; vl.TextSize = 11
            vl.TextXAlignment = Enum.TextXAlignment.Right
            vl.Position = UDim2.new(0.45, 0, 0, 0); vl.Size = UDim2.new(0.55, -8, 1, 0)
            return {
                Set = function(_, v) vl.Text = tostring(v) end,
                Get = function() return vl.Text end,
                Instance = row,
            }
        end

        function section:Button(name, callback)
            local btn = Instance.new("TextButton")
            btn.BackgroundColor3 = Theme.Row; btn.AutoButtonColor = false
            btn.BorderSizePixel = 0; btn.Text = name or "Button"; btn.FontFace = FONT_MED
            btn.TextColor3 = Theme.Text; btn.TextSize = 11
            btn.Size = UDim2.new(1, 0, 0, ROW_HEIGHT)
            btn.LayoutOrder = sNextOrder(); btn.Parent = contentFrame
            corner(btn, 6)
            btn.MouseEnter:Connect(function() tween(btn, TI, { BackgroundColor3 = Theme.RowHover }) end)
            btn.MouseLeave:Connect(function() tween(btn, TI, { BackgroundColor3 = Theme.Row }) end)
            btn.Activated:Connect(function()
                tween(btn, TI, { BackgroundColor3 = accent })
                task.wait(0.12)
                tween(btn, TI, { BackgroundColor3 = Theme.Row })
                if callback then task.spawn(callback) end
            end)
            return { Instance = btn }
        end

        function section:Toggle(name, default, callback)
            local state = default or false
            local row   = sNewRow(ROW_HEIGHT)
            local hb = Instance.new("TextButton", row)
            hb.BackgroundTransparency = 1; hb.Text = ""; hb.Size = UDim2.new(1, 0, 1, 0)
            local nl = Instance.new("TextLabel", hb)
            nl.BackgroundTransparency = 1; nl.Text = name or "Toggle"; nl.FontFace = FONT_MED
            nl.TextColor3 = Theme.Text; nl.TextSize = 11
            nl.TextXAlignment = Enum.TextXAlignment.Left
            nl.Position = UDim2.new(0, 8, 0, 0); nl.Size = UDim2.new(1, -52, 1, 0)
            local tr = Instance.new("Frame", hb)
            tr.BackgroundColor3 = state and accent or Theme.Off
            tr.AnchorPoint = Vector2.new(1, 0.5); tr.Position = UDim2.new(1, -8, 0.5, 0)
            tr.Size = UDim2.fromOffset(34, 17); tr.BorderSizePixel = 0; corner(tr, 9)
            local kn = Instance.new("Frame", tr)
            kn.BackgroundColor3 = Theme.Text; kn.AnchorPoint = Vector2.new(0, 0.5)
            kn.Position = state and UDim2.new(1, -15, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
            kn.Size = UDim2.fromOffset(13, 13); kn.BorderSizePixel = 0; corner(kn, 7)
            local api = {}
            function api:Set(v)
                state = v
                tween(tr, TI, { BackgroundColor3 = state and accent or Theme.Off })
                tween(kn, TI, { Position = state and UDim2.new(1,-15,0.5,0) or UDim2.new(0,2,0.5,0) })
                if callback then task.spawn(callback, state) end
            end
            function api:Get() return state end
            hb.Activated:Connect(function() api:Set(not state) end)
            api.Instance = row; return api
        end

        function section:Slider(name, min, max, default, callback)
            min = min or 0; max = max or 100
            default = math.clamp(default or min, min, max)
            local row = sNewRow(46)
            local nl = Instance.new("TextLabel", row)
            nl.BackgroundTransparency = 1; nl.Text = name or "Slider"; nl.FontFace = FONT_MED
            nl.TextColor3 = Theme.Text; nl.TextSize = 11
            nl.TextXAlignment = Enum.TextXAlignment.Left
            nl.Position = UDim2.new(0,8,0,5); nl.Size = UDim2.new(0.65,-8,0,16)
            local vl = Instance.new("TextLabel", row)
            vl.BackgroundTransparency = 1; vl.Text = tostring(default); vl.FontFace = FONT_BOLD
            vl.TextColor3 = accent; vl.TextSize = 11
            vl.TextXAlignment = Enum.TextXAlignment.Right; vl.AnchorPoint = Vector2.new(1, 0)
            vl.Position = UDim2.new(1,-8,0,5); vl.Size = UDim2.new(0.35,-8,0,16)
            local st = Instance.new("Frame", row)
            st.BackgroundColor3 = Theme.Off; st.Position = UDim2.new(0,8,0,32)
            st.Size = UDim2.new(1,-16,0,5); st.BorderSizePixel = 0; corner(st, 3)
            local fl = Instance.new("Frame", st)
            fl.BackgroundColor3 = accent; fl.Size = UDim2.new((default-min)/(max-min),0,1,0)
            fl.BorderSizePixel = 0; corner(fl, 3)
            local kn = Instance.new("Frame", st)
            kn.BackgroundColor3 = Theme.Text; kn.AnchorPoint = Vector2.new(0.5,0.5)
            kn.Position = UDim2.new((default-min)/(max-min),0,0.5,0)
            kn.Size = UDim2.fromOffset(12,12); kn.BorderSizePixel = 0; kn.ZIndex = 2; corner(kn, 6)
            local value = default; local dragging = false
            local function applyS(a)
                value = math.clamp(math.floor(min+(max-min)*a+0.5),min,max)
                local fa = (max~=min) and (value-min)/(max-min) or 0
                fl.Size = UDim2.new(fa,0,1,0); kn.Position = UDim2.new(fa,0,0.5,0)
                vl.Text = tostring(value)
                if callback then task.spawn(callback, value) end
            end
            local function getAs(x) return math.clamp((x-st.AbsolutePosition.X)/st.AbsoluteSize.X,0,1) end
            st.InputBegan:Connect(function(inp)
                local t = inp.UserInputType
                if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
                    dragging = true; applyS(getAs(inp.Position.X))
                end
            end)
            st.InputEnded:Connect(function(inp)
                local t = inp.UserInputType
                if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then dragging = false end
            end)
            track(UserInputService.InputChanged:Connect(function(inp)
                local t = inp.UserInputType
                if dragging and (t == Enum.UserInputType.MouseMovement or t == Enum.UserInputType.Touch) then
                    applyS(getAs(inp.Position.X))
                end
            end))
            local api = {}
            function api:Set(v) applyS((math.clamp(v,min,max)-min)/(max-min)) end
            function api:Get() return value end
            api.Instance = row; return api
        end

        function section:ProgressBar(name, maxVal, accentColor)
            maxVal = maxVal or 100; local value = 0
            local row = sNewRow(46)
            local nl = Instance.new("TextLabel", row)
            nl.BackgroundTransparency = 1; nl.Text = name or "Progress"; nl.FontFace = FONT_MED
            nl.TextColor3 = Theme.Text; nl.TextSize = 11
            nl.TextXAlignment = Enum.TextXAlignment.Left
            nl.Position = UDim2.new(0,8,0,5); nl.Size = UDim2.new(0.65,0,0,16)
            local vl = Instance.new("TextLabel", row)
            vl.BackgroundTransparency = 1; vl.Text = "0 / " .. maxVal; vl.FontFace = FONT_BOLD
            vl.TextColor3 = accentColor or accent; vl.TextSize = 11
            vl.TextXAlignment = Enum.TextXAlignment.Right; vl.AnchorPoint = Vector2.new(1,0)
            vl.Position = UDim2.new(1,-8,0,5); vl.Size = UDim2.new(0.35,-8,0,16)
            local bg = Instance.new("Frame", row)
            bg.BackgroundColor3 = Theme.Off; bg.Position = UDim2.new(0,8,0,32)
            bg.Size = UDim2.new(1,-16,0,6); bg.BorderSizePixel = 0; corner(bg, 3)
            local fill = Instance.new("Frame", bg)
            fill.BackgroundColor3 = accentColor or accent; fill.Size = UDim2.new(0,0,1,0)
            fill.BorderSizePixel = 0; corner(fill, 3)
            local api = {}
            function api:Set(v)
                value = math.clamp(v, 0, maxVal)
                tween(fill, TI, { Size = UDim2.new(maxVal > 0 and value/maxVal or 0, 0, 1, 0) })
                vl.Text = value .. " / " .. maxVal
            end
            function api:Get() return value end
            api.Instance = row; return api
        end

        function section:Divider()
            local row = sNewRow(1, true)
            local line = Instance.new("Frame", row)
            line.BackgroundColor3 = Theme.Stroke; line.BackgroundTransparency = 0.4
            line.BorderSizePixel = 0; line.Size = UDim2.new(1, 0, 1, 0)
            return { Instance = row }
        end

        -- Expand / Collapse API
        section.Expand = function()
            collapsed = false
            contentFrame.Visible = true
            chevron.Text = "▼"
            tween(chevron, TI, { TextColor3 = accent })
        end
        section.Collapse = function()
            collapsed = true
            contentFrame.Visible = false
            chevron.Text = "▶"
            tween(chevron, TI, { TextColor3 = Theme.SubText })
        end
        section.IsCollapsed = function() return collapsed end
        section.Instance    = headerRow

        hitbox.Activated:Connect(function()
            if collapsed then section.Expand() else section.Collapse() end
        end)

        return section
    end

    ------------------------------------------------------------
    -- Divider
    ------------------------------------------------------------
    function Panel:Divider()
        local row = newRow(1, true)
        local line = Instance.new("Frame", row)
        line.BackgroundColor3       = Theme.Stroke
        line.BackgroundTransparency = 0.4
        line.BorderSizePixel        = 0
        line.Size                   = UDim2.new(1, 0, 1, 0)
        return { Instance = row }
    end

    ------------------------------------------------------------
    -- Panel controls
    ------------------------------------------------------------
    function Panel:Show()
        gui.Enabled = true
        tween(root, TI_S, { GroupTransparency = 0 })
    end

    function Panel:Hide()
        tween(root, TI_S, { GroupTransparency = 1 })
        task.wait(0.25)
        gui.Enabled = false
    end

    function Panel:Toggle()
        if gui.Enabled then self:Hide() else self:Show() end
    end

    function Panel:Destroy()
        for _, conn in connections do
            pcall(function() conn:Disconnect() end)
        end
        table.clear(connections)
        gui:Destroy()
    end

    function Panel:SetAccent(color)
        accent = color
    end

    function Panel:SetPosition(pos)
        position = pos
        root.Position = anchorPosition(pos, width)
    end

    function Panel:SetTitle(text)
        if titleBar then
            local lbl = titleBar:FindFirstChild("TitleLabel")
            if lbl then lbl.Text = text end
        end
    end

    function Panel:GetVisible()
        return gui.Enabled
    end

    ------------------------------------------------------------
    -- Notify (toast, appears below the panel)
    ------------------------------------------------------------
    function Panel:Notify(text, duration)
        duration = duration or 3

        local rp = root.AbsolutePosition
        local rs = root.AbsoluteSize

        local finalY = rp.Y + rs.Y + 8
        local startY = finalY + 12

        local notif = Instance.new("Frame")
        notif.Name                   = "Notification"
        notif.BackgroundColor3       = Theme.Surface
        notif.BackgroundTransparency = 1
        notif.BorderSizePixel        = 0
        notif.Position               = UDim2.new(0, rp.X, 0, startY)
        notif.Size                   = UDim2.new(0, rs.X, 0, 38)
        notif.ZIndex                 = 20
        notif.Parent                 = gui
        corner(notif, 8)
        stroke(notif, accent, 0.4, 1)

        -- Accent dot
        local dot = Instance.new("Frame", notif)
        dot.BackgroundColor3 = accent
        dot.BorderSizePixel  = 0
        dot.AnchorPoint      = Vector2.new(0, 0.5)
        dot.Position         = UDim2.new(0, 10, 0.5, 0)
        dot.Size             = UDim2.fromOffset(4, 4)
        dot.ZIndex           = 21
        corner(dot, 2)

        local lbl = Instance.new("TextLabel", notif)
        lbl.BackgroundTransparency = 1
        lbl.Text           = text or ""
        lbl.FontFace       = FONT_MED
        lbl.TextColor3     = Theme.Text
        lbl.TextSize       = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextTruncate   = Enum.TextTruncate.AtEnd
        lbl.Position       = UDim2.new(0, 22, 0, 0)
        lbl.Size           = UDim2.new(1, -30, 1, 0)
        lbl.ZIndex         = 21

        -- Slide up and fade in
        tween(notif, TI_S, {
            BackgroundTransparency = 0,
            Position               = UDim2.new(0, rp.X, 0, finalY),
        })

        task.spawn(function()
            task.wait(duration)
            -- Slide down and fade out
            tween(notif, TI_S, {
                BackgroundTransparency = 1,
                Position               = UDim2.new(0, rp.X, 0, finalY + 10),
            })
            task.wait(0.25)
            if notif.Parent then notif:Destroy() end
        end)
    end

    return Panel
end

return PanelLib
