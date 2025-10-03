local InstanceUtil = require(script.Parent.Parent.Utils.Instance)

local Popup = {}
Popup.__index = Popup

function Popup.new(theme)
  local self = setmetatable({}, Popup)
  self._theme = theme
  return self
end

function Popup:Show(opts)
  opts = opts or {}
  local title = opts.Title or "Popup"
  local content = opts.Content or ""
  local buttons = opts.Buttons or {}

  local screen = InstanceUtil.create("ScreenGui", {
    Name = "LibPopup",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
  })
  screen.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

  local frame = InstanceUtil.create("Frame", {
    Size = UDim2.fromOffset(360, 200),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    BackgroundColor3 = self._theme.surface,
  }, {
    InstanceUtil.roundCorner(10),
    InstanceUtil.stroke(self._theme.stroke, 1, 0.25),
  })
  frame.Parent = screen

  local titleLbl = InstanceUtil.create("TextLabel", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, -20, 0, 28),
    Position = UDim2.new(0, 10, 0, 10),
    Font = Enum.Font.GothamBold,
    Text = title,
    TextSize = 16,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextColor3 = self._theme.text,
  })
  titleLbl.Parent = frame

  local contentLbl = InstanceUtil.create("TextLabel", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, -20, 1, -78),
    Position = UDim2.new(0, 10, 0, 42),
    Font = Enum.Font.Gotham,
    Text = content,
    TextWrapped = true,
    TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    TextColor3 = self._theme.text,
  })
  contentLbl.Parent = frame

  local btnY = 160
  for i, btn in ipairs(buttons) do
    local x = 10 + (i-1) * 120
    local b = InstanceUtil.create("TextButton", {
      Size = UDim2.fromOffset(110, 28),
      Position = UDim2.new(0, x, 0, btnY),
      BackgroundColor3 = (btn.Variant == "Primary") and self._theme.primary or self._theme.surface2,
      Text = btn.Title or "OK",
      Font = Enum.Font.Gotham,
      TextSize = 14,
      TextColor3 = Color3.new(1,1,1),
      AutoButtonColor = true,
    }, {
      InstanceUtil.roundCorner(6),
    })
    b.Parent = frame
    b.MouseButton1Click:Connect(function()
      if typeof(btn.Callback) == "function" then
        pcall(btn.Callback)
      end
      screen:Destroy()
    end)
  end
end

return Popup
