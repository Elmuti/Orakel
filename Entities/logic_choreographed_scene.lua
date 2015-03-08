local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local Entity = {}
Entity.Status = true


Entity.Type = "Point"
Entity.EditorTexture = "http://www.roblox.com/asset/?id=221279682"


Entity.KeyValues = {
  ["EntityName"] = "";
  ["SceneScript"] = "";
  ["InterruptCurrent"] = true;
  ["Actor1"] = "";
  ["Actor2"] = "";
  ["Actor3"] = "";
  ["Actor4"] = "";
  ["Actor5"] = "";
  ["Actor6"] = "";
  ["Actor7"] = "";
  ["Actor8"] = "";
}

local function collectActors(ent)
  local actors = {}
  local num = 0
  for _, v in pairs(ent:GetChildren()) do
    if v.ClassName == "StringValue" then
      if string.find(v.Name, "Actor") then
        local actorId = string.sub(v.Name, 6)
        actors[actorId] = Orakel.FindEntity(v.Value)
        print("collectActors -> actorId: "..tostring(actorId).."  actorValue: "..tostring(actors[actorId]))
      end
    end
  end
  return actors
end


Entity.Inputs = {
  ["Start"] = function(ent)
    local actors = collectActors(ent)
    Orakel.RunScene(ent.SceneScript.Value, actors, ent.InterruptCurrent.Value)
  end;
}


Entity.Kill = function()
	Entity.Status = false
end




return Entity