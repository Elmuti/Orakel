--[[
	// FileName: ControlScript.lua
	// Version 1.0
	// Written by: jmargh
	// Description: Manages in game controls for both touch and keyboard/mouse devices.
	
	// This script will be inserted into PlayerScripts under each player by default. If you want to
	// create your own custom controls or modify these controls, you must place a script with this
	// name, ControlScript, under StarterPlayer -> PlayerScripts.
	
	// Required Modules:
		ClickToMove
		DPad
		KeyboardMovement
		Thumbpad
		Thumbstick
		TouchJump
		MasterControl
--]]

--[[ Services ]]--
local ContextActionService = game:GetService('ContextActionService')
local Players = game:GetService('Players')
local UserInputService = game:GetService('UserInputService')
-- Settings and GameSettings are read only
local Settings = UserSettings()
local GameSettings = Settings.GameSettings

-- Issue with play solo? (F6)
while not UserInputService.KeyboardEnabled and not UserInputService.TouchEnabled do
	wait()
end

--[[ Script Variables ]]--
while not Players.LocalPlayer do
	wait()
end
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild('PlayerGui')
local IsTouchDevice = UserInputService.TouchEnabled
local UserMovementMode = IsTouchDevice and GameSettings.TouchMovementMode or GameSettings.ComputerMovementMode
local DevMovementMode = IsTouchDevice and LocalPlayer.DevTouchMovementMode or LocalPlayer.DevComputerMovementMode
local IsUserChoice = (IsTouchDevice and DevMovementMode == Enum.DevTouchMovementMode.UserChoice) or
	DevMovementMode == Enum.DevComputerMovementMode.UserChoice
local TouchGui = nil
local TouchControlFrame = nil
local TouchJumpModule = nil
local IsModalEnabled = UserInputService.ModalEnabled
local BindableEvent_OnFailStateChanged = nil
local isJumpEnabled = false


--[[ Modules ]]--
local CurrentControlModule = nil
local ClickToMoveTouchControls = nil
local ControlModules = {}

local MasterControl = require(script:WaitForChild('MasterControl'))

if IsTouchDevice then
	ControlModules.Thumbstick = require(script.MasterControl:WaitForChild('Thumbstick'))
	ControlModules.Thumbpad = require(script.MasterControl:WaitForChild('Thumbpad'))
	ControlModules.DPad = require(script.MasterControl:WaitForChild('DPad'))
	ControlModules.Default = ControlModules.Thumbstick
	TouchJumpModule = require(script.MasterControl:WaitForChild('TouchJump'))
	BindableEvent_OnFailStateChanged = script.Parent:WaitForChild('OnClickToMoveFailStateChange')
else
	ControlModules.Keyboard = require(script.MasterControl:WaitForChild('KeyboardMovement'))
end
ControlModules.Gamepad = require(script.MasterControl:WaitForChild('Gamepad'))


--[[ Initialization/Setup ]]--
local function createTouchGuiContainer()
	if TouchGui then TouchGui:Destroy() end
	
	-- Container for all touch device guis
	TouchGui = Instance.new('ScreenGui')
	TouchGui.Name = "TouchGui"
	TouchGui.Parent = PlayerGui
	
	TouchControlFrame = Instance.new('Frame')
	TouchControlFrame.Name = "TouchControlFrame"
	TouchControlFrame.Size = UDim2.new(1, 0, 1, 0)
	TouchControlFrame.BackgroundTransparency = 1
	TouchControlFrame.Parent = TouchGui
	
	ControlModules.Thumbstick:Create(TouchControlFrame)
	ControlModules.DPad:Create(TouchControlFrame)
	ControlModules.Thumbpad:Create(TouchControlFrame)
	TouchJumpModule:Create(TouchControlFrame)
end

--[[ Local Functions ]]--
local function setJumpModule(isEnabled)
	if not isEnabled then
		TouchJumpModule:Disable()
	elseif CurrentControlModule == ControlModules.Thumbpad or CurrentControlModule == ControlModules.Thumbstick or
		CurrentControlModule == ControlModules.Default then
		--
		TouchJumpModule:Enable()
	end
