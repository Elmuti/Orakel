--Don't touch
local pathLib = {}
local master_node_table, mnt_index
 
--Touch
local ai_max_range = math.huge
local printAStarPerformance = false
local Orakel = require(game.ReplicatedStorage.Orakel.Main)
 
function pathLib.SearchById(masterTable, searchId)
    for i, j in pairs(masterTable) do
        if j.ID == searchId then
            return j.Brick
        end
    end
    return nil
end
 
 
function pathLib.SearchByBrick(masterTable, brick)
    for i, j in pairs(masterTable) do
            if j.Brick == brick then
                    return j.ID
            end
    end
    return nil
end

function pathLib.GetNodeData(masterTable, node)
    for _, nodeInTable in pairs(masterTable) do
		if type(node) == "number" then
			if nodeInTable.ID == node then
				return nodeInTable
			end
		else
			if nodeInTable.Brick == node then
				return nodeInTable
			end
		end
    end
    return nil
end
 
 
function DrawColoredSurface(part, face)
        local surfGui = Instance.new("SurfaceGui", part)
        surfGui.Name = tostring(face).."Layer"
        surfGui.CanvasSize = Vector2.new(64, 64)
        surfGui.Adornee = part
        surfGui.Face = face
        surfGui.Enabled = true
        local lab = Instance.new("ImageLabel", surfGui)
        lab.Size = UDim2.new(1, 0, 1, 0)
        lab.BorderSizePixel = 1
        return lab
end
 
 
function DrawColoredSurfaces(part, color, transparency)
        local labs = {}
        labs[1] = DrawColoredSurface(part, Enum.NormalId.Front)
        labs[2] = DrawColoredSurface(part, Enum.NormalId.Back)
        labs[3] = DrawColoredSurface(part, Enum.NormalId.Right)
        labs[4] = DrawColoredSurface(part, Enum.NormalId.Left)
        labs[5] = DrawColoredSurface(part, Enum.NormalId.Top)
        labs[6] = DrawColoredSurface(part, Enum.NormalId.Bottom)
        for _, v in pairs(labs) do
                v.BackgroundColor3 = color
                v.BackgroundTransparency = transparency
                v.BorderColor3 = color
        end
end
 
 
function DrawLine(p, a, b, c)
        local distance = (b.Position - a.Position).magnitude
        local part = Instance.new("Part", p)
        part.Transparency  = 1
        part.Anchored      = true
        part.CanCollide    = false
        part.TopSurface    = Enum.SurfaceType.Smooth
        part.BottomSurface = Enum.SurfaceType.Smooth
        part.formFactor    = Enum.FormFactor.Custom
        part.Size          = Vector3.new(0.2, 0.2, distance)
        part.CFrame        = CFrame.new(b.Position, a.Position) * CFrame.new(0, 0, -distance/2)
		part.Archivable    = false
        local pl = Instance.new("PointLight", part)
        pl.Shadows = true
        pl.Range = 16
        pl.Color = c
        DrawColoredSurfaces(part, c, 0.2)
        return part
end
       
       
function pathLib.DrawPath(path)
        local drawn = Instance.new("Model", workspace)
        drawn.Name = "DrawnPath"
        local red, green, last
        local num = 0
        local pLen = #path
        local colorInterval = (255 / pLen) / 255
        local a = path[1]
        local b = path[pLen]
        for _, p in pairs(path) do
                if num < 255 then
                        num = num + 1
                end
                if not (last == nil)then
                        red = num * colorInterval
                        DrawLine(drawn, last, p, Color3.new(1 - red, red, 0))
                end
                last = p
        end
        return drawn
end
 

function pathLib.NodeIsSafe(node, masterTable)
    for i, j in pairs(masterTable) do
		if type(node) == "number" then
            if j.ID == node then
            	return j.Safe
            end
		else
            if j.Brick == node then
            	return j.Safe
            end
		end
    end
    return true
end


function pathLib.NodeIsPossibleCover(node, masterTable)
    for i, j in pairs(masterTable) do
		if type(node) == "number" then
            if j.ID == node then
            	return j.PossibleCover
            end
		else
            if j.Brick == node then
            	return j.PossibleCover
            end
		end
    end
    return false
end


function NodeObjectFromBrick(brick)
        if brick.ClassName ~= "Part" then
                return nil
        end
        local node_index = mnt_index
        master_node_table[node_index] = {
                ID = mnt_index,
                Brick = brick,
                Connections = {},
				PossibleCover = false,
				Safe = true
        }

        for i, child in pairs(brick:GetChildren()) do
                if child.ClassName == "ObjectValue" and child.Name == "connection" then
						if child.Value == nil then
							print("SHIT STAIN")
							local p = Instance.new("Part", workspace)
							p.Name = "SHIT STAIN"
							p.Anchored = true
							p.CFrame = brick.CFrame
						end
	
	
                        local brick2 = child.Value
                        local ID = pathLib.SearchByBrick(master_node_table, brick2)
                        if ID == nil then
                                mnt_index = mnt_index + 1
                                ID = NodeObjectFromBrick(brick2)
                        end
                        local con = {
                                ID = ID,
                                G = (master_node_table[ID].Brick.Position - brick.Position).magnitude
                        }
                        table.insert(master_node_table[node_index].Connections, con)
				elseif child.ClassName == "BoolValue" and child.Name == "PossibleCover" then
					master_node_table[node_index].PossibleCover = child.Value
                end
        end

		local map = Orakel.GetMap()
		local ray = Ray.new(brick.Position, Vector3.new(0, -15, 0))
		local hit, pos = workspace:FindPartOnRayWithIgnoreList(ray, {map:FindFirstChild("Entities"), map:FindFirstChild("Clip")})
       
		if hit ~= nil then
			if hit.Name == "trigger_hurt" then
				master_node_table[node_index].Safe = false
			end
		else
			master_node_table[node_index].Safe = false
		end

        return node_index
