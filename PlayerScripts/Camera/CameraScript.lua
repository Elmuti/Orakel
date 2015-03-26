local RunService = game:GetService('RunService')
local UserInputService = game:GetService('UserInputService')
local PlayersService = game:GetService('Players')


local RootCamera = script:WaitForChild('RootCamera')
local ClassicCamera = require(RootCamera:WaitForChild('ClassicCamera'))()
local FollowCamera = require(RootCamera:WaitForChild('FollowCamera'))()
local PopperCam = require(script:WaitForChild('PopperCam'))
local Invisicam = require(script:WaitForChild('Invisicam'))
local ClickToMove = require(script:WaitForChild('ClickToMove'))()
local TransparencyController = require(script:WaitForChild('TransparencyController'))()
local StarterPlayer = game:GetService('StarterPlayer')

local GameSettings = UserSettings().GameSettings


local EnabledCamera = nil
local EnabledOcclusion = nil

local currentCameraConn = nil
local renderSteppedConn = nil


local function IsTouch()
	return UserInputService.TouchEnabled
end

local function shouldUseCustomCamera()
	local player = PlayersService.LocalPlayer
	local currentCamera = workspace.CurrentCamera
	if player then
		if currentCamera == nil or (currentCamera and currentCamera.CameraType == Enum.CameraType.Custom) then
			return true, player, currentCamera
		end
	end
	return false, player, currentCamera
end

local function isClickToMoveOn()
	local customModeOn, player, currentCamera = shouldUseCustomCamera()
	if customModeOn then
		if IsTouch() then -- Touch
			if player.DevTouchMovementMode == Enum.DevTouchMovementMode.ClickToMove or
					(player.DevTouchMovementMode == Enum.DevTouchMovementMode.UserChoice and GameSettings.TouchMovementMode == Enum.TouchMovementMode.ClickToMove) then
				return true
			end
		else -- Computer
			if player.DevComputerMovementMode == Enum.DevComputerMovementMode.ClickToMove or
					(player.DevComputerMovementMode == Enum.DevComputerMovementMode.UserChoice and GameSettings.ComputerMovementMode == Enum.ComputerMovementMode.ClickToMove) then
				return true
			end
		end
	end
	return false
end

local function getCurrentCameraMode()
	local customModeOn, player, currentCamera = shouldUseCustomCamera()
	if customModeOn then
		if IsTouch() then -- Touch (iPad, etc...)
			if isClickToMoveOn() then
				return Enum.DevTouchMovementMode.ClickToMove.Name
			elseif player.DevTouchCameraMode == Enum.DevTouchCameraMovementMode.UserChoice then
				local touchMovementMode = GameSettings.TouchCameraMovementMode
				if touchMovementMode == Enum.TouchCameraMovementMode.Default then
					return Enum.TouchCameraMovementMode.Follow.Name
				end
				return touchMovementMode.Name
			else
				return player.DevTouchCameraMode.Name
			end
		else -- Computer
			if isClickToMoveOn() then
				return Enum.DevComputerMovementMode.ClickToMove.Name
			elseif player.DevComputerCameraMode == Enum.DevComputerCameraMovementMode.UserChoice then
				local computerMovementMode = GameSettings.ComputerCameraMovementMode
				if computerMovementMode == Enum.ComputerCameraMovementMode.Default then
					return Enum.ComputerCameraMovementMode.Classic.Name
				end
				return computerMovementMode.Name
			else
				return player.DevComputerCameraMode.Name
			end
		end
	end
end

local function getCameraOcclusionMode()
	local customModeOn, player, currentCamera = shouldUseCustomCamera()
	if customModeOn then
		return player.DevCameraOcclusionMode
	end
end

local function Update()
	if EnabledCamera then
		EnabledCamera:Update()
	end
	if EnabledOcclusion then
		EnabledOcclusion:Update()
	end
	if shouldUseCustomCamera() then
		TransparencyController:Update()
	end
