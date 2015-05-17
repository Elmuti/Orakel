local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local Entity = {}
Entity.Status = true
local assetLib = Orakel.LoadModule("AssetLib")



Entity.Type = "Brush"
Entity.EditorTexture = "http://www.roblox.com/asset/?id=220516410"

Entity.KeyValues = {
  ["EntityName"] = "";
  ["DustType"] = "Normal"; --Normal, Burning
  ["Intensity"] = 1.0;
}


Entity.Update = function(ent)
  print("creating particle emitter")
  local pe = Instance.new("ParticleEmitter", ent)
  pe.Transparency = 1
  pe.Lifetime = 20
  pe.Speed = NumberRange.new(0, -0.1)
  pe.VelocitySpread = 1
  
  if ent.DustType == "Burning" then
    pe.Texture = assetLib.Particles["dustmote_burn"]
    pe.LightEmission = 1
    pe.Rate = ent.Intensity.Value * 10
    pe.Size = NumberSequence.new({
      NumberSequenceKeypoint.new(0, 0, 0);
      NumberSequenceKeypoint.new(0.55, 0.312, 0.312);
      NumberSequenceKeypoint.new(1, 0, 0);
    })
  else
    pe.Texture = assetLib.Particles["dustmote"]
    pe.LightEmission = 0
    pe.Color = ColorSequence.new(
      Color3.new(139/255, 139/255, 139/255), 
      Color3.new(139/255, 139/255, 139/255)
    )
    pe.Size = NumberSequence.new({
      NumberSequenceKeypoint.new(0, 0, 0);
      NumberSequenceKeypoint.new(0.268, 0.0625, 0.0625);
      NumberSequenceKeypoint.new(1, 0, 0);
    })
    pe.Rate = ent.Intensity.Value * 100
  end
end




Entity.Kill = function(ent)
  Entity.Status = false
end




return Entity