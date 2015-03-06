-----Crux Animation Module by wes_BAN
-----			Original: https://github.com/wes-BAN/crux-animation (Includes example script)
-----I TAKE NO CREDIT FOR THE MODULE SCRIPT!

-----Edits by FromLegoUniverse
-- -	Edits:
-- 	1. Changed "joint.C0 = cf" to "joint.C1 = cf"
-- 		Reason: For script to create modules



local Module = {}
local Stepped = game:GetService("RunService").Stepped

local ANIMATION_FPS = 60

---------------
-- Enums ------
---------------

Module.Enum = {}

Module.Enum.BlendMode = {
	["Blend"] = 1;
	["Additive"] = 2;
}

Module.Enum.WrapMode = {
	["Once"] = 1;
	["Loop"] = 2;
	["PingPong"] = 3;
	["ClampForever"] = 4;
}

Module.Enum.PlayMode = {
	["StopSameLayer"] = 1;
	["StopAll"] = 2;
}

---------------
-- Utils ------
---------------

local EMPTY_CFRAME = CFrame.new()

-- Returns a new value of enumType. If the parameter -is- an enum, just return the paramter
local function getEnumValue(value, enumType)
	if type(value) == "string" then
		local enumeration = Module.Enum[enumType][value]

		if not enumeration then
			error(value .. " is not a valid EnumItem (" .. enumType .. ")", 2)
		end

		return enumeration
	else
		return value
	end
end

local function lerp(a, b, c)
	return a + (b - a) * c
end

local function sign(n)
	return n > 0 and 1 or n < 0 and -1 or 0
end

local function round(n)
	return n > 0 and math.floor(n + 0.5) or math.ceil(n - 0.5)
end

local function clamp(n, min, max)
	min, max = min or 0, max or 1
	return n < min and min or n > max and max or n
end

local function deepCopyTable(original)
    local copy = {}
    for k, v in pairs(original) do
		if type(v) == 'table' then
		    v = deepCopyTable(v)
		end
		copy[k] = v
    end
    return copy
end

local function getIndex(t, search)
	for i, v in pairs(t) do
		if v == search then
			return i
		end
	end
end


-- Credit to Stravant (TODO: find out his name)

