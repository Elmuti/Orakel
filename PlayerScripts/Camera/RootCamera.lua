local UserInputService = game:GetService('UserInputService')
local PlayersService = game:GetService('Players')

local CameraScript = script.Parent
local ShiftLockController = require(CameraScript:WaitForChild('ShiftLockController'))

local IsTouch = UserInputService.TouchEnabled

local function clamp(low, high, num)
	if low <= high then
		return math.min(high, math.max(low, num))
	end
	return num
end

local function findAngleBetweenXZVectors(vec2, vec1)
	return math.atan2(vec1.X*vec2.Z-vec1.Z*vec2.X, vec1.X*vec2.X + vec1.Z*vec2.Z)
end

local function IsFinite(num)
	return num == num and num ~= 1/0 and num ~= -1/0
end

local humanoidCache = {}
local function findPlayerHumanoid(player)
	local character = player and player.Character
	if character then
		local resultHumanoid = humanoidCache[player]
		if resultHumanoid and resultHumanoid.Parent == character then
			return resultHumanoid
		else
			humanoidCache[player] = nil -- Bust Old Cache
			for _, child in pairs(character:GetChildren()) do
				if child:IsA('Humanoid') then
					humanoidCache[player] = child
					return child
				end
			end
		end
	end
end

local MIN_Y = math.rad(-80)
local MAX_Y = math.rad(80)

local TOUCH_SENSITIVTY = Vector2.new(math.pi*2.25, math.pi*2)
local MOUSE_SENSITIVITY = Vector2.new(math.pi*4, math.pi*2)

local SEAT_OFFSET = Vector3.new(0,5,0)
local HEAD_OFFSET = Vector3.new(0, 1.5, 0)

local UseRenderCFrame = false
pcall(function()
	local rc = Instance.new('Part'):GetRenderCFrame()
	UseRenderCFrame = (rc ~= nil)
end)

local function GetRenderCFrame(part)
	return UseRenderCFrame and part:GetRenderCFrame() or part.CFrame
end

