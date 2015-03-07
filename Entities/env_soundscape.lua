--THIS ENTITY DOESN'T RUN ON IT'S OWN.
--IT REQUIRES TO BE PARSED BY Client/Sound.lua

local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local Entity = {}
Entity.Status = true


Entity.Type = "Point"
Entity.EditorTexture = "http://www.roblox.com/asset/?id=183645930"


Entity.KeyValues = {
  ["EntityName"] = "";
  ["Soundscape"] = "";
}


Entity.Inputs = {}

Entity.Update = function(ent)
end


Entity.Kill = function()
  Entity.Status = false
end



return Entity