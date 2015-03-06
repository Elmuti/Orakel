local char = script.Parent
local head = char:WaitForChild("Head")
local torso = char:WaitForChild("Torso")
local hum = char:WaitForChild("Humanoid")
local destReachRange = 2
local findCoverRadius = 35
local losRange = 128
local hearRange = 48
local ai_max_range = math.huge
local attackRange = 2 --65
local minDamageHeight = 15
local maxDamageHeight = 35
local runSpeed = 16
local patrolSpeed = 6
local IsFalling = false
local initTarget = char.InitGoal.Value
local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local npcLib = Orakel.LoadModule("NpcLib")
local pathLib = Orakel.LoadModule("PathLib")
local mathLib = Orakel.LoadModule("MathLib")
local faceAnim = Orakel.LoadModule("FacialAnimation")

local map = Orakel.GetMap()
local masterTable, mnt_index = pathLib.CollectNodes(map.Nodes)


warn(Orakel.Configuration.PrintHeader..script:GetFullName().."-> Initializing Npc")


local gyro
function initGyro()
	gyro = Instance.new("BodyGyro", script.Parent.Torso)
	gyro.D = 50
	gyro.P = 500
	gyro.maxTorque = Vector3.new(0, 400000, 0)
end

function rotateTowards(goal)
	if gyro ~= nil then
		gyro.cframe = CFrame.new(torso.Position, goal) - torso.Position
	end
end

function moveChar(pos)
	--hum:Move((pos - torso.Position).unit)
	hum:MoveTo(pos)
end

function stopChar()
	hum:Move((torso.Position - torso.Position).unit)
end

function fadeCorpse()
	warn(Orakel.Configuration.PrintHeader..script:GetFullName().."-> Death")
	wait(Orakel.GameInfo.CorpseFadeTime)
	char:Destroy()
end


function hasReachedDestination(dest)
	if (torso.Position - dest.Position).magnitude <= destReachRange then
		return true
	else
		return false
	end
end


function lineOfSight(a, b)
	local los = false
	local vis = npcLib.LineOfSight(a, b, losRange, _G.ignorelist)
	local behind = (b.CFrame:toObjectSpace(a.CFrame).p.Z < 0)
	if vis and not behind then
		los = true
	end
	return los
end

function attack()
	local weapon = game.ServerStorage.Weapons:FindFirstChild(char.Weapons.Value)
	--local bp = npcLib.GetRealBodyPart(bp)
	
	
	
end


function chooseTarget()
	local targets = {}
	--Find NPC targets
	for _, npc in pairs(workspace.npcCache:GetChildren()) do
		if npc.Health.Value > 0 and npc.Faction.Value ~= char.Faction.Value and npc ~= char then
			local los = lineOfSight(head, npc.Head)
			if los then
				table.insert(targets, npc)
			else
				if npc.EmittingSound.Value then
					local dist = (torso.Position - npc.Torso.Position).magnitude
					if dist <= hearRange then
						table.insert(targets, npc)
					end
				end
			end
		end
	end
	--Find Player targets
	for _, plrInGame in pairs(game.Players:GetPlayers()) do
		local plr = plrInGame.Character
		if plr ~= nil then
			if plr:FindFirstChild("Health") then
				if plr.Health.Value > 0 and plr.Faction.Value ~= char.Faction.Value then
					local los = lineOfSight(head, plr.Head)
					if los then
						table.insert(targets, plr)
					else
						if plr.EmittingSound.Value then
							local dist = (torso.Position - plr.Torso.Position).magnitude
							if dist <= hearRange then
								table.insert(targets, plr)
							end
						end
					end
				end
			end
		end
	end
	
	if #targets > 1 then
		local nearest = targets[1]
		for t = 2, #targets do
			local old = (nearest.Torso.Position - torso.Position).magnitude
			local new = (targets[t].Torso.Position - torso.Position).magnitude
			if new < old then
				nearest = targets[t]
			end
		end
	elseif #targets == 1 then
		return targets[1]
	end
	return nil
end


function findNearestCover(coverToIgnore)
	local coverNodes = pathLib.GetNodesVisibleInRadius(torso.Position, findCoverRadius, false, map.Nodes, masterTable)
	local cover = {}
	
	for _, node in pairs(coverNodes) do
		local data = pathLib.GetNodeData(masterTable, node)
		if data.PossibleCover then
			table.insert(cover, data.Brick)
		end
	end
	
	if #cover > 1  then
	    local nearest = cover[1]
	    for n = 2, #cover do
            local old = (nearest.Position - torso.Position).magnitude
            local new = (torso.Position - cover[n].Position).magnitude
            if new < old and cover[n] ~= coverToIgnore then
            	nearest = cover[n]
            end
	    end
		return nearest
	elseif #cover == 1 then
		return cover[1]
	end
	
	return nil
end


