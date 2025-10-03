local InstanceUtil = require(script.Parent.Parent.Utils.Instance)

local TextBoxEl = {}
TextBoxEl.__index = TextBoxEl

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
    Text = tostring(labelText or "Textbox"),
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

function TextBoxEl.new(theme, parent, labelText, placeholder, onReturn)
  local rowFrame, right = row(theme, parent, labelText)

  local box = InstanceUtil.create("TextBox", {
    Size = UDim2.new(1, 0, 0, 24),
    BackgroundColor3 = theme.surface,
    Text = "",
    PlaceholderText = placeholder or "",
    Font = Enum.Font.Gotham,
    TextSize = 12,
    TextColor3 = theme.text,
    ClearTextOnFocus = false,
  }, {
    InstanceUtil.roundCorner(6),
    InstanceUtil.stroke(theme.stroke, 1, 0.5),
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
    Instance = rowFrame,
  }
end

return TextBoxEl
