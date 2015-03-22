local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local Entity = {}
Entity.Status = true


Entity.Type = "Point"
Entity.EditorTexture = ""

Entity.KeyValues = {
  ["EntityName"] = "";
}


Entity.Inputs = {
  ["Toggle"] = function(ent)
    local pl = ent:FindFirstChild("PointLight")
    if pl then
      pl.Enabled = not pl.Enabled
    end
  end;
}




Entity.Update = function(ent)
end


Entity.Kill = function()
  Entity.Status = false
end





return Entity