local ColorUtil = {}

function ColorUtil.fromHex(hex)
  hex = tostring(hex):gsub("#", "")
  if #hex == 3 then
    local r = tonumber(hex:sub(1,1)..hex:sub(1,1), 16)
    local g = tonumber(hex:sub(2,2)..hex:sub(2,2), 16)
    local b = tonumber(hex:sub(3,3)..hex:sub(3,3), 16)
    return Color3.fromRGB(r, g, b)
  elseif #hex == 6 then
    local r = tonumber(hex:sub(1,2), 16)
    local g = tonumber(hex:sub(3,4), 16)
    local b = tonumber(hex:sub(5,6), 16)
    return Color3.fromRGB(r, g, b)
  end
  error("Invalid hex color: " .. tostring(hex))
end

function ColorUtil.toHex(color3)
  local r = math.floor(color3.R * 255 + 0.5)
  local g = math.floor(color3.G * 255 + 0.5)
  local b = math.floor(color3.B * 255 + 0.5)
  return string.format("#%02X%02X%02X", r, g, b)
end

return ColorUtil
