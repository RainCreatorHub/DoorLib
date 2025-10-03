--[[
  Roblox UI Library (Studio + Executor-friendly)
  - Fixed window size: 470 x 340
  - Tabs, Sections, and common controls (Buttons, Toggles, Sliders, Dropdowns, Textboxes, Keybinds)
  - Executor-friendly parenting (gethui/CoreGui fallback) and syn.protect_gui if available

  Usage (see examples/Example.client.lua):
    local UILibrary = require(path_to_module)
    local window = UILibrary.createWindow({
      title = "Minha UI",
      size = Vector2.new(470, 340),
      toggleKey = Enum.KeyCode.RightShift, -- hotkey to show/hide
      startOpen = true,                    -- start visible
    })
    local tab = window:AddTab("Principal")
    local section = tab:AddSection("Geral")
    section:AddButton("Dizer Olá", function() print("Olá!") end)

  Notes:
  - This library is intentionally built for legitimate Roblox Studio/client usage.
  - Parent preference order: gethui() -> CoreGui -> PlayerGui
--]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local function assertClient()
  if not RunService:IsClient() then
    error("UILibrary must be required from a LocalScript (client)")
  end
end

local function create(instanceClassName, props, children)
  local inst = Instance.new(instanceClassName)
  if props then
    for k, v in pairs(props) do
      inst[k] = v
    end
  end
  if children then
    for _, child in ipairs(children) do
      child.Parent = inst
    end
  end
  return inst
end

local function createRoundCorner(radius)
  return create("UICorner", { CornerRadius = UDim.new(0, radius) })
end

local function createStroke(color, thickness, transparency)
  return create("UIStroke", {
    Color = color,
    Thickness = thickness or 1,
    Transparency = transparency or 0,
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
  })
end

local function fromHex(hex)
  hex = hex:gsub("#", "")
  if (#hex == 3) then
    local r = tonumber(hex:sub(1,1)..hex:sub(1,1), 16)
    local g = tonumber(hex:sub(2,2)..hex:sub(2,2), 16)
    local b = tonumber(hex:sub(3,3)..hex:sub(3,3), 16)
    return Color3.fromRGB(r, g, b)
  elseif (#hex == 6) then
    local r = tonumber(hex:sub(1,2), 16)
    local g = tonumber(hex:sub(3,4), 16)
    local b = tonumber(hex:sub(5,6), 16)
    return Color3.fromRGB(r, g, b)
  end
  error("Invalid hex color: " .. tostring(hex))
end

local DEFAULT_THEME = {
  background = fromHex("#111215"),
  surface = fromHex("#181a1f"),
  surface2 = fromHex("#1f2229"),
  text = fromHex("#e5e7eb"),
  textDim = fromHex("#a3a6ad"),
  primary = fromHex("#4f46e5"),
  accent = fromHex("#22c55e"),
  danger = fromHex("#ef4444"),
  stroke = fromHex("#2a2e36"),
}

local PADDING = 10
local TITLEBAR_HEIGHT = 36
local TABBAR_HEIGHT = 32
local SECTION_HEADER_HEIGHT = 22
local CONTROL_HEIGHT = 30
local CONTROL_GAP = 8

local UILibrary = {}
UILibrary.__index = UILibrary

local Window = {}
Window.__index = Window

local Tab = {}
Tab.__index = Tab

local Section = {}
Section.__index = Section

-- Utility: drag a frame using UserInputService
local function enableDrag(frame, dragHandle)
  local dragging = false
  local dragStart
  local startPos

  dragHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
      dragging = true
      dragStart = input.Position
      startPos = frame.Position
      input.Changed:Connect(function()
        if input.UserInputState == Enum.UserInputState.End then
          dragging = false
        end
      end)
    end
  end)

  dragHandle.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
      local delta = input.Position - dragStart
      frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
  end)
end

-- Window API
function UILibrary.createWindow(options)
  assertClient()

  options = options or {}
  local title = options.title or "UI Library"
  local size = options.size or Vector2.new(470, 340)
  local theme = options.theme or DEFAULT_THEME
  local toggleKey = options.toggleKey or Enum.KeyCode.RightShift
  local startOpen = options.startOpen
  if startOpen == nil then startOpen = true end

  local player = Players.LocalPlayer
  local playerGui = player:WaitForChild("PlayerGui")

  local screenGui = create("ScreenGui", {
    Name = "UILibrary",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
  })

  -- Executor-friendly: protect and parent to hidden UI/CoreGui if available
  local function safeCall(fn)
    local ok, _ = pcall(fn)
    return ok
  end

  -- syn.protect_gui support if present
  safeCall(function()
    if syn and typeof(syn) == "table" and typeof(syn.protect_gui) == "function" then
      syn.protect_gui(screenGui)
    end
  end)

  local parented = false
  -- Try gethui() first
  safeCall(function()
    if gethui and typeof(gethui) == "function" then
      local hidden = gethui()
      if typeof(hidden) == "Instance" then
        screenGui.Parent = hidden
        parented = true
      end
    end
  end)

  -- Then try CoreGui
  if not parented then
    safeCall(function()
      local coreGui = game:GetService("CoreGui")
      screenGui.Parent = coreGui
      parented = true
    end)
  end

  -- Fallback to PlayerGui
  if not parented then
    screenGui.Parent = playerGui
  end

  -- Centered window
  local windowFrame = create("Frame", {
    Name = "Window",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.fromOffset(size.X, size.Y),
    BackgroundColor3 = theme.surface,
    BorderSizePixel = 0,
  }, {
    createRoundCorner(8),
    createStroke(theme.stroke, 1, 0.25),
  })
  windowFrame.Parent = screenGui

  -- Title bar
  local titleBar = create("Frame", {
    Name = "TitleBar",
    Size = UDim2.new(1, 0, 0, TITLEBAR_HEIGHT),
    BackgroundColor3 = theme.surface2,
    BorderSizePixel = 0,
  }, {
    createRoundCorner(8),
    createStroke(theme.stroke, 1, 0.15),
  })
  titleBar.Parent = windowFrame

  local titleLabel = create("TextLabel", {
    Name = "Title",
    BackgroundTransparency = 1,
    Size = UDim2.new(1, -2 * PADDING, 1, 0),
    Position = UDim2.new(0, PADDING, 0, 0),
    Font = Enum.Font.GothamBold,
    Text = title,
    TextSize = 16,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextColor3 = theme.text,
  })
  titleLabel.Parent = titleBar

  -- Close button
  local closeButton = create("TextButton", {
    Name = "Close",
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -PADDING, 0.5, 0),
    Size = UDim2.fromOffset(22, 22),
    BackgroundColor3 = theme.danger,
    Text = "",
    AutoButtonColor = true,
  }, {
    createRoundCorner(6),
  })
  closeButton.Parent = titleBar

  local closeIcon = create("TextLabel", {
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(1,1),
    Text = "✕",
    Font = Enum.Font.Gotham,
    TextSize = 14,
    TextColor3 = Color3.new(1,1,1),
  })
  closeIcon.Parent = closeButton

  -- Tab bar
  local tabBar = create("Frame", {
    Name = "TabBar",
    Size = UDim2.new(1, 0, 0, TABBAR_HEIGHT),
    Position = UDim2.new(0, 0, 0, TITLEBAR_HEIGHT),
    BackgroundColor3 = theme.surface,
    BorderSizePixel = 0,
  })
  tabBar.Parent = windowFrame

  local tabLayout = create("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    Padding = UDim.new(0, 6),
    SortOrder = Enum.SortOrder.LayoutOrder,
    HorizontalAlignment = Enum.HorizontalAlignment.Left,
    VerticalAlignment = Enum.VerticalAlignment.Center,
  })
  tabLayout.Parent = tabBar

  local tabPadding = create("UIPadding", {
    PaddingLeft = UDim.new(0, PADDING),
    PaddingRight = UDim.new(0, PADDING),
  })
  tabPadding.Parent = tabBar

  -- Content area
  local contentFrame = create("Frame", {
    Name = "Content",
    BackgroundColor3 = theme.background,
    BorderSizePixel = 0,
    Position = UDim2.new(0, 0, 0, TITLEBAR_HEIGHT + TABBAR_HEIGHT),
    Size = UDim2.new(1, 0, 1, -(TITLEBAR_HEIGHT + TABBAR_HEIGHT)),
  }, {
    createStroke(theme.stroke, 1, 0.5),
  })
  contentFrame.Parent = windowFrame

  local tabs = {}
  local activeTab

  local windowObj = setmetatable({
    _theme = theme,
    _screenGui = screenGui,
    _window = windowFrame,
    _titleBar = titleBar,
    _tabBar = tabBar,
    _content = contentFrame,
    _tabs = tabs,
    _activeTab = nil,
    _toggleKey = toggleKey,
    _connections = {},
  }, Window)

  enableDrag(windowFrame, titleBar)

  closeButton.MouseButton1Click:Connect(function()
    windowObj:SetOpen(false)
  end)

  -- Visibility
  windowObj:SetOpen(startOpen)

  -- Toggle hotkey support
  table.insert(windowObj._connections, UserInputService.InputBegan:Connect(function(input, processed)
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == windowObj._toggleKey and not processed then
      windowObj:SetOpen(not windowObj._window.Visible)
    end
  end))

  return windowObj
