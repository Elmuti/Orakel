local Module = {}

local Orakel = require(game.ReplicatedStorage.Orakel.Main)


Module.SetCameraDefault = function(tween, dur)
	local cam = workspace.CurrentCamera
	local char = game.Players.LocalPlayer.Character
	local mouse = game.Players.LocalPlayer:GetMouse()
	
	if tween then
		cam:Interpolate(CFrame.new(char.Torso.Position + Vector3.new(0, 2, 0)), mouse.Hit, dur or 1)
	end

	cam.CameraType = Enum.CameraType.Custom
	cam.CameraSubject = game.Players.LocalPlayer.Character.Humanoid
	cam.FieldOfView = 70
end



Module.TweenCamera = function(c0, f0, c1, f1, t0, tween)
	local cam = workspace.CurrentCamera
	cam.CameraType = Enum.CameraType.Scriptable
	c1 = CFrame.new(c1.p, f1.p)
	if tween then
		cam:Interpolate(c1, f1, t0 or 1)
	else
	  cam.CoordinateFrame = CFrame.new(c1.p, f1.p)
	end
end



Module.ShakeCamera = function(c0, f0, intensity, duration, opposite)
	local opposite = opposite or true
	local t = time()
	local i = (intensity/2)
	local i2 = i
	while ((time()-t) < duration) do
		if (opposite) then
			i = (i2*((time()-t)/duration))
		else
			i = (i*(1-((time()-t)/duration)))
		end
		workspace.CurrentCamera.CoordinateFrame = (c0*CFrame.new((-i+(math.random()*i)),(-i+(math.random()*i)),(-i+(math.random()*i))))
		workspace.CurrentCamera.Focus = (f0*CFrame.new((-i+(math.random()*i)),(-i+(math.random()*i)),(-i+(math.random()*i))))
		wait(0)
	end
	workspace.CurrentCamera.CoordinateFrame = c0
	workspace.CurrentCamera.Focus = f0
end



return Module