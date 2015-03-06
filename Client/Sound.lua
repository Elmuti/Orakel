local player = game.Players.LocalPlayer
local char = player.CharacterAdded:wait()
local torso = char:WaitForChild("Torso")
local cam = workspace.CurrentCamera
local events = game.ReplicatedStorage
local pgui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local currentScape
local Orakel = require(events.Orakel.Main)
local npclib = Orakel.LoadModule("NpcLib")
local soundscapes = Orakel.LoadModule("Soundscapes")
local sndLib = Orakel.LoadModule("SoundLib")

while _G.volume == nil do wait() end

local createSound = sndLib.CreateSound
local playSoundClientEvent = sndLib.PlaySoundClientEvent
local playSoundClient = sndLib.PlaySoundClient
local stopSoundClient = sndLib.StopSoundClient
local stopAllSoundsClient = sndLib.StopAllSoundsClient
local fadeSound = sndLib.FadeSound

Orakel.PrintStatus(script:GetFullName())

function bestSoundscape()
	--
	--	returns nearest visible soundscape
	--	if none visible, gets nearest
	--
	local map = Orakel.GetMap()
	
	if map ~= nil then
		local ents = map.Entities
		local sslist = {}
		for _, ent in pairs(ents:GetChildren()) do
			if ent.Name == "env_soundscape" then
				table.insert(sslist, ent)
			end
		end

		local vis = {} --scapes with LoS
		local prox = {} --scapes in proximity
		local best
		local nearest = sslist[1]
		local nearestVis
		for _, ss in pairs(sslist) do
			if npclib.LineOfSight(cam.CoordinateFrame.p, ss, 512, _G.ignorelist) then
				table.insert(vis, ss)
			end
		end

		if #vis > 0 then 
			--NEAREST VISIBLE FOUND
			nearestVis = vis[1]
			for i = 2, #vis do
				local oldDist = (cam.CoordinateFrame.p - nearestVis.Position).magnitude
				local newDist = (cam.CoordinateFrame.p - vis[i].Position).magnitude
				if newDist < oldDist then
					nearestVis = vis[i]
				end
			end
			best = nearestVis
		else 
			--NEAREST VISIBLE DOES NOT EXIST, STAY WITH ORIGINAL SOUNDSCAPE
			best = currentScape
		end
		
		if best ~= nil then
			if type(best) ~= "string" then
				return best.Soundscape.Value
			end
		end
	end
	return nil
end


function updateSoundscape()
	local map = Orakel.GetMap()
	if map ~= nil then
		local best = bestSoundscape()
		if currentScape ~= best then
			if best ~= nil then
				currentScape = best
				local ss = soundscapes[best]
				local main = ss["Main"]
				local rand = ss["Random"]
				local reverb = ss.Reverb
				game.SoundService.AmbientReverb = reverb

				for _, s in pairs(pgui.AmbientSounds:GetChildren()) do
					coroutine.resume(coroutine.create(function()
						fadeSound(s, 0, 2)
						s:Stop()
						s:Destroy()
					end))
				end
				
				for name, props in pairs(main) do
					if not pgui.AmbientSounds:FindFirstChild(name) then
						coroutine.resume(coroutine.create(function()
							local s = playSoundClient("global", name, props[1], 0, props[3], true)
							fadeSound(s, props[2], 2)
						end))
					end
				end
		
				for name, props in pairs(rand) do
					coroutine.resume(coroutine.create(function()
						local oldScape = currentScape
						local name, props = name, props
						while wait(math.random(props[1][1],props[1][2])) do
							if currentScape ~= oldScape then
								break
							end
							playSoundClient("global", name, props[2], props[3], props[4], false)
						end
					end))
				end
			end
		end
	end
end


function updateLoop()
	spawn(function()
		while true do
			updateSoundscape()
			wait(.25)
		end
	end)
end




game.ReplicatedStorage.Events.MapLoad.OnClientEvent:connect(updateLoop)
game.ReplicatedStorage.Events.PlaySoundClient.OnClientEvent:connect(playSoundClientEvent)