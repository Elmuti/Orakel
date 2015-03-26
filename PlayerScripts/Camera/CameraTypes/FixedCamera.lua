local PlayersService = game:GetService('Players')
local RootCameraCreator = require(script.Parent)


local function CreateFixedCamera()
	local module = RootCameraCreator()
	
	local lastUpdate = tick()
	function module:Update()
		local now = tick()
		
		local camera = 	workspace.CurrentCamera
		local player = PlayersService.LocalPlayer
		if lastUpdate == nil or now - lastUpdate > 1 then
			module:ResetCameraLook()
			self.LastCameraTransform = nil
		end
		
		local subjectPosition = self:GetSubjectPosition()		
		if subjectPosition and player and camera then
			local zoom = self:GetCameraZoom()
			if zoom <= 0 then
				zoom = 0.1
			end
			local newLookVector = self:RotateCamera(self:GetCameraLook(), self.RotateInput)
			self.RotateInput = Vector2.new()
			
			camera.CoordinateFrame = CFrame.new(camera.Focus.p - (zoom * newLookVector), camera.Focus.p)
			self.LastCameraTransform = camera.CoordinateFrame
		end
		lastUpdate = now
	end
	
	return module
end

return CreateFixedCamera
