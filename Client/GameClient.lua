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
  game.ReplicatedStorage.Events.ToggleLoadingDialog:Fire()
  local oldMap = Orakel.GetMap()
  if oldMap ~= nil then
    oldMap:Destroy()
  end
  local camLib = Orakel.LoadModule("CameraLib")
  camLib.SetCameraDefault(false, 0.1)
  game.ReplicatedStorage.Events.MapChange:Fire()
  currentMap = player.CurrentMap
  
  local map = game.ReplicatedStorage.Maps[mapname]
  currentMap.Value = mapLib.LoadMap(map)
  currentMap = currentMap.Value

  print("Waiting for player ready")
  repeat
    wait()
  until rdy.Value == true
  print("Player ready")
  wait(2)
  
  spawnPlayer(currentMap)
  wait(1)
  torso.Anchored = false
  wait(2)
  Orakel.InitEntities(currentMap)
  
  game.ReplicatedStorage.Events.ShowMenu:Fire()
  game.ReplicatedStorage.Events.UpdateRayCastIgnoreList:Fire()
  game.ReplicatedStorage.Events.ToggleLoadingDialog:Fire()
  game.ReplicatedStorage.Events.MapLoad:Fire()
end


initMap(Orakel.GameInfo.BackgroundLevel)
game.ReplicatedStorage.Events.InitNewMap.Event:connect(initMap)


