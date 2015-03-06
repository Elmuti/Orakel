local player = game.Players.LocalPlayer
local events = game.ReplicatedStorage
local char = player.Character
local cam = workspace.CurrentCamera
local mouse = player:GetMouse()
local welds = {} --1: left, 2: right
local Tool = script.Parent
local tool = Tool
local leftArmWeld
local rightArmWeld
local arms, torso

local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local anim = Orakel.LoadModule("WeapAnimLib")
local mat = Orakel.LoadModule("AssetLib")
local mathLib = Orakel.LoadModule("MathLib")
local physLib = Orakel.LoadModule("PhysLib")

local prepareToRemove = {}
local data, maxSoftPenetrate, maxHardPenetrate
local curWalkSpeed = 0

data = tool:WaitForChild("Data")
wait(1)


maxSoftPenetrate = 2 * data.Damage.PenetrationMultiplier.Value
maxHardPenetrate = 1 * data.Damage.PenetrationMultiplier.Value
local canfire = false
local reloading = false

local fxCache = workspace:FindFirstChild("fxCache")
if not fxCache then
	fxCache = Instance.new("Model", workspace)
	fxCache.Name = "fxCache"
end
table.insert(_G.ignorelist, fxCache)


function removePrepared()
	for _, o in pairs(prepareToRemove) do
		o:Destroy()
	end
end



function compressDamage(zedId, wepname, bodypart, origin, dmgtype)
	return origin, zedId..","..wepname..","..bodypart..","..dmgtype
end


function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end


function changeWeapon(newdata)
	canfire = false
	tool.Data:Destroy()
	data = newdata:clone()
	data.Parent = tool
	for _, o in pairs(tool:children()) do
		if o.Name ~= "Data" or o.Name ~= "Handle" or o.Name ~= "Main" or o.Name ~= "Component" then
			o:Destroy()
		end
	end
	canfire = true
	maxSoftPenetrate = 3 * data.Damage.PenetrationMultiplier.Value
	maxHardPenetrate = 1 * data.Damage.PenetrationMultiplier.Value
end


function vectorToFace(hit, vec)
	if hit == nil then return nil end
	vec = hit.CFrame:toObjectSpace(CFrame.new(hit.Position, hit.Position+vec)).lookVector
	vec = Vector3.new(mathLib.Round(vec.x),mathLib.Round(vec.y),mathLib.Round(vec.z))
	if vec == Vector3.new(0, 0, 1) then
		return Enum.NormalId.Back
	elseif vec == Vector3.new(0, 0, -1) then
		return Enum.NormalId.Front
	elseif vec == Vector3.new(-1, 0, 0) then
		return Enum.NormalId.Left
	elseif vec == Vector3.new(1, 0, 0) then
		return Enum.NormalId.Right
	elseif vec == Vector3.new(0, 1, 0) then
		return Enum.NormalId.Top
	elseif vec == Vector3.new(0, -1, 0) then
		return Enum.NormalId.Bottom
	end
	return nil
end

function playSound(type)
	if type == "Reload" then
		local s = Instance.new("Sound", tool.Handle)
		s.Volume = 0.15
		s.SoundId = data.ReloadSound.Value
		s:Play()
		game.Debris:AddItem(s, 3)
	elseif type == "Fire" then
		local s = Instance.new("Sound", tool.Handle)
		s.Volume = 0.25
		s.SoundId = data.FireSound.Value
		s:Play()
		game.Debris:AddItem(s, 2)
	end
end


function getRayEntranceAndExit(pos, dir, distance)
	local ignore = deepcopy(_G.ignorelist)
	local Ray1 = Ray.new(pos, dir.unit*distance)
	local obj, enter, enterface = workspace:FindPartOnRayWithIgnoreList(Ray1, _G.ignorelist)
	if obj ~= nil then
		table.insert(ignore, obj)
	end
	local Ray2 = Ray.new(enter, dir.unit*distance)
	local _, hpos2 = workspace:FindPartOnRayWithIgnoreList(Ray2, ignore)
	local Ray3 = Ray.new(hpos2, CFrame.new(hpos2, enter).lookVector.unit*distance)
	local _, exit, exitface = workspace:FindPartOnRayWithIgnoreList(Ray3, _G.ignorelist)
	return obj, enter, exit, vectorToFace(obj, enterface), vectorToFace(obj, exitface)
end