end

local function setClickToMove()
	if DevMovementMode == Enum.DevTouchMovementMode.ClickToMove or DevMovementMode == Enum.DevComputerMovementMode.ClickToMove or
		UserMovementMode == Enum.ComputerMovementMode.ClickToMove or UserMovementMode == Enum.TouchMovementMode.ClickToMove then
		--
		if IsTouchDevice then
			ClickToMoveTouchControls = CurrentControlModule or ControlModules.Default
		end
	else
		if IsTouchDevice and ClickToMoveTouchControls then
			ClickToMoveTouchControls:Disable()
			ClickToMoveTouchControls = nil
		end
	end
end

--[[ Controls State Management ]]--
local onControlsChanged = nil
if IsTouchDevice then
	createTouchGuiContainer()
	onControlsChanged = function()
		local newModuleToEnable = nil
		if not IsUserChoice then
			if DevMovementMode == Enum.DevTouchMovementMode.Thumbstick then
				newModuleToEnable = ControlModules.Thumbstick
				isJumpEnabled = true
			elseif DevMovementMode == Enum.DevTouchMovementMode.Thumbpad then
				newModuleToEnable = ControlModules.Thumbpad
				isJumpEnabled = true
			elseif DevMovementMode == Enum.DevTouchMovementMode.DPad then
				newModuleToEnable = ControlModules.DPad
			elseif DevMovementMode == Enum.DevTouchMovementMode.ClickToMove then
				-- Managed by CameraScript
				newModuleToEnable = nil
			elseif DevMovementMode == Enum.DevTouchMovementMode.Scriptable then
				newModuleToEnable = nil
			end
		else
			if UserMovementMode == Enum.TouchMovementMode.Default or UserMovementMode == Enum.TouchMovementMode.Thumbstick then
				newModuleToEnable = ControlModules.Thumbstick
				isJumpEnabled = true
			elseif UserMovementMode == Enum.TouchMovementMode.Thumbpad then
				newModuleToEnable = ControlModules.Thumbpad
				isJumpEnabled = true
			elseif UserMovementMode == Enum.TouchMovementMode.DPad then
				newModuleToEnable = ControlModules.DPad
			elseif UserMovementMode == Enum.TouchMovementMode.ClickToMove then
				-- Managed by CameraScript
				newModuleToEnable = nil
			end
		end
		setClickToMove()
		if newModuleToEnable ~= CurrentControlModule then
			if CurrentControlModule then
				CurrentControlModule:Disable()
			end
			setJumpModule(isJumpEnabled)
			CurrentControlModule = newModuleToEnable
			if CurrentControlModule and not IsModalEnabled then
				CurrentControlModule:Enable()
				if isJumpEnabled then TouchJumpModule:Enable() end
			end
		end
	end
elseif UserInputService.KeyboardEnabled then
	onControlsChanged = function()
		-- NOTE: Click to move still uses keyboard. Leaving cases in case this ever changes.
		local newModuleToEnable = nil
		if not IsUserChoice then
			if DevMovementMode == Enum.DevComputerMovementMode.KeyboardMouse then
				newModuleToEnable = ControlModules.Keyboard
			elseif DevMovementMode == Enum.DevComputerMovementMode.ClickToMove then
				-- Managed by CameraScript
				newModuleToEnable = ControlModules.Keyboard
			end 
		else
			if UserMovementMode == Enum.ComputerMovementMode.KeyboardMouse or UserMovementMode == Enum.ComputerMovementMode.Default then
				newModuleToEnable = ControlModules.Keyboard
			elseif UserMovementMode == Enum.ComputerMovementMode.ClickToMove then
				-- Managed by CameraScript
				newModuleToEnable = ControlModules.Keyboard
			end
		end
		if newModuleToEnable ~= CurrentControlModule then
			if CurrentControlModule then
				CurrentControlModule:Disable()
			end
			CurrentControlModule = newModuleToEnable
			if CurrentControlModule then
				CurrentControlModule:Enable()
			end
		end
	end
