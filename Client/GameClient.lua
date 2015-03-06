local events = game.ReplicatedStorage
local player = game.Players.LocalPlayer
local char = player.CharacterAdded:wait()
local torso = char:WaitForChild("Torso")
local head = char:WaitForChild("Head")
local hum = char:WaitForChild("Humanoid")

local Orakel = require(game.ReplicatedStorage.Orakel.Main)


Orakel.PrintVersion()
Orakel.PrintStatus(script:GetFullName())
