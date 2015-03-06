local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local Entity = {}
Entity.Status = true
local assetLib = Orakel.LoadModule("AssetLib")
local physLib = Orakel.LoadModule("PhysLib")


Entity.KeyValues = {
  ["EntityName"] = "";
  ["Health"] = 10;
}


Entity.Inputs = {
  ["Break"] = function(ent)
    local origin = ent.Position
    local realmat = assetLib.RealMaterial:Get(ent)
    local texture = ent:FindFirstChild("Texture")
    physLib.SpawnGibs(origin, realmat, ent.Size, texture)
  end;
}



Entity.Update = function(ent)
  while wait(1/20) do
    if ent.Health.Value <= 0 then
      Entity.Inputs["Break"](ent)
      break
    elseif not Entity.Status then
      break
    end
  end
end


Entity.Kill = function()
  Entity.Status = false
end



return Entity