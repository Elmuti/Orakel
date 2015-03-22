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
    local sl = ent:FindFirstChild("SurfaceLight")
    if sl then
      sl.Enabled = not sl.Enabled
    end
  end;
}




Entity.Update = function(ent)
end


Entity.Kill = function()
  Entity.Status = false
end





return Entity