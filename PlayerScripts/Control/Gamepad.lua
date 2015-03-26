--[[
	// FileName: Gamepad
	// Written by: jeditkacheff
	// Description: Implements movement controls for gamepad devices (XBox, PS4, MFi, etc.)
--]]
local Gamepad = {}

local MasterControl = require(script.Parent)

local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local UserInputService = game:GetService('UserInputService')
local ContextActionService = game:GetService('ContextActionService')
local StarterPlayer = game:GetService('StarterPlayer')
local Settings = UserSettings()
local GameSettings = Settings.GameSettings
local currentMoveVector = Vector3.new(0,0,0)

while not Players.LocalPlayer do
	wait()
end
local LocalPlayer = Players.LocalPlayer

--[[ Constants ]]--
local thumbstickDeadzone = 0.14

--[[ Public API ]]--
function Gamepad:Enable()
	local forwardValue  = 0
	local backwardValue = 0
	local leftValue = 0
	local rightValue = 0
	
	local moveFunc = LocalPlayer.Move
	local gamepadSupports = UserInputService.GamepadSupports
	
	local controlCharacterGamepad1 = function(actionName, inputState, inputObject)
		if inputObject.UserInputType ~= Enum.UserInputType.Gamepad1 then return end
		if inputObject.KeyCode ~= Enum.KeyCode.Thumbstick1 then return end
		
		if inputObject.Position.magnitude > thumbstickDeadzone then
			MasterControl:AddToPlayerMovement(-currentMoveVector)
			currentMoveVector =  Vector3.new(inputObject.Position.X, 0, -inputObject.Position.Y)
			MasterControl:AddToPlayerMovement(currentMoveVector)
		else
			MasterControl:AddToPlayerMovement(-currentMoveVector)
			currentMoveVector =  Vector3.new(0,0,0)
		end
	end
	
	local jumpCharacterGamepad1 = function(actionName, inputState, inputObject)		
		if inputObject.UserInputType ~= Enum.UserInputType.Gamepad1 then return end
		if inputObject.KeyCode ~= Enum.KeyCode.ButtonA then return end
		
		MasterControl:SetIsJumping(inputObject.UserInputState == Enum.UserInputState.Begin)
	end
	
	local doDpadMoveUpdate = function()
		if not gamepadSupports(UserInputService, Enum.UserInputType.Gamepad1, Enum.KeyCode.Thumbstick1) then
			if LocalPlayer and LocalPlayer.Character then
				MasterControl:AddToPlayerMovement(-currentMoveVector)
				currentMoveVector = Vector3.new(leftValue + rightValue,0,forwardValue + backwardValue)
				MasterControl:AddToPlayerMovement(currentMoveVector)
			end
		end
	end
	
	local moveForwardFunc = function(actionName, inputState, inputObject)
		if inputState == Enum.UserInputState.End then
			forwardValue = -1
		elseif inputState == Enum.UserInputState.Begin then
			forwardValue = 0
		end
		
		doDpadMoveUpdate()
	end
	
	local moveBackwardFunc = function(actionName, inputState, inputObject)	
		if inputState == Enum.UserInputState.End then
			backwardValue = 1
		elseif inputState == Enum.UserInputState.Begin then
			backwardValue = 0
		end
		
		doDpadMoveUpdate()
	end
	
	local moveLeftFunc = function(actionName, inputState, inputObject)	
		if inputState == Enum.UserInputState.End then
			leftValue = -1
		elseif inputState == Enum.UserInputState.Begin then
			leftValue = 0
		end
		
		doDpadMoveUpdate()
	end
	
	local moveRightFunc = function(actionName, inputState, inputObject)	
		if inputState == Enum.UserInputState.End then
			rightValue = 1
		elseif inputState == Enum.UserInputState.Begin then
			rightValue = 0
		end
		
		doDpadMoveUpdate()
	end
	
	local activateToolFunc = function(actionName, inputState, inputObject)
		if inputObject.UserInputType ~= Enum.UserInputType.Gamepad1 then return end
		
		if inputState == Enum.UserInputState.End then
			local character = LocalPlayer and LocalPlayer.Character
			if character then
				local children = character:GetChildren()
				for i = 1, #children do
					if children[i]:IsA("Tool") then
						children[i]:Activate()
					end
				end
			end
		end
	end

	ContextActionService:BindActionToInputTypes("JumpButton",jumpCharacterGamepad1, false, Enum.KeyCode.ButtonA)
	ContextActionService:BindActionToInputTypes("MoveThumbstick",controlCharacterGamepad1, false, Enum.KeyCode.Thumbstick1)
	
	ContextActionService:BindActionToInputTypes("forwardDpad", moveForwardFunc, false, Enum.KeyCode.DPadUp)
	ContextActionService:BindActionToInputTypes("backwardDpad", moveBackwardFunc, false, Enum.KeyCode.DPadDown)
	ContextActionService:BindActionToInputTypes("leftDpad", moveLeftFunc, false, Enum.KeyCode.DPadLeft)
	ContextActionService:BindActionToInputTypes("rightDpad", moveRightFunc, false, Enum.KeyCode.DPadRight)
	
	ContextActionService:BindActionToInputTypes("ActivateTool", activateToolFunc, false, Enum.KeyCode.ButtonR1)
	
	UserInputService.GamepadDisconnected:connect(function(gamepadEnum)
		if gamepadEnum ~= Enum.UserInputType.Gamepad1 then return end
		
		MasterControl:AddToPlayerMovement(-currentMoveVector)
		currentMoveVector = Vector3.new(0,0,0)
	end)

	UserInputService.GamepadConnected:connect(function(gamepadEnum)
		if gamepadEnum ~= Enum.UserInputType.Gamepad1 then return end
		
		MasterControl:AddToPlayerMovement(-currentMoveVector)
		currentMoveVector = Vector3.new(0,0,0)
	end)
end

function Gamepad:Disable()
	
	ContextActionService:UnbindAction("forwardDpad")
	ContextActionService:UnbindAction("backwardDpad")
	ContextActionService:UnbindAction("leftDpad")
	ContextActionService:UnbindAction("rightDpad")
	
	ContextActionService:UnbindAction("MoveThumbstick")
	ContextActionService:UnbindAction("JumpButton")
	ContextActionService:UnbindAction("ActivateTool")
	
	MasterControl:AddToPlayerMovement(-currentMoveVector)
	currentMoveVector = Vector3.new(0,0,0)
end

return Gamepad
