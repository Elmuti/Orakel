local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local camLib = Orakel.LoadModule("CameraLib")
local Entity = {}
Entity.Status = true

Entity.Type = "Brush"
Entity.EditorTexture = ""

Entity.KeyValues = {
  ["EntityName"] = "";
  ["Enabled"] = false;
  ["Tween"] = false;
}


Entity.Inputs = {
  ["Toggle"] = function(ent)
    ent.Enabled.Value = not ent.Enabled.Value
  end;
}


Entity.Update = function(ent)
  while wait(1/20) do
    if ent.Enabled.Value then
      local map = Orakel.GetMap()
      local oldCf = workspace.CurrentCamera.CoordinateFrame
      local oldFoc = workspace.CurrentCamera.Focus
      camLib.TweenCamera(oldCf, oldFoc, ent.CFrame.CFrame, ent.Focus.CFrame, 2, ent.Tween.Value)
    else
      local cam = workspace.CurrentCamera
      if cam.CameraType == Enum.CameraType.Scriptable then
        camLib.SetCameraDefault(ent.Tween.Value, 2)
      end
    end
  end
end


Entity.Kill = function()
  Entity.Status = false
end



return Entity

