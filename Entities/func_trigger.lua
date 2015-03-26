local player = game.Players.LocalPlayer
local char = player.Character
local pgui = player.PlayerGui
local torso = char:WaitForChild("Torso")
local head = char:WaitForChild("Head")
local hum = char:WaitForChild("Humanoid")
local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local Entity = {}
Entity.Status = true
local sndLib = Orakel.LoadModule("SoundLib")
local assetLib = Orakel.LoadModule("AssetLib")

Entity.Type = "Brush"
Entity.EditorTexture = "http://www.roblox.com/asset/?id=221530480"

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
  ["Enabled"] = true;
  ["OnceOnly"] = true;
  ["StayInArea"] = false;
  ["AreaTime"] = 5;
  ["Script"] = "";
  ["SoundTriggered"] = "";
  ["TimesUsed"] = 0;
  ["TargetEntity"] = "";
  ["TargetInput"] = ""
}


Entity.Inputs = {}

Entity.Outputs = {"OnTrigger", "OnEndTrigger"}


Entity.Update = function(trigger)
	local Success = true
	local Enabled = trigger.Enabled
	local StayInArea = trigger.StayInArea
	local OnceOnly = trigger.OnceOnly
	local Script = trigger.Script
	local Sound = trigger.SoundTriggered
	local TimesUsed = trigger.TimesUsed
	local AreaTime = trigger.AreaTime
	local Region = Region3.new(
		trigger.Position - trigger.Size / 2, 
		trigger.Position + trigger.Size / 2
	)
	while wait(1/10) do
		if Enabled.Value then
			if TimesUsed.Value > 0 and OnceOnly.Value then
				--print("Cannot re-trigger a used trigger")
			else
				if IsPartInRegion(torso, Region) then
					TimesUsed.Value = TimesUsed.Value + 1
					if StayInArea.Value then
						Success = false
						local t = 0
						while true do
							local act = wait(1/5)
							t = t + act
							if not IsPartInRegion(torso, Region) then
								Success = false
								break
							end
							if t >= AreaTime.Value then
								Success = true
								break
							end
						end
					end
					
					if Success then
						Orakel.FireOutput(trigger, "OnTrigger")
						Orakel.RunScript(Script.Value)
						
						if trigger.TargetEntity.Value ~= "" and trigger.TargetInput.Value ~= "" then
						  local targEnt = Orakel.FindEntity(trigger.TargetEntity.Value)
						  local targInp = trigger.TargetInput.Value
						  if targEnt ~= nil then
						    Orakel.FireInput(targEnt, targInp)
						  else
						    warn(Orakel.Configuration.WarnHeader.."Entity '"..trigger.TargetEntity.Value.."' does not exist! Cannot trigger input from trigger!")
						  end
						end

						if Orakel.FindSound(Sound.Value) ~= nil then
							sndLib.PlaySoundClient("3d", "", Orakel.FindSound(Sound.Value), 0.5, 1, false, 5, trigger)
						else
							warn(Orakel.Configuration.WarnHeader.."Trigger has invalid SoundId!")
						end
					end
				end
			end
		end
	end
end


Entity.Kill = function()
	Entity.Status = false
end




return Entity