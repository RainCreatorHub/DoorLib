local DoorLib = {
    _VERSION = "1.0.0",
    _DESCRIPTION = "A modern UI library for Roblox",
    _AUTHOR = "RainCreatorHub"
}

-- Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- Load components
DoorLib.Components = {
    Button = require(script.Components.Button),
    Window = require(script.Components.Window),
    Tab = require(script.Components.Tab),
    Toggle = require(script.Components.Toggle),
    Slider = require(script.Components.Slider)
}

-- Main window creation function
function DoorLib:CreateWindow(config)
    return self.Components.Window.new(config)
end

return DoorLib