local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local Entity = {}
Entity.Status = true
local assetLib = Orakel.LoadModule("AssetLib")
local sndLib = Orakel.LoadModule("SoundLib")

Entity.Runtime = function(btn)
	print("initialized func_button, listening")
	while wait(1/20) do
		if btn.Clicked.Value and btn.Enabled.Value then
			if btn.TimesUsed.Value > 0 and btn.OnceOnly.Value then
				--print("Cant re-use a used button when OnceOnly is set to true!")
			else
				print("Using button")
				btn.TimesUsed.Value = btn.TimesUsed.Value + 1
				if assetLib.Sounds.Button[btn.SoundPressed.Value] ~= nil then
					sndLib.PlaySoundClient("3d", "", assetLib.Sounds.Button[btn.SoundPressed.Value], 0.5, 1, false, 5, btn)
					Orakel.RunScript(btn.Script.Value)
				else
					warn(Orakel.Configuration.WarnHeader.."Button has invalid SoundId!")
				end
				btn.Clicked.Value = false
			end
		end
	end
end


Entity.Kill = function()
	Entity.Status = false
end




return Entity