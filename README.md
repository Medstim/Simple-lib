# PanelLib

A lightweight Roblox Lua library for building clean, dark floating panels. No dependencies, executor-compatible, single file.

---

## Load

```lua
local PanelLib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Medstim/Simple-lib/refs/heads/main/MainSrc2.0.lua"
))()
```

---

## Creating a Panel

```lua
local Panel = PanelLib:CreatePanel({
    Title    = "My Panel",   -- string  | omit for no title bar
    Position = "topright",   -- string  | topright, topleft, bottomright, bottomleft
    Width    = 230,          -- number  | default: 230
    Accent   = Color3.fromRGB(100, 160, 255), -- Color3 | default: blue
})
```

Providing a `Title` enables two extra features automatically:
- **Dragging** — the title bar becomes a drag handle
- **Settings overlay** — a ⚙ gear button appears in the top-right corner of the title bar (see [Settings Overlay](#settings-overlay))

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

> ⚠ **Known issue:** `Panel:Toggle` is defined twice — once as the UI element constructor and once as the panel visibility control. The second definition overwrites the first, so calling `Panel:Toggle(name, default, callback)` after `CreatePanel` returns will toggle panel visibility instead of adding a toggle element. A rename fix is planned.

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

### ProgressBar
A read-only bar for displaying progress toward a maximum value. Animates on update.

```lua
-- Panel:ProgressBar(name, max, accentColor)
local xpBar = Panel:ProgressBar("XP", 1000)
local hpBar = Panel:ProgressBar("Health", 100, Color3.fromRGB(100, 220, 100))

xpBar:Set(450)
print(xpBar:Get()) -- 450
```

| Param | Type | Description |
|-------|------|-------------|
| `name` | `string` | Label text |
| `max` | `number` | Maximum value (default: 100) |
| `accentColor` | `Color3` | Optional. Overrides the panel accent for this bar |

The value label shows `current / max` (e.g. `450 / 1000`). Values are clamped to `[0, max]`.

---

### Divider
A thin horizontal line for separating sections.

```lua
Panel:Divider()
```

---

## Panel Controls

```lua
Panel:Show()                -- make the panel visible (fades in)
Panel:Hide()                -- fade out and disable the panel (0.25 s fade)
Panel:Toggle()              -- toggle visibility (conflicts with Toggle element — see above)
Panel:Destroy()             -- disconnect all connections and remove the ScreenGui
Panel:SetAccent(color)      -- change the accent Color3 at runtime
Panel:SetPosition(pos)      -- move the panel to a named anchor ("topright", "topleft", etc.)
Panel:SetTitle(text)        -- update the title bar label text
Panel:GetVisible()          -- returns true if the panel is currently enabled
```

---

## Settings Overlay

When a `Title` is provided, the panel gains a **⚙ gear button** in the title bar. Clicking it opens an overlay panel with three live controls — no code required:

### Accent Colour
A grid of colour swatches, one per built-in preset. Clicking a swatch applies that accent immediately and highlights it with a matching border.

| Preset | Colour |
|--------|--------|
| Default | `RGB(100, 160, 255)` — blue |
| Pink | `RGB(255, 100, 220)` |
| Green | `RGB(80, 200, 120)` |
| Red | `RGB(220, 70, 70)` |
| Purple | `RGB(160, 100, 255)` |
| Orange | `RGB(255, 150, 60)` |
| Teal | `RGB(60, 210, 190)` |
| White | `RGB(220, 220, 220)` |

### Opacity
A slider from 20 % to 100 % that adjusts the panel's background opacity in real time.

### Position
Four buttons — Top Right, Top Left, Bottom Right, Bottom Left — that reposition the panel to the chosen screen corner instantly.

---

## Customisation

### Accent colour
The accent colour affects slider fills, toggle tracks, progress bars, and stat values. Set it at creation, at runtime, or let the user pick from the settings overlay.

```lua
-- At creation
local Panel = PanelLib:CreatePanel({
    Accent = Color3.fromRGB(255, 100, 100),
})

-- At runtime
Panel:SetAccent(Color3.fromRGB(100, 255, 160))
```

Individual stats and progress bars can pin their own colour regardless of the panel accent:

```lua
local coins = Panel:Stat("Coins", 0, Color3.fromRGB(240, 180, 75))
local hp    = Panel:ProgressBar("HP", 100, Color3.fromRGB(100, 220, 100))
```

### Theme (internal)
The rest of the visual style is controlled by a `Theme` table inside the module. It is **not currently exposed** in the public API and must be edited directly in the source to change.

| Key | Default | Used for |
|-----|---------|----------|
| `Background` | `RGB(12, 12, 12)` | Root panel background |
| `Surface` | `RGB(18, 18, 18)` | Title bar background |
| `Row` | `RGB(24, 24, 24)` | Element row background |
| `RowHover` | `RGB(32, 32, 32)` | Button / position-picker hover state |
| `Stroke` | `RGB(45, 45, 45)` | Border and divider lines |
| `Text` | `RGB(225, 225, 225)` | Primary text, slider/toggle knobs |
| `SubText` | `RGB(110, 110, 110)` | Stat name labels, section labels, gear icon |
| `Accent` | `RGB(100, 160, 255)` | Default accent (overridable) |
| `Off` | `RGB(50, 50, 50)` | Toggle track (off state), slider/progress track |
| `Warning` | `RGB(255, 190, 70)` | Warning text and border |

---

## Full Example

```lua
local PanelLib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Medstim/Simple-lib/refs/heads/main/MainSrc2.0.lua"
))()

local plr = game.Players.LocalPlayer

local Panel = PanelLib:CreatePanel({
    Title    = "Stats",
    Position = "topright",
    Width    = 230,
    Accent   = Color3.fromRGB(100, 160, 255),
})

-- Stats
Panel:Label("── Leaderboard ──")
local throwsStat = Panel:Stat("Throws", "-", Color3.fromRGB(240, 180, 75))
local xpBar      = Panel:ProgressBar("XP", 1000)

Panel:Divider()

-- Controls
Panel:Label("── Settings ──")

Panel:Slider("Walk Speed", 16, 200, 16, function(value)
    local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = value end
end)

Panel:Button("Reset Character", function()
    plr.Character.Humanoid.Health = 0
end)

Panel:Divider()
Panel:Warning("Use at your own risk.")

-- Live stat updates
task.spawn(function()
    local ls = plr:WaitForChild("leaderstats")
    throwsStat:Set(ls.Throws.Value)
    ls.Throws:GetPropertyChangedSignal("Value"):Connect(function()
        throwsStat:Set(ls.Throws.Value)
    end)
end)

-- Toggle panel visibility with RightAlt
game:GetService("UserInputService").InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == Enum.KeyCode.RightAlt then
        Panel:Toggle()
    end
end)
```

---

## Notes

- **Position** options: `topright`, `topleft`, `bottomright`, `bottomleft` — 16 px margin from the screen edge.
- **Dragging** — panels with a `Title` can be freely dragged by the title bar.
- **Settings overlay** — accent presets, opacity, and position picker are built in and require no extra code; available whenever `Title` is set.
- **Accent colour** applies to slider fills, toggle tracks, progress bars, and stat values. Override per-element using the optional `accentColor` argument.
- **Title bar** is optional — omit `Title` from `CreatePanel` for a compact, drag-free, settings-free panel.
- **Executor compat** — the library resolves `gethui`, `cloneref`, and `CoreGui` automatically across common executors.
- **Connection cleanup** — `Panel:Destroy()` disconnects all `UserInputService` listeners before destroying the GUI, preventing leaks.
- **Toggle naming conflict** — `Panel:Toggle()` currently refers to the visibility control only. The Toggle UI element constructor is shadowed by it and cannot be called from the returned Panel object. Rename fix planned.
