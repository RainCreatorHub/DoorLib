local InstanceUtil = require(script.Parent.Parent.Utils.Instance)

local Button = {}
Button.__index = Button

function Button.new(theme, parent, text, callback)
  local btn = InstanceUtil.create("TextButton", {
    Size = UDim2.new(1, 0, 0, 30),
    BackgroundColor3 = theme.primary,
    Text = tostring(text or "Button"),
    Font = Enum.Font.Gotham,
    TextSize = 14,
    TextColor3 = Color3.new(1,1,1),
    AutoButtonColor = true,
  }, {
    InstanceUtil.roundCorner(6),
  })
  btn.Parent = parent

  if typeof(callback) == "function" then
    btn.MouseButton1Click:Connect(function()
      local ok, err = pcall(callback)
      if not ok then warn("Button callback error:", err) end
    end)
  end

  return btn
end

return Button
