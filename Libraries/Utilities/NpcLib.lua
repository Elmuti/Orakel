eng = {}

local PathTimeEstimateFailSafe = 2



function eng.GetRealBodyPart(bp)
	if bp == "Left Arm" or bp == "Right Arm" then
		return "Arms"
	elseif bp == "Left Leg" or bp == "Right Leg" then
		return "Legs"
	elseif bp == "Torso" then
		return "Torso"
	else
		return "Head"
	end
end


function eng.DealDamage(target, damage, dtype)
	local Orakel = require(game.ReplicatedStorage.Orakel.Main)
	local sndLib = Orakel.LoadModule("SoundLib")
	local assetLib = Orakel.LoadModule("AssetLib")
	local killSounds = assetLib.Player.Hurt["DEATH"]
	local isServer = (game.Players.LocalPlayer == nil)

	local cval = function(target, dtype)
		local dval = Instance.new("StringValue", target)
		dval.Name = "LastDamageType"
		dval.Value = dtype
	end
	
	print("Dealing "..damage.." of "..dtype.." damage to "..target.Parent:GetFullName())
	local sndId = assetLib.Player.Hurt[dtype]
	if target.ClassName == "Humanoid" then
		cval(target, dtype)
		target.Health = target.Health - damage
		if target.Health <= 0 then
			if isServer then
				game.ReplicatedStorage.Events.PlaySoundClient:FireAllClients("3d", "snd_death", killSounds[math.random(1,#killSounds)], 1, 1, false, 2, target.Parent.Head)
			else
				sndLib.PlaySoundClient("3d", "snd_death", killSounds[math.random(1,#killSounds)], 1, 1, false, 2, target.Parent.Head)
			end
		end
	elseif target.ClassName == "NumberValue" then
		cval(target, dtype)
		target.Value = target.Value - damage
		if target.Value <= 0 then
			if isServer then
				game.ReplicatedStorage.Events.PlaySoundClient:FireAllClients("3d", "snd_death", killSounds[math.random(1,#killSounds)], 1, 1, false, 2, target.Parent.Head)
			else
				sndLib.PlaySoundClient("3d", "snd_death", killSounds[math.random(1,#killSounds)], 1, 1, false, 2, target.Parent.Head)
			end
		end
	end
	if game.Players.LocalPlayer ~= nil then
		if target.Parent == game.Players.LocalPlayer.Character then
			if dtype == "DROWN" then
				if not target:FindFirstChild("Drowned") then
					sndLib.PlaySoundClient("global", "snd_hurt", sndId, 1, 1, false, 3)
					local dr = Instance.new("BoolValue", target)
					dr.Name = "Drowned"
					dr.Value = true
				end
			else
				sndLib.PlaySoundClient("global", "snd_hurt", sndId, 1, 1, false, 3)
			end
		end
	end
end



function eng.LineOfSight(a, b, dist, ignore)
	local pos1 = a
	local isVector = pcall(function() 
		local x = a.x
	end)
	if not isVector then
		pos1 = a.Position
	end
	local pos2 = b.Position
	local ray = Ray.new(pos1,(pos2-pos1).unit * dist)
	local hit,pos = workspace:FindPartOnRayWithIgnoreList(ray,ignore)
	if hit == b then
		return true
	end
	return false
end



function eng.EstimatedPathTime(a, b, ws)
	local dist = (a - b).magnitude
	return (dist / ws) + PathTimeEstimateFailSafe
end





return eng