end

function Window:SetTitle(newTitle)
  self._titleBar.Title.Text = tostring(newTitle)
end

function Window:SetOpen(isOpen)
  self._window.Visible = isOpen and true or false
end

function Window:Destroy()
  if self._screenGui then
    self._screenGui:Destroy()
  end
end

function Window:SetToggleKey(keyCode)
  if typeof(keyCode) == "EnumItem" and keyCode.EnumType == Enum.KeyCode then
    self._toggleKey = keyCode
  end
end

function Window:AddTab(tabName)
  local theme = self._theme

  local tabButton = create("TextButton", {
    Name = "TabButton_" .. tabName,
    BackgroundColor3 = self._theme.surface2,
    AutoButtonColor = true,
    Size = UDim2.fromOffset(110, 24),
    Text = tabName,
    TextSize = 14,
    Font = Enum.Font.Gotham,
    TextColor3 = self._theme.text,
  }, {
    createRoundCorner(6),
    createStroke(theme.stroke, 1, 0.3),
  })
  tabButton.Parent = self._tabBar

  local tabContent = create("ScrollingFrame", {
    Name = "TabContent_" .. tabName,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Size = UDim2.fromScale(1, 1),
    CanvasSize = UDim2.new(0, 0, 0, 0),
    ScrollBarThickness = 6,
    ScrollingDirection = Enum.ScrollingDirection.Y,
    Visible = false,
  })
  tabContent.Parent = self._content

  local contentPadding = create("UIPadding", {
    PaddingLeft = UDim.new(0, PADDING),
    PaddingRight = UDim.new(0, PADDING),
    PaddingTop = UDim.new(0, PADDING),
    PaddingBottom = UDim.new(0, PADDING),
  })
  contentPadding.Parent = tabContent

  local contentLayout = create("UIListLayout", {
    FillDirection = Enum.FillDirection.Vertical,
    Padding = UDim.new(0, CONTROL_GAP),
    SortOrder = Enum.SortOrder.LayoutOrder,
  })
  contentLayout.Parent = tabContent

  contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    tabContent.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + PADDING)
  end)

  local tabObj = setmetatable({
    _window = self,
    _theme = theme,
    _button = tabButton,
    _content = tabContent,
  }, Tab)

  self._tabs[#self._tabs + 1] = tabObj

  local function setActive()
    if self._activeTab == tabObj then return end
    for _, t in ipairs(self._tabs) do
      t._content.Visible = false
      t._button.BackgroundColor3 = theme.surface2
      t._button.TextColor3 = theme.text
    end
    tabObj._content.Visible = true
    tabObj._button.BackgroundColor3 = theme.primary
    tabObj._button.TextColor3 = Color3.new(1,1,1)
    self._activeTab = tabObj
  end

  tabButton.MouseButton1Click:Connect(setActive)

  if not self._activeTab then
    setActive()
  end

  return tabObj
end

-- Tab API
function Tab:AddSection(headerText)
  local theme = self._theme

  local sectionFrame = create("Frame", {
    Name = "Section",
    BackgroundColor3 = theme.surface2,
    BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 0, 0),
    AutomaticSize = Enum.AutomaticSize.Y,
  }, {
    createRoundCorner(8),
    createStroke(theme.stroke, 1, 0.35),
  })
  sectionFrame.Parent = self._content

  local sectionPadding = create("UIPadding", {
    PaddingLeft = UDim.new(0, PADDING),
    PaddingRight = UDim.new(0, PADDING),
    PaddingTop = UDim.new(0, PADDING),
    PaddingBottom = UDim.new(0, PADDING),
  })
  sectionPadding.Parent = sectionFrame

  local sectionLayout = create("UIListLayout", {
    FillDirection = Enum.FillDirection.Vertical,
    Padding = UDim.new(0, CONTROL_GAP),
    SortOrder = Enum.SortOrder.LayoutOrder,
  })
  sectionLayout.Parent = sectionFrame

  if headerText and headerText ~= "" then
    local header = create("TextLabel", {
      BackgroundTransparency = 1,
      Size = UDim2.new(1, 0, 0, SECTION_HEADER_HEIGHT),
      Font = Enum.Font.GothamBold,
      Text = headerText,
      TextSize = 14,
      TextXAlignment = Enum.TextXAlignment.Left,
      TextColor3 = theme.text,
    })
    header.Parent = sectionFrame
  end

  local sectionObj = setmetatable({
    _theme = theme,
    _container = sectionFrame,
  }, Section)

  return sectionObj
