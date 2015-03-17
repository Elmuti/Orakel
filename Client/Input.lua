local player = game.Players.LocalPlayer
local char = player.CharacterAdded:wait()
local pgui = player:WaitForChild("PlayerGui")
local torso = char:WaitForChild("Torso")
local input = game:GetService("UserInputService")
local mouse = player:GetMouse()

local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local sndLib = Orakel.LoadModule("SoundLib")
local assetLib = Orakel.LoadModule("AssetLib")
local strLib = Orakel.LoadModule("StringLib")

local vec2 = Vector2.new

warn(Orakel.Configuration.PrintHeader.."Ready for character input")


function callKbEvent(key, type)
	local w = char:findFirstChild("Weapon")
	if w then
		w.KeyboardEvent:Fire(key, type)
	end
end


local down = {
	W = false;
	A = false;
	S = false;
	D = false;
}

function moveKey(movekey)
	if movekey == Enum.KeyCode.W then
		down.W = not down.W
	elseif movekey == Enum.KeyCode.A then
		down.A = not down.A
	elseif movekey == Enum.KeyCode.S then
		down.S = not down.S
	elseif movekey == Enum.KeyCode.D then
		down.D = not down.D
	end
	if down.W or down.A or down.S or down.D then
		char.Humanoid.IsRunning:Fire(char.Humanoid.WalkSpeed)
	else
		char.Humanoid.IsRunning:Fire(0)
	end
end


input.InputBegan:connect(function(obj)
	if obj.UserInputType == Enum.UserInputType.Keyboard then
		--print(tostring(obj.KeyCode))
		callKbEvent(obj.KeyCode, -1)
		if obj.KeyCode == Enum.KeyCode.W or obj.KeyCode == Enum.KeyCode.A or obj.KeyCode == Enum.KeyCode.S or obj.KeyCode == Enum.KeyCode.D then
			moveKey(obj.KeyCode)
		elseif obj.KeyCode == Enum.KeyCode.Return then
			--hud.Console.PressedEnter:Fire()
		elseif obj.KeyCode == Enum.KeyCode.Quote then
			--hud.Console.PressedConsole:Fire()
		elseif obj.KeyCode == Enum.KeyCode.E then
			print("PRESSED E LEL")
			local hit = mouse.Target
			if hit ~= nil then
			  print("use target is not nil")
				if hit.Name == "func_button" then
				  print("use target is a button!")
          Orakel.FireInput(hit, "Use")
				end
			end
		end
	end
end)


input.InputEnded:connect(function(obj)
	if obj.UserInputType == Enum.UserInputType.Keyboard then
		if obj.KeyCode == Enum.KeyCode.W or obj.KeyCode == Enum.KeyCode.A or obj.KeyCode == Enum.KeyCode.S or obj.KeyCode == Enum.KeyCode.D then
			moveKey(obj.KeyCode)
		end
		callKbEvent(obj.KeyCode, 1)
	end
end)