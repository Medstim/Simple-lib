local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

----------------------------------------------------------------------
-- Configuration & Presets
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

local Presets = {
	["Default"] = { Accent = Color3.fromRGB(100, 160, 255) },
	["Pink"]    = { Accent = Color3.fromRGB(255, 100, 220) },
	["Green"]   = { Accent = Color3.fromRGB(80,  200, 120) },
	["Red"]     = { Accent = Color3.fromRGB(220, 70,  70)  },
	["Purple"]  = { Accent = Color3.fromRGB(160, 100, 255) },
	["Orange"]  = { Accent = Color3.fromRGB(255, 150, 60)  },
	["Teal"]    = { Accent = Color3.fromRGB(60,  210, 190) },
	["White"]   = { Accent = Color3.fromRGB(220, 220, 220) },
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
	local t = TweenService:Create(obj, info or TI, props)
	t:Play()
	return t
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

local function makeLabel(parent, text, font, size, color, pos, sz, xAlign)
	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Text                   = text or ""
	lbl.FontFace               = font or FONT_MED
	lbl.TextSize               = size or 11
	lbl.TextColor3             = color or Theme.Text
	lbl.TextXAlignment         = xAlign or Enum.TextXAlignment.Left
	lbl.Position               = pos or UDim2.new(0, 0, 0, 0)
	lbl.Size                   = sz or UDim2.new(1, 0, 1, 0)
	lbl.Parent                 = parent
	return lbl
end

local function anchorPosition(position, width)
	local pad = 16
	local pos = {
		topright    = UDim2.new(1, -(width + pad), 0, pad),
		topleft     = UDim2.new(0, pad, 0, pad),
		bottomright = UDim2.new(1, -(width + pad), 1, -(300 + pad)),
		bottomleft  = UDim2.new(0, pad, 1, -(300 + pad)),
	}
	return pos[position] or pos["topright"]
end

local function makeDraggable(frame, handle)
	local dragging, startPos, startFrame
	local dragConn

	local function stopDrag()
		dragging = false
		if dragConn then
			dragConn:Disconnect()
			dragConn = nil
		end
	end

	handle.InputBegan:Connect(function(inp)
		local t = inp.UserInputType
		if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
			dragging   = true
			startPos   = inp.Position
			startFrame = frame.Position

			if dragConn then dragConn:Disconnect() end
			dragConn = UserInputService.InputChanged:Connect(function(moveInp)
				local mt = moveInp.UserInputType
				if dragging and (mt == Enum.UserInputType.MouseMovement or mt == Enum.UserInputType.Touch) then
					local delta = moveInp.Position - startPos
					frame.Position = UDim2.new(
						startFrame.X.Scale, startFrame.X.Offset + delta.X,
						startFrame.Y.Scale, startFrame.Y.Offset + delta.Y
					)
				end
			end)

			inp.Changed:Connect(function()
				if inp.UserInputState == Enum.UserInputState.End then
					stopDrag()
				end
			end)
		end
	end)

	handle.InputEnded:Connect(function(inp)
		local t = inp.UserInputType
		if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
			stopDrag()
		end
	end)
end

----------------------------------------------------------------------
-- PanelLib
----------------------------------------------------------------------
local PanelLib = {}

function PanelLib:CreatePanel(cfg)
	cfg = cfg or {}

	local width    = cfg.Width    or 230
	local position = cfg.Position or "topright"
	local accent   = cfg.Accent   or Theme.Accent
	local title    = cfg.Title

	local connections = {}
	local function track(conn)
		table.insert(connections, conn)
		return conn
	end

	-- ScreenGui
	local gui = Instance.new("ScreenGui")
	gui.Name           = title and (title .. "Panel") or "PanelLib"
	gui.ResetOnSpawn   = false
	gui.IgnoreGuiInset = true
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.DisplayOrder   = 997
	gui.Enabled        = true
	gui.Parent         = getGui()

	-- Root
	local root = Instance.new("Frame")
	root.Name                   = "Root"
	root.BackgroundColor3        = Theme.Background
	root.BackgroundTransparency = 0.04
	root.BorderSizePixel        = 0
	root.Size                   = UDim2.new(0, width, 0, 0)
	root.AutomaticSize          = Enum.AutomaticSize.Y
	root.Position               = anchorPosition(position, width)
	root.Parent                 = gui
	corner(root, 10)
	stroke(root, Theme.Stroke, 0.5, 1)

	-- Settings Overlay
	local settingsOverlay = Instance.new("Frame")
	settingsOverlay.Name                   = "SettingsOverlay"
	settingsOverlay.BackgroundColor3        = Theme.Background
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

	local overlayPad = Instance.new("UIPadding")
	overlayPad.PaddingTop    = UDim.new(0, PADDING)
	overlayPad.PaddingBottom = UDim.new(0, PADDING)
	overlayPad.PaddingLeft   = UDim.new(0, PADDING)
	overlayPad.PaddingRight  = UDim.new(0, PADDING)
	overlayPad.Parent        = settingsOverlay

	local overlayLayout = Instance.new("UIListLayout")
	overlayLayout.Padding    = UDim.new(0, 6)
	overlayLayout.SortOrder = Enum.SortOrder.LayoutOrder
	overlayLayout.Parent    = settingsOverlay

	makeLabel(settingsOverlay, "ACCENT COLOUR", FONT_MED, 10, Theme.SubText, nil, UDim2.new(1, 0, 0, 16)):SetAttribute("Order", 1)

	local colourGrid = Instance.new("Frame")
	colourGrid.BackgroundTransparency = 1
	colourGrid.Size                   = UDim2.new(1, 0, 0, 0)
	colourGrid.AutomaticSize          = Enum.AutomaticSize.Y
	colourGrid.LayoutOrder            = 2
	colourGrid.Parent                 = settingsOverlay

	local colourGridLayout = Instance.new("UIGridLayout")
	colourGridLayout.CellSize             = UDim2.new(0, 26, 0, 26)
	colourGridLayout.CellPadding          = UDim2.new(0, 5, 0, 5)
	colourGridLayout.SortOrder            = Enum.SortOrder.LayoutOrder
	colourGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	colourGridLayout.Parent              = colourGrid

	local activeSwatchStroke = nil
	local presetOrder        = { "Default", "Pink", "Green", "Red", "Purple", "Orange", "Teal", "White" }

	for i, name in ipairs(presetOrder) do
		local color  = Presets[name].Accent
		local swatch = Instance.new("TextButton")
		swatch.BackgroundColor3 = color
		swatch.BorderSizePixel  = 0
		swatch.Text             = ""
		swatch.AutoButtonColor  = false
		swatch.LayoutOrder      = i
		swatch.Size             = UDim2.new(0, 26, 0, 26)
		swatch.Parent           = colourGrid
		corner(swatch, 6)

		swatch.Activated:Connect(function()
			accent = color
			if activeSwatchStroke then activeSwatchStroke:Destroy() end
			local sel = stroke(swatch, color, 0, 2)
			activeSwatchStroke = sel
		end)
	end

	makeLabel(settingsOverlay, "OPACITY", FONT_MED, 10, Theme.SubText, nil, UDim2.new(1, 0, 0, 16)):SetAttribute("Order", 3)

	local opacityRow = Instance.new("Frame")
	opacityRow.BackgroundTransparency = 1
	opacityRow.Size                   = UDim2.new(1, 0, 0, 24)
	opacityRow.LayoutOrder            = 4
	opacityRow.Parent                 = settingsOverlay

	local opacityTrack = Instance.new("Frame")
	opacityTrack.BackgroundColor3 = Theme.Off
	opacityTrack.Position         = UDim2.new(0, 0, 0.5, -3)
	opacityTrack.Size             = UDim2.new(1, -40, 0, 5)
	opacityTrack.BorderSizePixel  = 0
	opacityTrack.Parent           = opacityRow
	corner(opacityTrack, 3)

	local opacityFill = Instance.new("Frame")
	opacityFill.BackgroundColor3 = Theme.Accent
	opacityFill.Size             = UDim2.new(0.96, 0, 1, 0)
	opacityFill.BorderSizePixel  = 0
	opacityFill.Parent           = opacityTrack
	corner(opacityFill, 3)

	local opacityKnob = Instance.new("Frame")
	opacityKnob.BackgroundColor3 = Theme.Text
	opacityKnob.AnchorPoint      = Vector2.new(0.5, 0.5)
	opacityKnob.Position         = UDim2.new(0.96, 0, 0.5, 0)
	opacityKnob.Size             = UDim2.fromOffset(12, 12)
	opacityKnob.BorderSizePixel  = 0
	opacityKnob.ZIndex           = 2
	opacityKnob.Parent           = opacityTrack
	corner(opacityKnob, 6)

	local opacityLbl = makeLabel(opacityRow, "96%", FONT_BOLD, 11, Theme.SubText, UDim2.new(1, 0, 0.5, 0), UDim2.new(0, 34, 1, 0), Enum.TextXAlignment.Right)
	opacityLbl.AnchorPoint = Vector2.new(1, 0.5)

	local opacityDragging = false
	local function applyOpacity(alpha)
		local pct = math.clamp(math.floor(alpha * 100 + 0.5), 20, 100)
		alpha = pct / 100
		opacityFill.Size            = UDim2.new(alpha, 0, 1, 0)
		opacityKnob.Position        = UDim2.new(alpha, 0, 0.5, 0)
		opacityLbl.Text             = pct .. "%"
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

	makeLabel(settingsOverlay, "POSITION", FONT_MED, 10, Theme.SubText, nil, UDim2.new(1, 0, 0, 16)):SetAttribute("Order", 5)

	local posGrid = Instance.new("Frame")
	posGrid.BackgroundTransparency = 1
	posGrid.Size                   = UDim2.new(1, 0, 0, 0)
	posGrid.AutomaticSize          = Enum.AutomaticSize.Y
	posGrid.LayoutOrder            = 6
	posGrid.Parent                 = settingsOverlay

	local posGridLayout = Instance.new("UIGridLayout")
	posGridLayout.CellSize    = UDim2.new(0.5, -3, 0, 26)
	posGridLayout.CellPadding = UDim2.new(0, 5, 0, 5)
	posGridLayout.SortOrder   = Enum.SortOrder.LayoutOrder
	posGridLayout.Parent      = posGrid

	local posLabels = { "Top Right", "Top Left", "Bottom Right", "Bottom Left" }
	local posKeys   = { "topright",  "topleft",  "bottomright",  "bottomleft"  }

	for i, lbl in ipairs(posLabels) do
		local pb = Instance.new("TextButton")
		pb.BackgroundColor3 = Theme.Row
		pb.AutoButtonColor  = false
		pb.BorderSizePixel  = 0
		pb.Text             = lbl
		pb.FontFace         = FONT_MED
		pb.TextColor3       = Theme.SubText
		pb.TextSize         = 11
		pb.LayoutOrder      = i
		pb.Parent           = posGrid
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

	-- Title Bar
	local titleBar
	local settingsOpen = false

	if title then
		titleBar = Instance.new("Frame")
		titleBar.Name                   = "TitleBar"
		titleBar.BackgroundColor3        = Theme.Surface
		titleBar.BackgroundTransparency = 0.02
		titleBar.BorderSizePixel        = 0
		titleBar.Size                   = UDim2.new(1, 0, 0, 34)
		titleBar.ZIndex                 = 5
		titleBar.Parent                 = root
		corner(titleBar, 10)

		local flush = Instance.new("Frame")
		flush.BackgroundColor3        = Theme.Surface
		flush.BackgroundTransparency = 0.02
		flush.BorderSizePixel        = 0
		flush.Position               = UDim2.new(0, 0, 0.5, 0)
		flush.Size                   = UDim2.new(1, 0, 0.5, 0)
		flush.ZIndex                 = 5
		flush.Parent                 = titleBar

		stroke(titleBar, Theme.Stroke, 0.55, 1)

		local accentBar = Instance.new("Frame")
		accentBar.BackgroundColor3 = accent
		accentBar.BorderSizePixel  = 0
		accentBar.Position         = UDim2.new(0, 0, 0.2, 0)
		accentBar.Size             = UDim2.new(0, 2, 0.6, 0)
		accentBar.ZIndex           = 6
		accentBar.Parent           = titleBar
		corner(accentBar, 2)

		local titleLbl = makeLabel(titleBar, title, FONT_BOLD, 12, Theme.Text, UDim2.new(0, 14, 0, 0), UDim2.new(1, -50, 1, 0))
		titleLbl.ZIndex = 6

		local settingsBtn = Instance.new("TextButton")
		settingsBtn.BackgroundColor3        = Theme.Row
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
		settingsBtn.Parent                 = titleBar
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

	-- Body Content Container
	local body = Instance.new("Frame")
	body.Name                   = "Body"
	body.BackgroundTransparency = 1
	body.BorderSizePixel        = 0
	body.Position               = UDim2.new(0, 0, 0, title and 34 or 0)
	body.Size                   = UDim2.new(1, 0, 0, 0)
	body.AutomaticSize          = Enum.AutomaticSize.Y
	body.Parent                 = root

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding    = UDim.new(0, ROW_GAP)
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent    = body

	local bodyPad = Instance.new("UIPadding")
	bodyPad.PaddingTop    = UDim.new(0, PADDING)
	bodyPad.PaddingBottom = UDim.new(0, PADDING)
	bodyPad.PaddingLeft   = UDim.new(0, PADDING)
	bodyPad.PaddingRight  = UDim.new(0, PADDING)
	bodyPad.Parent        = body

	--------------------------------------------------------------
	-- Panel API & Components
	--------------------------------------------------------------
	local Panel  = {}
	local _order = 0

	local function nextOrder()
		_order += 1
		return _order
	end

	local function newRow(height, transparent)
		local row = Instance.new("Frame")
		row.BackgroundColor3        = transparent and Color3.new() or Theme.Row
		row.BackgroundTransparency = transparent and 1 or 0
		row.BorderSizePixel        = 0
		row.Size                   = UDim2.new(1, 0, 0, height or ROW_HEIGHT)
		row.LayoutOrder            = nextOrder()
		row.Parent                 = body
		if not transparent then corner(row, 6) end
		return row
	end

	function Panel:Destroy()
		for _, conn in ipairs(connections) do
			if conn and conn.Connected then
				conn:Disconnect()
			end
		end
		table.clear(connections)
		gui:Destroy()
	end

	function Panel:Label(text)
		local row = newRow(16, true)
		local lbl = makeLabel(row, text or "", FONT_MED, 10, Theme.SubText)

		return {
			Set      = function(_, t) lbl.Text = t end,
			Instance = row,
		}
	end

	function Panel:Warning(text)
		local row = newRow(ROW_HEIGHT, true)
		row.AutomaticSize          = Enum.AutomaticSize.Y
		row.BackgroundColor3        = Color3.fromRGB(34, 26, 12)
		row.BackgroundTransparency = 0
		corner(row, 6)
		stroke(row, Theme.Warning, 0.5, 1)

		local pad = Instance.new("UIPadding")
		pad.PaddingLeft   = UDim.new(0, 8)
		pad.PaddingRight  = UDim.new(0, 8)
		pad.PaddingTop    = UDim.new(0, 6)
		pad.PaddingBottom = UDim.new(0, 6)
		pad.Parent        = row

		local lbl = makeLabel(row, "⚠  " .. (text or ""), FONT_MED, 11, Theme.Warning)
		lbl.TextWrapped   = true
		lbl.AutomaticSize = Enum.AutomaticSize.Y
		lbl.Size          = UDim2.new(1, 0, 0, 0)

		return {
			Set      = function(_, t) lbl.Text = "⚠  " .. t end,
			Instance = row,
		}
	end

	function Panel:Stat(name, value, accentColor)
		local row = newRow(ROW_HEIGHT)

		makeLabel(row, name or "Stat", FONT_REG, 11, Theme.SubText, UDim2.new(0, 8, 0, 0), UDim2.new(0.55, -8, 1, 0))
		local valLbl = makeLabel(row, tostring(value or "-"), FONT_BOLD, 11, accentColor or accent, UDim2.new(0.45, 0, 0, 0), UDim2.new(0.55, -8, 1, 0), Enum.TextXAlignment.Right)

		return {
			Set      = function(_, v) valLbl.Text = tostring(v) end,
			Get      = function() return valLbl.Text end,
			Instance = row,
		}
	end

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

	function Panel:Toggle(name, default, callback)
		local state = default or false
		local row   = newRow(ROW_HEIGHT)

		local hitbox = Instance.new("TextButton")
		hitbox.BackgroundTransparency = 1
		hitbox.Text = ""
		hitbox.Size = UDim2.new(1, 0, 1, 0)
		hitbox.Parent = row

		makeLabel(hitbox, name or "Toggle", FONT_MED, 11, Theme.Text, UDim2.new(0, 8, 0, 0), UDim2.new(1, -52, 1, 0))

		local toggleTrack = Instance.new("Frame")
		toggleTrack.BackgroundColor3 = state and accent or Theme.Off
		toggleTrack.AnchorPoint      = Vector2.new(1, 0.5)
		toggleTrack.Position         = UDim2.new(1, -8, 0.5, 0)
		toggleTrack.Size             = UDim2.fromOffset(34, 17)
		toggleTrack.BorderSizePixel  = 0
		toggleTrack.Parent           = hitbox
		corner(toggleTrack, 9)

		local knob = Instance.new("Frame")
		knob.BackgroundColor3 = Theme.Text
		knob.AnchorPoint      = Vector2.new(0, 0.5)
		knob.Position         = state and UDim2.new(1, -15, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
		knob.Size             = UDim2.fromOffset(13, 13)
		knob.BorderSizePixel  = 0
		knob.Parent           = toggleTrack
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

	function Panel:Slider(name, min, max, default, step, callback)
		if type(step) == "function" then
			callback = step
			step = nil
		end
		min     = min     or 0
		max     = max     or 100
		default = math.clamp(default or min, min, max)

		local row = newRow(46)

		makeLabel(row, name or "Slider", FONT_MED, 11, Theme.Text, UDim2.new(0, 8, 0, 5), UDim2.new(0.65, -8, 0, 16))

		local valLbl = makeLabel(row, tostring(default), FONT_BOLD, 11, accent, UDim2.new(1, -8, 0, 5), UDim2.new(0.35, -8, 0, 16), Enum.TextXAlignment.Right)
		valLbl.AnchorPoint = Vector2.new(1, 0)

		local sliderTrack = Instance.new("Frame")
		sliderTrack.BackgroundColor3 = Theme.Off
		sliderTrack.Position         = UDim2.new(0, 8, 0, 32)
		sliderTrack.Size             = UDim2.new(1, -16, 0, 5)
		sliderTrack.BorderSizePixel  = 0
		sliderTrack.Parent           = row
		corner(sliderTrack, 3)

		local fill = Instance.new("Frame")
		fill.BackgroundColor3 = accent
		fill.Size             = UDim2.new((default - min) / (max - min), 0, 1, 0)
		fill.BorderSizePixel  = 0
		fill.Parent           = sliderTrack
		corner(fill, 3)

		local knob = Instance.new("Frame")
		knob.BackgroundColor3 = Theme.Text
		knob.AnchorPoint      = Vector2.new(0.5, 0.5)
		knob.Position         = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
		knob.Size             = UDim2.fromOffset(12, 12)
		knob.BorderSizePixel  = 0
		knob.ZIndex           = 2
		knob.Parent           = sliderTrack
		corner(knob, 6)

		local value    = default
		local dragging = false

		local function apply(a)
			local raw = min + (max - min) * a
			if step and step > 0 then
				value = math.clamp(math.floor(raw / step + 0.5) * step, min, max)
			else
				value = math.clamp(math.floor(raw + 0.5), min, max)
			end
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

	function Panel:ProgressBar(name, maxVal, accentColor)
		maxVal = maxVal or 100
		local value = 0
		local activeColor = accentColor or accent
		local row = newRow(46)

		makeLabel(row, name or "Progress", FONT_MED, 11, Theme.Text, UDim2.new(0, 8, 0, 5), UDim2.new(0.65, -8, 0, 16))

		local valLbl = makeLabel(row, "0%", FONT_BOLD, 11, activeColor, UDim2.new(1, -8, 0, 5), UDim2.new(0.35, -8, 0, 16), Enum.TextXAlignment.Right)
		valLbl.AnchorPoint = Vector2.new(1, 0)

		local progressTrack = Instance.new("Frame")
		progressTrack.BackgroundColor3 = Theme.Off
		progressTrack.Position         = UDim2.new(0, 8, 0, 32)
		progressTrack.Size             = UDim2.new(1, -16, 0, 5)
		progressTrack.BorderSizePixel  = 0
		progressTrack.Parent           = row
		corner(progressTrack, 3)

		local fill = Instance.new("Frame")
		fill.BackgroundColor3 = activeColor
		fill.Size             = UDim2.new(0, 0, 1, 0)
		fill.BorderSizePixel  = 0
		fill.Parent           = progressTrack
		corner(fill, 3)

		local api = {}
		function api:Set(v)
			value = math.clamp(v, 0, maxVal)
			local alpha = maxVal > 0 and (value / maxVal) or 0
			tween(fill, TI_S, { Size = UDim2.new(alpha, 0, 1, 0) })
			valLbl.Text = math.floor(alpha * 100 + 0.5) .. "%"
		end
		function api:Get() return value end
		api.Instance = row
		return api
	end

	function Panel:Dropdown(name, options, default, callback)
		options = options or {}
		local selected = default or options[1] or ""
		local isOpen = false

		local container = Instance.new("Frame")
		container.BackgroundColor3 = Theme.Row
		container.BorderSizePixel  = 0
		container.ClipsDescendants = true
		container.Size             = UDim2.new(1, 0, 0, ROW_HEIGHT)
		container.LayoutOrder      = nextOrder()
		container.Parent           = body
		corner(container, 6)

		local header = Instance.new("TextButton")
		header.BackgroundTransparency = 1
		header.Text                   = ""
		header.Size                   = UDim2.new(1, 0, 0, ROW_HEIGHT)
		header.Parent                 = container

		makeLabel(header, name or "Dropdown", FONT_MED, 11, Theme.Text, UDim2.new(0, 8, 0, 0), UDim2.new(0.5, -8, 1, 0))

		local selLbl = makeLabel(header, tostring(selected) .. "  ▼", FONT_MED, 11, accent, UDim2.new(0.5, 0, 0, 0), UDim2.new(0.5, -8, 1, 0), Enum.TextXAlignment.Right)

		local listFrame = Instance.new("Frame")
		listFrame.BackgroundTransparency = 1
		listFrame.Position               = UDim2.new(0, 0, 0, ROW_HEIGHT)
		listFrame.Size                   = UDim2.new(1, 0, 0, #options * ROW_HEIGHT)
		listFrame.Parent                 = container

		local listLayout = Instance.new("UIListLayout")
		listLayout.SortOrder = Enum.SortOrder.LayoutOrder
		listLayout.Parent    = listFrame

		local function updateDropdown()
			local targetH = isOpen and (ROW_HEIGHT + #options * ROW_HEIGHT) or ROW_HEIGHT
			tween(container, TI, { Size = UDim2.new(1, 0, 0, targetH) })
			selLbl.Text = tostring(selected) .. (isOpen and "  ▲" or "  ▼")
		end

		for i, opt in ipairs(options) do
			local optBtn = Instance.new("TextButton")
			optBtn.BackgroundColor3 = Theme.Row
			optBtn.AutoButtonColor  = false
			optBtn.BorderSizePixel  = 0
			optBtn.Text             = tostring(opt)
			optBtn.FontFace         = FONT_REG
			optBtn.TextColor3       = (opt == selected) and accent or Theme.SubText
			optBtn.TextSize         = 11
			optBtn.Size             = UDim2.new(1, 0, 0, ROW_HEIGHT)
			optBtn.LayoutOrder      = i
			optBtn.Parent           = listFrame

			optBtn.MouseEnter:Connect(function() tween(optBtn, TI, { BackgroundColor3 = Theme.RowHover }) end)
			optBtn.MouseLeave:Connect(function() tween(optBtn, TI, { BackgroundColor3 = Theme.Row }) end)
			optBtn.Activated:Connect(function()
				selected = opt
				isOpen = false
				updateDropdown()
				for _, child in ipairs(listFrame:GetChildren()) do
					if child:IsA("TextButton") then
						child.TextColor3 = (child.Text == tostring(selected)) and accent or Theme.SubText
					end
				end
				if callback then task.spawn(callback, selected) end
			end)
		end

		header.Activated:Connect(function()
			isOpen = not isOpen
			updateDropdown()
		end)

		local api = {}
		function api:Set(v)
			selected = v
			selLbl.Text = tostring(selected) .. (isOpen and "  ▲" or "  ▼")
			if callback then task.spawn(callback, selected) end
		end
		function api:Get() return selected end
		api.Instance = container
		return api
	end

	function Panel:TextBox(placeholder, default, callback)
		local row = newRow(ROW_HEIGHT)

		local tb = Instance.new("TextBox")
		tb.BackgroundTransparency = 1
		tb.Text                   = default or ""
		tb.PlaceholderText        = placeholder or "Type here..."
		tb.PlaceholderColor3      = Theme.SubText
		tb.FontFace               = FONT_MED
		tb.TextColor3             = Theme.Text
		tb.TextSize               = 11
		tb.TextXAlignment         = Enum.TextXAlignment.Left
		tb.Position               = UDim2.new(0, 8, 0, 0)
		tb.Size                   = UDim2.new(1, -16, 1, 0)
		tb.ClearTextOnFocus       = false
		tb.Parent                 = row

		tb.FocusLost:Connect(function(enterPressed)
			if callback then task.spawn(callback, tb.Text, enterPressed) end
		end)

		return {
			Set      = function(_, t) tb.Text = t end,
			Get      = function() return tb.Text end,
			Instance = row,
		}
	end

	function Panel:Keybind(name, defaultKey, callback)
		local currentKey = defaultKey or Enum.KeyCode.Unknown
		local binding = false
		local row = newRow(ROW_HEIGHT)

		makeLabel(row, name or "Keybind", FONT_MED, 11, Theme.Text, UDim2.new(0, 8, 0, 0), UDim2.new(0.6, -8, 1, 0))

		local keyBtn = Instance.new("TextButton")
		keyBtn.BackgroundColor3 = Theme.Off
		keyBtn.AutoButtonColor  = false
		keyBtn.BorderSizePixel  = 0
		keyBtn.Text             = currentKey.Name
		keyBtn.FontFace         = FONT_BOLD
		keyBtn.TextColor3       = accent
		keyBtn.TextSize         = 10
		keyBtn.AnchorPoint      = Vector2.new(1, 0.5)
		keyBtn.Position         = UDim2.new(1, -8, 0.5, 0)
		keyBtn.Size             = UDim2.fromOffset(60, 20)
		keyBtn.Parent           = row
		corner(keyBtn, 4)

		keyBtn.Activated:Connect(function()
			binding = true
			keyBtn.Text = "..."
		end)

		track(UserInputService.InputBegan:Connect(function(inp, gpe)
			if binding then
				if inp.UserInputType == Enum.UserInputType.Keyboard then
					currentKey = inp.KeyCode
					binding = false
					keyBtn.Text = currentKey.Name
				end
			elseif not gpe and inp.KeyCode == currentKey then
				if callback then task.spawn(callback, currentKey) end
			end
		end))

		return {
			Set      = function(_, k) currentKey = k; keyBtn.Text = k.Name end,
			Get      = function() return currentKey end,
			Instance = row,
		}
	end

	return Panel
end

return PanelLib
