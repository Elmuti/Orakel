-- Adapted to work with ROBLOX-specific values.
-- Written by FriendlyBiscuit
-- Documentation available in the Help script.


	-- Disclaimer for Robert Penner's Easing Equations license:

	-- TERMS OF USE - EASING EQUATIONS

	-- Open source under the BSD License.

	-- Copyright © 2001 Robert Penner
	-- All rights reserved.

	-- Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

	--     * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
	--     * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
	--     * Neither the name of the author nor the names of contributors may be used to endorse or promote products derived from this software without specific prior written permission.

	-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


-- Shortcuts
local pow = math.pow
local sin = math.sin
local cos = math.cos
local pi = math.pi
local sqrt = math.sqrt
local abs = math.abs
local asin  = math.asin

-- Functions
local function linear(t, b, c, d)
	return c * t / d + b
end

local function inQuad(t, b, c, d)
	t = t / d
	return c * pow(t, 2) + b
end

local function outQuad(t, b, c, d)
	t = t / d
	return -c * t * (t - 2) + b
end

local function inOutQuad(t, b, c, d)
	t = t / d * 2
	if t < 1 then
		return c / 2 * pow(t, 2) + b
	else
		return -c / 2 * ((t - 1) * (t - 3) - 1) + b
	end
end

local function outInQuad(t, b, c, d)
	if t < d / 2 then
		return outQuad (t * 2, b, c / 2, d)
	else
		return inQuad((t * 2) - d, b + c / 2, c / 2, d)
	end
end

local function inCubic(t, b, c, d)
	t = t / d
	return c * pow(t, 3) + b
end

local function outCubic(t, b, c, d)
	t = t / d - 1
	return c * (pow(t, 3) + 1) + b
end

local function inOutCubic(t, b, c, d)
	t = t / d * 2
	if t < 1 then
		return c / 2 * t * t * t + b
	else
		t = t - 2
		return c / 2 * (t * t * t + 2) + b
	end
end

local function outInCubic(t, b, c, d)
	if t < d / 2 then
		return outCubic(t * 2, b, c / 2, d)
	else
		return inCubic((t * 2) - d, b + c / 2, c / 2, d)
	end
end

local function inQuart(t, b, c, d)
	t = t / d
	return c * pow(t, 4) + b
end

local function outQuart(t, b, c, d)
	t = t / d - 1
	return -c * (pow(t, 4) - 1) + b
end

local function inOutQuart(t, b, c, d)
	t = t / d * 2
	if t < 1 then
		return c / 2 * pow(t, 4) + b
	else
	t = t - 2
		return -c / 2 * (pow(t, 4) - 2) + b
	end
end

local function outInQuart(t, b, c, d)
	if t < d / 2 then
		return outQuart(t * 2, b, c / 2, d)
	else
		return inQuart((t * 2) - d, b + c / 2, c / 2, d)
	end
end

local function inQuint(t, b, c, d)
	t = t / d
	return c * pow(t, 5) + b
end

local function outQuint(t, b, c, d)
	t = t / d - 1
	return c * (pow(t, 5) + 1) + b
end

local function inOutQuint(t, b, c, d)
	t = t / d * 2
	if t < 1 then
		return c / 2 * pow(t, 5) + b
	else
		t = t - 2
		return c / 2 * (pow(t, 5) + 2) + b
	end
end

local function outInQuint(t, b, c, d)
	if t < d / 2 then
		return outQuint(t * 2, b, c / 2, d)
	else
		return inQuint((t * 2) - d, b + c / 2, c / 2, d)
	end
end

local function inSine(t, b, c, d)
	return -c * cos(t / d * (pi / 2)) + c + b
end

local function outSine(t, b, c, d)
	return c * sin(t / d * (pi / 2)) + b
end

local function inOutSine(t, b, c, d)
	return -c / 2 * (cos(pi * t / d) - 1) + b
end

local function outInSine(t, b, c, d)
	if t < d / 2 then
		return outSine(t * 2, b, c / 2, d)
	else
		return inSine((t * 2) -d, b + c / 2, c / 2, d)
	end
end

local function inExpo(t, b, c, d)
	if t == 0 then
		return b
	else
		return c * pow(2, 10 * (t / d - 1)) + b - c * 0.001
	end
end

local function outExpo(t, b, c, d)
	if t == d then
		return b + c
	else
		return c * 1.001 * (-pow(2, -10 * t / d) + 1) + b
	end
end

local function inOutExpo(t, b, c, d)
	if t == 0 then return b end
	if t == d then return b + c end
	t = t / d * 2
	if t < 1 then
		return c / 2 * pow(2, 10 * (t - 1)) + b - c * 0.0005
	else
		t = t - 1
		return c / 2 * 1.0005 * (-pow(2, -10 * t) + 2) + b
	end
end

local function outInExpo(t, b, c, d)
	if t < d / 2 then
		return outExpo(t * 2, b, c / 2, d)
	else
		return inExpo((t * 2) - d, b + c / 2, c / 2, d)
	end
end

local function inCirc(t, b, c, d)
	t = t / d
	return(-c * (sqrt(1 - pow(t, 2)) - 1) + b)
