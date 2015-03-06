local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local Entity = {}
Entity.Status = true
local phys = Orakel.LoadModule("PhysLib")


Entity.KeyValues = {
  ["EntityName"] = "";
  ["FrontAttach"] = nil;
  ["EndAttach"] = nil;
  ["FrontOffset"] = nil;
  ["EndOffset"] = nil;
  ["EndAnchored"] = false;
}

Entity.Inputs = {
  


}


Entity.Update = function(e)
	local pos = e.Position
	local len = e.Length
	local fa = e.FrontAttach
	local ea = e.EndAttach
	local rope = phys.Rope.new(workspace.Ignore)
	rope.FrontAttach = e
	if ea == nil then
		rope.FrontOffset = Vector3.new(pos - Vector3.new(0, len.Value, 0))
	else
		rope.EndAttach = ea.Value
		rope.Length = (e.Position - ea.Value.Position).magnitude
		--abc
	end
	rope.EndAnchored = false
end


Entity.Kill = function()
	Entity.Status = false
end



return Entity