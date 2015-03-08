local player = game.Players.LocalPlayer
local char = player.CharacterAdded:wait()
local pgui = player.PlayerGui
local splash, logo, gamelogo
local showtime_logo = 3
local showtime_gamelogo = 3

local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local tLib = Orakel.LoadModule("TweenLib")
local sndLib = Orakel.LoadModule("SoundLib")

function createSplash()
	local main = Instance.new("ScreenGui", pgui)
	splash = Instance.new("Frame", main)
	splash.BackgroundColor3 = Color3.new(0,0,0)
	splash.Size = UDim2.new(1,0,1,0)
	splash.Position = UDim2.new(0,0,0,0)
	
	logo = Instance.new("ImageLabel", splash)
	logo.Name = "Logo"
	logo.BackgroundTransparency = 1
	logo.Image = Orakel.Configuration.Logo.Full
	logo.Position = UDim2.new(0.15, 0, 0.3, 0)
	logo.Size = UDim2.new(0.7, 0, 0.2, 0)
	logo.ImageTransparency = 1
	
	gamelogo = Instance.new("ImageLabel", splash)
	gamelogo.Name = "Game"
	gamelogo.BackgroundTransparency = 1
	gamelogo.Image = Orakel.Configuration.Logo.Full
	gamelogo.Position = UDim2.new(0.15, 0, 0.3, 0)
	gamelogo.Size = UDim2.new(0.7, 0, 0.2, 0)
	gamelogo.ImageTransparency = 1
end

createSplash()

local rdy = player:FindFirstChild("Ready")
while rdy == nil do wait() end
print("Ready found")

function main()
	sndLib.PlaySoundClient("global", "introMusic", Orakel.GameInfo.IntroSong, 0.5, 1, false, 120)
	gamelogo.Image = Orakel.GameInfo.Icon
	logo.Image = Orakel.Configuration.Logo.Full
	tLib:TweenRenderAsync(splash, "BackgroundColor3", Color3.new(1,1,1), "Linear", 2)
	tLib:TweenRender(logo, "ImageTransparency", 0, "Linear", 2)
	wait(showtime_logo)
	tLib:TweenRender(logo, "ImageTransparency", 1, "Linear", 2)
	--tLib:TweenRender(gamelogo, "ImageTransparency", 0, "Linear", 2)
	--wait(showtime_gamelogo)
	--tLib:TweenRenderAsync(gamelogo, "ImageTransparency", 1, "Linear", 2)
	tLib:TweenRender(splash, "BackgroundColor3", Color3.new(0,0,0), "Linear", 2)
	game.ReplicatedStorage.Events.PlayerReady:FireServer()

	game.ReplicatedStorage.Events.MapLoad.Event:connect(function()
		tLib:TweenRender(splash, "BackgroundTransparency", 1, "Linear", 2)
	end)
end


if not rdy.Value then
	main()
else
	game.ReplicatedStorage.Events.MapLoad.Event:connect(function()
		tLib:TweenRender(splash, "BackgroundTransparency", 1, "Linear", 2)
	end)
end