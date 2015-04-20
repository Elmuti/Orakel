local root = script.Parent
local Module = {}
local run = game:GetService("RunService")



Module.Configuration = {
  Version = "version 0.8.9.3";
  SoloTestMode = game:FindService("NetworkServer") == nil and game:FindService("NetworkClient") == nil;
  PrintHeader = "Orakel |  ";
  WarnHeader = "Orakel Warning |  ";
  ErrorHeader = "Orakel Error |  ";
  Logo = {
    Full = "http://www.roblox.com/asset/?id=220270074";
    Symbol = "http://www.roblox.com/asset/?id=220270067";
    Text = "http://www.roblox.com/asset/?id=220270070";
  };
  Entities = root.Entities;
  GoogleAnalyticsModule = 153590792;
  GoogleTrackingId = ""; --IF BLANK, USES THE ID IN ServerScriptService/GoogleAnalytics.lua INSTEAD!
}


--Everything here should be game specific:
Module.GameInfo = {
  Name = "ORAKEL"; --Name of the game
  Icon = "http://www.roblox.com/asset/?id=220270070"; --Game icon
  Menu = {
   Icon = "http://www.roblox.com/asset/?id=224720024"; --Main menu icon
   FontSize = Enum.FontSize.Size18;
   Font = Enum.Font.Legacy;
   ButtonSize = UDim2.new(1, 0, 0.1, 0);
  };
  IntroSong = "http://www.roblox.com/asset/?id=157520543"; --Main menu music
  MainMenu = true; --Run main menu OR just straight up load a level?
  BackgroundLevel = "bg_c1m1"; --Level to show on main menu
  StartLevel = "c1m1"; --Level to run when loading a new game
  --MapsDir = game.ServerStorage.Maps;
  ScriptsDir = game.ReplicatedStorage.Scripts;
  CutsceneDir = game.ReplicatedStorage.Cutscenes;
  AnimsDir = game.ReplicatedStorage.Animations;
  EventsDir = game.ReplicatedStorage.Events;
  CustomPlayer = false; --Use a custom character(non-humanoid)
  CameraOffset = CFrame.new(0, 2, 0); --NOTE: ONLY ACTIVE WHEN CUSTOMPLAYER IS ENABLED
  --3rd. Person: CFrame.new(1, 2, 10);
  CorpseFadeTime = 10; --Global NPC corpse fade delay, can be overriden from NPC keyvalues/flags
}



--Essentially this list defines what brushes are drawn invisible when compiled
Module.EntitiesToHide = {
  --string Entity, bool setInvis
  ["point_camera"] = true;
  ["info_player_start"] = true;
  ["func_button"] = true;
  ["func_water"] = true;
  ["func_trigger"] = true;
  ["trigger_hurt"] = true;
  ["nav_clip"] = true;
  ["func_precipitation"] = true;
}


