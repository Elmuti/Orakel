local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local Entity = {}
Entity.Status = true
local assetLib = Orakel.LoadModule("AssetLib")
local phys = Orakel.LoadModule("PhysLib")
local sndLib = Orakel.LoadModule("SoundLib")

Entity.Runtime = function(e)
	while wait(1/20) do
		if e.Enabled.Value then
			if assetLib.Sounds.Explosion[e.ExplosionSound.Value] ~= nil then
				sndLib.PlaySoundClientAsync("3d", "", assetLib.Sounds.Explosion[e.ExplosionSound.Value], 1, 1, false, 10, e)
			else
				warn(Orakel.Configuration.WarnHeader..e.EntityName.Value.." tried to play sound '"..e.ExplosionSound.Value.."' which does not exist!")
			end
			phys.Explosion(e.Position, e.IsVisual.Value, e.DamageMultiplier.Value, e.MaxRadius.Value, e.KillRadius.Value)
			e.Enabled.Value = false
		end
	end
end


Entity.Kill = function()
	Entity.Status = false
end





return Entity