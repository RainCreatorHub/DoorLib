local InstanceUtil = require(script.Parent.Parent.Utils.Instance)
local UserInputService = game:GetService("UserInputService")

local Dropdown = {}
Dropdown.__index = Dropdown

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
    Text = tostring(labelText or "Dropdown"),
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

function Dropdown.new(theme, parent, labelText, options, defaultOption, onChanged)
  options = options or {}
  local selected = defaultOption or options[1]

  local rowFrame, right = row(theme, parent, labelText)

  local dropdown = InstanceUtil.create("TextButton", {
    Size = UDim2.new(1, 0, 0, 24),
    BackgroundColor3 = theme.surface,
    Text = tostring(selected or ""),
    Font = Enum.Font.Gotham,
    TextSize = 12,
    TextColor3 = theme.text,
    AutoButtonColor = true,
  }, {
    InstanceUtil.roundCorner(6),
    InstanceUtil.stroke(theme.stroke, 1, 0.5),
  })
  dropdown.Parent = right

  local listHolder = InstanceUtil.create("Frame", {
    BackgroundColor3 = theme.surface2,
    BorderSizePixel = 0,
    Visible = false,
    Position = UDim2.new(0, 0, 1, 6),
    Size = UDim2.new(1, 0, 0, 0),
  }, {
    InstanceUtil.roundCorner(6),
    InstanceUtil.stroke(theme.stroke, 1, 0.5),
  })
  listHolder.Parent = right

  local listLayout = InstanceUtil.create("UIListLayout", {
    FillDirection = Enum.FillDirection.Vertical,
    Padding = UDim.new(0, 4),
    SortOrder = Enum.SortOrder.LayoutOrder,
  })
  listLayout.Parent = listHolder

  local listPadding = InstanceUtil.create("UIPadding", {
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
      local optBtn = InstanceUtil.create("TextButton", {
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundColor3 = theme.surface,
        Text = tostring(opt),
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = theme.text,
        AutoButtonColor = true,
      }, {
        InstanceUtil.roundCorner(6),
        InstanceUtil.stroke(theme.stroke, 1, 0.5),
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

    task.defer(function()
      local contentY = listLayout.AbsoluteContentSize.Y + 12
      listHolder.Size = UDim2.new(1, 0, 0, math.min(contentY, 160))
    end)
  end

  dropdown.MouseButton1Click:Connect(function()
    listHolder.Visible = not listHolder.Visible
    rebuildOptions()
  end)

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
    Instance = rowFrame,
  }
end

return Dropdown
