local InstanceUtil = {}

function InstanceUtil.create(instanceClassName, props, children)
  local instance = Instance.new(instanceClassName)
  if props then
    for propertyName, propertyValue in pairs(props) do
      instance[propertyName] = propertyValue
    end
  end
  if children then
    for _, child in ipairs(children) do
      if typeof(child) == "Instance" then
        child.Parent = instance
      end
    end
  end
  return instance
end

function InstanceUtil.roundCorner(radius)
  return InstanceUtil.create("UICorner", { CornerRadius = UDim.new(0, radius or 8) })
end

function InstanceUtil.stroke(color3, thickness, transparency)
  return InstanceUtil.create("UIStroke", {
    Color = color3 or Color3.fromRGB(255,255,255),
    Thickness = thickness or 1,
    Transparency = transparency or 0,
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
  })
end

function InstanceUtil.padding(px)
  return InstanceUtil.create("UIPadding", {
    PaddingLeft = UDim.new(0, px or 8),
    PaddingRight = UDim.new(0, px or 8),
    PaddingTop = UDim.new(0, px or 8),
    PaddingBottom = UDim.new(0, px or 8),
  })
end

return InstanceUtil