end

-- Section API: Controls
function Section:AddLabel(text)
  local label = create("TextLabel", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, CONTROL_HEIGHT),
    Font = Enum.Font.Gotham,
    Text = tostring(text),
    TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextColor3 = self._theme.text,
  })
  label.Parent = self._container
  return label
end

function Section:AddButton(buttonText, onClick)
  local btn = create("TextButton", {
    Size = UDim2.new(1, 0, 0, CONTROL_HEIGHT),
    BackgroundColor3 = self._theme.primary,
    Text = tostring(buttonText or "Button"),
    Font = Enum.Font.Gotham,
    TextSize = 14,
    TextColor3 = Color3.new(1,1,1),
    AutoButtonColor = true,
  }, {
    createRoundCorner(6),
  })
  btn.Parent = self._container

  if typeof(onClick) == "function" then
    btn.MouseButton1Click:Connect(function()
      local ok, err = pcall(onClick)
      if not ok then warn("Button callback error:", err) end
    end)
  end

  return btn
end

local function buildLabeledRow(theme, parent, labelText)
  local row = create("Frame", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, CONTROL_HEIGHT),
  })
  row.Parent = parent

  local label = create("TextLabel", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, -160, 1, 0),
    Position = UDim2.new(0, 0, 0, 0),
    Font = Enum.Font.Gotham,
    Text = tostring(labelText),
    TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextColor3 = theme.text,
  })
  label.Parent = row

  local right = create("Frame", {
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 150, 1, 0),
    Position = UDim2.new(1, -150, 0, 0),
  })
  right.Parent = row

  return row, label, right
