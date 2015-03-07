local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local Entity = {}
Entity.Status = true


Entity.Type = "Brush"
Entity.EditorTexture = ""

Entity.KeyValues = {
  ["EntityName"] = "";
}


Entity.Inputs = {}



Entity.Update = function(e)
	if e:IsA("BasePart") then
		e.Anchored = false
	else
		for _, p in pairs(e:children()) do
			p.Anchored = false
		end
	end
end


Entity.Kill = function()
	Entity.Status = false
end


return Entity