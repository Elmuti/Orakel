local mapLib = {}
local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local EntDir = game.ReplicatedStorage.Orakel.Entities

local function getSearchLocs(map)
  local locs = {}
  for _, loc in pairs(map:children()) do
    if loc.ClassName == "Model" and loc.Name ~= "Geometry" then
      print("Invis location: "..loc:GetFullName())
      table.insert(locs, loc)
    end
  end
  return locs
end

local function allowedToHide(obj)
  local list = Orakel.EntitiesToHide
  for ent, bool in pairs(list) do
    if obj.Name == ent then
      return true
    end
  end
  return false
end


function editorTextures()
  local textures = {}
  for _, entSc in pairs(EntDir:GetChildren()) do
    local ent
    local stat, err = pcall(function()
      ent = require(entSc)
    end)
    if not stat then
      warn(Orakel.Configuration.PrintHeader.."INTERNAL ENTITY ERROR! "..err)
    end
    if ent.EditorTexture ~= "" or ent.EditorTexture ~= nil then
      textures[entSc.Name] = ent.EditorTexture
    end
  end
  return textures
end


function recInvis(dir)
  local children = Orakel.GetChildrenRecursive(dir)
  for _, obj in pairs(children) do
    if obj:IsA("BasePart") then
      if obj.Name == "node_walk" or obj.Name == "CFrame" or obj.Name == "Focus" then
        obj.Transparency = 1
      end
    elseif obj.ClassName == "Texture" or obj.ClassName == "Decal" then
      local edTextures = editorTextures(obj)
      for edEnt, edtx in pairs(edTextures) do
        if edtx == obj.Texture then
          print("Entity texture found: "..obj:GetFullName())
          obj:Destroy()
        end
      end
    elseif obj.ClassName == "BillboardGui" then
      obj:Destroy()
    end
  end
end



local function invisClutter(map)
  local locs = getSearchLocs(map)
  for _, loc in pairs(locs) do
    recInvis(loc)
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