end

function Section:AddToggle(labelText, defaultState, onChanged)
  local theme = self._theme

  local row, _, right = buildLabeledRow(theme, self._container, labelText or "Toggle")

  local toggle = create("TextButton", {
    Size = UDim2.fromOffset(50, 24),
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, 0, 0.5, 0),
    BackgroundColor3 = theme.surface,
    Text = "",
    AutoButtonColor = false,
  }, {
    createRoundCorner(12),
    createStroke(theme.stroke, 1, 0.5),
  })
  toggle.Parent = right

  local knob = create("Frame", {
    Size = UDim2.fromOffset(20, 20),
    Position = UDim2.new(0, 2, 0.5, 0),
    AnchorPoint = Vector2.new(0, 0.5),
    BackgroundColor3 = theme.textDim,
    BorderSizePixel = 0,
  }, {
    createRoundCorner(10),
  })
  knob.Parent = toggle

  local state = defaultState and true or false

  local function render()
    if state then
      toggle.BackgroundColor3 = theme.accent
      knob.Position = UDim2.new(1, -22, 0.5, 0)
      knob.BackgroundColor3 = Color3.new(1,1,1)
    else
      toggle.BackgroundColor3 = theme.surface
      knob.Position = UDim2.new(0, 2, 0.5, 0)
      knob.BackgroundColor3 = theme.textDim
    end
  end

  local function set(newState, fire)
    state = newState and true or false
    render()
    if fire and typeof(onChanged) == "function" then
      local ok, err = pcall(onChanged, state)
      if not ok then warn("Toggle callback error:", err) end
    end
  end

  toggle.MouseButton1Click:Connect(function()
    set(not state, true)
  end)

  render()

  return {
    Set = function(_, v) set(v, true) end,
    Get = function() return state end,
    Instance = row,
  }
end