end

local function outCirc(t, b, c, d)
	t = t / d - 1
	return(c * sqrt(1 - pow(t, 2)) + b)
end

local function inOutCirc(t, b, c, d)
	t = t / d * 2
	if t < 1 then
		return -c / 2 * (sqrt(1 - t * t) - 1) + b
	else
		t = t - 2
		return c / 2 * (sqrt(1 - t * t) + 1) + b
	end
end

local function outInCirc(t, b, c, d)
	if t < d / 2 then
		return outCirc(t * 2, b, c / 2, d)
	else
		return inCirc((t * 2) - d, b + c / 2, c / 2, d)
	end
end

local function outBounce(t, b, c, d)
	t = t / d
	if t < 1 / 2.75 then
		return c * (7.5625 * t * t) + b
	elseif t < 2 / 2.75 then
		t = t - (1.5 / 2.75)
		return c * (7.5625 * t * t + 0.75) + b
	elseif t < 2.5 / 2.75 then
		t = t - (2.25 / 2.75)
		return c * (7.5625 * t * t + 0.9375) + b
	else
		t = t - (2.625 / 2.75)
		return c * (7.5625 * t * t + 0.984375) + b
	end
end

local function inBounce(t, b, c, d)
	return c - outBounce(d - t, 0, c, d) + b
end

local function inOutBounce(t, b, c, d)
	if t < d / 2 then
		return inBounce(t * 2, 0, c, d) * 0.5 + b
	else
		return outBounce(t * 2 - d, 0, c, d) * 0.5 + c * .5 + b
	end
end

local function outInBounce(t, b, c, d)
	if t < d / 2 then
		return outBounce(t * 2, b, c / 2, d)
	else
		return inBounce((t * 2) - d, b + c / 2, c / 2, d)
	end
end

-- Easing Enums
local EasingFunctions = {
	["Linear"] = linear;
	["InQuad"] = inQuad;
	["OutQuad"] = outQuad;
	["InOutQuad"] = inOutQuad;
	["OutInQuad"] = outInQuad;
	["InCubic"] = inCubic;
	["OutCubic"] = outCubic;
	["InOutCubic"] = inOutCubic;
	["OutInCubic"] = outInCubic;
	["InQuart"] = inQuart;
	["OutQuart"] = outQuart;
	["InOutQuart"] = inOutQuart;
	["OutInQuart"] = outInQuart;
	["InQuint"] = inQuint;
	["OutQuint"] = outQuint;
	["InOutQuint"] = inOutQuint;
	["OutInQuint"] = outInQuint;
	["InSine"] = inSine;
	["OutSine"] = outSine;
	["InOutSine"] = inOutSine;
	["OutInSine"] = outInSine;
	["InExpo"] = inExpo;
	["OutExpo"] = outExpo;
	["InOutExpo"] = inOutExpo;
	["OutInExpo"] = outInExpo;
	["InCirc"] = inCirc;
	["OutCirc"] = outCirc;
	["InOutCirc"] = inOutCirc;
	["OutInCirc"] = outInCirc;
	["InBounce"] = inBounce;
	["OutBounce"] = outBounce;
	["InOutBounce"] = inOutBounce;
	["OutInBounce"] = outInBounce;
}

local RBXAnimator = { }
local RunService = game:GetService("RunService")

function PropertyType(Object, Property)
	local IsColor, _ = pcall(function() local r, g, b = Object[Property].r, Object[Property].g, Object[Property].b end)

	if Object:IsA("GuiObject") and (Property == "Size" or Property == "Position") then
		return "GuiProperty"
	elseif IsColor then
		return "ColorProperty"
	elseif Object:IsA("BasePart") and (Property == "Size" or Property == "Position" or Property == "Rotation") then
		return "VectorProperty"
	elseif Property == "CFrame" or Property == "CoordinateFrame" then
		return "CFrameProperty"
	end
end

