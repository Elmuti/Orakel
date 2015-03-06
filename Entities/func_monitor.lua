local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local Entity = {}
Entity.Status = true

Entity.Runtime = function(mon)
	while wait(1/2) do
		if mon.Enabled.Value then
			local track = game.ReplicatedStorage.Orakel.AnimSheets:FindFirstChild(mon.TrackName.Value)
			if track then
				track = require(track)
				local sgui = Instance.new("SurfaceGui", mon)
				sgui.Face = Enum.NormalId.Front
				sgui.Adornee = mon
				local il = Instance.new("ImageLabel", sgui)
				il.Size = UDim2.new(1, 0, 1, 0)
				track:Init(il)
				while true do
					if not mon.Enabled.Value then
						break
					end
					local nextFrame = track:NextFrame()
					il.ImageRectOffset = nextFrame
					track:Yield()
				end
			end
		end
	end
end


Entity.Kill = function()
	Entity.Status = false
end





return Entity