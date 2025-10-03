local UserInputService = game:GetService("UserInputService")

local Drag = {}

function Drag.enable(frame, handle)
  local dragging = false
  local dragStart
  local startPos

  handle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
      dragging = true
      dragStart = input.Position
      startPos = frame.Position
      input.Changed:Connect(function()
        if input.UserInputState == Enum.UserInputState.End then
          dragging = false
        end
      end)
    end
  end)

  handle.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
      local delta = input.Position - dragStart
      frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
  end)
end

return Drag
