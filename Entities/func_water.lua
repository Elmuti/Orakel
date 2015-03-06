local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local Entity = {}
Entity.Status = true

Entity.Runtime = function(part)
	part.Transparency = 1
	part.CanCollide = false
	local a,b,c,d =
	(part.Position.x - part.Size.x/2)/4,
	(part.Position.z - part.Size.z/2)/4,
	((part.Position.x + part.Size.x/2)/4)-1,
	((part.Position.z + part.Size.z/2)/4)-1
	
	workspace.Terrain:SetCells(
	Region3int16.new(
	Vector3int16.new(
	a,
	(part.Position.y - part.Size.y/2)/4,
	b),
	Vector3int16.new(
	c,
	(part.Position.y + part.Size.y/2)/4,
	d)),
	"Water",0,0
	)
end


Entity.Kill = function()
	Entity.Status = false
end





return Entity