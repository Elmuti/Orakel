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


return eng