local PlayersService = game:GetService('Players')
local RootCameraCreator = require(script.Parent)

local UP_VECTOR = Vector3.new(0, 1, 0)
local XZ_VECTOR = Vector3.new(1,0,1)

local function clamp(low, high, num)
	if low <= high then
		return math.min(high, math.max(low, num))
	end
	print("Trying to clamp when low:", low , "is larger than high:" , high , "returning input value.")
	return num
end

local function IsFinite(num)
	return num == num and num ~= 1/0 and num ~= -1/0
end

local function IsFiniteVector3(vec3)
	return IsFinite(vec3.x) and IsFinite(vec3.y) and IsFinite(vec3.z)
end

-- May return NaN or inf or -inf
local function findAngleBetweenXZVectors(vec2, vec1)
	-- This is a way of finding the angle between the two vectors:
	return math.atan2(vec1.X*vec2.Z-vec1.Z*vec2.X, vec1.X*vec2.X + vec1.Z*vec2.Z)
end

local function CreateFollowCamera()
	local module = RootCameraCreator()	
	
	local tweenAcceleration = math.rad(220)
	local tweenSpeed = math.rad(0)
	local tweenMaxSpeed = math.rad(250)
	local timeBeforeAutoRotate = 2
	
	local lastUpdate = tick()
	module.LastUserPanCamera = tick()
	function module:Update()
		local now = tick()
		
		local userPanningTheCamera = (self.UserPanningTheCamera == true)
		local camera = 	workspace.CurrentCamera
		local player = PlayersService.LocalPlayer
		local humanoid = self:GetHumanoid()
		local cameraSubject = camera and camera.CameraSubject
		local isClimbing = humanoid and humanoid:GetState() == Enum.HumanoidStateType.Climbing
		local isInVehicle = cameraSubject and cameraSubject:IsA('VehicleSeat')
		local isOnASkateboard = cameraSubject and cameraSubject:IsA('SkateboardPlatform')

		if lastUpdate == nil or now - lastUpdate > 1 then
			module:ResetCameraLook()
			self.LastCameraTransform = nil
		end
		
		if lastUpdate then
			-- Cap out the delta to 0.5 so we don't get some crazy things when we re-resume from
			local delta = math.min(0.5, now - lastUpdate)
			local angle = 0
			if not (isInVehicle or isOnASkateboard) then
				angle = angle + (self.TurningLeft and -120 or 0)
				angle = angle + (self.TurningRight and 120 or 0)
			end

			local gamepadRotation = self:UpdateGamepad()
			if gamepadRotation ~= Vector2.new(0,0) then
				userPanningTheCamera = true				
				self.RotateInput = self.RotateInput + gamepadRotation
			end
			
			if angle ~= 0 then
				userPanningTheCamera = true
				self.RotateInput = self.RotateInput + Vector2.new(math.rad(angle * delta), 0)
			end
		end
		
		-- Reset tween speed if user is panning
		if userPanningTheCamera then
			tweenSpeed = 0
			module.LastUserPanCamera = tick()
		end
		
		local subjectPosition = self:GetSubjectPosition()		
		if subjectPosition and player and camera then
			local zoom = self:GetCameraZoom()
			if zoom <= 0 then
				zoom = 0.1
			end
			
			if self:GetShiftLock() and not self:IsInFirstPerson() then
				local newLookVector = self:RotateCamera(self:GetCameraLook(), self.RotateInput)
				local offset = ((newLookVector * XZ_VECTOR):Cross(UP_VECTOR).unit * 1.75)
				-- Check for NaNs
				if IsFiniteVector3(offset) then
					subjectPosition = subjectPosition + offset
				end
				-- For now we want players to be able to zoom to first person from shift lock mode. We can
				-- revisit this at a later time.
				--zoom = math.max(zoom, 5)
			else
				if self.LastCameraTransform and not userPanningTheCamera and now - module.LastUserPanCamera > timeBeforeAutoRotate then
					if (isClimbing or isInVehicle or isOnASkateboard) and lastUpdate and humanoid and humanoid.Torso then
						local forwardVector = humanoid.Torso.CFrame.lookVector
						if isOnASkateboard then
							forwardVector = cameraSubject.CFrame.lookVector
						end
						local timeDelta = (now - lastUpdate)
						
						tweenSpeed = clamp(0, tweenMaxSpeed, tweenSpeed + tweenAcceleration * timeDelta)
						
						local percent = clamp(0, 1, tweenSpeed * timeDelta)
						if not isClimbing and self:IsInFirstPerson() then
							percent = 1
						end
						local y = findAngleBetweenXZVectors(forwardVector, self:GetCameraLook())
						-- Check for NaN
						if IsFinite(y) and math.abs(y) > 0.0001 then
							self.RotateInput = self.RotateInput + Vector2.new(y * percent, 0)
						end
					elseif not self:IsInFirstPerson() then
						local lastVec = -(self.LastCameraTransform.p - subjectPosition)
						local y = findAngleBetweenXZVectors(lastVec, self:GetCameraLook())
						-- Check for NaNs
						if IsFinite(y) and math.abs(y) > 0.0001 then
							self.RotateInput = self.RotateInput + Vector2.new(y, 0)
						end
					end
				end
			end
			local newLookVector = self:RotateCamera(self:GetCameraLook(), self.RotateInput)
			self.RotateInput = Vector2.new()
			
			camera.Focus = CFrame.new(subjectPosition)
			camera.CoordinateFrame = CFrame.new(camera.Focus.p - (zoom * newLookVector), camera.Focus.p)
			self.LastCameraTransform = camera.CoordinateFrame
		end
		
		lastUpdate = now
	end
	
	return module
end

return CreateFollowCamera
