local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local Entity = {}
Entity.Status = true


Entity.Type = "Brush"
Entity.EditorTexture = ""

Entity.KeyValues = {
  ["EntityName"] = "";
  ["Enabled"] = false;
  ["Looped"] = true
  ["TrackName"] = "";
}


Entity.Inputs = {
  ["TurnOn"] = function(ent)
    ent.Enabled.Value = true
    local track = Orakel.FindMonitorTrack(ent.TrackName.Value)
    if track then
      track = require(track)
      local sgui = Instance.new("SurfaceGui", ent)
      sgui.Face = Enum.NormalId.Front
      sgui.Adornee = ent
      local il = Instance.new("ImageLabel", ent)
      il.Size = UDim2.new(1, 0, 1, 0)
      track:Init(il)
      while true do
        if not ent.Enabled.Value then
          break
        end
        local nextFrame = track:NextFrame()
        il.ImageRectOffset = nextFrame
        track:Yield()
      end
    end
  end;

  ["TurnOff"] = function(ent)
    ent.Enabled.Value = false
  end;
}




Entity.Update = function(mon)
end


Entity.Kill = function()
	Entity.Status = false
end





return Entity