local function CreateCamera()
	local this = {}

	this.ShiftLock = false
	this.Enabled = false
	local pinchZoomSpeed = 20
	local isFirstPerson = false
	this.RotateInput = Vector2.new()

	function this:GetShiftLock()
		return ShiftLockController:IsShiftLocked()
	end

	function this:GetHumanoid()
		local player = PlayersService.LocalPlayer
		return findPlayerHumanoid(player)
	end

	function this:GetHumanoidRootPart()
		local humanoid = this:GetHumanoid()
		return humanoid and humanoid.Torso
	end

	function this:GetRenderCFrame(part)
		GetRenderCFrame(part)
	end

	function this:GetSubjectPosition()
		local result = nil
		local camera = workspace.CurrentCamera
		local cameraSubject = camera and camera.CameraSubject
		if cameraSubject then
			if cameraSubject:IsA('VehicleSeat') then
				local subjectCFrame = GetRenderCFrame(cameraSubject)
				result = subjectCFrame.p + subjectCFrame:vectorToWorldSpace(SEAT_OFFSET)
			elseif cameraSubject:IsA('SkateboardPlatform') then
				local subjectCFrame = GetRenderCFrame(cameraSubject)
				result = subjectCFrame.p + SEAT_OFFSET
			elseif cameraSubject:IsA('BasePart') then
				local subjectCFrame = GetRenderCFrame(cameraSubject)
				result = subjectCFrame.p
			elseif cameraSubject:IsA('Model') then
				result = cameraSubject:GetModelCFrame().p
			elseif cameraSubject:IsA('Humanoid') then
				local humanoidRootPart = cameraSubject.Torso
				if humanoidRootPart and humanoidRootPart:IsA('BasePart') then
					local subjectCFrame = GetRenderCFrame(humanoidRootPart)
					result = subjectCFrame.p + HEAD_OFFSET +
						subjectCFrame:vectorToWorldSpace(cameraSubject.CameraOffset)
				end
			end
		end
		return result
	end

	function this:ResetCameraLook()
	end

	function this:GetCameraLook()
		return workspace.CurrentCamera and workspace.CurrentCamera.CoordinateFrame.lookVector or Vector3.new(0,0,1)
	end

	function this:GetCameraZoom()
		if this.currentZoom == nil then
			local player = PlayersService.LocalPlayer
			this.currentZoom = player and clamp(player.CameraMinZoomDistance, player.CameraMaxZoomDistance, 10) or 10
		end
		return this.currentZoom
	end

	function this:GetCameraActualZoom()
		local camera = workspace.CurrentCamera
		if camera then
			return (camera.CoordinateFrame.p - camera.Focus.p).magnitude
		end
	end

	function this:ViewSizeX()
		local result = 1024
		local player = PlayersService.LocalPlayer
		local mouse = player and player:GetMouse()
		if mouse then
			result = mouse.ViewSizeX
		end
		return result
	end

	function this:ViewSizeY()
		local result = 768
		local player = PlayersService.LocalPlayer
		local mouse = player and player:GetMouse()
		if mouse then
			result = mouse.ViewSizeY
		end
		return result
	end

	function this:ScreenTranslationToAngle(translationVector)
		local screenX = this:ViewSizeX()
		local screenY = this:ViewSizeY()
		local xTheta = (translationVector.x / screenX)
		local yTheta = (translationVector.y / screenY)
		return Vector2.new(xTheta, yTheta)
	end

	function this:RotateCamera(startLook, xyRotateVector)
		-- Could cache these values so we don't have to recalc them all the time
		local startCFrame = CFrame.new(Vector3.new(), startLook)
		local startVertical = math.asin(startLook.y)
		local yTheta = clamp(-MAX_Y + startVertical, -MIN_Y + startVertical, xyRotateVector.y)
		local resultLookVector = (CFrame.Angles(0, -xyRotateVector.x, 0) * startCFrame * CFrame.Angles(-yTheta,0,0)).lookVector
		return resultLookVector, Vector2.new(xyRotateVector.x, yTheta)
	end

	function this:IsInFirstPerson()
		return isFirstPerson
	end

	function this:ZoomCamera(desiredZoom)
		local player = PlayersService.LocalPlayer
		if player then
			if player.CameraMode == Enum.CameraMode.LockFirstPerson then
				this.currentZoom = 0
			else
				this.currentZoom = clamp(player.CameraMinZoomDistance, player.CameraMaxZoomDistance, desiredZoom)
			end
		end
		-- set mouse behavior
		if self:GetCameraZoom() < 2 then
			isFirstPerson = true
			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		else
			isFirstPerson = false
			if not self:GetShiftLock() then
				UserInputService.MouseBehavior = Enum.MouseBehavior.Default
			end
		end
		ShiftLockController:SetIsInFirstPerson(isFirstPerson)
		return self:GetCameraZoom()
	end

	local function rk4Integrator(position, velocity, t)
		local direction = velocity < 0 and -1 or 1
		local function acceleration(p, v)
			local accel = direction * math.max(1, (p / 3.3) + 0.5)
			return accel
		end

		local p1 = position
		local v1 = velocity
		local a1 = acceleration(p1, v1)
		local p2 = p1 + v1 * (t / 2)
		local v2 = v1 + a1 * (t / 2)
		local a2 = acceleration(p2, v2)
		local p3 = p1 + v2 * (t / 2)
		local v3 = v1 + a2 * (t / 2)
		local a3 = acceleration(p3, v3)
		local p4 = p1 + v3 * t
		local v4 = v1 + a3 * t
		local a4 = acceleration(p4, v4)

		local positionResult = position + (v1 + 2 * v2 + 2 * v3 + v4) * (t / 6)
		local velocityResult = velocity + (a1 + 2 * a2 + 2 * a3 + a4) * (t / 6)
		return positionResult, velocityResult
	end

	function this:ZoomCameraBy(zoomScale)
		local zoom = this:GetCameraActualZoom()
		if zoom then
			-- Can break into more steps to get more accurate integration
			zoom = rk4Integrator(zoom, zoomScale, 1)
			self:ZoomCamera(zoom)
		end
		return self:GetCameraZoom()
	end

	function this:ZoomCameraFixedBy(zoomIncrement)
		return self:ZoomCamera(self:GetCameraZoom() + zoomIncrement)
	end

	function this:Update()
	end

	---- Input Events ----
	local startPos = nil
	local lastPos = nil
	local panBeginLook = nil

	local fingerTouches = {}
	local NumUnsunkTouches = 0

	local StartingDiff = nil
	local pinchBeginZoom = nil

	this.ZoomEnabled = true
	this.PanEnabled = true
	this.KeyPanEnabled = true

	local function OnTouchBegan(input, processed)
		fingerTouches[input] = processed
		if not processed then
			NumUnsunkTouches = NumUnsunkTouches + 1
		end
	end

	local function OnTouchChanged(input, processed)
		if fingerTouches[input] == nil then
			fingerTouches[input] = processed
			if not processed then
				NumUnsunkTouches = NumUnsunkTouches + 1
			end
		end

		if NumUnsunkTouches == 1 then
			if fingerTouches[input] == false then
				panBeginLook = panBeginLook or this:GetCameraLook()
				startPos = startPos or input.Position
				lastPos = lastPos or startPos
				this.UserPanningTheCamera = true

				local delta = input.Position - lastPos
				if this.PanEnabled then
					local desiredXYVector = this:ScreenTranslationToAngle(delta) * TOUCH_SENSITIVTY
					this.RotateInput = this.RotateInput + desiredXYVector
				end

				lastPos = input.Position
			end
		else
			panBeginLook = nil
			startPos = nil
			lastPos = nil
			this.UserPanningTheCamera = false
		end
		if NumUnsunkTouches == 2 then
			local unsunkTouches = {}
			for touch, wasSunk in pairs(fingerTouches) do
				if not wasSunk then
					table.insert(unsunkTouches, touch)
				end
			end
			if #unsunkTouches == 2 then
				local difference = (unsunkTouches[1].Position - unsunkTouches[2].Position).magnitude
				if StartingDiff and pinchBeginZoom then
					local scale = difference / math.max(0.01, StartingDiff)
					local clampedScale = clamp(0.1, 10, scale)
					if this.ZoomEnabled then
						this:ZoomCamera(pinchBeginZoom / clampedScale)
					end
				else
					StartingDiff = difference
					pinchBeginZoom = this:GetCameraActualZoom()
				end
			end
		else
			StartingDiff = nil
			pinchBeginZoom = nil
		end
	end

	local function OnTouchEnded(input, processed)
		if fingerTouches[input] == false then
			if NumUnsunkTouches == 1 then
				panBeginLook = nil
				startPos = nil
				lastPos = nil
				this.UserPanningTheCamera = false
			elseif NumUnsunkTouches == 2 then
				StartingDiff = nil
				pinchBeginZoom = nil
			end
		end

		if fingerTouches[input] ~= nil and fingerTouches[input] == false then
			NumUnsunkTouches = NumUnsunkTouches - 1
		end
		fingerTouches[input] = nil
	end

	local function OnMouse2Down(input, processed)
		if processed then return end
		-- Check if they are in first-person
		if UserInputService.MouseBehavior ~= Enum.MouseBehavior.LockCenter then
			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
		end
		panBeginLook = this:GetCameraLook()
		startPos = input.Position
		lastPos = startPos
		this.UserPanningTheCamera = true
	end

	local function OnMouse2Up(input, processed)
		-- Check if they are in first-person
		if UserInputService.MouseBehavior ~= Enum.MouseBehavior.LockCenter then
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		end

		panBeginLook = nil
		startPos = nil
		lastPos = nil
		this.UserPanningTheCamera = false
	end

	local function OnMouseMoved(input, processed)
		if startPos and lastPos and panBeginLook then
			local currPos = lastPos + input.Delta
			local totalTrans = currPos - startPos
			if this.PanEnabled then
				local desiredXYVector = this:ScreenTranslationToAngle(input.Delta) * MOUSE_SENSITIVITY
				this.RotateInput = this.RotateInput + desiredXYVector
			end
			lastPos = currPos
		elseif this:IsInFirstPerson() or this:GetShiftLock() then
			if this.PanEnabled then
				local desiredXYVector = this:ScreenTranslationToAngle(input.Delta) * MOUSE_SENSITIVITY
				this.RotateInput = this.RotateInput + desiredXYVector
			end
		end
	end

	local function OnMouseWheel(input, processed)
		if not processed then
			if this.ZoomEnabled then
				this:ZoomCameraBy(clamp(-1, 1, -input.Position.Z) * 1.4)
			end
		end
	end

	local function OnKeyDown(input, processed)
		if processed then return end
		if this.ZoomEnabled then
			if input.KeyCode == Enum.KeyCode.I then
				this:ZoomCameraBy(-5)
			elseif input.KeyCode == Enum.KeyCode.O then
				this:ZoomCameraBy(5)
			end
		end
		if panBeginLook == nil and this.KeyPanEnabled then
			if input.KeyCode == Enum.KeyCode.Left then
				this.TurningLeft = true
			elseif input.KeyCode == Enum.KeyCode.Right then
				this.TurningRight = true
			elseif input.KeyCode == Enum.KeyCode.Comma then
				this.RotateInput = this.RotateInput + Vector2.new(math.rad(-35),0)
				this.LastUserPanCamera = tick()
				this.LastCameraTransform = nil
			elseif input.KeyCode == Enum.KeyCode.Period then
				this.RotateInput = this.RotateInput + Vector2.new(math.rad(35),0)
				this.LastUserPanCamera = tick()
				this.LastCameraTransform = nil
			elseif input.KeyCode == Enum.KeyCode.PageUp then
			--elseif input.KeyCode == Enum.KeyCode.Home then
				this.RotateInput = this.RotateInput + Vector2.new(0,math.rad(15))
				this.LastCameraTransform = nil
			elseif input.KeyCode == Enum.KeyCode.PageDown then
			--elseif input.KeyCode == Enum.KeyCode.End then
				this.RotateInput = this.RotateInput + Vector2.new(0,math.rad(-15))
				this.LastCameraTransform = nil
			end
		end
	end

	local function OnKeyUp(input, processed)
		if input.KeyCode == Enum.KeyCode.Left then
			this.TurningLeft = false
		elseif input.KeyCode == Enum.KeyCode.Right then
			this.TurningRight = false
		end
	end

	local lastThumbstickRotate = nil
	local numOfSeconds = 0.7
	local currentSpeed = 0
	local maxSpeed = 0.1
	local thumbstickSensitivity = 1.0
	local lastThumbstickPos = Vector2.new(0,0)
	local ySensitivity = 0.65
	local lastVelocity = nil
	
	-- K is a tunable parameter that changes the shape of the S-curve
	-- the larger K is the more straight/linear the curve gets
	local k = 0.35
	local lowerK = 0.8
	local function SCurveTranform(t)
		t = clamp(-1,1,t)
		if t >= 0 then
			return (k*t) / (k - t + 1)
		end
		return -((lowerK*-t) / (lowerK + t + 1))
	end
	
	-- DEADZONE
	local DEADZONE = 0.1
	local function toSCurveSpace(t)
		return (1 + DEADZONE) * (2*math.abs(t) - 1) - DEADZONE
	end
	
	local function fromSCurveSpace(t)
		return t/2 + 0.5
	end
	
	local function gamepadLinearToCurve(thumbstickPosition)
		local function onAxis(axisValue)
			local sign = 1
			if axisValue < 0 then
				sign = -1
			end
			local point = fromSCurveSpace(SCurveTranform(toSCurveSpace(math.abs(axisValue))))
			point = point * sign
			return clamp(-1,1,point)
		end
		return Vector2.new(onAxis(thumbstickPosition.x), onAxis(thumbstickPosition.y))
	end

	function this:UpdateGamepad()
		local gamepadPan = this.GamepadPanningCamera
		if gamepadPan then
			gamepadPan = gamepadLinearToCurve(gamepadPan)
			local currentTime = tick()
			if gamepadPan.X ~= 0 or gamepadPan.Y ~= 0 then
				this.userPanningTheCamera = true
			elseif gamepadPan == Vector2.new(0,0) then
				lastThumbstickRotate = nil
				if lastThumbstickPos == Vector2.new(0,0) then
					currentSpeed = 0
				end
			end

			local finalConstant = 0

			if lastThumbstickRotate then
				local elapsedTime = (currentTime - lastThumbstickRotate) * 10
				currentSpeed = currentSpeed + (maxSpeed * ((elapsedTime*elapsedTime)/numOfSeconds))

				if currentSpeed > maxSpeed then currentSpeed = maxSpeed end

				if lastVelocity then
					local velocity = (gamepadPan - lastThumbstickPos)/(currentTime - lastThumbstickRotate)
					local velocityDeltaMag = (velocity - lastVelocity).magnitude

					if velocityDeltaMag > 12 then
						currentSpeed = currentSpeed * (20/velocityDeltaMag)
						if currentSpeed > maxSpeed then currentSpeed = maxSpeed end
					end
				end

				finalConstant = thumbstickSensitivity * currentSpeed
				lastVelocity = (gamepadPan - lastThumbstickPos)/(currentTime - lastThumbstickRotate)
			end

			lastThumbstickPos = gamepadPan
			lastThumbstickRotate = currentTime

			return Vector2.new( gamepadPan.X * finalConstant, gamepadPan.Y * finalConstant * ySensitivity)
		end

		return Vector2.new(0,0)
	end

	local InputBeganConn, InputChangedConn, InputEndedConn = nil, nil, nil

	function this:DisconnectInputEvents()
		if InputBeganConn then
			InputBeganConn:disconnect()
			InputBeganConn = nil
		end
		if InputChangedConn then
			InputChangedConn:disconnect()
			InputChangedConn = nil
		end
		if InputEndedConn then
			InputEndedConn:disconnect()
			InputEndedConn = nil
		end
		this.TurningLeft = false
		this.TurningRight = false
		this.LastCameraTransform = nil
		this.UserPanningTheCamera = false
		this.RotateInput = Vector2.new()
		this.GamepadPanningCamera = Vector2.new(0,0)

		-- Reset input states
		startPos = nil
		lastPos = nil
		panBeginLook = nil

		fingerTouches = {}
		NumUnsunkTouches = 0

		StartingDiff = nil
		pinchBeginZoom = nil

		if UserInputService.MouseBehavior ~= Enum.MouseBehavior.LockCenter then
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		end
	end

	function this:ConnectInputEvents()
		InputBeganConn = UserInputService.InputBegan:connect(function(input, processed)
			if input.UserInputType == Enum.UserInputType.Touch and IsTouch then
				OnTouchBegan(input, processed)
			elseif input.UserInputType == Enum.UserInputType.MouseButton2 and not IsTouch then
				OnMouse2Down(input, processed)
			elseif input.UserInputType == Enum.UserInputType.Gamepad1 and input.KeyCode == Enum.KeyCode.ButtonR3 then
				if this.currentZoom > 0.5 then
					this:ZoomCamera(0)
				else
					this:ZoomCamera(10)
				end
			end
			-- Keyboard
			if input.UserInputType == Enum.UserInputType.Keyboard then
				OnKeyDown(input, processed)
			end
		end)

		InputChangedConn = UserInputService.InputChanged:connect(function(input, processed)
			if input.UserInputType == Enum.UserInputType.Touch and IsTouch then
				OnTouchChanged(input, processed)
			elseif input.UserInputType == Enum.UserInputType.MouseMovement and not IsTouch then
				OnMouseMoved(input, processed)
			elseif input.UserInputType == Enum.UserInputType.MouseWheel and not IsTouch then
				OnMouseWheel(input, processed)
			elseif input.UserInputType == Enum.UserInputType.Gamepad1 and input.KeyCode == Enum.KeyCode.Thumbstick2 then
				this.GamepadPanningCamera = Vector2.new(input.Position.X, -input.Position.Y)
			end
		end)

		InputEndedConn = UserInputService.InputEnded:connect(function(input, processed)
			if input.UserInputType == Enum.UserInputType.Touch and IsTouch then
				OnTouchEnded(input, processed)
			elseif input.UserInputType == Enum.UserInputType.MouseButton2 and not IsTouch then
				OnMouse2Up(input, processed)
			elseif input.UserInputType == Enum.UserInputType.Gamepad1 and input.KeyCode == Enum.KeyCode.Thumbstick2 then
				this.GamepadPanningCamera = Vector2.new(0,0)
			end
			-- Keyboard
			if input.UserInputType == Enum.UserInputType.Keyboard then
				OnKeyUp(input, processed)
			end
		end)
	end

	function this:SetEnabled(newState)
		if newState ~= self.Enabled then
			self.Enabled = newState
			if self.Enabled then
				self:ConnectInputEvents()
			else
				self:DisconnectInputEvents()
			end
		end
	end

	local function OnPlayerAdded(player)
		player.Changed:connect(function(prop)
			if this.Enabled then
				if prop == "CameraMode" or prop == "CameraMaxZoomDistance" or prop == "CameraMinZoomDistance" then
					 this:ZoomCameraBy(0)
				end
			end
		end)

		local function OnCharacterAdded(newCharacter)
			this:ZoomCamera(10)
			local humanoid = findPlayerHumanoid(player)
			local start = tick()
			while tick() - start < 0.3 and (humanoid == nil or humanoid.Torso == nil) do
				wait()
				humanoid = findPlayerHumanoid(player)
			end
			local function setLookBehindChatacter()
				if humanoid and humanoid.Torso and player.Character == newCharacter then
					local newDesiredLook = (humanoid.Torso.CFrame.lookVector - Vector3.new(0,0.7,0)).unit
					local horizontalShift = findAngleBetweenXZVectors(newDesiredLook, this:GetCameraLook())
					local vertShift = math.asin(this:GetCameraLook().y) - math.asin(newDesiredLook.y)
					if not IsFinite(horizontalShift) then
						horizontalShift = 0
					end
					if not IsFinite(vertShift) then
						vertShift = 0
					end
					this.RotateInput = Vector2.new(horizontalShift, vertShift)
					-- reset old camera info so follow cam doesn't rotate us
					this.LastCameraTransform = nil
				end
			end
			wait()
			setLookBehindChatacter()
		end

		player.CharacterAdded:connect(function(character)
			if this.Enabled then
				OnCharacterAdded(character)
			end
		end)
		if player.Character then
			spawn(function() OnCharacterAdded(player.Character) end)
		end
	end
	if PlayersService.LocalPlayer then
		OnPlayerAdded(PlayersService.LocalPlayer)
	end
	PlayersService.ChildAdded:connect(function(child)
		if child and PlayersService.LocalPlayer == child then
			OnPlayerAdded(PlayersService.LocalPlayer)
		end
	end)

	return this
end

return CreateCamera
