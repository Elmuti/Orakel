local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local Entity = {}
Entity.Status = true


Entity.Type = "Point"
Entity.EditorTexture = ""

Entity.KeyValues = {
  ["EntityName"] = "";
  ["InitialValue"] = 0;
  ["MinValue"] = 0;
  ["MaxValue"] = 100;
  ["Counter"] = 0
}

local function getCounterConstrained(ent)
  local min = Orakel.GetKeyValue(ent, "MinValue")
  local max = Orakel.GetKeyValue(ent, "MaxValue")
  local c = Orakel.GetKeyValue(ent, "Counter")
  Orakel.FireOutput(ent, "OutValue")
end

local function checkHit(ent)
  local min = Orakel.GetKeyValue(ent, "MinValue")
  local max = Orakel.GetKeyValue(ent, "MaxValue")
  local c = Orakel.GetKeyValue(ent, "Counter")
  if c <= min then
    Orakel.FireOutput(ent, "OnHitMin")
  elseif c >= max then
    Orakel.FireOutput(ent, "OnHitMax")
  end
end


Entity.Inputs = {
  ["Add"] = function(ent, amount)
    local c = Orakel.GetKeyValue(ent, "Counter")
    Orakel.SetKeyValue(ent, "Counter", c + amount)
    checkHit(ent)
  end;
  ["Divide"] = function(ent, amount)
    local c = Orakel.GetKeyValue(ent, "Counter")
    Orakel.SetKeyValue(ent, "Counter", c / amount)
    checkHit(ent)
  end;
  ["Multiply"] = function(ent, amount)
    local c = Orakel.GetKeyValue(ent, "Counter")
    Orakel.SetKeyValue(ent, "Counter", c * amount)
    checkHit(ent)
  end;
  ["SetValue"] = function(ent, amount)
    Orakel.SetKeyValue(ent, "Counter", amount)
    checkHit(ent)
    Orakel.FireOutput(ent, "OutValue")
  end;
  ["SetValueNoFire"] = function(ent, amount)
    Orakel.SetKeyValue(ent, "Counter", amount)
  end;
}

Entity.Outputs = {"OnHitMin", "OnHitMax", "OutValue", "OnGetValue"}

Entity.Update = function(ent)
  local initVal = Orakel.GetKeyValue(ent, "InitialValue")
  Orakel.SetKeyValue(ent, "Counter", initVal)
end


Entity.Kill = function()
  Entity.Status = false
end





return Entity