function drawLine(pos1, pos2, t0)
	local dist = (pos1-pos2).magnitude
	local rayPart = Instance.new("Part", workspace)
	table.insert(_G.ignorelist, rayPart)
	rayPart.Name = "NodeConnector"
	rayPart.BrickColor = BrickColor.new("Lime green")
	rayPart.Transparency = 0.5
	rayPart.Anchored = true
	rayPart.CanCollide = false
	rayPart.TopSurface = Enum.SurfaceType.Smooth
	rayPart.BottomSurface = Enum.SurfaceType.Smooth
	rayPart.formFactor = Enum.FormFactor.Custom
	rayPart.Size = Vector3.new(0.2, 0.2, dist)
	rayPart.CFrame = CFrame.new(pos1, pos2) * CFrame.new(0, 0, -dist/2)
	game:GetService("Debris"):AddItem(rayPart, t0)
	return rayPart
end

function drawPos(pos, color, t0)
	if pos == nil then return end
	local p = Instance.new("Part", workspace)
	table.insert(_G.ignorelist, p)
	p.BrickColor = color
	p.Transparency = 0.5
	p.Anchored = true
	p.CanCollide = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.formFactor = Enum.FormFactor.Custom
	p.Size = Vector3.new(0.2, 0.2, 0.2)
	p.CFrame = CFrame.new(pos)
	game:GetService("Debris"):AddItem(p, t0)
	return p
end

function createSmokeFx(pos, lookat)
	local fx = Instance.new("Part", fxCache)
	fx.Anchored = true
	fx.Transparency = 1
	fx.Name = "BulletSmokeEffect"
	fx.CanCollide = false
	fx.formFactor = "Custom"
	fx.Size = Vector3.new(0.2, 0.2, 0.2)
	fx.CFrame = CFrame.new(pos, lookat)
	game.Debris:AddItem(fx, 3)
	local s = Instance.new("Smoke", fx)
	s.Opacity = 0.3
	s.RiseVelocity = 2
	s.Size = 0.1
	s.Enabled = true
	spawn(function()
		wait(1)
		s.Enabled = false
	end)
end



