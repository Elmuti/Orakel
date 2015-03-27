local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local Entity = {}
Entity.Status = true


Entity.Type = "Point"
Entity.EditorTexture = ""

Entity.KeyValues = {
  ["EntityName"] = "";
  ["Enabled"] = true;
  ["UseRandomInterval"] = false;
  ["MinInterval"] = 1;
  ["MaxInterval"] = 10;
  ["RefireInterval"] = 1;
}


Entity.Inputs = {
  ["Toggle"] = function(ent)
    ent.Enabled.Value = not ent.Enabled.Value
  end;
}

Entity.Outputs = {"OnTimer"}


local function getTimerInterval(ent)
  local useRand = Orakel.GetKeyValue(ent, "UseRandomInterval")
  local min = Orakel.GetKeyValue(ent, "MinInterval")
  local max = Orakel.GetKeyValue(ent, "MaxInterval")
  local int = Orakel.GetKeyValue(ent, "RefireInterval")
  if useRand then
    return math.random(min, max)
  end
  return int
end


Entity.Update = function(ent)
  while wait(1/20) do
    if ent.Enabled.Value then
      while wait(getTimerInterval(ent)) do
        Orakel.FireOutput(ent, "OnTimer")
      end
    end
  end
end


Entity.Kill = function()
  Entity.Status = false
end





return Entity