function Tween(Object, Property, EndValue, EasingType, EasingTime, Render)
	assert(Object, "Cannot Tween a nil object.")
	assert(Property, "Cannot Tween a nil property.")
	assert(EndValue, "Cannot Tween without an end value.")
	assert(EasingFunctions[EasingType], "Cannot Tween with a nil easing type.")

	local EasingType = (EasingType and EasingType) or "linear"
	local EasingTime = (Render and (EasingTime and (EasingTime / (1 / 60))) or (1 / (1 / 60))) or ((EasingTime and (EasingTime / 0.03)) or (1 / 0.03))

	if PropertyType(Object, Property) == "GuiProperty" then -- UDim2 support
		local Begin = Object[Property]

		for Elapsed = 1, EasingTime do
			if Begin == EndValue then break end
			Object[Property] = UDim2.new(
				EasingFunctions[EasingType](Elapsed, Begin.X.Scale, (EndValue.X.Scale - Begin.X.Scale), EasingTime),
				EasingFunctions[EasingType](Elapsed, Begin.X.Offset, (EndValue.X.Offset - Begin.X.Offset), EasingTime),
				EasingFunctions[EasingType](Elapsed, Begin.Y.Scale, (EndValue.Y.Scale - Begin.Y.Scale), EasingTime),
				EasingFunctions[EasingType](Elapsed, Begin.Y.Offset, (EndValue.Y.Offset - Begin.Y.Offset), EasingTime)
			)
			if Render then
				RunService.RenderStepped:wait()
			else
				RunService.Heartbeat:wait()
			end
		end

		Object[Property] = EndValue
	elseif PropertyType(Object, Property) == "CFrameProperty" then -- CoordinateFrame support
		local x, y, z, xx, xy, xz, yx, yy, yz, zx, zy, zz = Object[Property]:components()
		local xe, ye, ze, xxe, xye, xze, yxe, yye, yze, zxe, zye, zze = EndValue:components()
		local Begin = Object[Property]
		
		for Elapsed = 1, EasingTime do
			if Begin == EndValue then break end
			Object[Property] = CFrame.new(
				EasingFunctions[EasingType](Elapsed, x, (xe - x), EasingTime),
				EasingFunctions[EasingType](Elapsed, y, (ye - y), EasingTime),
				EasingFunctions[EasingType](Elapsed, z, (ze - z), EasingTime),
				EasingFunctions[EasingType](Elapsed, xx, (xxe - xx), EasingTime),
				EasingFunctions[EasingType](Elapsed, xy, (xye - xy), EasingTime),
				EasingFunctions[EasingType](Elapsed, xz, (xze - xz), EasingTime),
				EasingFunctions[EasingType](Elapsed, yx, (yxe - yx), EasingTime),
				EasingFunctions[EasingType](Elapsed, yy, (yye - yy), EasingTime),
				EasingFunctions[EasingType](Elapsed, yz, (yze - yz), EasingTime),
				EasingFunctions[EasingType](Elapsed, zx, (zxe - zx), EasingTime),
				EasingFunctions[EasingType](Elapsed, zy, (zye - zy), EasingTime),
				EasingFunctions[EasingType](Elapsed, zz, (zze - zz), EasingTime)
			)
			if Render then
				RunService.RenderStepped:wait()
			else
				RunService.Heartbeat:wait()
			end
		end

		Object[Property] = EndValue
	elseif PropertyType(Object, Property) == "VectorProperty" then -- Vector3 support
		local Begin = Object[Property]

		for Elapsed = 1, EasingTime do
			if Begin == EndValue then break end
			Object[Property] = Vector3.new(
				EasingFunctions[EasingType](Elapsed, Begin.X, (EndValue.X - Begin.X), EasingTime),
				EasingFunctions[EasingType](Elapsed, Begin.Y, (EndValue.Y - Begin.Y), EasingTime),
				EasingFunctions[EasingType](Elapsed, Begin.Z, (EndValue.Z - Begin.Z), EasingTime)
			)
			if Render then
				RunService.RenderStepped:wait()
			else
				RunService.Heartbeat:wait()
			end
		end

		Object[Property] = EndValue
	elseif PropertyType(Object, Property) == "ColorProperty" then
		local Begin = Object[Property]

		for Elapsed = 1, EasingTime do
			if Begin == EndValue then break end
			Object[Property] = Color3.new(
				(Begin.r ~= EndValue.r and EasingFunctions[EasingType](Elapsed, Begin.r, (EndValue.r - Begin.r), EasingTime)) or EndValue.r,
				(Begin.g ~= EndValue.g and EasingFunctions[EasingType](Elapsed, Begin.g, (EndValue.g - Begin.g), EasingTime)) or EndValue.g,
				(Begin.b ~= EndValue.b and EasingFunctions[EasingType](Elapsed, Begin.b, (EndValue.b - Begin.b), EasingTime)) or EndValue.b
			)
			if Render then
				RunService.RenderStepped:wait()
			else
				RunService.Heartbeat:wait()
			end
		end

		Object[Property] = EndValue
	else -- Integer support
		local Begin = Object[Property]

		for Elapsed = 1, EasingTime do
			if Begin == EndValue then break end
			Object[Property] = EasingFunctions[EasingType](Elapsed, Begin, (EndValue - Begin), EasingTime)
			if Render then
				RunService.RenderStepped:wait()
			else
				RunService.Heartbeat:wait()
			end
		end

		Object[Property] = EndValue
	end
end

function RBXAnimator:Tween(Object, Property, EndValue, EasingType, EasingTime)
	Tween(Object, Property, EndValue, EasingType, EasingTime, false)
end

function RBXAnimator:TweenAsync(Object, Property, EndValue, EasingType, EasingTime)
	spawn(function()
		Tween(Object, Property, EndValue, EasingType, EasingTime, false)
	end)
end

function RBXAnimator:TweenRender(Object, Property, EndValue, EasingType, EasingTime)
	Tween(Object, Property, EndValue, EasingType, EasingTime, true)
end

function RBXAnimator:TweenRenderAsync(Object, Property, EndValue, EasingType, EasingTime)
	spawn(function()
		Tween(Object, Property, EndValue, EasingType, EasingTime, true)
	end)
end

return RBXAnimator
