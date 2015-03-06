color = {};

function color:__From(r, g, b)
	r = self:Limit(r);
	g = self:Limit(g);
	b = self:Limit(b);
	return Color3.new(r / 255, g / 255, b / 255);
end

function color:Limit(v, max)
	max = max or 255;
	return (v < 0 and 0 or (v > max and max) or v);
end

function color:Get(col3)
	return col3.r * 255, col3.g * 255, col3.b * 255;
end

function color:ToHex(col3, hash)
	hash = hash or false;
	local r,g,b = self:Get(col3);
	return string.format(hash and "#%.2X%.2X%.2X" or "%.2X%.2X%.2X", r,g,b);
end

function color:Tween(c0, c1, t0)
	local curValue = c0
	local steps = t0 * 60
	
	
	for step = 1, steps do
		c0.r = c0.r - (curValue.r - c1.r) / steps
		c0.g = c0.g - (curValue.g - c1.g) / steps
		c0.b = c0.b - (curValue.b - c1.b) / steps
		game:GetService("RunService").RenderStepped:wait()
	end

	
	
	
end





function color:FromBrickColor(col)
	if (type(col) == 'string') then
		return BrickColor.new(col).Color;
	elseif (type(col) == 'userdata') then
		return col.Color;
	end
end

function color:FromColor(col, int)
	return self:From(col.r * 255, col.g * 255, col.b * 255, int);
end

function color:From(red,grn,blu,int)
	local _int = (int and self:Limit(int, 100) or 100) / 100;
	local r,g,b = self:Get(self:__From(red,grn,blu));
	
	return self:__From(r * _int, g * _int, b * _int);
end

function color:Tone(amt)
	amt = self:Limit(amt);
	return self:__From(amt, amt, amt);
end

function color:FromHex(hex, int)
	local hex_str = "^#?([a-fA-F0-9]+)$";
	local match = hex:match(hex_str);

	if (match and match:len() == 6) then
		local results = {};
		for sub in match:gmatch("[a-fA-F0-9][a-fA-F0-9]") do
			table.insert(results,  tonumber('0x' .. sub) or 0);
		end
		
		table.insert(results, int);
		
		return self:From(unpack(results));
	elseif (match and match:len() == 3) then
		local results = {};
		for sub in match:gmatch("[a-fA-F0-9]") do
			table.insert(results,  tonumber('0x' .. sub .. sub) or 0);
		end
		
		table.insert(results, int);
		
		return self:From(unpack(results));		
	else
		error("Invalid Hexidecimal supplied 0x" .. hex);
	end
end

function color:Between(col0, col1, int)
	int = self:Limit(int, 100); -- 0 - 100 (percentage)
	
	local r0,g0,b0 = self:Get(col0);
	local r1,g1,b1 = self:Get(col1);

	local r2d = r1 + (r1 - r0) * (int/100 - 1);
	local g2d = g1 + (g1 - g0) * (int/100 - 1);
	local b2d = b1 + (b1 - b0) * (int/100 - 1);

	return self:From(r2d, g2d, b2d);
end

function color:ExtendColor3()
	_Color3 = Color3;
	local env = setmetatable({},{
		__index = (function(self, i)
			if (color[i] ~= nil) then
				return rawget(color, i);
			else
				return rawget(_Color3, i);
			end
		end); --Color3
	});
	getfenv(0)['Color3'] = env;
end


color.White = Color3.new(1,1,1);
color.Black = Color3.new(0,0,0);
color.Red = Color3.new(1,0,0);
color.Green = Color3.new(0,1,0);
color.Blue = Color3.new(0,0,1);
color.Cyan = Color3.new(0,1,1);
color.Pink = Color3.new(1,0,1);
color.Yellow = Color3.new(1,1,0);
color.Orange = Color3.new(1, 0.75, 0);

return color;