--THIS ENTITY DOESN'T RUN ON IT'S OWN.
--IT REQUIRES TO BE PARSED BY Client/Lighting.lua


local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local Entity = {}
Entity.Status = true


Entity.Type = "Point"
Entity.EditorTexture = "http://www.roblox.com/asset/?id=185590198"


Entity.KeyValues = {
  ["EntityName"] = "";
  ["Enabled"] = true;
  --_parameters
}


Entity.Inputs = {
  ["ChangeParam"] = function(ent, param, newVal)
    local params = ent:FindFirstChild("_parameters")
    if params then
      local ex = params:FindFirstChild(param, true)
      if ex then
        ex.Value = newVal
      end
    else
      warn(Orakel.Configuration.ErrorHeader.."_parameters not found in light_env!")
    end
  end;
}

Entity.Update = function(ent)
end


Entity.Kill = function()
  Entity.Status = false
end



return Entity