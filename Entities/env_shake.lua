local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local Entity = {}
Entity.Status = true
local camLib = Orakel.LoadModule("CameraLib")

Entity.Runtime = function(ent)
	while wait(1/20) do
		if ent.Enabled.Value then
			local amp = ent.Amplitude.Value
			local dur = ent.Duration.Value
			local freq = ent.Frequency.Value
			local cam = workspace.CurrentCamera
			camLib.ShakeCamera(cam.CoordinateFrame, cam.Focus, freq, dur, true)
			ent.Enabled = false
		end
	end
end


Entity.Kill = function()
	Entity.Status = false
end



return Entity