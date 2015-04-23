--This file is a homage to a close friend of mine
--It should be ignored
--WU LA CLAN REPRESENT

local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local Entity = {}
Entity.Status = true
local physLib = Orakel.LoadModule("PhysLib")


Entity.Type = "Point"
Entity.EditorTexture = ""


Entity.KeyValues = {
  ["EntityName"] = "";
  ["DestructionMode"] = true; --walsu equals destruction, this is never false
}


Entity.Inputs = {
  ["InitiateDestruction"] = function(ent)
    print("killing all living beings with explosions")
    for numex = 1, 512 do
      local point = Vector3.new(
        math.random(-512, 512),
        math.random(-512, 512),
        math.random(-512, 512)
      )
      physLib.Explosion(point, true, 1000, 10240, 10240)
    end
  end;
}

Entity.Load = function(ent)
  print("destruction imminent, run for your lives")
end

Entity.Update = function(trigger)

end


Entity.Kill = function()
  print("Walsu is not kill. Walsu is never kill.")
end



return Entity