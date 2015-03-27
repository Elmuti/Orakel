local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local Entity = {}
Entity.Status = true


Entity.Type = "Brush"
Entity.EditorTexture = "http://www.roblox.com/asset/?id=221530480"


Entity.KeyValues = {
  ["EntityName"] = ""; 
}


Entity.Inputs = {}


Entity.Kill = function()
  Entity.Status = false
end



return Entity