function pathFind(target, startPos, goalPos)
	local startID = pathLib.GetNearestNode(startPos, false, map.Nodes, masterTable)
	local goalID = pathLib.GetNearestNode(startPos, false, map.Nodes, masterTable)
	local path = pathLib.AStar(masterTable, startID, goalID, true)
	
	
	for nodeNum, node in pairs(path) do
		warn(Orakel.Configuration.PrintHeader..script:GetFullName().."-> MOVIN TO NODE")

		local eta = npcLib.EstimatedPathTime(torso.Position, node.Position, hum.WalkSpeed)
		local timeWalked = 0
		
		while true do
			moveChar(node.Position)
			local act = wait(1/10)
			timeWalked = timeWalked + act
			rotateTowards(node.Position)
			local newTarget = chooseTarget()
			--Reached node, Move to next node
			if hasReachedDestination(node) then
				warn(Orakel.Configuration.PrintHeader..script:GetFullName().."-> Reached node, Move to next node")
				break
			end
			--Target changed!
			if newTarget ~= target and newTarget ~= nil then
				warn(Orakel.Configuration.PrintHeader..script:GetFullName().."-> Target changed from "..tostring(target).." to "..tostring(newTarget)..", aborting pathfind!")
				return false
			end
			--Timed out! Return false, acquire new path
			if timeWalked > eta then
				warn(Orakel.Configuration.PrintHeader..script:GetFullName().."-> Timed out!")
				return false
			end
			--Got line of sight on target, Stop finding the path and just walk there
			if npcLib.LineOfSight(head, target.Torso, losRange, _G.ignorelist) and (torso.Position - target.Torso.Position).magnitude <= 25 then
				warn(Orakel.Configuration.PrintHeader..script:GetFullName().."-> Got line of sight on target, Stop pathfinding")
				return false
			end
		end
	end
	return true
end



function takeDamage(player, dmg, dtype)
	if dmg >= char.Health.Value then
		npcLib.DealDamage(char.Health, dmg, dtype)
		npcLib.DealDamage(hum, dmg, dtype)
	else
		npcLib.DealDamage(char.Health, dmg, dtype)
	end
	if char.Health.Value <= 0 then
		hum.PlatformStand = true
	end
end



function humanoidFall(falling)
	IsFalling = falling
	if IsFalling then
		local maxHeight = 0
		while IsFalling do
			local height = math.abs(torso.Position.y)
			if height > maxHeight then
				maxHeight = height
			end
			wait(1/30)
		end
		local fallHeight = maxHeight - torso.Position.y
		local impactHeight = fallHeight - minDamageHeight
		if fallHeight > minDamageHeight then
		    local mult = ((minDamageHeight - maxDamageHeight) / 100)
            local dmg = (minDamageHeight - fallHeight) / mult
            dmg = mathLib.Round(dmg)
			npcLib.DealDamage(hum, dmg, "FALL")
		end
	end
end


function numSuccessfulCollects(ent)
	local num = 0
	for _, cl in pairs(ent:GetChildren()) do
		if cl.Name == "DidCollect" then
			num = num + 1
		end
	end
	return num
end

local didCollect = false
function listenForRecollect(ent)
	while wait(1/5) do
		if ent.Enabled.Value and not didCollect then
			print("RE-COLLECTING NODES")
			didCollect = true
			masterTable, mnt_index = pathLib.CollectNodes(map.Nodes)
			local dc = Instance.new("BoolValue", ent)
			dc.Name = "DidCollect"
			dc.Value = true
		elseif not ent.Enabled.Value then
			didCollect = false
		end
		if ent.Enabled.Value then
			local suc = numSuccessfulCollects(ent)
			local npcs = workspace.npcCache:GetChildren()
			if #npcs == suc then
				print("DISABLING AI_RECOLLECT, EVERYONE COLLECTED NEW GRAPHS")
				ent.Enabled.Value = false
			end
		end
	end
end


for _, ent in pairs(map.Entities:GetChildren()) do
	if ent.Name == "ai_recollect" then
		spawn(function() 
			listenForRecollect(ent) 
		end)
	end
end

warn(Orakel.Configuration.PrintHeader..script:GetFullName().."-> NPC loaded")

initGyro()
faceAnim.Init(head, char.FacialExpression.Value)


while true do
	wait(1/30)
	
	if initTarget ~= nil and initTarget ~= "" then
		local ent = Orakel.FindEntity(initTarget)
		pathFind(ent, torso.Position, ent.Position)
		initTarget = nil
	end

	local target = chooseTarget()
	local idle = char.IdleBehaviour.Value
	
	if target ~= nil and char.CanFight.Value then
		warn(Orakel.Configuration.PrintHeader..script:GetFullName().."-> Walking to target")
		local canWalkTo = npcLib.LineOfSight(head, target.Torso, losRange, _G.ignorelist) and (torso.Position - target.Torso.Position).magnitude <= 25
		if canWalkTo then
			hum.WalkSpeed = runSpeed
			while wait(1/20) do
				if not canWalkTo or chooseTarget() ~= target then
					break
				end
				canWalkTo = npcLib.LineOfSight(head, target.Torso, losRange, _G.ignorelist) and (torso.Position - target.Torso.Position).magnitude <= 25
				moveChar(target.Torso.Position)
				rotateTowards(target.Torso.Position)
			end
		else
			hum.WalkSpeed = runSpeed
			warn(Orakel.Configuration.PrintHeader..script:GetFullName().."-> Pathfinding to "..tostring(target))
			pathFind(target, torso.Position, target.Torso.Position)
		end
	else
		if idle == "Patrol" then
			warn(Orakel.Configuration.PrintHeader..script:GetFullName().."-> Patrolling")
			hum.WalkSpeed = patrolSpeed
			while wait(1/10) do
				local route = pathLib.GetNodesVisibleInRadius(torso.Position, findCoverRadius, false, map.Nodes, masterTable)
				if #route > 1 then
					local goal = route[math.random(1,#route)]
					local success = pathFind(goal, torso.Position, goal.Position)
					if success then
						wait(math.random(1,10))
					else
						break
					end
				end
			end
			
		end
	end
end







hum.Died:connect(fadeCorpse)
hum.FreeFalling:connect(humanoidFall)
char.TakeDamage.Event:connect(takeDamage)









