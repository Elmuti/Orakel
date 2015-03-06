local eng = {}

eng.Million = 1000000
eng.Billion = 1000000000
eng.Trillion = 1000000000000
eng.Quadrillion = 1000000000000000


function eng.Round(num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end


function eng.SecondsToTimerFormat(int)
	local prefix, suffix = "", ""
	local minutes = math.floor(int / 60)
	local seconds = int % 60
	if minutes < 10 then
		prefix = "0"
	end
	if seconds < 10 then
		suffix = "0"
	end
	return prefix..tostring(minutes)..":"..suffix..tostring(seconds)
end


function eng.Format(num, decimalPlaces)
	local idp = decimalPlaces or 4
	if num < math.huge then
		if num >= eng.Quadrillion then
			local f = num / eng.Quadrillion
			return tostring(eng.Round(f, idp).." quad")
		elseif num >= eng.Trillion then
			local f = num / eng.Trillion
			return tostring(eng.Round(f, idp).." tril")
		elseif num >= eng.Billion then
			local f = num / eng.Billion
			return tostring(eng.Round(f, idp).." b")
		elseif num >= eng.Million then
			local f = num / eng.Million
			return tostring(eng.Round(f, idp).." mil")
		elseif num >= 1000 then
			local f = num / 1000
			return tostring(eng.Round(f, idp).." k")
		end
	else
		return "infinite"
	end
end


function eng.TweenValue(instance, property, goalValue, duration, fps, callback)
	local curValue = instance[property]
	local steps = duration * fps
	for i = 1, steps do
		instance[property] = instance[property] - (curValue - goalValue) / steps
		if fps > 30 then
			local frames = 0
			while true do
				game:GetService("RunService").RenderStepped:wait()
				frames = frames + 1
				if frames >= (60 - fps) then
					break
				end
			end
		else
			wait(1 / fps)
		end
	end
	if callback ~= nil then
		if type(callback) == "function" then
			return callback()
		end
	end
end


return eng