--[[
	// FileName: TouchJump
	// Version 1.0
	// Written by: jmargh
	// Description: Implements jump controls for touch devices. Use with Thumbstick and Thumbpad
--]]

local Players = game:GetService('Players')

local TouchJump = {}

local MasterControl = require(script.Parent)

--[[ Script Variables ]]--
while not Players.LocalPlayer do
	wait()
end
local LocalPlayer = Players.LocalPlayer
local JumpButton = nil
local OnInputEnded = nil		-- defined in Create()

--[[ Constants ]]--
local TOUCH_CONTROL_SHEET = "rbxasset://textures/ui/TouchControlsSheet.png"

--[[ Public API ]]--
function TouchJump:Enable()
	JumpButton.Visible = true
end

function TouchJump:Disable()
	JumpButton.Visible = false
	OnInputEnded()
end

function TouchJump:Create(parentFrame)
	if JumpButton then
		JumpButton:Destroy()
		JumpButton = nil
	end
	
	local isSmallScreen = parentFrame.AbsoluteSize.y <= 500
	local jumpButtonSize = isSmallScreen and 70 or 90
	
	JumpButton = Instance.new('ImageButton')
	JumpButton.Name = "JumpButton"
	JumpButton.Visible = false
	JumpButton.BackgroundTransparency = 1
	JumpButton.Image = TOUCH_CONTROL_SHEET
	JumpButton.ImageRectOffset = Vector2.new(176, 222)
	JumpButton.ImageRectSize = Vector2.new(174, 174)
	JumpButton.Size = UDim2.new(0, jumpButtonSize, 0, jumpButtonSize)
	JumpButton.Position = isSmallScreen and UDim2.new(1, jumpButtonSize * -2.25, 1, -jumpButtonSize - 20) or
		UDim2.new(1, jumpButtonSize * -2.75, 1, -jumpButtonSize - 120)
	
	local touchObject = nil	
	JumpButton.InputBegan:connect(function(inputObject)
		if touchObject or inputObject.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		
		touchObject = inputObject
		JumpButton.ImageRectOffset = Vector2.new(0, 222)
		MasterControl:SetIsJumping(true)
	end)
	
	OnInputEnded = function()
		touchObject = nil
		MasterControl:SetIsJumping(false)
		JumpButton.ImageRectOffset = Vector2.new(176, 222)
	end
	
	JumpButton.InputEnded:connect(function(inputObject)
		if inputObject == touchObject then
			OnInputEnded()
		end
	end)
	
	JumpButton.Parent = parentFrame
end

return TouchJump
