local storage = game.ReplicatedStorage
local player = game.Players.LocalPlayer
local char = player.CharacterAdded:wait()
local torso = char:WaitForChild("Torso")
local head = char:WaitForChild("Head")
local hum = char:WaitForChild("Humanoid")
local pgui = player.PlayerGui
local hud = pgui.Hud
local curHealth = hum.Health

local Orakel = require(storage.Orakel.Main)
local tLib = Orakel.LoadModule("TweenLib")
--local npcLib = Orakel.LoadModule("NpcLib")

local redOverlay = "rbxassetid://220186892"
local blueOverlay = "rbxassetid://220198902"
local tweening = false

function ToggleLoadingDialog()
  hud.LoadingFrame.Visible = not hud.LoadingFrame.Visible
end


function hurtOverlay(hpFrac)
  if not tweening then
    print("Tweening hurtframe image to "..hpFrac.." transparency")
    spawn(function()
      tLib:TweenRender(hud.HurtFrame.ImageLabel, "ImageTransparency", hpFrac, "Linear", .3)
      tLib:TweenRender(hud.HurtFrame.ImageLabel, "ImageTransparency", 1, "Linear", .3)
      tweening = false
    end)
  end
end


function HealthChanged(health)
  local dtype = hum:FindFirstChild("LastDamageType")
  local change = math.abs(curHealth - health)
  if curHealth > health then
    --damaged
    if dtype then
      if dtype.Value == "DROWN" then
        hud.HurtFrame.ImageLabel.Image = blueOverlay
        hurtOverlay(hum.Health / 100)
      else
        hud.HurtFrame.ImageLabel.Image = redOverlay
        hurtOverlay(hum.Health / 100)
      end
      dtype:Destroy()
    else
      hud.HurtFrame.ImageLabel.Image = blueOverlay
      hurtOverlay(hum.Health / 100)
    end
  else 
    --healed

  end
  curHealth = health
  
  if hum.Health <= 0 then
    tLib:TweenRenderAsync(hud.HurtFrame, "BackgroundTransparency", 0, "Linear", 0.3)
  end
end



hum.HealthChanged:connect(HealthChanged)
storage.Events.ToggleLoadingDialog.Event:connect(ToggleLoadingDialog)




