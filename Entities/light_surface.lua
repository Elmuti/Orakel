local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local ltLib = Orakel.LoadModule("LightingLib")
local Entity = {}
Entity.Status = true


Entity.Type = "Point"
Entity.EditorTexture = ""

Entity.KeyValues = {
  ["EntityName"] = "";
  ["Appearance"] = "";
  ["EntityToLookAt"] = "";
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
  while wait(1/20) do
    local sl = ent:FindFirstChild("SurfaceLight")
    if sl then
      if sl.Enabled then
        local br = sl.Brightness
        local app = ent.Appearance.Value
        local len = app:len()
        local int = ltLib.UpdateInterval
        if len > 1 then
          while true do
            for c = 1, len do
              local nbr = ltLib.BrightFromChar(app:sub(c,c))
              sl.Brightness = nbr
              wait(int)
            end
          end
        end
      end
    end
  end
end


Entity.Kill = function()
  Entity.Status = false
end





return Entity