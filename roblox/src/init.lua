local Theme = require(script.Core.Theme)
local Localization = require(script.Core.Localization)
local Window = require(script.UI.Window)
local Tab = require(script.UI.Tab)
local Section = require(script.UI.Section)

local Button = require(script.Elements.Button)
local Toggle = require(script.Elements.Toggle)
local Slider = require(script.Elements.Slider)
local Dropdown = require(script.Elements.Dropdown)
local TextBoxEl = require(script.Elements.TextBox)
local Keybind = require(script.Elements.Keybind)

local Notify = require(script.Services.Notify)
local Popup = require(script.Services.Popup)

local Lib = {}
Lib.__index = Lib
Lib.Version = "0.1.0"

function Lib.new(config)
  local self = setmetatable({}, Lib)
  self.Theme = Theme.new((config and config.Theme) or "Dark")
  self.Localization = Localization.new(config and config.Localization)
  self.Notify = Notify.new(self.Theme:Get())
  self.Popup = Popup.new(self.Theme:Get())
  return self
end

function Lib:CreateWindow(options)
  options = options or {}
  local win = Window.new(self.Theme:Get(), {
    title = options.Title or "Lib",
    size = options.Size or UDim2.fromOffset(470, 340),
    startOpen = options.StartOpen ~= false,
    toggleKey = options.ToggleKey or Enum.KeyCode.RightShift,
  })

  local api = {}

  function api:Tab(tabOptions)
    local tab = win:AddTab(tabOptions and tabOptions.Title or "Tab")

    local t = {}

    function t:Section(secOptions)
      local section = tab:AddSection(secOptions and secOptions.Title or "Section")

      return setmetatable({ _theme = Lib.Theme:Get(), _section = section }, {
        __index = function(_, key)
          if key == "Button" then
            return function(_, args)
              return Button.new(Lib.Theme:Get(), section._container or section._content or section, args.Title, args.Callback)
            end
          elseif key == "Toggle" then
            return function(_, args)
              return Toggle.new(Lib.Theme:Get(), section._container or section._content or section, args.Title, args.Value, args.Callback)
            end
          elseif key == "Slider" then
            return function(_, args)
              local v = args.Value or { Min = 0, Max = 100, Default = 50 }
              return Slider.new(Lib.Theme:Get(), section._container or section._content or section, args.Title, v.Min, v.Max, v.Default, args.Callback)
            end
          elseif key == "Dropdown" then
            return function(_, args)
              return Dropdown.new(Lib.Theme:Get(), section._container or section._content or section, args.Title, args.Values, args.Value, args.Callback)
            end
          elseif key == "Input" or key == "TextBox" then
            return function(_, args)
              return TextBoxEl.new(Lib.Theme:Get(), section._container or section._content or section, args.Title, args.Placeholder, args.Callback)
            end
          elseif key == "Keybind" then
            return function(_, args)
              return Keybind.new(Lib.Theme:Get(), section._container or section._content or section, args.Title, args.Value or Enum.KeyCode.RightShift, args.Callback)
            end
          end
        end
      })
    end

    return t
  end

  function api:SetTitle(newTitle)
    win:SetTitle(newTitle)
  end

  function api:SetToggleKey(kc)
    win._toggleKey = kc
  end

  function api:Destroy()
    win:Destroy()
  end

  return api
end

function Lib:SetTheme(themeName)
  self.Theme:Set(themeName)
end

function Lib:GetThemes()
  return self.Theme:GetThemes()
end

function Lib:Localization(config)
  self.Localization = Localization.new(config)
  return self.Localization
end

return Lib
