local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local Entity = {}
Entity.Status = true
local sndLib = Orakel.LoadModule("SoundLib")
local cfLib = Orakel.LoadModule("CFrameLib")

Entity.Type = "Brush"
Entity.EditorTexture = ""

Entity.KeyValues = {
 ["EntityName"] = "";
 ["Goal"] = Vector3.new(0, 0, 0);
 ["Start"] = Vector3.new(0, 0, 0);
 ["Duration"] = 5;
 ["StartSound"] = "";
 ["MoveSound"] = "";
 ["StopSound"] = "";
 ["Moving"] = false;
}


Entity.Inputs = {
  ["Move"] = function(ent)
    Orakel.SetKeyValue(ent, "Moving", true)
    Orakel.FireOutput(ent, "MoveStarted")
    local prim = ent:FindFirstChild("Primary") 
    if not prim then
      warn(Orakel.Configuration.ErrorHeader.." FUNC_MOVELINEAR DOES NOT HAVE A PRIMARY PART")
    end
    
    ent.PrimaryPart = prim
    local startSound = Orakel.FindSound(ent.StartSound.Value)
    local stopSound = Orakel.FindSound(ent.StopSound.Value)
    local moveSound = Orakel.FindSound(ent.MoveSound.Value)
    startSound = sndLib.PlaySoundClient("3d", "", startSound, 1, 1, false, 10, ent.Primary)
    moveSound = sndLib.PlaySoundClient("3d", "", moveSound, 1, 1, false, ent.Duration.Value + 2, ent.Primary)
    local tweenSuccess = cfLib.TweenLinear(
      ent, 
      ent.Primary.CFrame, 
      CFrame.new(ent.Goal.Value), 
      ent.Duration.Value
    )
    moveSound:Stop()
    stopSound = sndLib.PlaySoundClient("3d", "", stopSound, 1, 1, false, 10, ent.Primary)
    if tweenSuccess then
      Orakel.FireOutput(ent, "GoalReached")
      Orakel.SetKeyValue(ent, "Moving", false)
    else
      Orakel.FireOutput(ent, "Stopped")
    end
  end;
  
  ["Stop"] = function(ent)
    warn(Orakel.Configuration.WarnHeader.." Cannot use input 'Stop' on func_movelinear! Not yet implemented!")
    Orakel.SetKeyValue(ent, "Moving", false)
  end;
  
  ["Reset"] = function(ent)
    local s = Orakel.GetKeyValue(ent, "Start")
    ent:SetPrimaryPartCFrame(CFrame.new(s))
    Orakel.FireOutput(ent, "OnReset")
  end;
}

Entity.Outputs = {"MoveStarted", "GoalReached", "Stopped", "OnReset"}


Entity.Update = function(ent)
  Orakel.SetKeyValue(ent, "Start", ent.Primary.Position)
  Orakel.SetKeyValue(ent, "Moving", false)
end


Entity.Kill = function()
	Entity.Status = false
end





return Entity