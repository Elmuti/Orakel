local Module = {}

Module.Expressions = {
	["Happy"] = "http://www.roblox.com/asset/?id=12451696";
	["Sad"] = "http://www.roblox.com/asset/?id=8560975";
	["Angry"] = "http://www.roblox.com/asset/?id=25678231";
	["Scared"] = "http://www.roblox.com/asset/?id=147144644";
	["Surprised"] = "http://www.roblox.com/asset/?id=22877700";
	["Normal"] = "http://www.roblox.com/asset/?id=64064193";
	["Bored"] = "http://www.roblox.com/asset/?id=8560971";
	["Sick"] = "http://www.roblox.com/asset/?id=26619096";
	["Stare"] = "http://www.roblox.com/asset/?id=13038375";
	["Sorry"] = "http://www.roblox.com/asset/?id=7074944";
	["Convincing"] = "http://www.roblox.com/asset/?id=20722130";
	["Suspicious"] = "http://www.roblox.com/asset/?id=209994929";
	["Unsure"] = "http://www.roblox.com/asset/?id=173789324";
	["Winky"] = "http://www.roblox.com/asset/?id=7863475";
	["Crying"] = "http://www.roblox.com/asset/?id=14127194";
	["Awkward"] = "http://www.roblox.com/asset/?id=23932048";
	["Dead"] = "http://www.roblox.com/asset/?id=15426038";
}



function Module.Init(head, initExp)
	local old = head:FindFirstChild("Face")
	if old then
		old:Destroy()
	end
	local new = Instance.new("Decal", head)
	new.Name = "Face"
	new.Face = Enum.NormalId.Front
	new.Texture = Module.Expressions[initExp]
end


function Module.NewFace(head, expression)
	local face = head:FindFirstChild("Face")
	local newExp = Module.Expressions[expression]
	if face and newExp ~= nil then
		face.Texture = Module.Expressions[expression]
	end
end





return Module
