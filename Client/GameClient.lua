local events = game.ReplicatedStorage
local player = game.Players.LocalPlayer
local char = player.CharacterAdded:wait()
local torso = char:WaitForChild("Torso")
local head = char:WaitForChild("Head")
local hum = char:WaitForChild("Humanoid")
local rdy = player:WaitForChild("Ready")
local currentMap = Instance.new("ObjectValue", player)
currentMap.Name = "CurrentMap"

local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local mapLib = Orakel.LoadModule("MapLib")

Orakel.PrintVersion()
Orakel.PrintStatus(script:GetFullName())



function spawnPlayer(map)
  print("Spawning player")
  local spawn = map.Entities["info_player_start"]
  torso.CFrame = spawn.Torso.CFrame
end


function initMap(mapname)
  game.ReplicatedStorage.Events.MapChange:Fire()
  
  local map = game.ReplicatedStorage.Maps[mapname]
  currentMap.Value = mapLib.LoadMap(map, currentMap.Value)
  currentMap = currentMap.Value
  
  game.ReplicatedStorage.Events.ToggleLoadingDialog:Fire(currentMap.LevelName.Value, currentMap.Image.Value)
  
  print("Waiting for player ready")
  repeat
    wait()
  until rdy.Value == true
  print("Player ready")
  
  spawnPlayer(currentMap)
  
  game.ReplicatedStorage.Events.UpdateRayCastIgnoreList:Fire()
  game.ReplicatedStorage.Events.MapLoad:Fire()
  game.ReplicatedStorage.Events.ToggleLoadingDialog:Fire(currentMap.LevelName.Value, currentMap.Image.Value)
  
  Orakel.InitEntities(currentMap)
end


initMap(Orakel.GameInfo.StartLevel)


