local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local sndLib = Orakel.LoadModule("SoundLib")
local Entity = {}
Entity.Status = true


Entity.Type = "Point"
Entity.EditorTexture = "http://www.roblox.com/asset/?id=229676666"

Entity.KeyValues = {
  ["EntityName"] = "";
  ["Sound"] = "";
  ["Volume"] = 1;
  ["Pitch"] = 1;
  ["Looped"] = false;
  ["Global"] = false;
  ["StartSilent"] = true;
  ["SourceEntity"] = "";
}


Entity.Inputs = {
  ["Play"] = function(ent)
    local stype = "3d"
    if ent.Global.Value then
      stype = "global"
    end
    sndLib.PlaySoundClient(
      stype, 
      "snd_ambient_generic", 
      Orakel.FindSound(ent.Sound.Value), 
      ent.Volume.Value, 
      ent.Pitch.Value, 
      ent.Looped.Value, 
      -1, 
      Orakel.FindEntity(ent.SourceEntity.Value) or ent
    )
  end;
  ["Stop"] = function(ent)
    local snd = ent:FindFirstChild("snd_ambient_generic", true)
    if snd then
      snd:Stop()
      Orakel.RemoveItem(snd, 1)
    end
  end;
}




Entity.Update = function(ent)
  if not ent.StartSilent.Value then
    Entity["Play"](ent)
  end
end


Entity.Kill = function()
  Entity.Status = false
end





return Entity