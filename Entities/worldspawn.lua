local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local Entity = {}
Entity.Status = true


Entity.Type = "worldspawn"
Entity.EditorTexture = ""


Entity.KeyValues = {
  ["EntityName"] = ""; --Map name
  ["Description"] = ""; --Map's description / title.
  ["Message"] = ""; --Chapter Title that appears onscreen when this level starts.
  ["IsCold"] = false; --Do characters breathe steam?
  ["ShowGameTitle"] = false; --Show game title on load
}


Entity.Inputs = {}

Entity.Update = function(ent)
  Entity.KeyValues["EntityName"] = ent.Name
end


Entity.Kill = function()
	Entity.Status = false
end



return Entity