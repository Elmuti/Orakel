local mapLib = {}
local Orakel = require(game.ReplicatedStorage.Orakel.Main)



local function getSearchLocs(map)
  local locs = {}
  for _, loc in pairs(map:children()) do
    if loc.ClassName == "Model" and loc.Name ~= "Geometry" then
      table.insert(locs, loc)
    end
  end
  return locs
end



local function recursiveInvis(dir)
  for _, obj in pairs(dir:children()) do
    if obj.ClassName == "BillboardGui" then
      obj:Destroy()
    elseif obj:IsA("BasePart") then
      obj.Transparency = 1
      for _, ch in pairs(obj:children()) do
        if ch.ClassName == "Texture" then
          ch:Destroy()
        end
      end
    else
      recursiveInvis(obj)
    end
  end
end



local function invisClutter(map)
  local locs = getSearchLocs(map)
  for _, loc in pairs(locs) do
    recursiveInvis(loc)
  end
end



function mapLib.LoadMap(map, currentMap)
  warn(Orakel.Configuration.PrintHeader..'Loading map "'..tostring(map)..'"')
  
  --Remove any old map data:
  workspace.Terrain:Clear()
  local currentMap = map.Name
  if workspace:findFirstChild(currentMap) then
    workspace[currentMap]:Destroy()
  end
  
  --Load the new map
  local mC = map:clone()
  mC.Parent = workspace
  wait(.25)
  --Re-Position the map
  mC:MoveTo(Vector3.new(0, 1000, 0))
  wait(.25)
  
  --Hide editor stuff(Entity sprites, trigger textures etc.)
  invisClutter(mC)
  
  --Set up lighting parameters
  local params = map["_parameters"]:children()
  local skySides = map["_parameters"]["Skybox"]:children()
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
  warn(Orakel.Configuration.PrintHeader..'Map "'..tostring(map)..'" loaded!')
  return mC
end





return mapLib