local lerpCFrame, getCFrameInterpolator; do
	local fromAxisAngle = CFrame.fromAxisAngle
	local components = CFrame.new().components
	local inverse = CFrame.new().inverse
	local v3 = Vector3.new
	local acos = math.acos
	local sqrt = math.sqrt
	local invroot2 = 1/math.sqrt(2)

	function lerpCFrame(c0, c1, alpha) -- (CFrame from, CFrame to) -> (float theta, (float fraction -> CFrame between))
		-- The expanded matrix
		local _, _, _, xx, yx, zx,
			       xy, yy, zy,
			       xz, yz, zz = components(inverse(c0)*c1)

		-- The cos-theta of the axisAngles from
		local cosTheta = (xx + yy + zz - 1)/2

		-- Rotation axis
		local rotationAxis = v3(yz - zy, zx - xz, xy - yx)

		-- The position to tween through
		local positionDelta = (c1.p - c0.p)

		-- Theta
		local theta;

		-- Catch degenerate cases
		if cosTheta >= 0.999 then
			-- Case same rotation, just return an interpolator over the positions
			return c0 + positionDelta*alpha
		elseif cosTheta <= -0.999 then
			-- Case exactly opposite rotations, disambiguate
			theta = math.pi
			xx = (xx + 1) / 2
			yy = (yy + 1) / 2
			zz = (zz + 1) / 2
			if xx > yy and xx > zz then
				if xx < 0.001 then
					rotationAxis = v3(0, invroot2, invroot2)
				else
					local x = sqrt(xx)
					xy = (xy + yx) / 4
					xz = (xz + zx) / 4
					rotationAxis = v3(x, xy/x, xz/x)
				end
			elseif yy > zz then
				if yy < 0.001 then
					rotationAxis = v3(invroot2, 0, invroot2)
				else
					local y = sqrt(yy)
					xy = (xy + yx) / 4
					yz = (yz + zy) / 4
					rotationAxis = v3(xy/y, y, yz/y)
				end
			else
				if zz < 0.001 then
					rotationAxis = v3(invroot2, invroot2, 0)
				else
					local z = sqrt(zz)
					xz = (xz + zx) / 4
					yz = (yz + zy) / 4
					rotationAxis = v3(xz/z, yz/z, z)
				end
			end
		else
			-- Normal case, get theta from cosTheta
			theta = acos(cosTheta)
		end

		return c0*fromAxisAngle(rotationAxis, theta*alpha) + positionDelta*alpha
	end

	function getCFrameInterpolator(c0, c1) -- (CFrame from, CFrame to) -> (float theta, (float fraction -> CFrame between))
		-- The expanded matrix
		local _, _, _, xx, yx, zx,
			       xy, yy, zy,
			       xz, yz, zz = components(inverse(c0)*c1)

		-- The cos-theta of the axisAngles from
		local cosTheta = (xx + yy + zz - 1)/2

		-- Rotation axis
		local rotationAxis = v3(yz-zy, zx-xz, xy-yx)

		-- The position to tween through
		local positionDelta = (c1.p - c0.p)

		-- Theta
		local theta;

		-- Catch degenerate cases
		if cosTheta >= 0.999 then
			-- Case same rotation, just return an interpolator over the positions
			return function(t)
				return c0 + positionDelta*t
			end
		elseif cosTheta <= -0.999 then
			-- Case exactly opposite rotations, disambiguate
			theta = math.pi
			xx = (xx + 1) / 2
			yy = (yy + 1) / 2
			zz = (zz + 1) / 2
			if xx > yy and xx > zz then
				if xx < 0.001 then
					rotationAxis = v3(0, invroot2, invroot2)
				else
					local x = sqrt(xx)
					xy = (xy + yx) / 4
					xz = (xz + zx) / 4
					rotationAxis = v3(x, xy/x, xz/x)
				end
			elseif yy > zz then
				if yy < 0.001 then
					rotationAxis = v3(invroot2, 0, invroot2)
				else
					local y = sqrt(yy)
					xy = (xy + yx) / 4
					yz = (yz + zy) / 4
					rotationAxis = v3(xy/y, y, yz/y)
				end
			else
				if zz < 0.001 then
					rotationAxis = v3(invroot2, invroot2, 0)
				else
					local z = sqrt(zz)
					xz = (xz + zx) / 4
					yz = (yz + zy) / 4
					rotationAxis = v3(xz/z, yz/z, z)
				end
			end
		else
			-- Normal case, get theta from cosTheta
			theta = acos(cosTheta)
		end

		-- Return the interpolator
		return function(t)
			return c0*fromAxisAngle(rotationAxis, theta*t) + positionDelta*t
		end
	end
end


local function quaternionFromCFrame(cf)
	local mx,  my,  mz,
	      m00, m01, m02,
	      m10, m11, m12,
	      m20, m21, m22 = cf:components()
	local trace = m00 + m11 + m22

	if trace > 0 then
		local s = math.sqrt(1 + trace)
		local recip = 0.5/s
		return (m21-m12)*recip, (m02-m20)*recip, (m10-m01)*recip, s*0.5
	else
		if m11 > m00 then
			local s = math.sqrt(m11-m22-m00+1)
			local recip = 0.5/s
			return (m01+m10)*recip, 0.5*s, (m21+m12)*recip, (m02-m20)*recip
		elseif m22 > (i == 0 and m00 or m11) then
			local s = math.sqrt(m22-m00-m11+1)
			local recip = 0.5/s
			return (m02+m20)*recip, (m12+m21)*recip, 0.5*s, (m10-m01)*recip
		else
			local s = math.sqrt(m00-m11-m22+1)
			local recip = 0.5/s
			return 0.5*s, (m10+m01)*recip, (m20+m02)*recip, (m21-m12)*recip
		end
	end
end

