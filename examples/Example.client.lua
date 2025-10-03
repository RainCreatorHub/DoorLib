-- Example usage for UILibrary
-- Place this LocalScript under StarterPlayerScripts or run in Studio as a client

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Adjust the path below to wherever you put Lib.lua
-- For example, if you move Lib.lua into ReplicatedStorage as a ModuleScript:
-- local Lib = require(ReplicatedStorage:WaitForChild("Lib"))
-- In this repo layout, use a ModuleScript copy of roblox/Lib.lua in your game

local Lib --[[ = require(path_to_module_in_your_game) ]]

-- DEMO (pseudo):
-- local window = Lib.createWindow({
--   title = "Minha UI",
--   size = Vector2.new(470, 340),
--   toggleKey = Enum.KeyCode.RightShift,
--   startOpen = true,
-- })
-- local tabMain = window:AddTab("Principal")
-- local secGeneral = tabMain:AddSection("Geral")
-- secGeneral:AddLabel("Bem-vindo à UI!")
-- secGeneral:AddButton("Dizer Olá", function()
--   print("Olá do botão!")
-- end)
--
-- local toggle = secGeneral:AddToggle("Ativar Coisa", false, function(state)
--   print("Toggle:", state)
-- end)
--
-- local slider = secGeneral:AddSlider("Velocidade", 0, 100, 50, function(v)
--   print("Slider:", v)
-- end)
--
-- local dropdown = secGeneral:AddDropdown("Modo", {"Clássico","Rápido","Seguro"}, "Clássico", function(opt)
--   print("Dropdown:", opt)
-- end)
--
-- local textbox = secGeneral:AddTextbox("Digite algo", "mensagem", function(text)
--   print("Textbox:", text)
-- end)
--
-- local keybind = secGeneral:AddKeybind("Tecla de Toggle", Enum.KeyCode.RightShift, function(kc)
--   print("Keybind trocado para:", kc.Name)
-- end)

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
