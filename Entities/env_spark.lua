local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local Entity = {}
Entity.Status = true

Entity.Type = "Point"
Entity.EditorTexture = "http://www.roblox.com/asset/?id=184030937"

Entity.KeyValues = {
  ["EntityName"] = "";
  ["Enabled"] = true;
  ["Life"] = 1;
  ["MaxAmount"] = 35;
  ["MaxInterval"] = 2;
  ["MinAmount"] = 8;
  ["MinInterval"] = 1;
  ["VelocityModifier"] = 0.6;
  ["VelocityModifierY"] = 0.8;
}


Entity.Inputs = {
  ["Toggle"] = function(ent)
    ent.Enabled.Value = not ent.Enabled.Value
  end;
}

Entity.Update = function(ent)
end


Entity.Kill = function()
	Entity.Status = false
end



return Entity