local function quaternionSlerp(a, b, t)
	local cosTheta = a[1]*b[1] + a[2]*b[2] + a[3]*b[3] + a[4]*b[4]
	local startInterp, finishInterp;

	if cosTheta >= 0.0001 then
		if (1 - cosTheta) > 0.0001 then
			local theta = math.acos(cosTheta)
			local invSinTheta = 1/math.sin(theta)
			startInterp = math.sin((1-t)*theta)*invSinTheta
			finishInterp = math.sin(t*theta)*invSinTheta
		else
			startInterp = 1-t
			finishInterp = t
		end
	else
		if (1+cosTheta) > 0.0001 then
			local theta = math.acos(-cosTheta)
			local invSinTheta = 1/math.sin(theta)
			startInterp = math.sin((t-1)*theta)*invSinTheta
			finishInterp = math.sin(t*theta)*invSinTheta
		else
			startInterp = t-1
			finishInterp = t
		end
	end

	return a[1]*startInterp + b[1]*finishInterp,
	       a[2]*startInterp + b[2]*finishInterp,
	       a[3]*startInterp + b[3]*finishInterp,
	       a[4]*startInterp + b[4]*finishInterp
end

local function slerp(a, b, t)
	local qa = {quaternionFromCFrame(a)}
	local qb = {quaternionFromCFrame(b)}
	local qx, qy, qz, w = quaternionSlerp(qa, qb, t)
	local pos = (1 - t) * a.p + t * b.p

	return CFrame.new(pos.x, pos.y, pos.z, qx, qy, qz, w)
end


-- Credit to Roblox Corp.

local Signal = {} do
	function Signal.new()
		local sig = {}
		local mSignaler = Instance.new("BoolValue")
		local mHandlers = {}
		local mArgData;
		function sig:fire(...)
			mArgData = {...}
			mSignaler.Value = not mSignaler.Value
		end
		function sig:connect(f)
			if not f then error("connect(nil)", 2) end
			return mSignaler.Changed:connect(function()
				f(unpack(mArgData))
			end)
		end
		function sig:wait()
			mSignaler.Changed:wait()
			return unpack(mArgData)
		end
		return sig
	end
end

---------------
-- Easing -----
---------------

-- TODO: More easing types + better overall implementation
--       Generated In/Out/InOut easing functions


local Easing = {} do
	Easing.Linear = function(step)
		return step
	end

	Easing.QuadIn = function(step)
		return step ^ 2
	end

	Easing.CubeIn = function(step)
		return step ^ (1/3)
	end

	Easing.QuartIn = function(step)
		return step ^ (1/4)
	end

	Easing.SineIn = function(step)
		return 1 - math.cos(step * math.pi / 2)
	end

	Easing.SineOut = function(step)
		return math.sin(step * math.pi / 2)
	end

	Easing.SineInOut = function(step)
		return 0.5 + math.cos(step * math.pi) / -2
	end

	Easing.ElasticOut = function(step, amplitude, period)
		local t, b, c, d, a, p = step, 0, 1, 1, amplitude, period

		if t == 0 then return b end

		t = t / d

		if t == 1 then return b + c end

		if not p then p = d * 0.3 end

		local s;

		if not a or a < math.abs(c) then
			a = c
			s = p / 4
		else
			s = p / (2 * math.pi) * math.asin(c/a)
		end

		return a * math.pow(2, -10 * t) * math.sin((t * d - s) * (2 * math.pi) / p) + c + b
	end
end

---------------
-- Classes ----
---------------

