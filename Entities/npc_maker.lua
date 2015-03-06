local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local Entity = {}
Entity.Status = true


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