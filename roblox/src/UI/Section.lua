local InstanceUtil = require(script.Parent.Parent.Utils.Instance)

local Section = {}
Section.__index = Section

local PADDING = 10
local CONTROL_GAP = 8
local SECTION_HEADER_HEIGHT = 22
local CONTROL_HEIGHT = 30

function Section.new(theme, parent, headerText)
  local self = setmetatable({}, Section)
  self._theme = theme

  local sectionFrame = InstanceUtil.create("Frame", {
    Name = "Section",
    BackgroundColor3 = theme.surface2,
    BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 0, 0),
    AutomaticSize = Enum.AutomaticSize.Y,
  }, {
    InstanceUtil.roundCorner(8),
    InstanceUtil.stroke(theme.stroke, 1, 0.35),
  })
  sectionFrame.Parent = parent

  local sectionPadding = InstanceUtil.create("UIPadding", {
    PaddingLeft = UDim.new(0, PADDING),
    PaddingRight = UDim.new(0, PADDING),
    PaddingTop = UDim.new(0, PADDING),
    PaddingBottom = UDim.new(0, PADDING),
  })
  sectionPadding.Parent = sectionFrame

  local sectionLayout = InstanceUtil.create("UIListLayout", {
    FillDirection = Enum.FillDirection.Vertical,
    Padding = UDim.new(0, CONTROL_GAP),
    SortOrder = Enum.SortOrder.LayoutOrder,
  })
  sectionLayout.Parent = sectionFrame

  if headerText and headerText ~= "" then
    local header = InstanceUtil.create("TextLabel", {
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

  self._container = sectionFrame

  return self
end

function Section:AddRaw(instance)
  instance.Parent = self._container
  return instance
end

return Section