end

local function OnCameraMovementModeChange(newCameraMode)
	if newCameraMode == Enum.DevComputerMovementMode.ClickToMove.Name then
		ClickToMove:Start()
		if EnabledCamera then
			EnabledCamera:SetEnabled(false)
			EnabledCamera = nil
		end
		TransparencyController:SetEnabled(false)
	else
		if newCameraMode == Enum.ComputerCameraMovementMode.Classic.Name then
			if EnabledCamera ~= ClassicCamera then
				if EnabledCamera then
					EnabledCamera:SetEnabled(false)
				end
				EnabledCamera = ClassicCamera
				EnabledCamera:SetEnabled(true)
			end
			TransparencyController:SetEnabled(true)
		elseif newCameraMode == Enum.ComputerCameraMovementMode.Follow.Name then
			if EnabledCamera ~= FollowCamera then
				if EnabledCamera then 
					EnabledCamera:SetEnabled(false)
				end
				EnabledCamera = FollowCamera
				EnabledCamera:SetEnabled(true)
			end
			TransparencyController:SetEnabled(true)
		else -- Our camera movement code was disabled by the developer
			if EnabledCamera then
				EnabledCamera:SetEnabled(false)
				EnabledCamera = nil
			end
			TransparencyController:SetEnabled(false)
		end
		ClickToMove:Stop()
	end

	local newOcclusionMode = getCameraOcclusionMode()
	if EnabledOcclusion == Invisicam and newOcclusionMode ~= Enum.DevCameraOcclusionMode.Invisicam then
		Invisicam:Cleanup()
	end
	if newOcclusionMode == Enum.DevCameraOcclusionMode.Zoom then
		EnabledOcclusion = PopperCam
	elseif newOcclusionMode == Enum.DevCameraOcclusionMode.Invisicam then
		EnabledOcclusion = Invisicam
	else
		EnabledOcclusion = false
	end

	local success = pcall(function() local isAThing = RunService.BindToRenderStep end)
	if not success then
		if renderSteppedConn then
			renderSteppedConn:disconnect()
		end
		renderSteppedConn = RunService.RenderStepped:connect(Update)
	end
end


local function OnCameraSubjectChanged(newSubject)
	TransparencyController:SetSubject(newSubject)
end

local function OnNewCamera()
	OnCameraMovementModeChange(getCurrentCameraMode())

	local currentCamera = workspace.CurrentCamera
	if currentCamera then
		if currentCameraConn then
			currentCameraConn:disconnect()
		end
		currentCameraConn = currentCamera.Changed:connect(function(prop)
			if prop == 'CameraType' then
				OnCameraMovementModeChange(getCurrentCameraMode())
			elseif prop == 'CameraSubject' then
				OnCameraSubjectChanged(currentCamera.CameraSubject)
			end
		end)

		OnCameraSubjectChanged(currentCamera.CameraSubject)
	end
end


local function OnPlayerAdded(player)
	workspace.Changed:connect(function(prop)
		if prop == 'CurrentCamera' then
			OnNewCamera()
		end
	end)

	player.Changed:connect(function(prop)
		OnCameraMovementModeChange(getCurrentCameraMode())
	end)

	GameSettings.Changed:connect(function(prop)
		OnCameraMovementModeChange(getCurrentCameraMode())
	end)

	local success = pcall(function() RunService:BindToRenderStep("cameraRenderUpdate",Enum.RenderPriority.Camera.Value,Update) end)
	if not success then
		if renderSteppedConn then
			renderSteppedConn:disconnect()
		end
		renderSteppedConn = RunService.RenderStepped:connect(Update)
	end

	OnNewCamera()
	OnCameraMovementModeChange(getCurrentCameraMode())
end

do
	while PlayersService.LocalPlayer == nil do wait() end
	OnPlayerAdded(PlayersService.LocalPlayer)
end
