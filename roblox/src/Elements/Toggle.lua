local InstanceUtil = require(script.Parent.Parent.Utils.Instance)

local Toggle = {}
Toggle.__index = Toggle

local function row(theme, parent, labelText)
  local frame = InstanceUtil.create("Frame", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 30),
  })
  frame.Parent = parent

  local label = InstanceUtil.create("TextLabel", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, -160, 1, 0),
    Font = Enum.Font.Gotham,
    Text = tostring(labelText or "Toggle"),
    TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextColor3 = theme.text,
  })
  label.Parent = frame

  local right = InstanceUtil.create("Frame", {
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 150, 1, 0),
    Position = UDim2.new(1, -150, 0, 0),
  })
  right.Parent = frame

  return frame, right
end

function Toggle.new(theme, parent, labelText, defaultState, onChanged)
  local rowFrame, right = row(theme, parent, labelText)

  local toggle = InstanceUtil.create("TextButton", {
    Size = UDim2.fromOffset(50, 24),
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, 0, 0.5, 0),
    BackgroundColor3 = theme.surface,
    Text = "",
    AutoButtonColor = false,
  }, {
    InstanceUtil.roundCorner(12),
    InstanceUtil.stroke(theme.stroke, 1, 0.5),
  })
  toggle.Parent = right

  local knob = InstanceUtil.create("Frame", {
    Size = UDim2.fromOffset(20, 20),
    Position = UDim2.new(0, 2, 0.5, 0),
    AnchorPoint = Vector2.new(0, 0.5),
    BackgroundColor3 = theme.textDim,
    BorderSizePixel = 0,
  }, {
    InstanceUtil.roundCorner(10),
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
    Instance = rowFrame,
  }
end

return Toggle
