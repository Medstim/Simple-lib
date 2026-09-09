# PanelLib

A lightweight Roblox Lua library for building clean, dark floating panels. No dependencies, executor-compatible, single file.

---

## Load

```lua
local PanelLib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/YOUR_NAME/YOUR_REPO/main/PanelLib.lua"
))()
```

---

## Creating a Panel

```lua
local Panel = PanelLib:CreatePanel({
    Title    = "My Panel",   -- string  | omit for no title bar
    Position = "topright",   -- string  | topright, topleft, bottomright, bottomleft
    Width    = 220,          -- number  | default: 220
    Accent   = Color3.fromRGB(100, 160, 255), -- Color3 | default: blue
})
```

---

## Elements

### Label
A small muted section header. No background.

```lua
local lbl = Panel:Label("── Section ──")

lbl:Set("── Updated ──")
```

---

### Warning
An amber highlighted row for notices.

```lua
local warn = Panel:Warning("These are local-only spoofs.")

warn:Set("Updated warning text.")
```

---

### Stat
A key/value row for displaying live data.

```lua
-- Panel:Stat(name, defaultValue, accentColor)
local throws = Panel:Stat("Throws", "-")
local coins  = Panel:Stat("Coins",  0, Color3.fromRGB(240, 180, 75))

throws:Set(48291)
print(throws:Get()) -- "48291"
```

| Param | Type | Description |
|-------|------|-------------|
| `name` | `string` | Left-side label |
| `defaultValue` | `any` | Initial value shown on the right |
| `accentColor` | `Color3` | Optional. Overrides the panel accent for this row |

---

### Button
A clickable row that flashes accent on press.

```lua
-- Panel:Button(name, callback)
Panel:Button("Reset Character", function()
    game.Players.LocalPlayer.Character.Humanoid.Health = 0
end)
```

---

### Toggle
An on/off switch with an animated knob.

```lua
-- Panel:Toggle(name, default, callback)
local speedToggle = Panel:Toggle("Speed Hack", false, function(state)
    local hum = game.Players.LocalPlayer.Character.Humanoid
    hum.WalkSpeed = state and 60 or 16
end)

speedToggle:Set(true)    -- turn on, fires callback
speedToggle:Set(false)   -- turn off, fires callback
print(speedToggle:Get()) -- true / false
```

| Param | Type | Description |
|-------|------|-------------|
| `name` | `string` | Label text |
| `default` | `boolean` | Starting state |
| `callback` | `function(state: boolean)` | Fires on every change |

---

### Slider
A draggable slider that snaps to whole numbers.

```lua
-- Panel:Slider(name, min, max, default, callback)
local ws = Panel:Slider("Walk Speed", 16, 200, 16, function(value)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
end)

ws:Set(60)
print(ws:Get()) -- 60
```

| Param | Type | Description |
|-------|------|-------------|
| `name` | `string` | Label text |
| `min` | `number` | Minimum value |
| `max` | `number` | Maximum value |
| `default` | `number` | Starting value |
| `callback` | `function(value: number)` | Fires while dragging |

---

### Divider
A thin horizontal line for separating sections.

```lua
Panel:Divider()
```

---

## Panel Controls

```lua
Panel:Show()             -- make the panel visible
Panel:Hide()             -- hide the panel
Panel:Toggle()           -- toggle visibility
Panel:Destroy()          -- remove the panel entirely
Panel:SetAccent(color)   -- change the accent Color3 at runtime
```

---

## Full Example

```lua
local PanelLib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/YOUR_NAME/YOUR_REPO/main/PanelLib.lua"
))()

local plr = game.Players.LocalPlayer

local Panel = PanelLib:CreatePanel({
    Title    = "Stats",
    Position = "topright",
    Width    = 220,
    Accent   = Color3.fromRGB(100, 160, 255),
})

-- Stats
Panel:Label("── Leaderboard ──")
local throwsStat = Panel:Stat("Throws", "-", Color3.fromRGB(240, 180, 75))

Panel:Divider()

-- Controls
Panel:Label("── Settings ──")

Panel:Toggle("Speed Hack", false, function(state)
    local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = state and 60 or 16 end
end)

Panel:Slider("Walk Speed", 16, 200, 16, function(value)
    local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = value end
end)

Panel:Button("Reset Character", function()
    plr.Character.Humanoid.Health = 0
end)

Panel:Divider()
Panel:Warning("Use at your own risk.")

-- Live throws update
task.spawn(function()
    local ls = plr:WaitForChild("leaderstats")
    throwsStat:Set(ls.Throws.Value)
    ls.Throws:GetPropertyChangedSignal("Value"):Connect(function()
        throwsStat:Set(ls.Throws.Value)
    end)
end)

-- Toggle panel with RightAlt
game:GetService("UserInputService").InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == Enum.KeyCode.RightAlt then
        Panel:Toggle()
    end
end)
```

---

## Notes

- **Position** options: `topright`, `topleft`, `bottomright`, `bottomleft` — anchors with a 16px margin from the screen edge.
- **Accent colour** applies to stat values, slider fills, and toggle knobs. Override per-stat using the optional third argument on `Panel:Stat()`.
- **Title bar** is optional — omit `Title` from `CreatePanel` for a borderless panel with no header.
- **Executor compat** — the library resolves `gethui`, `cloneref`, and `CoreGui` automatically across common executors.
