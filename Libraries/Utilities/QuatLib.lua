
	
	
	-- ~ Orakel ~
	
	--   File:            qLib.lua
	--   Author:          Archaic0
	--   Description:     Quaternion interpolation library
	
	--   Functions:
	-- 	qLib.tweenWeld(weld, c0, c1, duration, easing)
	
	--   Easing Styles:
	-- 	linear     - Smooth transition
	-- 	quadIn     - Slight dampening
	-- 	quadOut    - -II-
	-- 	quadInOut  - -II-



do
	local function newQuat(x, y, z, w)
		return setmetatable({x, y, z, w}, {
			__unm = function(q) return newQuat(-q[1], -q[2], -q[3], -q[4]) end;
			__mul = function(q, n) return newQuat(q[1]*n, q[2]*n, q[3]*n, q[4]*n) end;
			__div = function(q, n) return newQuat(q[1]/n, q[2]/n, q[3]/n, q[4]/n) end;
			__add = function(q0, q1) return newQuat(q0[1]+q1[1], q0[2]+q1[2], q0[3]+q1[3], q0[4]+q1[4]) end;
		})
	end
	local function quatSlerp(q0, q1, t)
		local dot = q0[1]*q1[1] + q0[2]*q1[2] + q0[3]*q1[3] + q0[4]*q1[4]
		if dot < 0 then dot = -dot q1 = -q1 end
		if dot > 0.95 then
			local q2 = q0 * (1-t) + q1 * t
			return q2/math.sqrt(q2[1]*q2[1] + q2[2]*q2[2] + q2[3]*q2[3] + q2[4]*q2[4])
		end
		local angle = math.acos(dot)
		return (q0*math.sin(angle*(1-t)) + q1*math.sin(angle*t))/math.sin(angle)
	end
	local function quatFromCFrame(cf)
		local _, _, _, m00, m01, m02, m10, m11, m12, m20, m21, m22 = cf:components()
		local x, y, z, w
		local trace = m00 + m11 + m22
		if trace > 0 then
			local s = math.sqrt(trace+1)*2
			return newQuat( (m21-m12)/s, (m02-m20)/s, (m10-m01)/s, .25*s )
		elseif (m00 > m11) and (m00 > m22) then 
			local s = math.sqrt(1 + m00 - m11 - m22)*2
			return newQuat( .25*s, (m01+m10)/s, (m02+m20)/s, (m21-m12)/s )
		elseif m11 > m22 then
			local s = math.sqrt(1 + m11 - m00 - m22)*2
			return newQuat( (m01+m10)/s, .25*s, (m12+m21)/s, (m02-m20)/s )
		else
			local s = math.sqrt(1 + m22 - m00 - m11)*2
			return newQuat( (m10-m01)/s, (m12+m21)/s, .25*s, (m10-m01)/s )
		end
	end
	function cframeLerp(cf0, cf1, t)
		local qs = quatSlerp(quatFromCFrame(cf0), quatFromCFrame(cf1), t)
		return CFrame.new(cf0.x*(1-t) + cf1.x*t, cf0.y*(1-t) + cf1.y*t, cf0.z*(1-t) + cf1.z*t, qs[1], qs[2], qs[3], qs[4])
	end
end

Ease = {
	linear = function(t)
		return t
	end,
	quadIn = function(t)
		return t*t
	end,
	quadOut = function(t)
		return -1 * t * (t-2)
	end,
	quadInOut = function(t)
		t = t / 0.5
		if t < 1 then return 0.5 * t * t end
		t = t - 1
		return -0.5 * (t * (t-2) - 1)
	end
}

Tween = {}
Tween.new = function(weld, c0, c1, duration, easing)
	local self = setmetatable( {}, { __index = Tween } )
	self.weld = weld
	self.startC0 = weld.C0
	self.startC1 = weld.C1
	self.c0 = c0 or CFrame.new()
	self.c1 = c1 or CFrame.new()
	self.duration = duration
	self.elapsedTime = 0
	self.easingFunction = easing or Ease.linear
	return self
end

Tween.update = function(self, deltaTime)
	self.elapsedTime = self.elapsedTime + deltaTime
	if self.elapsedTime >= self.duration then
		return "dead"
	else
		self:applyToJoint()
	end
end

Tween.applyToJoint = function(self)
	self.weld.C0 = cframeLerp(self.startC0, self.c0, self.easingFunction(self.elapsedTime/self.duration))
	self.weld.C1 = cframeLerp(self.startC1, self.c1, self.easingFunction(self.elapsedTime/self.duration))
end

local tweenList = {}

tweenWeld = function(weld, c0, c1, duration, easing)
	local newTween = Tween.new(weld, c0, c1, duration, easing)
	tweenList[weld] = newTween
end

local renderStepped = game:service("RunService").RenderStepped
local prevTick = tick()

renderStepped:connect(function()
	local deltaTick = tick() - prevTick
	prevTick = tick()
	
	for weld, tween in pairs(tweenList) do
		local result = tween:update(deltaTick)
		if result == "dead" then
			tweenList[weld] = nil
		end
	end
end)

return {tweenWeld,Ease}
