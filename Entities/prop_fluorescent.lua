--THIS ENTITY IS OBSOLETE
--USE "LIGHT", "LIGHT_SPOT" OR "LIGHT_SURFACE" INSTEAD

local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local Entity = {}
Entity.Status = true

Entity.Type = "Brush"
Entity.EditorTexture = ""

Entity.KeyValues = {
  ["EntityName"] = "";
  ["Fluorescent"] = false;
}


Entity.Inputs = {}

Entity.Update = function(ent)
  while wait(1/20) do
    if ent.Fluorescent.Value then
      while true do
        wait(math.random(0.1, 3))
        local sl = ent.light_spot.SurfaceLight
        local pl = ent.light.PointLight
        pl.Enabled = not pl.Enabled
        sl.Enabled = not sl.Enabled
      end
    end
  end
end


Entity.Kill = function()
  Entity.Status = false
end



return Entity