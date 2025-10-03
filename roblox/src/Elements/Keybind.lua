local InstanceUtil = require(script.Parent.Parent.Utils.Instance)
local UserInputService = game:GetService("UserInputService")

local Keybind = {}
Keybind.__index = Keybind

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
    Text = tostring(labelText or "Keybind"),
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

function Keybind.new(theme, parent, labelText, defaultKeyCode, onChanged)
  local rowFrame, right = row(theme, parent, labelText)
  local currentKeyCode = defaultKeyCode or Enum.KeyCode.RightShift
  local listening = false

  local bindBtn = InstanceUtil.create("TextButton", {
    Size = UDim2.new(1, 0, 0, 24),
    BackgroundColor3 = theme.surface,
    Text = currentKeyCode.Name,
    Font = Enum.Font.Gotham,
    TextSize = 12,
    TextColor3 = theme.text,
    AutoButtonColor = true,
  }, {
    InstanceUtil.roundCorner(6),
    InstanceUtil.stroke(theme.stroke, 1, 0.5),
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
    Instance = rowFrame,
  }
end

return Keybind
