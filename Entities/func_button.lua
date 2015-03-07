local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local Entity = {}
Entity.Status = true
local assetLib = Orakel.LoadModule("AssetLib")
local sndLib = Orakel.LoadModule("SoundLib")


Entity.Type = "Brush"
Entity.EditorTexture = ""

Entity.KeyValues = {
  ["EntityName"] = "";
  ["Enabled"] = true;
  ["HoldToUse"] = false;
  ["OnceOnly"] = true;
  ["Radius"] = 20;
  ["Script"] = "";
  ["SoundPressed"] = "";
  ["TimesUsed"] = 0;
  ["Clicked"] = false;
}

Entity.Inputs = {
  ["Use"] = function(btn)
    if btn.Enabled.Value then
        if btn.TimesUsed.Value > 0 and btn.OnceOnly.Value then
          --print("Cant re-use a used button when OnceOnly is set to true!")
        else
          btn.TimesUsed.Value = btn.TimesUsed.Value + 1
          if assetLib.Sounds.Button[btn.SoundPressed.Value] ~= nil then
            sndLib.PlaySoundClient("3d", "", Orakel.FindSound(btn.SoundPressed.Value), 0.5, 1, false, 5, btn)
            Orakel.RunScript(btn.Script.Value)
          else
            warn(Orakel.Configuration.WarnHeader..ent.EntityName.Value.." has invalid SoundId!")
          end
          btn.Clicked.Value = false
        end
    end
  end;
 }



Entity.Update = function(btn)
end


Entity.Kill = function(ent)
	Entity.Status = false
end




return Entity