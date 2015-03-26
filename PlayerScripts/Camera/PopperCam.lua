-- PopperCam Version 12
-- OnlyTwentyCharacters

local PopperCam = {} -- Guarantees your players won't see outside the bounds of your map!

---------------
-- Constants --
---------------

local POP_RESTORE_RATE = 0.3
local CAST_SCREEN_SCALES = { -- (Relative)
	Vector2.new(1, 1) / 2, -- Center
	Vector2.new(0, 0), -- Top left
	Vector2.new(1, 0), -- Top right
	Vector2.new(1, 1), -- Bottom right
	Vector2.new(0, 1), -- Bottom left
}
local NEAR_CLIP_PLANE_OFFSET = 0.5 --NOTE: Not configurable

---------------
-- Variables --
---------------

local PlayersService = game:GetService('Players')
local Player = PlayersService.LocalPlayer
local PlayerMouse = Player:GetMouse()

local Camera = nil
local CameraChangeConn = nil

local PlayerCharacters = {} -- For ignoring in raycasts
local VehicleParts = {} -- Also just for ignoring

local LastPopAmount = 0
local LastZoomLevel = 0

---------------------
-- Local Functions --
---------------------

local function CastRay(fromPoint, toPoint, ignoreList)
	local vector = toPoint - fromPoint
	local ray = Ray.new(fromPoint, vector.Unit * math.min(vector.Magnitude, 999))
	return workspace:FindPartOnRayWithIgnoreList(ray, ignoreList or {})
end

-- Casts and recasts until it hits either: nothing, or something not transparent or collidable
local function PiercingCast(fromPoint, toPoint, ignoreList) --NOTE: Modifies ignoreList!
	repeat
		local hitPart, hitPoint = CastRay(fromPoint, toPoint, ignoreList)
		if hitPart and (hitPart.Transparency > 0.95 or hitPart.CanCollide == false) then
			table.insert(ignoreList, hitPart)
		else
			return hitPart, hitPoint
		end
	until false
end

local function ScreenToWorld(screenPoint, screenSize, pushDepth)
	local cameraFOV, cameraCFrame = Camera.FieldOfView, Camera.CoordinateFrame
	local imagePlaneDepth = screenSize.y / (2 * math.tan(math.rad(cameraFOV) / 2))
	local direction = Vector3.new(screenPoint.x - (screenSize.x / 2), (screenSize.y / 2) - screenPoint.y, -imagePlaneDepth)
	local worldDirection = (cameraCFrame:vectorToWorldSpace(direction)).Unit
	local theta = math.acos(math.min(1, worldDirection:Dot(cameraCFrame.lookVector)))
	local fixedPushDepth = pushDepth / math.sin((math.pi / 2) - theta)
	return cameraCFrame.p + worldDirection * fixedPushDepth
end

local function OnCameraChanged(property)
	if property == 'CameraSubject' then
		local newSubject = Camera.CameraSubject
		if newSubject and newSubject:IsA('VehicleSeat') then
			VehicleParts = newSubject:GetConnectedParts(true)
		else
			VehicleParts = {}
		end
	end
end

local function OnCharacterAdded(player, character)
	PlayerCharacters[player] = character
end

local function OnPlayersChildAdded(child)
	if child:IsA('Player') then
		child.CharacterAdded:connect(function(character)
			OnCharacterAdded(child, character)
		end)
		if child.Character then
			OnCharacterAdded(child, child.Character)
		end
	end
end

local function OnPlayersChildRemoved(child)
	if child:IsA('Player') then
		PlayerCharacters[child] = nil
	end
end

local function OnWorkspaceChanged(property)
	if property == 'CurrentCamera' then
		local newCamera = workspace.CurrentCamera
		if newCamera then
			Camera = newCamera
			
			if CameraChangeConn then
				CameraChangeConn:disconnect()
			end
			CameraChangeConn = Camera.Changed:connect(OnCameraChanged)
		end
	end
end

-----------------------
-- Exposed Functions --
-----------------------

function PopperCam:Update()
	-- First, prep some intermediate vars
	local focusPoint = Camera.Focus.p
	local cameraCFrame = Camera.CoordinateFrame
	local cameraFrontPoint = cameraCFrame.p + (cameraCFrame.lookVector * NEAR_CLIP_PLANE_OFFSET)
	local screenSize = Vector2.new(PlayerMouse.ViewSizeX, PlayerMouse.ViewSizeY)
	local ignoreList = {}
	for _, character in pairs(PlayerCharacters) do
		table.insert(ignoreList, character)
	end
	for _, basePart in pairs(VehicleParts) do
		table.insert(ignoreList, basePart)
	end
	
	-- Cast rays at the near clip plane, from corresponding points near the focus point,
	-- and find the direct line that is the most cut off
	local largest = 0
	for _, screenScale in pairs(CAST_SCREEN_SCALES) do
		local clipWorldPoint = ScreenToWorld(screenSize * screenScale, screenSize, NEAR_CLIP_PLANE_OFFSET)
		local rayStartPoint = focusPoint + (clipWorldPoint - cameraFrontPoint)
		local _, hitPoint = PiercingCast(rayStartPoint, clipWorldPoint, ignoreList)
		local cutoffAmount = (hitPoint - clipWorldPoint).Magnitude
		if cutoffAmount > largest then
			largest = cutoffAmount
		end
	end
	
	-- Then check if the user zoomed since the last frame,
	-- and if so, reset our pop history so we stop tweening
	local zoomLevel = (cameraCFrame.p - focusPoint).Magnitude
	if math.abs(zoomLevel - LastZoomLevel) > 0.001 then
		LastPopAmount = 0
	end
	
	-- Finally, pop (zoom) the camera in by that most-cut-off amount, or the last pop amount if that's more
	local popAmount = math.max(largest, LastPopAmount)
	if popAmount > 0 then
		Camera.CoordinateFrame = cameraCFrame + (cameraCFrame.lookVector * popAmount)
		LastPopAmount = math.max(popAmount - POP_RESTORE_RATE, 0) -- Shrink it for the next frame
	end
	
	LastZoomLevel = zoomLevel
end

------------------
-- Script Logic --
------------------

-- Connect to the current and all future cameras
workspace.Changed:connect(OnWorkspaceChanged)
OnWorkspaceChanged('CurrentCamera')

-- Connect to all Players so we can ignore their Characters
PlayersService.ChildRemoved:connect(OnPlayersChildRemoved)
PlayersService.ChildAdded:connect(OnPlayersChildAdded)
for _, player in pairs(PlayersService:GetPlayers()) do
	OnPlayersChildAdded(player)
end

return PopperCam
