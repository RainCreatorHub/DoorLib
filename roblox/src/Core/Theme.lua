local ColorUtil = require(script.Parent.Parent.Utils.Color)

local Theme = {}
Theme.__index = Theme

local THEMES = {
  Dark = {
    background = ColorUtil.fromHex("#111215"),
    surface = ColorUtil.fromHex("#181a1f"),
    surface2 = ColorUtil.fromHex("#1f2229"),
    text = ColorUtil.fromHex("#e5e7eb"),
    textDim = ColorUtil.fromHex("#a3a6ad"),
    primary = ColorUtil.fromHex("#4f46e5"),
    accent = ColorUtil.fromHex("#22c55e"),
    danger = ColorUtil.fromHex("#ef4444"),
    stroke = ColorUtil.fromHex("#2a2e36"),
  },
  Light = {
    background = ColorUtil.fromHex("#f5f5f7"),
    surface = ColorUtil.fromHex("#ffffff"),
    surface2 = ColorUtil.fromHex("#f0f1f3"),
    text = ColorUtil.fromHex("#111215"),
    textDim = ColorUtil.fromHex("#4b5563"),
    primary = ColorUtil.fromHex("#4f46e5"),
    accent = ColorUtil.fromHex("#16a34a"),
    danger = ColorUtil.fromHex("#dc2626"),
    stroke = ColorUtil.fromHex("#e5e7eb"),
  },
}

function Theme.new(initial)
  local self = setmetatable({}, Theme)
  self._themes = THEMES
  self._current = THEMES[initial or "Dark"]
  self._currentName = initial or "Dark"
  self._onChange = Instance.new("BindableEvent")
  return self
end

function Theme:GetThemes()
  local list = {}
  for name, _ in pairs(self._themes) do
    table.insert(list, name)
  end
  table.sort(list)
  return list
end

function Theme:Get()
  return self._current
end

function Theme:GetName()
  return self._currentName
end

function Theme:Set(name)
  local theme = self._themes[name]
  if theme then
    self._current = theme
    self._currentName = name
    self._onChange:Fire()
  end
end

function Theme:OnChange(callback)
  return self._onChange.Event:Connect(callback)
end

return Theme
