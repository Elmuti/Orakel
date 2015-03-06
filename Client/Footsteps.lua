local player = game.Players.LocalPlayer
local char = player.CharacterAdded:wait()
local head = char:WaitForChild("Head")
local torso = char:WaitForChild("Torso")
local hum = char:WaitForChild("Humanoid")

while _G.volume == nil do wait() end

--Remove ROBLOX Sounds:
local defs = player.Character:findFirstChild("Sound")
if defs then
	defs:Destroy()
end

for _,object in pairs(head:getChildren()) do
	if object:IsA("Sound") then
		object:Destroy()
	end
end

--Sound Data:
local sound = {
	current = nil
}


--Each table in this list contains the following data (in this order): string SoundId, number Pitch, number Volume, boolean Looped
sound.list = {
	fsConcrete = {"http://www.roblox.com/asset/?id=142548009",1.3,.6,true},
	fsCobblestone = {"http://www.roblox.com/asset/?id=142548009",1.3,.6,true},
	fsMetal = {"http://www.roblox.com/asset/?id=145180178",1.3,.6,true},
	fsCorrodedMetal = {"http://www.roblox.com/asset/?id=145180178",1.3,.5,true},
	fsDiamondPlate = {"http://www.roblox.com/asset/?id=178711774",1.3,.5,true},
	fsFoil = {"http://www.roblox.com/asset/?id=178711762",1.3,.5,true},
	fsGrass = {"http://www.roblox.com/asset/?id=145180183",1.3,.6,true}, 
	fsIce = {"http://www.roblox.com/asset/?id=145180170",0.8,.7,true},
	fsPlastic = {"http://www.roblox.com/asset/?id=142548009",1.3,.5,true},
	fsSmoothPlastic = {"http://www.roblox.com/asset/?id=142548009",1.3,.5,true},
	fsSlate = {"http://www.roblox.com/asset/?id=142548009",1.3,.6,true},
	fsWood = {"http://www.roblox.com/asset/?id=178711820",1,.7,true},
	fsWoodPlanks = {"http://www.roblox.com/asset/?id=178711820",1,.7,true},
	
	fsWater = {"http://www.roblox.com/asset/?id=178711791",1,.8,true},
	fsSnow = {"http://www.roblox.com/asset/?id=145536125",1,.7,true},
	
	jump = {"http://www.roblox.com/asset/?id=",1,.5,false},


	fsAir = {'',1,0,false},
	
	fsBrick = {"http://www.roblox.com/asset/?id=142548009",1.3,.6,true},
	fsSand = {"http://www.roblox.com/asset/?id=145180183",1.3,.3,true},
	fsFabric = {"http://www.roblox.com/asset/?id=133705377",1.3,2.2,true},
	fsGranite = {"http://www.roblox.com/asset/?id=142548009",1.3,.55,true},
	fsMarble = {"http://www.roblox.com/asset/?id=142548009",1.3,.58,true},
	fsPebble = {"http://www.roblox.com/asset/?id=142548009",1.3,.5,true},
}

math.randomseed(tick())
--Create Sounds:
for name,data in pairs(sound.list) do
	local s = Instance.new("Sound",player.Character.Head)
	s.Name = name
	s.SoundId = data[1]
	s.Pitch = data[2]
	s.Volume = data[3] * .2 * _G.volume --quiter footsteps. those sounds were way too loud to be just footsteps. ~maelstronomer
	s.Looped = data[4]
	--Replaces the ID with the actual sound Object in the above table:
	sound.list[name] = {s,data[2]}
end

--Floor Data:
local ground = {
	part = nil,
	position = nil
}

--Detect Floor:
ground.detect = function()
	--Ignores the player and their camera which allows you to add local parts onto the character without messing this up.
	if player.Character:FindFirstChild('Torso') then
		local ignore = {player.Character,workspace.CurrentCamera}
		local ray = Ray.new(player.Character.Torso.Position,Vector3.new(0,-10,0)) --10? , 6
		local hit,pos = workspace:FindPartOnRayWithIgnoreList(ray,ignore)
		ground.part = hit
		ground.position = pos
	end
end

local isWalking = false

--Tell the below loop that the player is walking:
player.Character.Humanoid.IsRunning.Event:connect(function(speed)
	if speed > 0 then
		isWalking = true
	else
		isWalking = false
	end
end)

--Play Jump Sound:
player.Character.Humanoid.Jumping:connect(function(state)
	if not script:FindFirstChild('last_jumped') then
		
		local last_jumped = Instance.new('BoolValue',script) --update November 2 '13 @ 17:48 hours by Maelstronomer
		last_jumped.Name = 'last_jumped'
		game.Debris:AddItem(last_jumped,.5)
		
		ground.detect()
		if ground.part and not ground.part:IsA('Terrain') then
			player.Character.Head.jump.Pitch= math.random((sound.list.jump[2]-.075)*100,(sound.list.jump[2]+.075)*100)/100 --any larger pitch deviation for the Jump sound makes it sound awful and low-quality. ~maelstronomer
			sound.list.jump[1]:Play()
		end
	end
end)


repeat wait(.1) until isWalking

--Loop that Does things:
spawn(function()
	while wait() do
		--Get the ground:
		ground.detect()
		
		--Play and stop sounds:
		if isWalking and (ground.part and ground.part.Transparency < 1 and ground.part.CanCollide) then
			--Gets the name of the material without spaces or detects whether the part is called 'Water' or 'Snow':
			local mat
			if ground.part.Name == "Water" or ground.part.Name == "Snow" or ground.part.Name == 'Air' then
				mat = ground.part.Name
			else
				mat = string.sub(tostring(ground.part.Material),15)
				mat = string.gsub(mat, "%s+", "")
			end
			--Plays the sound:
			if sound.current ~= sound.list["fs"..mat][1] then
				if sound.current then sound.current:Stop() end
				sound.current = sound.list["fs"..mat][1]
				sound.current:Play()
			end
			--Determines the pitch of the sound based on the original pitch and the character's walkspeed (where 16 is no change).
			sound.current.Pitch= math.random((sound.list["fs"..mat][2]-.4)*100,(sound.list["fs"..mat][2]+.4)*100)/100--completely new! ~maelstronomer
			sound.current.Pitch = sound.current.Pitch/(16/player.Character.Humanoid.WalkSpeed) --used to be just a pitch deviation from the original. BUT it has to be a deviation from the random pitch now. ~maelstronomer
		elseif sound.current then
			sound.current:Stop()
			sound.current = nil
		end
	end
end) --2nd latest update on November 2 '13 at 14:30 h along with the movement script.