local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local InstanceUtil = require(script.Parent.Parent.Utils.Instance)
local ColorUtil = require(script.Parent.Parent.Utils.Color)
local Drag = require(script.Parent.Parent.Utils.Drag)
local Tab = require(script.Parent.Tab)
local Section = require(script.Parent.Section)

local Window = {}
Window.__index = Window

local PADDING = 10
local TITLEBAR_HEIGHT = 36
local TABBAR_HEIGHT = 32

function Window.new(theme, options)
  options = options or {}
  local self = setmetatable({}, Window)
  self._theme = theme
  self._toggleKey = options.toggleKey or Enum.KeyCode.RightShift

  local player = Players.LocalPlayer
  local playerGui = player:WaitForChild("PlayerGui")

  local screenGui = InstanceUtil.create("ScreenGui", {
    Name = options.name or "Lib",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
  })
  screenGui.Parent = playerGui

  local frame = InstanceUtil.create("Frame", {
    Name = "Window",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = options.size or UDim2.fromOffset(470, 340),
    BackgroundColor3 = theme.surface,
    BorderSizePixel = 0,
  }, {
    InstanceUtil.roundCorner(8),
    InstanceUtil.stroke(theme.stroke, 1, 0.25),
  })
  frame.Parent = screenGui

  local titleBar = InstanceUtil.create("Frame", {
    Name = "TitleBar",
    Size = UDim2.new(1, 0, 0, TITLEBAR_HEIGHT),
    BackgroundColor3 = theme.surface2,
    BorderSizePixel = 0,
  }, {
    InstanceUtil.roundCorner(8),
    InstanceUtil.stroke(theme.stroke, 1, 0.15),
  })
  titleBar.Parent = frame

  local titleLabel = InstanceUtil.create("TextLabel", {
    Name = "Title",
    BackgroundTransparency = 1,
    Size = UDim2.new(1, -2 * PADDING, 1, 0),
    Position = UDim2.new(0, PADDING, 0, 0),
    Font = Enum.Font.GothamBold,
    Text = options.title or "Lib",
    TextSize = 16,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextColor3 = theme.text,
  })
  titleLabel.Parent = titleBar

  local closeButton = InstanceUtil.create("TextButton", {
    Name = "Close",
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -PADDING, 0.5, 0),
    Size = UDim2.fromOffset(22, 22),
    BackgroundColor3 = theme.danger,
    Text = "",
    AutoButtonColor = true,
  }, {
    InstanceUtil.roundCorner(6),
  })
  closeButton.Parent = titleBar

  local closeIcon = InstanceUtil.create("TextLabel", {
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(1,1),
    Text = "✕",
    Font = Enum.Font.Gotham,
    TextSize = 14,
    TextColor3 = Color3.new(1,1,1),
  })
  closeIcon.Parent = closeButton

  local tabBar = InstanceUtil.create("Frame", {
    Name = "TabBar",
    Size = UDim2.new(1, 0, 0, TABBAR_HEIGHT),
    Position = UDim2.new(0, 0, 0, TITLEBAR_HEIGHT),
    BackgroundColor3 = theme.surface,
    BorderSizePixel = 0,
  })
  tabBar.Parent = frame

  local tabLayout = InstanceUtil.create("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    Padding = UDim.new(0, 6),
    SortOrder = Enum.SortOrder.LayoutOrder,
    HorizontalAlignment = Enum.HorizontalAlignment.Left,
    VerticalAlignment = Enum.VerticalAlignment.Center,
  })
  tabLayout.Parent = tabBar

  local tabPadding = InstanceUtil.create("UIPadding", {
    PaddingLeft = UDim.new(0, PADDING),
    PaddingRight = UDim.new(0, PADDING),
  })
  tabPadding.Parent = tabBar

  local content = InstanceUtil.create("Frame", {
    Name = "Content",
    BackgroundColor3 = theme.background,
    BorderSizePixel = 0,
    Position = UDim2.new(0, 0, 0, TITLEBAR_HEIGHT + TABBAR_HEIGHT),
    Size = UDim2.new(1, 0, 1, -(TITLEBAR_HEIGHT + TABBAR_HEIGHT)),
  }, {
    InstanceUtil.stroke(theme.stroke, 1, 0.5),
  })
  content.Parent = frame

  self._screenGui = screenGui
  self._frame = frame
  self._titleBar = titleBar
  self._tabBar = tabBar
  self._content = content
  self._tabs = {}

  Drag.enable(frame, titleBar)

  closeButton.MouseButton1Click:Connect(function()
    self:SetOpen(false)
  end)

  self:SetOpen(options.startOpen ~= false)

  UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == self._toggleKey then
      self:SetOpen(not self._frame.Visible)
    end
  end)

  return self
end

function Window:_activateTab(tab)
  for _, t in ipairs(self._tabs) do
    t._content.Visible = false
    t._button.BackgroundColor3 = self._theme.surface2
    t._button.TextColor3 = self._theme.text
  end
  tab._content.Visible = true
  tab._button.BackgroundColor3 = self._theme.primary
  tab._button.TextColor3 = Color3.new(1,1,1)
end

function Window:AddTab(name)
  local tab = Tab.new(self._theme, self, tostring(name or "Tab"))
  table.insert(self._tabs, tab)
  if not self._active then
    self:_activateTab(tab)
  end
  return {
    AddSection = function(_, header)
      return Section.new(self._theme, tab._content, header)
    end
  }
end

function Window:SetOpen(isOpen)
  self._frame.Visible = isOpen and true or false
end

function Window:Destroy()
  if self._screenGui then self._screenGui:Destroy() end
end

function Window:SetTitle(newTitle)
  self._titleBar.Title.Text = tostring(newTitle)
end

return Window
