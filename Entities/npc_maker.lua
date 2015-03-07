local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local Entity = {}
Entity.Status = true


Entity.Type = "Point"
Entity.EditorTexture = "http://www.roblox.com/asset/?id=183645934"


Entity.KeyValues = {
  ["EntityName"] = "";
  ["Enabled"] = true;
  ["Frequency"] = 5;
  ["MaxNpcs"] = 10;
  ["NpcTemplate"] = "";
  ["NpcType"] = "";
  ["NumSpawns"] = 32;
  ["Weapons"] = "";
}


Entity.Inputs = {
  ["Toggle"] = function(ent)
    ent.Enabled.Value = not ent.Enabled.Value
  end;
}



Entity.Update = function(ent)

end


Entity.Kill = function()
  Entity.Status = false
end



return Entity