local InstanceUtil = require(script.Parent.Parent.Utils.Instance)

local Slider = {}
Slider.__index = Slider

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
    Text = tostring(labelText or "Slider"),
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

function Slider.new(theme, parent, labelText, minValue, maxValue, defaultValue, onChanged)
  minValue = typeof(minValue) == "number" and minValue or 0
  maxValue = typeof(maxValue) == "number" and maxValue or 100
  local value = math.clamp(typeof(defaultValue) == "number" and defaultValue or minValue, minValue, maxValue)

  local rowFrame, right = row(theme, parent, labelText)

  local slider = InstanceUtil.create("Frame", {
    Size = UDim2.new(1, 0, 0, 24),
    BackgroundColor3 = theme.surface,
    BorderSizePixel = 0,
  }, {
    InstanceUtil.roundCorner(6),
    InstanceUtil.stroke(theme.stroke, 1, 0.5),
  })
  slider.Parent = right

  local fill = InstanceUtil.create("Frame", {
    Size = UDim2.new((value - minValue) / (maxValue - minValue), 0, 1, 0),
    BackgroundColor3 = theme.primary,
    BorderSizePixel = 0,
  }, {
    InstanceUtil.roundCorner(6),
  })
  fill.Parent = slider

  local valueLabel = InstanceUtil.create("TextLabel", {
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

  local UserInputService = game:GetService("UserInputService")
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
    Instance = rowFrame,
  }
end

return Slider