function Section:AddSlider(labelText, minValue, maxValue, defaultValue, onChanged)
  local theme = self._theme
  minValue = typeof(minValue) == "number" and minValue or 0
  maxValue = typeof(maxValue) == "number" and maxValue or 100
  local value = math.clamp(typeof(defaultValue) == "number" and defaultValue or minValue, minValue, maxValue)

  local row, label, right = buildLabeledRow(theme, self._container, labelText or "Slider")

  local slider = create("Frame", {
    Size = UDim2.new(1, 0, 0, 24),
    BackgroundColor3 = theme.surface,
    BorderSizePixel = 0,
  }, {
    createRoundCorner(6),
    createStroke(theme.stroke, 1, 0.5),
  })
  slider.Parent = right

  local fill = create("Frame", {
    Size = UDim2.new((value - minValue) / (maxValue - minValue), 0, 1, 0),
    BackgroundColor3 = theme.primary,
    BorderSizePixel = 0,
  }, {
    createRoundCorner(6),
  })
  fill.Parent = slider

  local valueLabel = create("TextLabel", {
    BackgroundTransparency = 1,
    Size = UDim2.fromOffset(48, 24),
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, 0, 0.5, 0),
    Text = tostring(value),
    Font = Enum.Font.Gotham,
    TextSize = 12,
    TextColor3 = theme.text,
  })
  valueLabel.Parent = right

  local dragging = false

  local function setFromX(x)
    local abs = slider.AbsoluteSize.X
    local relX = math.clamp(x - slider.AbsolutePosition.X, 0, abs)
    local pct = abs > 0 and relX / abs or 0
    value = math.floor(minValue + pct * (maxValue - minValue) + 0.5)
    fill.Size = UDim2.new(pct, 0, 1, 0)
    valueLabel.Text = tostring(value)
    if typeof(onChanged) == "function" then
      local ok, err = pcall(onChanged, value)
      if not ok then warn("Slider callback error:", err) end
    end
  end

  slider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
      dragging = true
      setFromX(input.Position.X)
    end
  end)

  slider.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
      dragging = false
    end
  end)

  UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
      setFromX(input.Position.X)
    end
  end)

  return {
    Set = function(_, v)
      v = math.clamp(tonumber(v) or value, minValue, maxValue)
      local pct = (v - minValue) / (maxValue - minValue)
      fill.Size = UDim2.new(pct, 0, 1, 0)
      valueLabel.Text = tostring(v)
      value = v
    end,
    Get = function() return value end,
    Instance = row,
  }
end

function Section:AddDropdown(labelText, options, defaultOption, onChanged)
  local theme = self._theme
  options = options or {}
  local selected = defaultOption or (options[1] or "")

  local row, _, right = buildLabeledRow(theme, self._container, labelText or "Dropdown")

  local dropdown = create("TextButton", {
    Size = UDim2.new(1, 0, 0, 24),
    BackgroundColor3 = theme.surface,
    Text = tostring(selected),
    Font = Enum.Font.Gotham,
    TextSize = 12,
    TextColor3 = theme.text,
    AutoButtonColor = true,
  }, {
    createRoundCorner(6),
    createStroke(theme.stroke, 1, 0.5),
  })
  dropdown.Parent = right

  local listHolder = create("Frame", {
    BackgroundColor3 = theme.surface2,
    BorderSizePixel = 0,
    Visible = false,
    Position = UDim2.new(0, 0, 1, 6),
    Size = UDim2.new(1, 0, 0, 0),
  }, {
    createRoundCorner(6),
    createStroke(theme.stroke, 1, 0.5),
  })
  listHolder.Parent = right

  local listLayout = create("UIListLayout", {
    FillDirection = Enum.FillDirection.Vertical,
    Padding = UDim.new(0, 4),
    SortOrder = Enum.SortOrder.LayoutOrder,
  })
  listLayout.Parent = listHolder

  local listPadding = create("UIPadding", {
    PaddingLeft = UDim.new(0, 6),
    PaddingRight = UDim.new(0, 6),
    PaddingTop = UDim.new(0, 6),
    PaddingBottom = UDim.new(0, 6),
  })
  listPadding.Parent = listHolder

  local function rebuildOptions()
    for _, child in ipairs(listHolder:GetChildren()) do
      if child:IsA("TextButton") then child:Destroy() end
    end

    for _, opt in ipairs(options) do
      local optBtn = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundColor3 = theme.surface,
        Text = tostring(opt),
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = theme.text,
        AutoButtonColor = true,
      }, {
        createRoundCorner(6),
        createStroke(theme.stroke, 1, 0.5),
      })
      optBtn.Parent = listHolder

      optBtn.MouseButton1Click:Connect(function()
        selected = opt
        dropdown.Text = tostring(selected)
        listHolder.Visible = false
        if typeof(onChanged) == "function" then
          local ok, err = pcall(onChanged, selected)
          if not ok then warn("Dropdown callback error:", err) end
        end
      end)
    end

    -- autosize holder height
    task.defer(function()
      local contentY = listLayout.AbsoluteContentSize.Y + 12
      listHolder.Size = UDim2.new(1, 0, 0, math.min(contentY, 160))
    end)
  end

  dropdown.MouseButton1Click:Connect(function()
    listHolder.Visible = not listHolder.Visible
    rebuildOptions()
  end)

  -- Hide the list when clicking outside
  UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 and listHolder.Visible then
      local pos = input.Position
      local within = pos.X >= listHolder.AbsolutePosition.X and pos.X <= (listHolder.AbsolutePosition.X + listHolder.AbsoluteSize.X)
        and pos.Y >= listHolder.AbsolutePosition.Y and pos.Y <= (listHolder.AbsolutePosition.Y + listHolder.AbsoluteSize.Y)
      local withinDropdown = pos.X >= dropdown.AbsolutePosition.X and pos.X <= (dropdown.AbsolutePosition.X + dropdown.AbsoluteSize.X)
        and pos.Y >= dropdown.AbsolutePosition.Y and pos.Y <= (dropdown.AbsolutePosition.Y + dropdown.AbsoluteSize.Y)
      if not within and not withinDropdown then
        listHolder.Visible = false
      end
    end
  end)

  rebuildOptions()

  return {
    Set = function(_, v)
      selected = v
      dropdown.Text = tostring(v)
    end,
    Get = function() return selected end,
    SetOptions = function(_, newOptions)
      options = newOptions or {}
      rebuildOptions()
    end,
    Instance = row,
  }
