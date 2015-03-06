local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local eng = {}


function eng.RecursiveFind(dir, name)
	local found = {}
	local c = dir:GetChildren()
	for _, o in pairs(c) do
		if o.Name == name then
			table.insert(found, o)
		else
			eng.RecursiveFind(o, name)
		end
	end
	return found
end


function eng.LoadAsset(assetId, maxLoadTime)
	local contentProvider = game:GetService("ContentProvider")
	contentProvider:Preload(assetId)
	local currentQueuePosition = contentProvider.RequestQueueSize
	local lastQueueSize = currentQueuePosition
	local loadStart = tick()
	while wait(1/60) do
		if contentProvider.RequestQueueSize < lastQueueSize then
			currentQueuePosition = currentQueuePosition - (lastQueueSize-contentProvider.RequestQueueSize)	
		end
		if currentQueuePosition < 1 then 
			return true 
		end
		if maxLoadTime and tick() - loadStart > maxLoadTime then 
			break 
		end
		lastQueueSize = contentProvider.RequestQueueSize
	end
end



function eng.LoadMap(map,currentMap)
	warn(Orakel.Configuration.PrintHeader..'Loading map "'..tostring(map)..'"')
	workspace.Terrain:Clear()
	local currentMap = map.Name
	if workspace:findFirstChild(currentMap) then
		workspace[currentMap]:Destroy()
	end
	
	--load the actual map
	local mC = map:clone()
	mC.Parent = workspace
	wait(.25)
	mC:MoveTo(Vector3.new(0, 1000, 0))
	wait(.25)
	local params = map["_parameters"]:children()
	local skySides = map["_parameters"]["Skybox"]:children()
	--set lighting and skybox
	for k,v in pairs(params) do
		if v.Name == "Skybox" or v.Name == "MissionType" then
			--TODO: Why is this blank? Surely you created this statement for a purpose?
		else
			game.Lighting[v.Name] = v.Value
		end
	end
	local sky = game.Lighting:findFirstChild("Sky")
	if not sky then 
		sky = Instance.new("Sky",game.Lighting)
	end
	for k,v in pairs(skySides) do
		if v.Name == "CelestialBodiesShown" then
			sky.CelestialBodiesShown = v.Value
		elseif v.Name == "starcount" then
			sky.StarCount = v.Value
		else
			sky["Skybox"..v.Name] = v.Value
		end
	end
	
	local function invisBricks(d)
		for _, n in pairs(d:children()) do
			if n:IsA("BasePart") then
				n.Transparency = 1
				for _, t in pairs(n:GetChildren()) do
					if t.ClassName == "Texture" then
						t:Destroy()
					end
				end
			end
		end
	end
	
	local function invisSpawns(d)
		for _, o in pairs(d:children()) do
			if o:IsA("BasePart") then
				if o.Name == "Head"  or o.Name == "Right Arm" or o.Name == "Left Arm" or o.Name == "Torso" or o.Name == "Left Leg" or o.Name == "Right Leg" then
					o.Transparency = 1
				end
			else
				invisSpawns(o)
			end
		end
	end
	
	local function isBrushEntity(ins)
		for name, isBrushEntity in pairs(Orakel.EntityList) do
			if ins.Name == name then
				if isBrushEntity then
					return true
				end
			end
		end
		return false
	end
	
	local function invisEnts(d)
		for _, o in pairs(d:children()) do
			if isBrushEntity(o) then
				o.Transparency = 1
				for _, t in pairs(o:GetChildren()) do
					if t.ClassName == "Texture" then
						t:Destroy()
					end
				end
			elseif o.ClassName == "BillboardGui" then
				o:Destroy()
			elseif o.Name == "CFrame" or o.Name == "Focus" or o.Name == "weapon_spawn" then
				o.Transparency = 1
			else
				invisEnts(o)
			end
		end
	end
	
	local function killUnusedConnections(dir)
		for _, n in pairs(dir:children()) do
			for _, c in pairs(n:children()) do
				if c.Name == "connection" then
					if c.Value == nil then
						c:Destroy()
					end
				end
			end
		end
	end
	
	pcall(function() killUnusedConnections(mC.Nodes) end)
	pcall(function() invisSpawns(mC.PlayerSpawns) end)
	pcall(function() invisSpawns(mC.ZedSpawns) end)
	pcall(function() invisSpawns(mC.NpcSpawns) end)
	pcall(function() invisEnts(mC.Entities) end)
	pcall(function() invisBricks(mC.Nodes) end)
	pcall(function() invisBricks(mC.Clip) end)
	pcall(function() invisBricks(mC.NavClip) end)
	
	warn(Orakel.Configuration.PrintHeader..'Map "'..tostring(map)..'" loaded!')
	return mC
end

return eng