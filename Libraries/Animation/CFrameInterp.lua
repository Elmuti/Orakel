-- Optimized CFrame interpolator module ~ by Stravant
-- Based off of code by Treyreynolds posted on the Roblox Developer Forum

local fromAxisAngle = CFrame.fromAxisAngle
local components = CFrame.new().components
local inverse = CFrame.new().inverse
local v3 = Vector3.new
local acos = math.acos
local sqrt = math.sqrt
local invroot2 = 1/math.sqrt(2)

return function(c0, c1) -- (CFrame from, CFrame to) -> (float theta, (float fraction -> CFrame between))
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
	if cosTheta == 0 then
		-- Case exact same rotation, just interpolator over the position
		return 0, function(t)
			return c0 + positionDelta*t
		end	
	elseif cosTheta >= 0.999 then
		-- Case very similar rotations, just lineraly interpolate, as it is a good 
		-- approximation. At this small angle we can't reliably find a rotation axis
		-- for some values even if the rotation matrix would still be accurate.
		local startPos = c0.p
		local _, _, _, xx0, yx0, zx0, 
	                   xy0, yy0, zy0, 
	                   xz0, yz0, zz0 = components(c0)
		local _, _, _, xx1, yx1, zx1, 
	                   xy1, yy1, zy1, 
	                   xz1, yz1, zz1 = components(c1)
		return acos(cosTheta), function(t)
			local a = 1 - t
			return CFrame.new(0, 0, 0, xx0*a+xx1*t, yx0*a+yx1*t, zx0*a+zx1*t,
			                           xy0*a+xy1*t, yy0*a+yy1*t, zy0*a+zy1*t,
			                           xz0*a+xz1*t, yz0*a+yz1*t, zz0*a+zz1*t) + 
			       (startPos + positionDelta*t)
		end
	elseif cosTheta <= -0.9999 then
		-- Case exactly opposite rotations, disambiguate
		theta = math.pi
		xx = (xx + 1) / 2
		yy = (yy + 1) / 2
		zz = (zz + 1) / 2
		if xx > yy and xx > zz then
			if xx < 0.0001 then
				rotationAxis = v3(0, invroot2, invroot2)
			else
				local x = sqrt(xx)
				xy = (xy + yx) / 4
				xz = (xz + zx) / 4
				rotationAxis = v3(x, xy/x, xz/x)
			end
		elseif yy > zz then
			if yy < 0.0001 then
				rotationAxis = v3(invroot2, 0, invroot2)
			else
				local y = sqrt(yy)
				xy = (xy + yx) / 4
				yz = (yz + zy) / 4
				rotationAxis = v3(xy/y, y, yz/y)
			end	
		else
			if zz < 0.0001 then
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
	return theta, function(t)
		return c0*fromAxisAngle(rotationAxis, theta*t) + positionDelta*t
	end
end