end

function Section:AddTextbox(labelText, placeholder, onReturn)
  local theme = self._theme

  local row, _, right = buildLabeledRow(theme, self._container, labelText or "Textbox")

  local box = create("TextBox", {
    Size = UDim2.new(1, 0, 0, 24),
    BackgroundColor3 = theme.surface,
    Text = "",
    PlaceholderText = placeholder or "",
    Font = Enum.Font.Gotham,
    TextSize = 12,
    TextColor3 = theme.text,
    ClearTextOnFocus = false,
  }, {
    createRoundCorner(6),
    createStroke(theme.stroke, 1, 0.5),
  })
  box.Parent = right

  box.FocusLost:Connect(function(enterPressed)
    if enterPressed and typeof(onReturn) == "function" then
      local ok, err = pcall(onReturn, box.Text)
      if not ok then warn("Textbox callback error:", err) end
    end
  end)

  return {
    Set = function(_, v) box.Text = tostring(v or "") end,
    Get = function() return box.Text end,
    Instance = row,
  }
end

function Section:AddKeybind(labelText, defaultKeyCode, onChanged)
  local theme = self._theme
  local currentKeyCode = defaultKeyCode or Enum.KeyCode.RightShift
  local listening = false

  local row, _, right = buildLabeledRow(theme, self._container, labelText or "Keybind")

  local bindBtn = create("TextButton", {
    Size = UDim2.new(1, 0, 0, 24),
    BackgroundColor3 = theme.surface,
    Text = currentKeyCode.Name,
    Font = Enum.Font.Gotham,
    TextSize = 12,
    TextColor3 = theme.text,
    AutoButtonColor = true,
  }, {
    createRoundCorner(6),
    createStroke(theme.stroke, 1, 0.5),
  })
  bindBtn.Parent = right

  bindBtn.MouseButton1Click:Connect(function()
    listening = true
    bindBtn.Text = "Pressione uma tecla..."
  end)

  UserInputService.InputBegan:Connect(function(input, processed)
    if not listening then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
      currentKeyCode = input.KeyCode
      listening = false
      bindBtn.Text = currentKeyCode.Name
      if typeof(onChanged) == "function" then
        local ok, err = pcall(onChanged, currentKeyCode)
        if not ok then warn("Keybind callback error:", err) end
      end
    end
  end)

  return {
    Get = function() return currentKeyCode end,
    Set = function(_, keyCode)
      if typeof(keyCode) == "EnumItem" and keyCode.EnumType == Enum.KeyCode then
        currentKeyCode = keyCode
        bindBtn.Text = currentKeyCode.Name
      end
    end,
    Instance = row,
  }
end

return UILibrary
