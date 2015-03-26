
	-- // FileName: MasterControl
	-- // Version 1.0
	-- // Written by: jeditkacheff
	-- // Description: All character control scripts go thru this script, this script makes sure all actions are performed


--LOCAL VARS
local MasterControl = {}

local Players = game:GetService('Players')
local RunService = game:GetService('RunService')

while not Players.LocalPlayer do
	wait()
end
local LocalPlayer = Players.LocalPlayer
local CachedHumanoid = nil
local RenderSteppedCon = nil
local moveFunc = LocalPlayer.Move

local isJumping = false
local moveValue = Vector3.new(0,0,0)


--LOCAL FUNCS
local function getHumanoid()
	local character = LocalPlayer and LocalPlayer.Character
	if character then
		if CachedHumanoid and CachedHumanoid.Parent == character then
			return CachedHumanoid
		else
			CachedHumanoid = nil
			for _,child in pairs(character:GetChildren()) do
				if child:IsA('Humanoid') then
					CachedHumanoid = child
					return CachedHumanoid
				end
			end
		end
	end
end

--PUBLIC API
function MasterControl:Init()
	
	local renderStepFunc = function()
		if LocalPlayer and LocalPlayer.Character then
			local humanoid = getHumanoid()
			if not humanoid then return end
			
			if humanoid and not humanoid.PlatformStand and isJumping then
				humanoid.Jump = isJumping
			end

			moveFunc(LocalPlayer, moveValue, true)
		end
	end
	
	local success = pcall(function() RunService:BindToRenderStep("MasterControlStep", Enum.RenderPriority.Input.Value, renderStepFunc) end)
	
	if not success then
		if RenderSteppedCon then return end
		RenderSteppedCon = RunService.RenderStepped:connect(renderStepFunc)
	end
end

function MasterControl:Disable()
	local success = pcall(function() RunService:UnbindFromRenderStep("MasterControlStep") end)
	if not success then
		if RenderSteppedCon then
			RenderSteppedCon:disconnect()
			RenderSteppedCon = nil
		end
	end
	
	moveValue = Vector3.new(0,0,0)
	isJumping = false
end

function MasterControl:AddToPlayerMovement(playerMoveVector)
	moveValue = Vector3.new(moveValue.X + playerMoveVector.X, moveValue.Y + playerMoveVector.Y, moveValue.Z + playerMoveVector.Z)
end

function MasterControl:SetIsJumping(jumping)
	isJumping = jumping
end

function MasterControl:DoJump()
	local humanoid = getHumanoid()
	if humanoid then
		humanoid.Jump = true
	end
end

return MasterControl
