local events = game.ReplicatedStorage
local player = game.Players.LocalPlayer
local char = player.CharacterAdded:wait()
local torso = char:WaitForChild("Torso")
local head = char:WaitForChild("Head")
local hum = char:WaitForChild("Humanoid")
local run = game:GetService("RunService")

local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local animLib = Orakel.LoadModule("CruxAnimation")


local rigs = {}


function playAnimation(name, model, rigId)
	local rig
	local file = game.ReplicatedStorage.Animations:FindFirstChild(name)
	
	if file then
		local clip = animLib.AnimationClip.new(file)
		if rigs[rigId] ~= nil then
			rig = rigs[rigId]
			rig.Enabled = true
		else	
			rig = animLib.Skeleton.new(model)
			rig:AddClip(clip)
			rig.Enabled = true
			rigs[rigId] = rig
		end
		
		if rig:IsPlaying(name) then
			rig:Stop(name)
		end
		run.RenderStepped:wait()
		rig:Play(name)
	end
end


function stopAnimation(name, model, rigId)
	local rig
	if rigs[rigId] ~= nil then
		rig = rigs[rigId]
		if rig:IsPlaying(name) then
			rig:Stop(name)
		end
	end
end



function humanoidRunning(speed)
	if speed > 0 then
		stopAnimation("Idle", char, 1)
		playAnimation("Walk", char, 1)
	else
		stopAnimation("Walk", char, 1)
		playAnimation("Idle", char, 1)
	end
end



hum.Running:connect(humanoidRunning)
game.ReplicatedStorage.Events.PlayAnimation.OnClientEvent:connect(playAnimation)
