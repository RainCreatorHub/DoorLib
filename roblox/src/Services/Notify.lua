local InstanceUtil = require(script.Parent.Parent.Utils.Instance)

local Notify = {}
Notify.__index = Notify

function Notify.new(theme)
  local self = setmetatable({}, Notify)
  self._theme = theme
  return self
end

function Notify:Show(message, duration)
  duration = duration or 3
  local screen = InstanceUtil.create("ScreenGui", {
    Name = "LibNotify",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
  })
  screen.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

  local frame = InstanceUtil.create("TextLabel", {
    BackgroundColor3 = self._theme.surface2,
    Text = tostring(message),
    Font = Enum.Font.Gotham,
    TextSize = 14,
    TextColor3 = self._theme.text,
    Size = UDim2.fromOffset(280, 36),
    AnchorPoint = Vector2.new(1,1),
    Position = UDim2.new(1, -16, 1, -16),
  }, {
    InstanceUtil.roundCorner(8),
    InstanceUtil.stroke(self._theme.stroke, 1, 0.25),
  })
  frame.Parent = screen

  task.delay(duration, function()
    screen:Destroy()
  end)
end

return Notify
