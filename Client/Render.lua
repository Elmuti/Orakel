local events = game.ReplicatedStorage
local player = game.Players.LocalPlayer
local char = player.CharacterAdded:wait()
local pgui = player.PlayerGui
local torso = char:WaitForChild("Torso")
local head = char:WaitForChild("Head")
local hum = char:WaitForChild("Humanoid")
local burning = false
local onfire = false
local burn
local burndps = 0
local fadingOutFire = false
local IsFalling = false


local Orakel = require(events.Orakel.Main)
local coreLib = Orakel.LoadModule("CoreLib")
local phys = Orakel.LoadModule("PhysLib")
local sndLib = Orakel.LoadModule("SoundLib")
local assetLib = Orakel.LoadModule("AssetLib")
local mathLib = Orakel.LoadModule("MathLib")
local npcLib = Orakel.LoadModule("NpcLib")
local camLib = Orakel.LoadModule("CameraLib")

local minDamageHeight = 15
local maxDamageHeight = 35
local damageTickrate = 2

_G.ignorecommon = {}
_G.ignorelist = {}
_G.entityignore = {}
_G.volume = 1
_G.bulletfadetime = 20

game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
Orakel.PrintStatus(script:GetFullName())

wait(1)

map = Orakel.GetMap()



function preloadAssets()
	local assets = Orakel.LoadModule("AssetLib")
	local list = {
		assets.spritesheets,
		assets.smokesprites,
		assets.bloodsplatter,
		assets.decals,
		assets.textures
	}
	local function recursivePreload(dir)
		if type(dir) == "string" then
			--print("Preloading "..dir)
			game:GetService("ContentProvider"):Preload(dir)
		elseif type(dir) == "table" then
			for _, val in pairs(dir) do
				if type(val) == "string" then
					if string.find(val, "www.roblox.com") then
						--print("Preloading "..val)
						game:GetService("ContentProvider"):Preload(val)
					end
				else
					recursivePreload(val)
				end
			end
		end
	end
	for _, t in pairs(list) do
		recursivePreload(t)
	end
end


local playerEffects = {}

function playerEffects.Fire()
	local fx = {}
	for _, bp in pairs(char:children()) do
		if bp:IsA("BasePart") then
			local f = Instance.new("Fire", bp)
			f.Name = "Fire"
			f.Size = 3
			f.Heat = 15
			table.insert(fx, f)
		end
	end
	return fx
end


function playerEffects.Clear(fx)
	print("playereffects.clear")
	for _, f in pairs(fx) do
		if f.ClassName == "Fire" then
			f.Enabled = false
			coroutine.resume(coroutine.create(function()
				wait(2)
				f:Destroy()
			end))
		end
	end
end



function updatePlayerclips()
	local map = Orakel.GetMap()
	if map ~= nil then
		for _, c in pairs(map.PlayerClip:children()) do
			if c.ClassName == "IntValue" then
				local new = Instance.new("Part", map.PlayerClip)
				new.Name = "PlayerClip"
				new.Anchored = true
				new.Transparency = 1
				new.formFactor = "Custom"
				new.Size = c.Size.Value
				new.CFrame = c.CFrame.Value
				c:Destroy()
			end
		end
	end
end

function _G.updateRaycastIgnoreList()
	updateRaycastIgnoreList()
end

function updateRaycastIgnoreList()
	local map = Orakel.GetMap()
	if map ~= nil then
		_G.ignorecommon = {map}
		_G.ignoreai = {workspace.Ignore, map.Entities}
		_G.ignorelist = {workspace.Ignore, map.Entities, map.Clip, map.NavClip, char}
		_G.entityignore = {workspace.Ignore, map.Entities.info_player_start, map.Clip, map.NavClip, char}
	end
end


function updateRender()
	--for _, p in pairs(char:children()) do
		--if p:IsA("BasePart") then
			--p.LocalTransparencyModifier = 1
		--end
	--end
	
end


function fireProx()
	local fireprox = 0
	local firedps = 0
	local ents = workspace:FindFirstChild("Entities", true)
	if ents == nil then
		return 0, 0
	end
	local dps = 0
	for _, e in pairs(ents:children()) do
		if e.Name == "env_fire" then
			local localFireDps = e.DPS.Value
			local rad = e.HurtRadius.Value
			if (torso.Position - e.Position).magnitude < (rad / 2) then
				fireprox = fireprox + 1
				firedps = firedps + localFireDps
			end
		end
	end
	return firedps, fireprox
end
			
function burnPlayer()
	if not onfire then
		onfire = true
		events.Events.ApplyEffect:FireServer("Fire")
		while true do
			wait(.05)
			if not burning then
				wait(4)
				print("onfire = false")
				onfire = false
				events.RemoveEffect:FireServer("Fire")
			end
		end
	end
end

function calcDps()
	local dps = 0
	local firedps, fireprox = fireProx()
	dps = dps + firedps
	if onfire then
		dps = dps + 10
	end
	if fireprox > 0 then
		if not burning then
			burning = true
			spawn(burnPlayer)
		end
	else
		burning = false
	end
	return dps
end


function humanoidFall(falling)
	IsFalling = falling
	if IsFalling then
		local maxHeight = 0
		while IsFalling do
			local height = math.abs(torso.Position.y)
			if height > maxHeight then
				maxHeight = height
			end
			wait(1/30)
		end
		local fallHeight = maxHeight - torso.Position.y
		local impactHeight = fallHeight - minDamageHeight
		if fallHeight > minDamageHeight then
		    local mult = ((minDamageHeight - maxDamageHeight) / 100)
            local dmg = (minDamageHeight - fallHeight) / mult
            dmg = mathLib.Round(dmg)
			npcLib.DealDamage(hum, dmg, "FALL")
		end
	end
end


function dpsTick()
	local cancel = false
	events.Events.MapChange.Event:connect(function()
		cancel = true
	end)
	while true do
		wait(1/damageTickrate)
		local dps = calcDps() / damageTickrate
		if dps > 0 then
			npcLib.DealDamage(hum, dps, "BURN")
		end
		if cancel then
			break
		end
	end
end


function IsPartInRegion(part, region)
	local list = workspace:FindPartsInRegion3WithIgnoreList(region, _G.ignorecommon)
	for i = 1, #list do
		if list[i] == part then
			return true
		end
	end
	return false
end

function IsHumanoidInRegion(region)
	local list = workspace:FindPartsInRegion3WithIgnoreList(region, _G.ignorecommon)
	for i = 1, #list do
		if list[i].Name == "Torso" then
			local hum = list[i].Parent:FindFirstChild("Humanoid")
			if hum then
				return hum
			end
		end
	end
	return nil
end





-------------------------------------------------------------------------
----------                                                     ----------
----------				INITIALIZE ENTITY RUNTIMES             ----------	
----------													   ----------			
-------------------------------------------------------------------------


--function initEntities()
--	local map = Orakel.GetMap()
--	if map ~= nil then
--		for _, entity in pairs(map.Entities:GetChildren()) do
--			local ent = Orakel.Configuration.Entities:FindFirstChild(entity.Name)
--			if ent then
--				spawn(function()
--					local sc = require(ent)
--					sc.Runtime(entity)
--				end)
--			end
--		end
--	end
--end



updateRaycastIgnoreList()
preloadAssets()
game:GetService("RunService").RenderStepped:connect(updateRender)
events.Events.UpdateRayCastIgnoreList.Event:connect(updateRaycastIgnoreList)
events.Events.MapLoad.Event:connect(dpsTick)
--events.Events.MapChange.OnClientEvent:connect(initEntities)
hum.FreeFalling:connect(humanoidFall)









