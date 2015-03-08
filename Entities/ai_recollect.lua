local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local Entity = {}
Entity.Status = true


Entity.Type = "Point"
Entity.EditorTexture = "http://www.roblox.com/asset/?id=207047507"


Entity.KeyValues = {
  ["EntityName"] = ""; --Map name
}


Entity.Inputs = {
  ["Recollect"] = function(ent)
    if Entity.Status then
      warn(Orakel.Configuration.ErrorHeader.."Input 'Recollect' not yet implemented!")
      ent.Enabled.Value = not ent.Enabled.Value
    end
  end;
}


Entity.Kill = function()
  Entity.Status = false
end



return Entity