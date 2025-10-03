local InstanceUtil = require(script.Parent.Parent.Utils.Instance)

local Tab = {}
Tab.__index = Tab

local PADDING = 10
local CONTROL_GAP = 8

function Tab.new(theme, host, tabName)
  local self = setmetatable({}, Tab)
  self._theme = theme
  self._host = host

  local tabButton = InstanceUtil.create("TextButton", {
    Name = "TabButton_" .. tabName,
    BackgroundColor3 = theme.surface2,
    AutoButtonColor = true,
    Size = UDim2.fromOffset(110, 24),
    Text = tabName,
    TextSize = 14,
    Font = Enum.Font.Gotham,
    TextColor3 = theme.text,
  }, {
    InstanceUtil.roundCorner(6),
    InstanceUtil.stroke(theme.stroke, 1, 0.3),
  })
  tabButton.Parent = host._tabBar

  local tabContent = InstanceUtil.create("ScrollingFrame", {
    Name = "TabContent_" .. tabName,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Size = UDim2.fromScale(1, 1),
    CanvasSize = UDim2.new(0, 0, 0, 0),
    ScrollBarThickness = 6,
    ScrollingDirection = Enum.ScrollingDirection.Y,
    Visible = false,
  })
  tabContent.Parent = host._content

  local contentPadding = InstanceUtil.create("UIPadding", {
    PaddingLeft = UDim.new(0, PADDING),
    PaddingRight = UDim.new(0, PADDING),
    PaddingTop = UDim.new(0, PADDING),
    PaddingBottom = UDim.new(0, PADDING),
  })
  contentPadding.Parent = tabContent

  local contentLayout = InstanceUtil.create("UIListLayout", {
    FillDirection = Enum.FillDirection.Vertical,
    Padding = UDim.new(0, CONTROL_GAP),
    SortOrder = Enum.SortOrder.LayoutOrder,
  })
  contentLayout.Parent = tabContent

  contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    tabContent.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + PADDING)
  end)

  self._button = tabButton
  self._content = tabContent

  tabButton.MouseButton1Click:Connect(function()
    host:_activateTab(self)
  end)

  return self
end

return Tab
