local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local sndLib = {}
local player = game.Players.LocalPlayer
local pgui = player.PlayerGui



function sndLib.CreateSound(name, id, vol, ptc, looped)
	local gVol = _G.volume or .75
	local s = Instance.new("Sound")
	s.Name = name
	s.Looped = looped
	s.SoundId = id
	s.Volume = vol * gVol
	s.Pitch = ptc
	return s
end

function sndLib.PlayMusicClient(name, id, vol, ptc, looped, len)
	local s = sndLib.CreateSound(name, id, vol, ptc, looped)
	s.Parent = pgui.Music 
	s:Play()
	coroutine.resume(coroutine.create(function()
		wait(len)
		s:Stop()
		wait(1)
		s:Destroy()
	end))
	return s
end

function sndLib.PlaySoundClientEvent(stype, name, id, vol, ptc, looped, len, v3)
	sndLib.PlaySoundClient(stype, name, id, vol, ptc, looped, len, v3)
end


function sndLib.PlaySoundClient(stype, name, id, vol, ptc, looped, len, v3)
	--stype:  "global", "3d"
	--id: assetID
	--vol: Volume 0-1
	--ptc: Pitch 0-1
	--len: Length in seconds
	--v3: Vector3
	if stype == "global" then
		local s = sndLib.CreateSound(name, id, vol, ptc, looped)
		if name == "SoundScape" then
		  s.Parent = pgui.AmbientSounds
		elseif name == "Music" then
		  s.Parent = pgui.Music
		else
		  s.Parent = pgui.Sounds
	  end
		s:Play()
		return s
	elseif stype == "3d" then
	  print("playing "..tostring(stype), tostring(name), tostring(len), tostring(v3))
		local c
		if not v3:IsA("BasePart") then
			c = Instance.new("Part", workspace)
			c.Name = "ambient_generic"
			c.Transparency = 1
			c.formFactor = "Custom"
			c.Size = Vector3.new(0.2,0.2,0.2)
			c.CanCollide = false
			c.Anchored = true
			c.CFrame = CFrame.new(v3.x, v3.y, v3.z)
		else
			c = v3
		end
		local s = sndLib.CreateSound(name, id, vol, ptc, looped)
		s.Parent = c
		s:Play()
		if c:IsA("BasePart") then
			if len > -1 then
				Orakel.RemoveItem(s, len)
			end
		else
			if len > -1 then
				Orakel.RemoveItem(c, len)
			end
		end
		return s
	end
end


function sndLib.PlaySoundClientAsync(stype, name, id, vol, ptc, looped, len, v3)
	spawn(function()
		sndLib.PlaySoundClient(stype, name, id, vol, ptc, looped, len, v3)
	end)
end

function sndLib.StopSoundClient(sndname)
	local s = pgui.Sounds:findFirstChild(sndname)
	if s then
		s:Stop()
		s:Destroy()
	end
end


function sndLib.StopAllSoundsClient()
	local snd = pgui.Sounds:GetChildren()
	for _, s in pairs(snd) do
		s:Stop()
		s:Destroy()
	end
end


function sndLib.FadeSound(snd, endVolume, fadeDuration)
	local gVol = _G.volume or .75
	endVolume = endVolume * gVol
	local vol = snd.Volume
	local fps = 20
	local steps = fadeDuration * fps
	for i = 1, steps do
		snd.Volume = snd.Volume - (vol - endVolume) / steps
		wait(1 / fps)
	end
end













return sndLib