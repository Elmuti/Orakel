local player = game.Players.LocalPlayer
local char = player.CharacterAdded:wait()
local torso = char:WaitForChild("Torso")
local pgui = player:WaitForChild("PlayerGui")
local events = game.ReplicatedStorage
local cam = workspace.CurrentCamera
local currentLightEnv

local Orakel = require(events.Orakel.Main)
local tLib = Orakel.LoadModule("TweenLib")
local npcLib = Orakel.LoadModule("NpcLib")

wait(5)

Orakel.PrintStatus(script:GetFullName())

function changeAmb(p)
	--print("!!!!!! CHANGING LIGHT ENVIRONMENT !!!!!!")
	local params = p:children()
	local skySides = p["Skybox"]:children()
	for k,v in pairs(params) do
		if not v.Name == "Skybox" or not v.Name == "MissionType" then
			if v.Name == "Ambient" or v.Name == "OutdoorAmbient" or v.Name == "FogColor" or v.Name == "Brightness" then
				tLib:TweenRenderAsync(game.Lighting, v.Name, v.Value, "Linear", 1)
			else
				game.Lighting[v.Name] = v.Value
			end
		end
	end
	local sky = game.Lighting:findFirstChild("Sky")
	if not sky then 
		sky = Instance.new("Sky",game.Lighting)
	end
	for k,v in pairs(skySides) do
		if v.Name == "CelestialBodiesShown" then
			sky.CelestialBodiesShown = v.Value
		elseif v.Name == "starcount" then
			sky.StarCount = v.Value
		else
			sky["Skybox"..v.Name] = v.Value
		end
	end
end




function bestLightEnv()
	--
	--	returns nearest visible light_env
	--	if none visible, gets nearest
	--
	local map
	local mapname = events.Events.GetGameValue:InvokeServer("CurrentMap")
	if mapname ~= nil then
		map = workspace:findFirstChild(mapname)
	end
	
	if map ~= nil then
		local ents = map.Entities
		local sslist = {}
		for _, ent in pairs(ents:GetChildren()) do
			if ent.Name == "light_env" then
				table.insert(sslist, ent)
			end
		end

		local vis = {}
		local best
		local nearest = sslist[1]
		local nearestVis
		for _, ss in pairs(sslist) do
			if npcLib.LineOfSight(cam.CoordinateFrame.p, ss, 512, _G.ignorelist) then
				table.insert(vis, ss)
			end
		end

		if #vis > 0 then
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
			for i = 2, #sslist do
				local oldDist = (cam.CoordinateFrame.p - nearest.Position).magnitude
				local newDist = (cam.CoordinateFrame.p - sslist[i].Position).magnitude
				if newDist < oldDist then
					nearest = sslist[i]
				end
			end
			best = nearest
		end
		
		if best ~= nil then
			return best["_parameters"]
		end
	end
	return nil
end

function updateLightEnv()
	local best = bestLightEnv()
	if best ~= nil then
		if best ~= currentLightEnv then
			changeAmb(best)
			currentLightEnv = best
		end
	end
end

while true do
	updateLightEnv()
	wait(.25)
end