--Returns every descendant of "obj"
--@param obj Object.
Module.GetChildrenRecursive = function(obj)
  local children = obj:GetChildren()
  local list = {}
  for child = 1, #children do
    list[#list + 1] = children[child]
    local subChildren = Module.GetChildrenRecursive(children[child])
    for sc = 1, #subChildren do
      list[#list + 1] = subChildren[sc]
    end
  end
  return list
end


local function initEntity(ent, sc)
  --@ent Entity
  --@sc Module
  local entCode = require(sc)
  
  local kvals = entCode.KeyValues
  local inputs = entCode.Inputs
  local outputs = entCode.Outputs
  local defOuts = ent:FindFirstChild("Outputs")
  local update = entCode.Update
  local load = entCode.Load
  
  if load ~= nil then
    load(ent)
  end

  --print("initializing "..tostring(ent).." ...")
  
  if entCode.Inputs == nil then
    entCode.Inputs = {}
    inputs = entCode.Inputs
  end
  
  if entCode.Outputs == nil then
    entCode.Outputs = {}
    outputs = entCode.Outputs
  end
  
  for num = 1, 4 do
    entCode.Outputs[#entCode.Outputs + 1] = "OnUser"..num
  end

  for num = 1, 4 do
    entCode.Inputs["FireUser"..num] = function(ent)
      Module.FireOutput(ent, "OnUser"..num)
    end
  end
  
  if inputs ~= nil then
    for input, func in pairs(inputs) do
      local newInp = Module.InitInput(ent, input)
      newInp.Event:connect(func)
    end
  else
    --warn(Module.Configuration.WarnHeader.."Entity '"..tostring(ent).."' has no inputs defined!!")
  end
  
  if outputs ~= nil then
    for _, output in pairs(outputs) do
      Module.InitOutput(ent, output)
    end
  else
    --warn(Module.Configuration.WarnHeader.."Entity '"..tostring(ent).."' has no outputs defined!!")
  end
  
  
  if defOuts ~= nil then
    for _, out in pairs(defOuts:GetChildren()) do
      spawn(function() 
        local myOutput = out.MyOutput.Value
        local tgtEnt = out.TargetEntity.Value
        local tgtInp = out.TargetInput.Value
        local param = out.ParamOverride.Value
        local once = out.OnceOnly.Value
        local delay = out.Delay.Value
        local tfired = out.TimesFired
        
        local outEvent = ent:FindFirstChild(myOutput)
        if outEvent then
          outEvent.Event:connect(function()
            if tfired.Value > 0 and once then
              --SET TO "ONCE ONLY", CANT RE-FIRE
            else
              tfired.Value = tfired.Value + 1
              wait(delay)
              Module.FireInput(Module.FindEntity(tgtEnt), tgtInp)
            end
          end)
        end
      end)
    end
    
    if update ~= nil then
      local s,e = pcall(function()
        spawn(function()
          update(ent)
        end)
      end)
      if not s then
        --Error in the Entity code
        warn(Module.Configuration.PrintHeader.."INTERNAL ENTITY ERROR: "..e)
      end
    end
  end

  game.ReplicatedStorage.Events.MapChange.Event:connect(entCode.Kill)
end

--Initializes every entity in "map"
Module.InitEntities = function(map)
  local numEnts = 0
  local ents = map.Entities:GetChildren()
  local eScripts = game.ReplicatedStorage.Orakel.Entities:GetChildren()
  for _, ent in pairs(ents) do
    for _, es in pairs(eScripts) do
      if es.Name == ent.Name then
        numEnts = numEnts + 1
        initEntity(ent, es)
      end
    end
  end
  print("Initialized "..numEnts.." entities")
end

Module.InitOutput = function(ent, name)
  local be = Instance.new("BindableEvent")
  be.Name = name
  be.Parent = ent
  return be
end

Module.InitInput = function(ent, name)
  local be = Instance.new("BindableEvent")
  be.Name = name
  be.Parent = ent
  return be
end

--Fire input "inp" of entity "ent" with parameters "..."
Module.FireInput = function(ent, inp, ...)
  --warn(Module.Configuration.PrintHeader.."Firing input '"..inp.."' of '"..tostring(ent).."'")
  local ex = ent:FindFirstChild(inp, true)
  if ex then
    if ex.ClassName == "BindableEvent" then
      ex:Fire(ent, ...)
    end
  else
    warn(Module.Configuration.WarnHeader.."Tried to fire input '"..tostring(inp).."' which is not a part of '"..tostring(ent).."' !")
  end
end

--Fire output "inp" of entity "ent" with parameters "..."
Module.FireOutput = function(ent, out, ...)
  --warn(Module.Configuration.PrintHeader.."Firing output '"..out.."' of '"..tostring(ent).."'")
  local ex = ent:FindFirstChild(out, true)
  if ex then
    if ex.ClassName == "BindableEvent" then
      ex:Fire(ent, ...)
    end
  else
    warn(Module.Configuration.WarnHeader.."Tried to fire output '"..tostring(inp).."' which is not a part of '"..tostring(ent).."' !")
  end
end


Module.GetKeyValue = function(ent, val)
  local ex = ent:FindFirstChild(val, true)
  if ex then
    return ex.Value
  end
  return nil
end


Module.SetKeyValue = function(ent, val, newVal)
  local ex = ent:FindFirstChild(val, true)
  if ex then
    ex.Value = newVal
  end
end



Module.PrintVersion = function()
  warn("Orakel "..Module.Configuration.Version.." up and running!")
end



Module.PrintStatus = function(origin)
  warn(Module.Configuration.PrintHeader..origin.." initialized")
end



Module.WaitRender = function()
  run.RenderStepped:wait()
end


Module.FindSound = function(name)
  local assetlib = Module.LoadModule("AssetLib")
  for _, stype in pairs(assetlib.Sounds) do
    for sname, snd in pairs(stype) do
      if sname == name then
        return snd
      end
    end
  end
  return nil
end


local function findScript(rootDir, sc)
  local strLib = Module.LoadModule("StringLib")
  local folder, file
  local filename = sc
  if string.find(sc, "_") then
    filename = strLib.Split(sc, "_")
  end
  if type(filename) == "table" then
    folder = rootDir:FindFirstChild(filename[1])
    file = folder:FindFirstChild(filename[2])
  else
    file = rootDir:FindFirstChild(filename)
  end
  return file
end


Module.PlayCutscene = function(sc, arg)
  local dir = Module.GameInfo.CutsceneDir
  local file = findScript(dir, sc)
  if file then
    warn(Module.Configuration.PrintHeader.."Running cutscene '"..sc.."'")
    spawn(function()
      local stat,err = pcall(function()
        local sc = require(file)
        sc.Main(arg)
        Module.GameInfo.EventsDir.MapChange.Event:connect(sc.Kill)
      end)
      if not stat then
        warn(Module.Configuration.ErrorHeader..err)
      end
    end)
  else
    warn(Module.Configuration.WarnHeader.."Tried to run cutscene '"..sc.."' which does not exist!")
  end
end


Module.RunScript = function(sc, arg)
  local dir = Module.GameInfo.ScriptsDir
  local file = findScript(dir, sc)
  if file then
    warn(Module.Configuration.PrintHeader.."Running script '"..sc.."'")
    spawn(function()
      local stat,err = pcall(function()
        local sc = require(file)
        sc.Main(arg)
        Module.GameInfo.EventsDir.MapChange.Event:connect(sc.Kill)
      end)
      if not stat then
        warn(Module.Configuration.ErrorHeader..err)
      end
    end)
  else
    warn(Module.Configuration.WarnHeader.."Tried to run script '"..sc.."' which does not exist!")
  end
end


Module.RunScene = function(sc, arg, arg2)
  local dir = Module.GameInfo.ScriptsDir
  local file = findScript(dir, sc)
  if file then
    warn(Module.Configuration.PrintHeader.."Running choreo_scene '"..sc.."'")
    spawn(function()
      local stat,err = pcall(function()
        local sc = require(file)
        sc.Main(arg, arg2)
        Module.GameInfo.EventsDir.MapChange.Event:connect(sc.Kill)
      end)
      if not stat then
        warn(Module.Configuration.ErrorHeader..err)
      end
    end)
  else
    warn(Module.Configuration.WarnHeader.."Tried to run choreo_scene '"..sc.."' which does not exist!")
  end
end

--Returns the current map
Module.GetMap = function()
  local map
  if game.Players.LocalPlayer == nil then
    map = workspace.Game.CurrentMap.Value
  else
    map = game.Players.LocalPlayer.CurrentMap.Value
  end
  return map
end


function Module.RemoveItem(item, delay)
  spawn(function()
    wait(delay or 1)
    item:Destroy()
  end)
end


function Module.TLength(t)
    local l = 0
    for i, j in pairs(t) do
      if j ~= nil then
        l = l + 1
      end
    end
    return l
end



Module.RecursiveFindEntity = function(dir, entityName)
  local c = dir:GetChildren()
  for i = 1, #c do
    local entName = c[i]:FindFirstChild("EntityName")
    if entName then
      if entName.Value == entityName then
        return c[i]
      end
    else
      Module.RecursiveFindEntity(c[i], entityName)
    end
  end
  return nil
end




Module.FindEntity = function(entityName)
  if entityName == "" then 
    return nil 
  end
  local map = Module.GetMap()
  local ent
  if map ~= nil then
    ent = Module.RecursiveFindEntity(map.Entities, entityName)
  end
  return ent
end


Module.FindNpc = function(entityName)
  if entityName == "" then 
    return nil 
  end
  local map = Module.GetMap()
  local ent
  if map ~= nil then
    ent = Module.RecursiveFindEntity(workspace.npcCache, entityName)
  end
  return ent
end


Module.LoadModule = function(module)
  local root = script.Parent
  local found = root:FindFirstChild(module, true)
  if found then
    return require(found)
  else
    error(Module.Configuration.ErrorHeader.."Module '"..tostring(module).."' wasn't found!")
  end
end






return Module