local AnimationClip = {} do
	local ANIMCLIP_DEFAULT_NAME = "AnimationClip"
	local ANIMCLIP_DEFAULT_BLEND_MODE = Module.Enum.BlendMode.Blend
	local ANIMCLIP_DEFAULT_WRAP_MODE = Module.Enum.WrapMode.Once
	local ANIMCLIP_DEFAULT_WEIGHT = 1.0
	local ANIMCLIP_DEFAULT_SPEED = 1.0
	local ANIMCLIP_DEFAULT_STYLE = "Linear"

	local function readFormat(input)
		local format = {}
		local clipData;
		local name;
		local speed;
		local blendMode, wrapMode;
		local weight, timeStretch;

		if not input then
			error("AnimationClip :: No data supplied to create AnimationClip with", 3)
		end

		if type(input) == "table" then
			format = input
			clipData = format
		elseif type(input) == "userdata" and input:IsA("ModuleScript") then
			format = require(input)
			clipData = format
		end

		if type(clipData.Joints) ~= "table" then
			error("AnimationClip :: 'Joints' table expected inside clip format", 3)
		end

		-- Get enum values
		name      = format.Name
		blendMode = getEnumValue(clipData.BlendMode, "BlendMode")
		wrapMode  = getEnumValue(clipData.WrapMode, "WrapMode")
		weight    = format.Weight
		speed     = format.Speed

		-- Set clip info
		clipData.Name       = name or ANIMCLIP_DEFAULT_NAME
		clipData.Weight     = weight or ANIMCLIP_DEFAULT_WEIGHT
		clipData.Speed      = speed and math.max(0, speed) or ANIMCLIP_DEFAULT_SPEED
		clipData.BlendMode  = blendMode or ANIMCLIP_DEFAULT_BLEND_MODE
		clipData.WrapMode   = wrapMode or ANIMCLIP_DEFAULT_WRAP_MODE

		return clipData
	end

	local function getEasingAlpha(linearStep, style, params)
		return Easing[style](linearStep, params)
	end

	local function writeToClip(clip, frameNum, jointName, frames)
		local location = frameNum - 1

		for i, cframe in pairs(frames) do
			local frame = clip[location + i]
			if not frame then
				frame = {}
				clip[location + i] = frame
			end

			frame[jointName] = cframe
		end
	end

	local function sortKeyframes(keyframes)
		table.sort(keyframes, function(keyframe_a, keyframe_b)
			return keyframe_a.Frame < keyframe_b.Frame
		end)
	end

	-- Generates interpolator functions for each frame in a joint's animation cycle
	local function renderJointFrames(keyframes, speed)
		local frames = {}

		-- Sort keyframes so that the array is ordered from the lowest frame in the timeline to the highest
		sortKeyframes(keyframes)

		local lastKeyframe = keyframes[1]
		local frameNum = 1

		for _, keyframe in ipairs(keyframes) do
			local easingStyle = lastKeyframe.Style or ANIMCLIP_DEFAULT_STYLE
			local params = lastKeyframe.EasingParameters or {}

			local keyframeTime = round((keyframe.Frame - 1) * speed) + 1
			local interval = keyframeTime - frameNum
			local startCFrame, goalCFrame = lastKeyframe.CFrame, keyframe.CFrame
			local frameGoal = startCFrame

			for i = 0, interval do
				local step = interval == 0 and 0 or (i / interval)
				local alpha = getEasingAlpha(step, easingStyle, unpack(params))
				local newFrameGoal = lerpCFrame(startCFrame, goalCFrame, alpha)

				frames[frameNum + i] = getCFrameInterpolator(frameGoal, newFrameGoal)
				frameGoal = newFrameGoal
			end

			lastKeyframe = keyframe
			frameNum = keyframeTime
		end

		return frames
	end

	local function getJointStartingFrame(jointKeyframes)
		local startFrame = 1

		for _, goal in pairs(jointKeyframes) do
			startFrame = math.min(startFrame, goal.Frame)
		end

		return startFrame
	end

	local function renderClip(clip)
		local clipFrames = {}
		local speed = 1 / clip.Speed

		for jointName, keyframes in pairs(clip.Joints) do
			local startFrame = getJointStartingFrame(keyframes)
			local jointFrames = renderJointFrames(keyframes, speed)

			writeToClip(clipFrames, startFrame, jointName, jointFrames)
		end

		return clipFrames
	end

	local set = {} do
		set.Speed = function(self, v)
			self.Speed = v
			self._RenderedFrames = renderClip(self)
		end

		set.BlendMode = function(self, v)
			self.BlendMode = getEnumValue(v, "BlendMode")
		end

		set.WrapMode = function(self, v)
			self.WrapMode = getEnumValue(v, "WrapMode")
		end
	end

	local function setToRender(clip)
		local proxy = {}
		local mt = {
			__index = function(self, k)
				return clip[k]
			end,
			__newindex = function(self, k, v)
				if set[k] then
					set[k](clip, v)
				end
			end
		}
		setmetatable(proxy, mt)
		return proxy
	end

	-- Constructor
	function AnimationClip.new(format)
		-- Read the given format and convert it
		local this = readFormat(format)
		this._IsAnimationClip = true

		-- Render new frames
		this._RenderedFrames = renderClip(this)

		return setToRender(this)
	end
