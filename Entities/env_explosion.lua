local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local Entity = {}
Entity.Status = true
local assetLib = Orakel.LoadModule("AssetLib")
local phys = Orakel.LoadModule("PhysLib")
local sndLib = Orakel.LoadModule("SoundLib")

Entity.Type = "Point"
Entity.EditorTexture = "http://www.roblox.com/asset/?id=220513937"

Entity.KeyValues = {
  ["EntityName"] = "";
  ["Enabled"] = true;
  ["IsVisual"] = true;
  ["KillRadius"] = 8;
  ["MaxRadius"] = 32;
  ["DamageMultiplier"] = 1;
  ["ExplosionSound"] = "c4";

}


Entity.Inputs = {
  ["Explode"] = function(ent)
    if ent.Enabled.Value then
      if Orakel.FindSound(ent.ExplosionSound.Value) ~= nil then
        sndLib.PlaySoundClientAsync("3d", "", Orakel.FindSound(ent.ExplosionSound.Value), 1, 1, false, 10, ent)
      else
        warn(Orakel.Configuration.WarnHeader..ent.EntityName.Value.." tried to play sound '"..ent.ExplosionSound.Value.."' which does not exist!")
      end
      phys.Explosion(ent.Position, ent.IsVisual.Value, ent.DamageMultiplier.Value, ent.MaxRadius.Value, ent.KillRadius.Value)
    end
  end;
}




Entity.Update = function(ent)
end


Entity.Kill = function()
	Entity.Status = false
end





return Entity