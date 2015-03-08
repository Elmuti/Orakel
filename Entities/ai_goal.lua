local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local Entity = {}
Entity.Status = true


Entity.Type = "Point"
Entity.EditorTexture = "http://www.roblox.com/asset/?id=129531800"


Entity.KeyValues = {
  ["EntityName"] = ""; 
  ["WalkSpeed"] = 16;
}


Entity.Inputs = {}



Entity.Kill = function()
  Entity.Status = false
end



return Entity