end
 
 
function pathLib.CollectNodes(model)
        master_node_table = {}
        mnt_index = 1
        for i, child in pairs(model:GetChildren()) do
                if child.ClassName == "Part" and pathLib.SearchByBrick(master_node_table, child) == nil then
                        if NodeObjectFromBrick(child) then
                        	mnt_index = mnt_index + 1
						end
                end
        end
        return master_node_table, mnt_index
end
 
 
function Heuristic(id1, id2)
        local p1 = master_node_table[id1].Brick.Position
        local p2 = master_node_table[id2].Brick.Position
        return (p1 - p2).magnitude
end
 
 
function Len(t)
        local l = 0
        for i, j in pairs(t) do
                if j ~= nil then
                        l = l + 1
                end
        end
        return l
end
 
 
function GetPath(t, n)
        if t[n] == nil then
                return {n}
        else
                local t2 = GetPath(t, t[n])
                table.insert(t2, n)
                return t2
        end
end
 
 
function pathLib.GetFarthestNode(position, returnBrick, dir, masterTable)
        local nodeDir = dir
        if type(dir) ~= "table" then
                nodeDir = dir:children()
        end
        local farthest = nodeDir[1]
        for n = 2, #nodeDir do
                local old = (farthest.Position - position).magnitude
                local new = (position - nodeDir[n].Position).magnitude
                if new > old then
                        farthest = nodeDir[n]
                end
        end
        if returnBrick then
                return farthest
        else
                return pathLib.SearchByBrick(masterTable, farthest)
        end
end
 
 
function pathLib.GetNearestNode(position, returnBrick, dir, masterTable)
    local nodeDir = dir
    if type(dir) ~= "table" then
            nodeDir = dir:children()
    end
    local nearest = nodeDir[1]
    for n = 2, #nodeDir do
            local old = (nearest.Position - position).magnitude
            local new = (position - nodeDir[n].Position).magnitude
            if new < old then
                    nearest = nodeDir[n]
            end
    end
    if returnBrick then
            return nearest
    else
            return pathLib.SearchByBrick(masterTable, nearest)
    end
end
 

function pathLib.GetNodesVisibleInRadius(position, radius, returnBrick, dir, masterTable)
	local list = {}
	local map = Orakel.GetMap()
	for _, node in pairs(dir:GetChildren()) do
		local dist = (node.Position - position).magnitude
		if dist <= radius then
			local ray = Ray.new(position,(node.Position-position).unit * dist)
			local hit, pos = workspace:FindPartOnRayWithIgnoreList(ray, {map:FindFirstChild("Entities"), map:FindFirstChild("Clip")})
			if hit ~= nil then
				if hit == node then
					if returnBrick then
						table.insert(list, node)
					else
						table.insert(list, pathLib.SearchByBrick(node))
					end
				end
			end
		end
	end
	return list
end


function pathLib.AStar(masterTable, startID, endID, takeSafest)
	local takeSafestPath = takeSafest or true
    local now = tick()
    local closed = {}
    local open = {startID}
    local previous = {}
    local g_score = {}
    local f_score = {}
   
    g_score[startID] = 0
    f_score[startID] = Heuristic(startID, endID)
   
    while Len(open) > 0 do
        local current, current_i = nil, nil
        for i, j in pairs(open) do
            if current == nil then
	            current = j
	            current_i = i
            else
                if j ~= nil then
                    if f_score[j] < f_score[current] then
                        current = j
                        current_i = i
                    end
                end
            end
        end
       
        if current == endID then
	        local path = GetPath(previous, endID)
	        local ret = {}
	        for i, j in pairs(path) do
	        	table.insert(ret, masterTable[j].Brick)
	        end
	        if printAStarPerformance then
	        	print("Time taken for AStar to run: "..tostring(tick() - now))
	        end
	        return ret
        end
       
        open[current_i] = nil
        table.insert(closed, current)
       
        for i, j in pairs(masterTable[current].Connections) do
                local in_closed = false
                for k, l in pairs(closed) do
	                if l == j.ID then
                        in_closed = true
                        break
	                end
                end
                if in_closed == false then
                        local tentative_score = g_score[current] + j.G
                        local in_open = false
                        for k, l in pairs(open) do
                            if l == j.ID then
								if takeSafestPath then
									if j.Safe then
                                    	in_open = true
									end
								else
									in_open = true
								end
                                break
                            end
                        end
                        if in_open == false or tentative_score < g_score[j.ID] then
                            previous[j.ID] = current
                            g_score[j.ID] = tentative_score
                            f_score[j.ID] = g_score[j.ID] + Heuristic(j.ID, endID)
                            if in_open == false then
                            	table.insert(open, j.ID)
                            end
                        end
                end
        end
    end
    return nil
end
 
 
return pathLib