end

--[[ Settings Changed Connections ]]--
LocalPlayer.Changed:connect(function(property)
	if IsTouchDevice and property == 'DevTouchMovementMode' then
		DevMovementMode = LocalPlayer.DevTouchMovementMode
		IsUserChoice = DevMovementMode == Enum.DevTouchMovementMode.UserChoice
		if IsUserChoice then
			UserMovementMode = GameSettings.TouchMovementMode
		end
		onControlsChanged()
	elseif not IsTouchDevice and property == 'DevComputerMovementMode' then
		DevMovementMode = LocalPlayer.DevComputerMovementMode
		IsUserChoice = DevMovementMode == Enum.DevComputerMovementMode.UserChoice
		if IsUserChoice then
			UserMovementMode = GameSettings.ComputerMovementMode
		end
		onControlsChanged()
	end
end)

GameSettings.Changed:connect(function(property)
	if not IsUserChoice then return end
	if property == 'TouchMovementMode' or property == 'ComputerMovementMode' then
		UserMovementMode = GameSettings[property]
		onControlsChanged()
	end
end)

--[[ Touch Events ]]--
if IsTouchDevice then
	-- On touch devices we need to recreate the guis on character load.
	LocalPlayer.CharacterAdded:connect(function(character)
		createTouchGuiContainer()
		if CurrentControlModule then
			CurrentControlModule:Disable()
			CurrentControlModule = nil
		end
		onControlsChanged()
	end)
	
	UserInputService.Changed:connect(function(property)
		if property == 'ModalEnabled' then
			IsModalEnabled = UserInputService.ModalEnabled
			setJumpModule(not UserInputService.ModalEnabled)
			if UserInputService.ModalEnabled then
				if CurrentControlModule then
					CurrentControlModule:Disable()
				end
			else
				if CurrentControlModule then
					CurrentControlModule:Enable()
				end
			end
		end
	end)

	BindableEvent_OnFailStateChanged.Event:connect(function(isOn)
		if ClickToMoveTouchControls then
			if isOn then
				ClickToMoveTouchControls:Enable()
			else
				ClickToMoveTouchControls:Disable()
			end
			if ClickToMoveTouchControls == ControlModules.Thumbpad or ClickToMoveTouchControls == ControlModules.Thumbstick or
				ClickToMoveTouchControls == ControlModules.Default then
				--
				if isOn then
					TouchJumpModule:Enable()
				else
					TouchJumpModule:Disable()
				end
			end
		end
	end)
end

MasterControl:Init()
onControlsChanged()

-- why do I need a wait here?!?!?!? Sometimes touch controls don't disappear without this
wait()
if UserInputService:GetGamepadConnected(Enum.UserInputType.Gamepad1) then
	if CurrentControlModule and IsTouchDevice then
		CurrentControlModule:Disable()
	end
	if isJumpEnabled and IsTouchDevice then TouchJumpModule:Disable() end

	ControlModules.Gamepad:Enable()
end

UserInputService.GamepadDisconnected:connect(function(gamepadEnum)
	if gamepadEnum ~= Enum.UserInputType.Gamepad1 then return end
	
	if CurrentControlModule and IsTouchDevice then
			CurrentControlModule:Enable()
	end
	if isJumpEnabled and IsTouchDevice then TouchJumpModule:Enable() end
	
	ControlModules.Gamepad:Disable()
end)

UserInputService.GamepadConnected:connect(function(gamepadEnum)
	if gamepadEnum ~= Enum.UserInputType.Gamepad1 then return end
	
	if CurrentControlModule and IsTouchDevice then
		CurrentControlModule:Disable()
	end
	if isJumpEnabled and IsTouchDevice then TouchJumpModule:Disable() end
	
	ControlModules.Gamepad:Enable()
end)