function drawBulletFx(hit, pos, lookat, face, hitmat)
	local fx = Instance.new("Part", fxCache)
	fx.Anchored = true
	fx.Transparency = 1
	fx.Name = "BulletEffect"
	fx.CanCollide = false
	fx.formFactor = "Custom"
	fx.Size = Vector3.new(0.5, 0.5, 0.5)
	fx.CFrame = hit.CFrame
	fx.CFrame = CFrame.new(pos)
	local dec = Instance.new("Decal", fx)
	dec.Face = face
	dec.Texture = mat.Decals[hitmat][math.random(1,#mat.Decals[hitmat])]
	game.Debris:AddItem(fx, _G.bulletfadetime)
	return fx
end


function getSpread()
	local mult = 1
	if curWalkSpeed > 0 then
		mult = curWalkSpeed / 3
	end
	local spread = data.Spray.Value
	local dir = mouse.UnitRay.Direction
	local vec = Vector3.new(
		math.random(-spread, spread) / 80 * mult,
		math.random(-spread, spread) / 80 * mult,
		math.random(-spread, spread) / 80 * mult
	)
	dir = dir + vec
	return dir
end

function getCameraSpread()
	local mult = data.CameraSpreadMult.Value
	local vec = Vector3.new(
		math.random(-mult, mult), 
		math.random((-mult / 2), -mult), 
		math.random(-mult, mult)
	)
	return vec.x, vec.y, vec.z
end



function fire(recursive, origin, dir)
	mouse.TargetFilter = workspace
	canfire = false
	local penetrate = false
	local recursive = (recursive or 0)
	local mousehit, target = mouse.Hit.p, mouse.Target
	local dirVec = getSpread()
	local hit, enter, exit, enterface, exitface = getRayEntranceAndExit(origin or mouse.UnitRay.Origin, dir or dirVec, 999)
	if hit ~= nil then
		local dist = (enter - exit).magnitude + recursive
		local rm = mat.RealMaterial:Get(hit)
		if rm == "flesh" or rm == "fabric" or rm == "tile" or rm == "glass" or rm == "wood" then
			if dist <= maxSoftPenetrate then
				penetrate = true
			end
		else
			if dist <= maxHardPenetrate then
				penetrate = true
			end
		end
		if penetrate then
			spawn(function() fire(dist, exit, mouse.UnitRay.Direction) end)
		end
		if hit.Parent:findFirstChild("npc_ai") then
			if hit.Parent.Health.Value > 0 then
				events.Events.Damage:FireServer(hit.Parent.Name, data.DamageType.Value)
			end
		else
			local enterFx, exitFx
			local distNoRec = (enter - exit).magnitude
			enterFx = drawBulletFx(hit, enter, exit, enterface, mat.RealMaterial:Get(hit))
			createSmokeFx(enter, tool.Handle.Position)
			if distNoRec < 4 then
				exitFx = drawBulletFx(hit, exit, enter, exitface, mat.RealMaterial:Get(hit))
				createSmokeFx(exit, enter)
			end
			if hit.Name == "func_breakable" then
				if hit.Health.Value > 0 then
					print("FUCKING HIT A FUNC_BREAKABLE, SEND SERVER FUCKS TO GIVE")
					events.Events.DamageProp:FireServer(hit, data.WepName.Value, hit.Position, mat.RealMaterial:Get(hit), hit.Size)
				end
			end
			
		end
	end
	--drawLine(tool.Handle.Position, enter, 4)
	spawn(function()
		local showImpacts = events.Events.GetServerVar:InvokeServer("sv_showimpacts")
		local impactVisTime
		if showImpacts == 1 then
			impactVisTime = events.Events.GetServerVar:InvokeServer("sv_impactshowtime")
			drawPos(enter, BrickColor.new("Lime green"), impactVisTime)
			drawPos(exit, BrickColor.new("Really red"), impactVisTime)
		end
	end)
	
	if recursive == 0 then
		spawn(function()
			local cam_rot = cam.CoordinateFrame - cam.CoordinateFrame.p
			local cam_scroll = (cam.CoordinateFrame.p - cam.Focus.p).magnitude
			local ncf = CFrame.new(cam.Focus.p) * cam_rot * CFrame.fromEulerAnglesXYZ(getCameraSpread())
			cam.CoordinateFrame = ncf * CFrame.new(0, 0, cam_scroll)
		end)
	end
	wait(0.08)
	canfire = true
end


-- function reload()
-- 	if data.Ammo.Total.Value > 0 then
-- 		local clipmax = data.Ammo.ClipMax.Value
-- 		if data.Ammo.Clip.Value > 0 then
-- 			if data.Ammo.Total.Value <= clipmax then
-- 				print("reload type 1")
-- 				playSound("Reload")
-- 				local toAdd = data.Ammo.Total.Value + data.Ammo.Clip.Value
-- 				local toTake = toAdd - clipmax
-- 				data.Ammo.Clip.Value = data.Ammo.Clip.Value + toAdd
-- 				data.Ammo.Total.Value = data.Ammo.Total.Value - toTake
-- 			else
-- 				print("reload type 2")
-- 				playSound("Reload")
-- 				local toAdd = clipmax - data.Ammo.Clip.Value
-- 				data.Ammo.Clip.Value = data.Ammo.Clip.Value + toAdd
-- 				data.Ammo.Total.Value = data.Ammo.Total.Value - toAdd
-- 			end
-- 		else
-- 			if data.Ammo.Total.Value <= clipmax then
-- 				print("reload type 3")
-- 				playSound("Reload")
-- 				data.Ammo.Clip.Value = data.Ammo.Total.Value
-- 				data.Ammo.Total.Value = 0
-- 			else
-- 				print("reload type 4")
-- 				playSound("Reload")
-- 				data.Ammo.Clip.Value = data.Ammo.Clip.Value + clipmax
-- 				data.Ammo.Total.Value = data.Ammo.Total.Value - clipmax
-- 			end
-- 		end
-- 	end
-- end

function reload()
	playSound("Reload")
	local clip = data.Ammo.Clip.Value
	local ammo = data.Ammo.Total.Value
	local maxclip = data.Ammo.ClipMax.Value
	local ammolost = maxclip - clip
	if clip > 0 then
		if ammo >= maxclip then
			clip = maxclip
			ammo = ammo - maxclip + clip
		elseif ammo < maxclip then
			clip = ammo
			ammo = 0
		end
	elseif clip == 0 then
		if ammo >= maxclip then
			clip = maxclip
			ammo = ammo - maxclip + clip
		elseif ammo < maxclip then
			clip = ammo
			ammo = 0
		end
	end
end

function mouse1down()
	m1down = true
	if canfire and not reloading  then
		if data.Auto.Value and data.Ammo.Clip.Value > 0 then
			while m1down == true do
				playSound("Fire")
				fire()
				data.Ammo.Clip.Value = data.Ammo.Clip.Value - 1
				wait(1 / (data.Firerate.Value / 60))
			end
		elseif data.Burst.Value and data.Ammo.Clip.Value > 0 then
			for shot = 1, 3 do
				playSound("Fire")
				fire()
				data.Ammo.Clip.Value = data.Ammo.Clip.Value - 1
				wait(1 / (data.Firerate.Value / 60))
			end
		elseif data.Single.Value and data.Ammo.Clip.Value > 0 then
			playSound("Fire")
			fire()
			data.Ammo.Clip.Value = data.Ammo.Clip.Value - 1
			wait(1 / (data.Firerate.Value / 60))
		elseif data.Shotgun.Value and data.Ammo.Clip.Value > 0 then
			for shot = 1, data.ShotgunShells.Value do
				playSound("Fire")
				fire()
			end
			data.Ammo.Clip.Value = data.Ammo.Clip.Value - 1
			wait(1 / (data.Firerate.Value / 60))
		elseif data.Melee.Value then
			playSound("Fire")
		elseif data.Grenade.Value then
			playSound("Fire")
		end
	end
end

function mouse1up()
	m1down = false
end

function mouse2down()
	
end

function kbEvent(key, type)
	if type == -1 then
		if key == Enum.KeyCode.LeftControl then
			print("LEFT CTRL DOWN")
		elseif key == Enum.KeyCode.R and not reloading then
			reload()
		end
	elseif type == 1 then
		if key == Enum.KeyCode.LeftControl then
			print("LEFT CTRL UP")
		end
	end
end

function running(sp)
	curWalkSpeed = sp
end

function equipped(mouse)
	print("equipped :)")
	mouse.Button1Down:connect(mouse1down)
	mouse.Button1Up:connect(mouse1up)
	mouse.Button2Down:connect(mouse2down)
	tool.KeyboardEvent.Event:connect(kbEvent)
	player.Character.Humanoid.Running:connect(running)
	torso = Tool.Parent:FindFirstChild("Torso")
	arms = {Tool.Parent:FindFirstChild("Left Arm"), Tool.Parent:FindFirstChild("Right Arm")}
	if arms ~= nil and torso ~= nil then
		local sh = {torso:FindFirstChild("Left Shoulder"), torso:FindFirstChild("Right Shoulder")}
		sh[1].Part1 = nil
		sh[2].Part1 = nil
		local weld1 = Instance.new("Weld") -- left arm
		leftArmWeld = weld1
		weld1.Part0 = torso
		weld1.Parent = torso
		weld1.Part1 = arms[1]
		if data.Auto.Value then 
			weld1.C1 = CFrame.new(-0.35, 1.4, 0.6) * CFrame.fromEulerAnglesXYZ(math.rad(290), 0, math.rad(-90))
		else
			weld1.C1 = CFrame.new(-0.25, 0.2, 0.7) * CFrame.fromEulerAnglesXYZ(math.rad(320), -1, math.rad(-90))
		end
		welds[1] = weld1
		local weld2 = Instance.new("Weld") -- right arm
		rightArmWeld = weld2
		weld2.Part0 = torso
		weld2.Parent = torso
		weld2.Part1 = arms[2]
		if data.Auto.Value then
			weld2.C1 = CFrame.new(-0.75, 0.1, 0.35) * CFrame.fromEulerAnglesXYZ(math.rad(-90), math.rad(-15), 0)
		else
			weld2.C1 = CFrame.new(-0.95, 0.1, 0.35) * CFrame.fromEulerAnglesXYZ(math.rad(-76), math.rad(-25), 0)
		end
		welds[2] = weld2
		canfire = true
	else
		print("arms or torso dun exist :/")
	end
end

function unEquipped(mouse)
	if arms ~= nil and torso ~= nil then
		local sh = {torso:FindFirstChild("Left Shoulder"), torso:FindFirstChild("Right Shoulder")}
		sh[1].Part1 = arms[1]
		sh[2].Part1 = arms[2]
		welds[1].Parent = nil
		welds[2].Parent = nil
	end
end

tool.Equipped:connect(equipped)
tool.Unequipped:connect(unEquipped)