end


local Crossfade = {} do
	Crossfade.__index = Crossfade

	function Crossfade.new(start, goal, duration)
		local this = {}
		this._StartTime = tick()
		this._Duration = duration
		this._Start = start
		this._Goal = goal

		return setmetatable(this, Crossfade)
	end

	function Crossfade:SetGoal(newGoal, duration)
		self._Start = self:GetValue()
		self._Goal = newGoal
		self._StartTime = tick()
		self._Duration = duration
	end

	-- Returns the current value and whether the crossfade has completed
	function Crossfade:GetValue()
		if self._Duration == 0 then
			return self._Goal
		else
			local progress = clamp((tick() - self._StartTime) / self._Duration)
			local start, goal = self._Start, self._Goal

			local value = lerp(start, goal, progress)
			return value, value == goal
		end
	end

	function Crossfade:IsComplete()
		return self:GetValue() == self._Goal
	end
end


local AnimationState = {} do
	local ANIMSTATE_DEFAULT_NAME = "AnimationState"

	local WRAPMODE_ONCE          = Module.Enum.WrapMode.Once
	local WRAPMODE_LOOP          = Module.Enum.WrapMode.Loop
	local WRAPMODE_CLAMP_FOREVER = Module.Enum.WrapMode.ClampForever
	local WRAPMODE_PING_PONG     = Module.Enum.WrapMode.PingPong

	local get = {} do
		get.Layer = function(self)
			return self._Layer
		end

		get.NormalizedTime = function(self)
			return self.Time / self._Length
		end

		get.BlendMode = function(self)
			return self._BlendMode
		end

		get.WrapMode = function(self)
			return self._WrapMode
		end

		get.Length = function(self)
			return self._Length
		end
	end

	local set = {} do
		set.Layer = function(self, v, skeleton)
			if v < 1 then
				error("AnimationState :: Invalid layer", 2)
			end

			self._Layer = math.floor(v)
			skeleton:_SampleLayers()
		end

		set.NormalizedTime = function(self, v)
			self.Time = self._Length * v
		end

		set.BlendMode = function(self, v)
			self._BlendMode = getEnumValue(v, "BlendMode")
		end

		set.WrapMode = function(self, v)
			self._WrapMode = getEnumValue(v, "WrapMode")
		end
	end

	local function setStateMetatable(state, skeleton)
		local mt = {} do
			mt.__index = function(self, k)
				if get[k] then
					return get[k](self)
				else
					return AnimationState[k]
				end
			end
			mt.__newindex = function(self, k, v)
				if set[k] then
					set[k](self, v, skeleton)
				end
			end
		end
		return setmetatable(state, mt)
	end

	function AnimationState.new(skeleton, clip)
		local this = {}

		this.Clip = deepCopyTable(clip)
		this.Name = clip.Name
		this.Weight = clip.Weight
		this._BlendMode = clip.BlendMode
		this._WrapMode = clip.WrapMode

		this.Speed = 1.0
		this.Time = 0.0

		this.Callback = function() end

		this.Played = Signal.new()
		this.Stopped = Signal.new()

		this._Frames = clip._RenderedFrames
		this._Layer = 1
		this._IsPlaying = false
		this._Length = #clip._RenderedFrames / ANIMATION_FPS
		this._FrameBuffer = {}

		this._Crossfade = Crossfade.new(0, 0, 0)
		this._IsFading = false

		this.Enabled = true
		return setStateMetatable(this, skeleton)
	end

	function AnimationState:_BufferFrame(endFrame, alpha)
		local buffer = self._FrameBuffer
		buffer = {}

		for jointName, lerp in pairs(endFrame) do
			buffer[jointName] = lerp(alpha)
		end

		return buffer
	end

	function AnimationState:_GetCurrentFrame()
		local currentTime, normalizedTime;
		local timeSampleStart, timeSampleEnd;
		local frames, frameCount = self._Frames, #self._Frames
		local time, length = self.Time, self.Length
		local result;
		local alpha;

		-- Wrap time value
		if self.WrapMode == WRAPMODE_LOOP then
			currentTime = time % length

		-- Do wrapping mode for PingPong playback
		elseif self.WrapMode == WRAPMODE_PING_PONG then
			currentTime = length - math.abs(time % (2 * length) - length)

		-- Clamp time otherwise
		elseif self.WrapMode == WRAPMODE_ONCE or self.WrapMode == WRAPMODE_CLAMP_FOREVER then
			currentTime = clamp(time, 0, length)
		end

		normalizedTime = clamp(currentTime / length)
		timeSampleStart, alpha = math.modf((frameCount - 1) * normalizedTime)

		timeSampleStart = timeSampleStart + 1
		timeSampleEnd = timeSampleStart % frameCount + 1

		result = self:_BufferFrame(frames[timeSampleEnd], alpha)
		return result, timeSampleStart, normalizedTime
	end

	function AnimationState:_Play(resume)
		local wrap = self.WrapMode
		-- Reset time
		if (wrap ~= WRAPMODE_CLAMP_FOREVER) then
			if (not resume) or (wrap == WRAPMODE_ONCE) then
				self.Time = 0.0
			end
		end

		self._IsPlaying = true
		self.Played:fire()
	end

	function AnimationState:_Stop()
		if self._IsPlaying then
			self._IsPlaying = false
			self.Stopped:fire()
		end
	end

	function AnimationState:_DoCallback(frameJoints, frameNum, normalizedTime)
		local newWeight, presets, offsets = self.Callback(frameJoints, frameNum, normalizedTime)

		if newWeight then
			self.Weight = newWeight
		end

		return presets or {}, offsets or {}
	end
