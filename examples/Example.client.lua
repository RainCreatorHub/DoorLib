-- Example usage for UILibrary
-- Place this LocalScript under StarterPlayerScripts or run in Studio as a client

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Adjust the path below to wherever you put Lib.lua
-- For example, if you move Lib.lua into ReplicatedStorage as a ModuleScript:
-- local Lib = require(ReplicatedStorage:WaitForChild("Lib"))
-- In this repo layout, use a ModuleScript copy of roblox/Lib.lua in your game

-- src-based Lib usage
-- local Lib = require(ReplicatedStorage:WaitForChild("Lib")) -- if you package src as ModuleScript
-- or if you keep folder structure, require("src/init") accordingly.

-- DEMO (pseudo):
-- local lib = Lib.new({ Theme = "Dark" })
-- local window = lib:CreateWindow({
--   Title = "Lib", Size = UDim2.fromOffset(470, 340), ToggleKey = Enum.KeyCode.RightShift, StartOpen = true
-- })
--   title = "Minha UI",
--   size = Vector2.new(470, 340),
--   toggleKey = Enum.KeyCode.RightShift,
--   startOpen = true,
-- })
-- local tabMain = window:Tab({ Title = "Principal" })
-- local secGeneral = tabMain:Section({ Title = "Geral" })
-- secGeneral:Button({ Title = "Dizer Olá", Callback = function() print("Olá do botão!") end })
--
-- secGeneral:Toggle({ Title = "Ativar Coisa", Value = false, Callback = function(state) print("Toggle:", state) end })
--
-- secGeneral:Slider({ Title = "Velocidade", Value = { Min = 0, Max = 100, Default = 50 }, Callback = function(v) print("Slider:", v) end })
--
-- secGeneral:Dropdown({ Title = "Modo", Values = {"Clássico","Rápido","Seguro"}, Value = "Clássico", Callback = function(opt) print("Dropdown:", opt) end })
--
-- secGeneral:Input({ Title = "Digite algo", Placeholder = "mensagem", Callback = function(text) print("Textbox:", text) end })
--
-- secGeneral:Keybind({ Title = "Tecla de Toggle", Value = Enum.KeyCode.RightShift, Callback = function(kc) print("Keybind trocado para:", kc.Name) end })

-- Executor-style (example snippet):
-- local success, Lib = pcall(function()
--   return loadstring(game:HttpGet("https://example.com/Lib.lua"))()
-- end)
-- if success then
--   local window = Lib.createWindow({ title = "Minha UI", size = Vector2.new(470, 340), toggleKey = Enum.KeyCode.RightShift })
--   local tab = window:AddTab("Principal")
--   local sec = tab:AddSection("Geral")
--   sec:AddButton("Olá", function() print("Olá") end)
-- end
