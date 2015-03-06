local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local Entity = {}
Entity.Status = true
local sndLib = Orakel.LoadModule("SoundLib")


Entity.Runtime = function(ent)
	while wait(1/20) do
		if ent.Enabled.Value then
			local prim = ent:FindFirstChild("Primary") 
			if not prim then
				warn(Orakel.Configuration.ErrorHeader.." FUNC_MOVELINEAR DOES NOT HAVE A PRIMARYPART")
			end
			ent.PrimaryPart = prim
			local startSound = Orakel.FindSound(ent.StartSound.Value)
			local stopSound = Orakel.FindSound(ent.StopSound.Value)
			local moveSound = Orakel.FindSound(ent.MoveSound.Value)
			startSound = sndLib.PlaySoundClient("3d", "", startSound, 1, 1, false, 10, ent.Primary)
			moveSound = sndLib.PlaySoundClient("3d", "", moveSound, 1, 1, false, ent.Duration.Value + 2, ent.Primary)
			Orakel.TweenModel(
				ent, 
				ent.Primary.CFrame, 
				CFrame.new(ent.Goal.Value), 
				ent.Duration.Value
			)
			stopSound = sndLib.PlaySoundClient("3d", "", stopSound, 1, 1, false, 10, ent.Primary)
			ent.Enabled.Value = false
		end
	end
end


Entity.Kill = function()
	Entity.Status = false
end





return Entity