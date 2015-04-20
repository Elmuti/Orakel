local player = game.Players.LocalPlayer
local char = player.Character
local pgui = player.PlayerGui
local torso = char:WaitForChild("Torso")
local head = char:WaitForChild("Head")
local hum = char:WaitForChild("Humanoid")
local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local Entity = {}
Entity.Status = true
local npcLib = Orakel.LoadModule("NpcLib")


Entity.Type = "Brush"
Entity.EditorTexture = "http://www.roblox.com/asset/?id=220516410"

local function IsPartInRegion(part, region)
	local list = workspace:FindPartsInRegion3WithIgnoreList(region, _G.ignorecommon)
	for i = 1, #list do
		if list[i] == part then
			return true
		end
	end
	return false
end

local function IsHumanoidInRegion(region)
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

Entity.KeyValues = {
  ["EntityName"] = "";
  ["Interval"] = 1;
  ["Radius"] = 0;
  ["Enabled"] = true;
  ["Damage"] = 1;
  ["DamageType"] = "DROWN";
}


Entity.Inputs = {}

Entity.Load = function(ent)
  for _, c in pairs(ent:GetChildren()) do
    if c.ClassName == "Texture" then
      c:Destroy()
    end
  end
end

Entity.Update = function(trigger)
	local Enabled = trigger.Enabled
	local DamageType = trigger.DamageType
	local Radius = trigger.Radius
	local Interval = trigger.Interval
	local Damage = trigger.Damage


	local Region = Region3.new(
		trigger.Position - trigger.Size / 2, 
		trigger.Position + trigger.Size / 2
	)
	while wait(Interval.Value) do
		if Enabled.Value then
			if Radius.Value <= 0 then
				local hum = IsHumanoidInRegion(Region)
				if hum ~= nil then
					npcLib.DealDamage(hum, Damage.Value, DamageType.Value)
					local hval = hum.Parent:FindFirstChild("Health")
					if hval then
						if hval.ClassName == "NumberValue" then
							npcLib.DealDamage(hval, Damage.Value, DamageType.Value)
						end
					end
				end
			else
				for _, npc in pairs(workspace.npcCache:children()) do
					local dist = (npc.Torso.Position - trigger.Position).magnitude
					if dist <= Radius.Value then
						local hval = npc:FindFirstChild("Health")
						npcLib.DealDamage(hval, Damage.Value, DamageType.Value)
					end
				end
				local dist = (torso.Position - trigger.Position).magnitude
				if dist <= Radius.Value then
					npcLib.DealDamage(hum, Damage.Value, DamageType.Value)
				end
			end
		end
	end
end


Entity.Kill = function()
	Entity.Status = false
end



return Entity