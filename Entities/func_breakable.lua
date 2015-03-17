local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local Entity = {}
Entity.Status = true
local assetLib = Orakel.LoadModule("AssetLib")
local physLib = Orakel.LoadModule("PhysLib")


Entity.Type = "Brush"
Entity.EditorTexture = ""

Entity.KeyValues = {
  ["EntityName"] = "";
  ["Health"] = 100;
}


Entity.Inputs = {
  ["Damage"] = function(ent, dmg)
    ent.Health.Value = ent.Health.Value - dmg
  end;
  ["Break"] = function(ent)
    if ent:IsA("BasePart") then
      local origin = ent.Position
      local realmat = assetLib.RealMaterial:Get(ent)
      local texture = ent:FindFirstChild("Texture")
      physLib.SpawnGibs(origin, realmat, ent.Size, texture)
      ent:Destroy()
      Entity.Status = false
    else
      local children = Orakel.GetChildrenRecursive(ent)
      for _, child in pairs(children) do
        if child:IsA("BasePart") then
          local origin = child.Position
          local realmat = assetLib.RealMaterial:Get(child)
          local texture = child:FindFirstChild("Texture")
          physLib.SpawnGibs(origin, realmat, child.Size, texture)
          child:Destroy()
        end
      end
      Entity.Status = false
    end
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