end


local Skeleton = {} do
	local WRAPMODE_ONCE = Module.Enum.WrapMode.Once
	local BLENDMODE_BLEND    = Module.Enum.BlendMode.Blend
	local BLENDMODE_ADDITIVE = Module.Enum.BlendMode.Additive

	local function fillJoints(model, nonRecursive)
		local joints = {}

		local function setJoints(part)
			for _, obj in pairs(part:GetChildren()) do
				if obj:IsA("JointInstance") then
					joints[obj.Name] = obj
				end
				if not nonRecursive then
					setJoints(obj)
				end
			end
		end

		setJoints(model, nonRecursive)
		return joints
	end

	local mt = {} do
		mt.__index = function(self, k)
			if Skeleton[k] then
				return Skeleton[k]
			elseif k == "Enabled" then
				return self._Enabled
			else
				return self:_GetState(k)
			end
		end
		mt.__newindex = function(self, k, v)
			if k == "Enabled" and type(v) == "boolean" then
				self._Enabled = v
				if v then
					spawn(function()
						self:_StartAsync()
					end)
				end
			end
		end
	end

	function Skeleton.new(model, nonRecursive)
		local this = {}
		this.Cull = false

		this._Enabled = false
		this._States = {}
		this._Layers = {}

		this._Joints = fillJoints(model, nonRecursive)
		this._LayerBuffer = {}
		this._SkeletonBuffer = {}

		this._PlayingLayers = {}
		this._Queue = {}

		return setmetatable(this, mt)
	end

	function Skeleton:_StartAsync()
		local t = tick()
		local dt = 0.0
		while self._Enabled do
			dt = tick() - t
			self:_Update(dt)

			t = tick()
			Stepped:wait()
		end
	end

	function Skeleton:_Update(dt)
		local blendedJoints = self._SkeletonBuffer
		local playingLayers = self._PlayingLayers
		local bottomLayer = true
		local cull = self.Cull

		self:_EvaluateQueue()

		for layer = 1, #playingLayers do
			local states = playingLayers[layer]

			local layerBuffer = self._LayerBuffer
			layerBuffer = {}

			local k = 0
			for i = 1, #states do
				local state = states[i - k]

				-- Get crossfade values
				local fadeValue, finished = state._Crossfade:GetValue()
				local completedFade = (fadeValue == 0) and finished
				local canPlay = state.Enabled and state._IsPlaying

				if not canPlay or completedFade then
					if completedFade then
						state:_Stop()
					end
					table.remove(states, i - k)
					k = k + 1
				else
					local reachedEnd = false

					-- Animate
					if (not cull) and (state.BlendMode == BLENDMODE_BLEND) then
						local frame = self:_UpdateState(state, blendedJoints, bottomLayer)
						table.insert(layerBuffer, {frame, fadeValue})
					end

					-- Only play once?
					if state.WrapMode == WRAPMODE_ONCE then
						if sign(state.Time) >= 0 then
							-- Animation is playing normally
							if state.Time > state._Length then
								reachedEnd = true
								state:_Stop()
							end
						else
							-- Animation is in reverse
							if state.Time < 0 then
								reachedEnd = true
								state:_Stop()
							end
						end
					end

					-- Update state's time
					if not reachedEnd then
						state.Time = state.Time + (dt * state.Speed)
					end
				end
			end

			-- Do fading
			if (not cull) then
				for i = 1, #layerBuffer do
					local stateBuffer = layerBuffer[i]

					local frame, fadeValue = stateBuffer[1], stateBuffer[2]
					self:_BlendAdditiveUpwards(frame, layer)

					if fadeValue == 1 then
						for joint, cf in pairs(frame) do
							blendedJoints[joint] = cf
						end
					elseif fadeValue ~= 0 then
						for joint, cf in pairs(frame) do
							blendedJoints[joint] = slerp(blendedJoints[joint] or EMPTY_CFRAME, cf, fadeValue)
						end
					end
				end
			end

			-- Ensure that the next iteration in the loop won't be considered the bottom layer
			bottomLayer = false
		end

		if (not cull) then
			for joint, cf in pairs(blendedJoints) do
				joint.C1 = cf
			end
		end
	end

	function Skeleton:_BlendAdditiveUpwards(frame, start)
		local nextLayer, additiveFrame = next(self._PlayingLayers, start)
		if not additiveFrame then
			return
		end

		for _, state in pairs(additiveFrame) do
			if state.BlendMode == BLENDMODE_ADDITIVE then
				local addedFrame, frameNum, normalizedTime = state:_GetCurrentFrame()
				local presets, offsets = state:_DoCallback(addedFrame, frameNum, normalizedTime)

				for jointName, cf in pairs(addedFrame) do
					local joint = self._Joints[jointName]

					if joint then
						local preset, offset = presets[jointName], offsets[jointName]
						local blendCF = frame[joint]

						if preset then
							cf = preset * cf
						end
						if offset then
							cf = cf * offset
						end

						if not blendCF then
							blendCF = EMPTY_CFRAME
						end

						if state.Weight == 1 then
							blendCF = blendCF * cf
						elseif state.Weight ~= 0 then
							blendCF = blendCF * slerp(EMPTY_CFRAME, cf, state.Weight)
						end

						frame[joint] = blendCF
					end
				end
			end
		end

		if (nextLayer + 1) <= #self._PlayingLayers then
			self:_BlendAdditiveUpwards(frame, nextLayer)
		end
	end

	function Skeleton:_UpdateState(state, layerBuffer, bottomLayer)
		-- Get current frame
		local frame, frameNum, normalizedTime = state:_GetCurrentFrame()
		local presets, offsets = state:_DoCallback(frame, frameNum, normalizedTime)
		local blendedFrame = {}

		-- Apply to joints
		for jointName, cf in pairs(frame) do
			local joint = self._Joints[jointName]

			if joint then
				local preset, offset = presets[jointName], offsets[jointName]
				local blendCF = layerBuffer[joint]

				if preset then
					cf = preset * cf
				end
				if offset then
					cf = cf * offset
				end

				if not blendCF then
					blendCF = EMPTY_CFRAME
				end

				if ((state.Weight == 1) and (state.BlendMode == BLENDMODE_BLEND)) or bottomLayer then
					blendCF = cf
				elseif state.Weight ~= 0 then
					blendCF = slerp(blendCF, cf, state.Weight)
				end

				blendedFrame[joint] = blendCF
			end
		end

		return blendedFrame
	end

	function Skeleton:_GetState(name)
		for _, state in pairs(self._States) do
			if state.Name == name then
				return state
			end
		end
	end

	function Skeleton:_GetStatesInLayer(layer)
		local states = {}

		for _, state in pairs(self._States) do
			if state._Layer == layer then
				table.insert(states, state)
			end
		end

		return states
	end

	function Skeleton:_SampleLayers()
		local layers = {}

		for _, state in pairs(self._States) do
			local stateLayer = layers[state._Layer]

			if not stateLayer then
				stateLayer = {}
				layers[state._Layer] = stateLayer
			end

			table.insert(stateLayer, state)
		end

		self._Layers = layers
	end

	function Skeleton:GetStates()
		local states = {}
		for i, state in pairs(self._States) do
			states[i] = state
		end
		return states
	end

	function Skeleton:AddClip(clip, name)
		if (not clip) or (type(clip) ~= "table") or (not clip._IsAnimationClip) then
			error("Skeleton :: AnimationClip expected", 2)
		end

		local newState = AnimationState.new(self, clip)
		newState.Name = name or newState.Name
		table.insert(self._States, newState)

		self:_SampleLayers()
		return newState
	end

	function Skeleton:Play(name, playMode)
		local state, playMode;

		state = self:_GetState(name)
		if not state then
			error("Skeleton :: '" .. tostring(name) .. "' is not a valid AnimationState", 2)
		end

		if not state.Enabled then
			return false
		end

		playMode = getEnumValue(playMode, "PlayMode")
		if (not playMode) or playMode.Name == "StopSameLayer" then
			local states = self:_GetStatesInLayer(state._Layer)
			for _, stateToStop in pairs(states) do
				stateToStop:_Stop()
			end
		elseif playMode.Name == "StopAll" then
			for _, stateToStop in pairs(self._States) do
				stateToStop:_Stop()
			end
		end

		state._Crossfade:SetGoal(1, 0)
		state:_Play()

		self:_PlayThroughLayer(state)
		return true
	end

	function Skeleton:Crossfade(name, fadeLength, mode)
		local state, playMode;

		fadeLength = fadeLength or 0.3
		state = self:_GetState(name)
		if not state then
			error("Skeleton :: '" .. tostring(name) .. "' is not a valid AnimationState", 2)
		end

		if (not state.Enabled) or (state._Crossfade._Goal == 1) then
			return false
		end

		playMode = getEnumValue(playMode, "PlayMode")
		if (not playMode) or playMode.Name == "StopSameLayer" then
			local states = self:_GetStatesInLayer(state._Layer)
			for _, stateToStop in pairs(states) do
				stateToStop._Crossfade:SetGoal(0, fadeLength)
			end
		elseif playMode.Name == "StopAll" then
			for _, stateToStop in pairs(self._States) do
				stateToStop._Crossfade:SetGoal(0, fadeLength)
			end
		end

		local _, finished = state._Crossfade:GetValue()
		state._Crossfade:SetGoal(1, fadeLength)
		state:_Play(not finished)

		self:_PlayThroughLayer(state)
		return true
	end

	function Skeleton:_EvaluateQueue()
		for i = 1, #self._Queue do
			local state = self._Queue[i]

			local layer = state._Layer
			local playedLayer = self._PlayingLayers[layer]

			if not playedLayer then
				playedLayer = {}
				self._PlayingLayers[layer] = playedLayer
			end

			local i = getIndex(playedLayer, state)
			if i then
				table.remove(playedLayer, i)
			end
			table.insert(playedLayer, state)
		end
		-- Empty queue
		self._Queue = {}
	end

	function Skeleton:_PlayThroughLayer(state)
		table.insert(self._Queue, state)
	end

	function Skeleton:Stop(name)
		local state = self:_GetState(name)
		if not state then
			error("Skeleton :: '" .. tostring(name) .. "' is not a valid AnimationState", 2)
		end

		state:_Stop()
	end

	function Skeleton:IsPlaying(name)
		local state = self:_GetState(name)
		if not state then
			-- Perhaps error instead?
			return false
		end

		return state._IsPlaying
	end
end



Module.Skeleton = Skeleton
Module.AnimationClip = AnimationClip

return Module

