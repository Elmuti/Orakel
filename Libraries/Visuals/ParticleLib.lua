local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local alib = Orakel.LoadModule("AssetLib")

local rService = game:GetService("RunService")
local eng = {}

warn(Orakel.Configuration.PrintHeader..script:GetFullName().." dependencies loaded")


function eng.FadeSprite(s, endTransparency, fadeDuration)
	local itp = s.ImageTransparency
	local fps = 10
	local steps = fadeDuration * fps
	for i = 1, steps do
		s.ImageTransparency = s.ImageTransparency - (itp - endTransparency) / steps
		wait(1 / fps)
	end
end

function eng.CreateSpark(origin, velMod, velModY, life)
	local sparkcolor = Color3.new(1, 1, math.random())
	local p = Instance.new("Part", workspace)
	p.CanCollide = false
	p.Transparency = 1
	p.formFactor = "Custom"
	p.Size = Vector3.new(.1,.1,.1)
	p.CFrame = CFrame.new(
		origin.Position.x, 
		origin.Position.y, 
		origin.Position.z
	)
	game.Debris:AddItem(p, life)
	local pl = Instance.new("PointLight", p)
	pl.Shadows = true
	pl.Color = sparkcolor
	pl.Range = 4
	local c = Instance.new("BillboardGui", p)
	c.Enabled = true
	c.Adornee = p
	c.Size = UDim2.new(1, 0, 1, 0)
	local il = Instance.new("ImageLabel", c)
	il.Size = UDim2.new(.1, 0, .1, 0)
	il.BorderSizePixel = 0
	il.BackgroundColor3 = sparkcolor
	p.Velocity = Vector3.new(
		math.random(-25, 25) * velMod,
		math.random(5, 50) * velModY,
		math.random(-25, 25) * velMod
	)
	return p
end


function eng.CreateSparks(origin, minAmount, maxAmount, velMod, velModY, life)
	for i = 1, math.random(minAmount, maxAmount) do
		eng.CreateSpark(origin, velMod, velModY, life)
	end
end

function eng.CreateSmoke(origin, size, risevelocity, color, transparency, life)
	local yInterval = Vector3.new(0, risevelocity * 0.1, 0)
	while true do
		local rvec = Vector3.new(
			math.random(-size, size),
			0,
			math.random(-size, size)
		)
		local p = Instance.new("Part", workspace)
			p.Name = "env_smoke_sprite"
			p.Anchored = true
			p.CanCollide = false
			p.Transparency = 1
			p.formFactor = "Custom"
			p.Size = Vector3.new(.1,.1,.1)
			p.CFrame = CFrame.new(
				origin.Position.x + rvec.x, 
				origin.Position.y, 
				origin.Position.z + rvec.z
			)
			game.Debris:AddItem(p, life * 2)
			
		local c = Instance.new("BillboardGui", p)
		c.Enabled = true
		c.Adornee = p
		c.Size = UDim2.new(2, 0, 2, 0)
		local il = Instance.new("ImageLabel", c)
		il.Image = alib.smokesprites[math.random(1,#alib.smokesprites)]
		il.Size = UDim2.new(1 * size, 0, 1 * size, 0)
		il.BorderSizePixel = 0
		il.BackgroundTransparency = 1
		il.ImageTransparency = 1
		il.ImageColor3 = color
		
		coroutine.resume(coroutine.create(function()
			repeat
				il.Size = il.Size + UDim2.new(.1, 0, .1, 0)
				wait(1/5)
			until il.Size.X.Scale >= size
		end))
		
		coroutine.resume(coroutine.create(function()
			local floatDir = Vector3.new(
				math.random(-.1, .1),
				0,
				math.random(-.1, .1)
			)
			local bools = {false,true}
			local rotdir = bools[math.random(1,#bools)]
			local t = 0
			while true do
				local newVec = p.CFrame.p + yInterval + floatDir
				if rotdir then
					il.Rotation = il.Rotation + math.random(0, 2)
				else
					il.Rotation = il.Rotation - math.random(0, 2)
				end
				p.CFrame = CFrame.new(newVec)
				rService.RenderStepped:wait()
				t = t + 0.01
				if t >= life then
					eng.FadeSprite(il, 1, 0.5)
					p:Destroy()
				end
			end
		end))
		coroutine.resume(coroutine.create(function()
			eng.FadeSprite(il, transparency, 0.5)
		end))
		wait(1/15)
	end
	
	
end


function eng.FireCircle(origin, radius, rvec, firecolor, yInterval)
	print("fire circle")
	for angle = 1, (360 / 20) do
		local p = Instance.new("Part", workspace)
		p.Name = "env_fire_sprite"
		p.Anchored = true
		p.CanCollide = false
		p.Transparency = 1
		p.formFactor = "Custom"
		p.Size = Vector3.new(.1,.1,.1)
		p.CFrame = CFrame.new(
			origin.Position.x + rvec.x, 
			origin.Position.y, 
			origin.Position.z + rvec.z
		) * CFrame.Angles(math.rad(angle * 20), 0, 0)
		  * CFrame.new(0, 0, radius)
		game.Debris:AddItem(p, 3)
		
		local pl = Instance.new("PointLight", p)
		pl.Shadows = true
		pl.Color = firecolor
		pl.Range = 4
		local c = Instance.new("BillboardGui", p)
		c.Enabled = true
		c.Adornee = p
		c.Size = UDim2.new(2, 0, 2, 0)
		local il = Instance.new("ImageLabel", c)
		il.Size = UDim2.new(1, 0, 1, 0)
		il.BorderSizePixel = 0
		il.BackgroundTransparency = 1
		il.ImageColor3 = firecolor
		
		coroutine.resume(coroutine.create(function()
			local sheet = alib.spritesheets["fire"]
			local ssize = sheet.size
			local id = sheet.id
			local num = sheet.tiles
			il.Image = id
			il.ImageRectSize = Vector2.new(ssize, ssize)

			for curs = 0, num do
				il.ImageRectOffset = Vector2.new((curs * ssize), 0)
				wait(1/15)
			end
			eng.FadeSprite(il, 1, 0.5)
			p:Destroy()
		end))
		
		coroutine.resume(coroutine.create(function()
			local floatDir = Vector3.new(
				math.random(-.1, .1),
				0,
				math.random(-.1, .1)
			)
			while true do
				local newVec = p.CFrame.p + yInterval + floatDir
				p.CFrame = CFrame.new(newVec)
				rService.RenderStepped:wait()
			end
		end))
	end
end

function eng.CreateFire(origin, size)
	print("eng.CreateFire->")
	local firecolor = Color3.new(1, 1, 1)
	local velMod = 1
	local velModY = 1
	local yInterval = Vector3.new(0, 0.1, 0)
	while true do
		local rvec = Vector3.new(
			math.random(-size / 2, size / 2),
			0,
			math.random(-size / 2, size / 2)
		)
		eng.FireCircle(origin + Vector3.new(0, 3, 0), size / 2, rvec, firecolor, yInterval)
		eng.FireCircle(origin, size, rvec, firecolor, yInterval)
		wait(1/10)
	end
end

warn(Orakel.Configuration.PrintHeader..script:GetFullName().." loaded successfully")

return eng
