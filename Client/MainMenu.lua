local player = game.Players.LocalPlayer
local char = player.CharacterAdded:wait()
local torso = char:WaitForChild("Torso")
local pgui = player.PlayerGui
local menu = pgui:FindFirstChild("Menu")
local frame
local currentMap = player:FindFirstChild("CurrentMap")


local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local sndLib = Orakel.LoadModule("SoundLib")

if not menu then
  menu = Instance.new("ScreenGui", pgui)
  menu.Name = "Menu"
end


local listPosition = UDim2.new(0.15, 0, 0.5, 0)
local listSize = UDim2.new(0.2, 0, 0.4, 0)
local buttonSize = Orakel.GameInfo.Menu.ButtonSize

function buttonClickSound()
  sndLib.PlaySoundClient("global", "", Orakel.FindSound("Beep"), 0.4, 1, false, 4)
end


function createButton(text, pos, func)
  local tb = Instance.new("TextButton")
  tb.Position = pos
  tb.Size = buttonSize
  tb.BackgroundTransparency = 1
  tb.TextXAlignment = Enum.TextXAlignment.Left
  tb.Font = Orakel.GameInfo.Menu.Font
  tb.FontSize = Orakel.GameInfo.Menu.FontSize
  tb.Name = text
  tb.Text = text
  tb.Parent = frame
  tb.Modal = true
  tb.TextColor3 = Color3.new(1, 1, 1)
  tb.MouseEnter:connect(function()
    sndLib.PlaySoundClient("global", "", Orakel.FindSound("Click"), 0.4, 1, false, 4)
    tb.TextColor3 = Color3.new(.8, .8, .8)
  end)
  tb.MouseLeave:connect(function()
    tb.TextColor3 = Color3.new(1, 1, 1)
  end)
  tb.MouseButton1Click:connect(func)
  tb.MouseButton1Click:connect(buttonClickSound)
  return tb
end


function newGame()
  menu:Destroy()
  torso.Anchored = true
  game.ReplicatedStorage.Events.InitNewMap:Fire(Orakel.GameInfo.StartLevel)
end

function loadGame()


end

function options()


end

function quitGame()


end


function initMenu()
  frame = Instance.new("Frame")
  frame.Size = listSize
  frame.Position = listPosition
  frame.BackgroundTransparency = 1
  frame.Parent = menu
  
  local logo = Instance.new("ImageLabel")
  logo.Position = UDim2.new(0.15, 0, 0.2, 0)
  logo.Size = UDim2.new(0.39, 0, 0.15, 0)
  logo.Image = Orakel.GameInfo.Menu.Icon
  logo.BackgroundTransparency = 1
  logo.Parent = menu

  local newButton = createButton("NEW GAME", UDim2.new(0, 0, 0, 0), newGame)
  local loadButton = createButton("LOAD GAME", UDim2.new(0, 0, 0.11, 0), loadGame)
  local optButton = createButton("OPTIONS", UDim2.new(0, 0, 0.22, 0), options)
  local quitButton = createButton("QUIT", UDim2.new(0, 0, 0.33, 0), quitGame)
end


game.ReplicatedStorage.Events.ShowMenu.Event:connect(initMenu)

