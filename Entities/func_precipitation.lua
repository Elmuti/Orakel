local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local Entity = {}


Entity.Type = "Brush"
Entity.EditorTexture = "http://www.roblox.com/asset/?id=221530480"

local plr = game.Players.LocalPlayer
local char = plr.Character
local pgui = plr.PlayerGui
local mouse = plr:GetMouse();

-- For mild efficiency gains, these are defined without
-- their indexing (.) and as locals:
local mathrandom = math.random;
local pi = math.pi
local CFramenew = CFrame.new;
local Vector3new = Vector3.new;
local mathcos, mathsin = math.cos, math.sin;
local Raynew = Ray.new;
local FindPartOnRay = workspace.FindPartOnRay;

-- Generates a vector *roughly* evenly distributed
-- with a magnitude between low and high.
function randring(low, high)
	local t = mathrandom() * pi * 2;
	local r = mathrandom() * (high-low) + low;
	return mathcos(t) * r, 0, mathsin(t) * r;
end

-- The SurfaceGui for falling raindrops
local decal = Instance.new("SurfaceGui");
decal.CanvasSize = Vector2.new(200, 200);
decal.Name = "DropSurface";

-- The label that appears as a raindrop.
local labelBase = Instance.new("ImageLabel");
labelBase.BackgroundTransparency = 1;
labelBase.ImageColor3 = Color3.new(121/255,121/255,121/255);
labelBase.Size = UDim2.new(0, 5, 0, 100);
labelBase.ImageTransparency = 0.75;
labelBase.Image = "rbxassetid://221405600";

-- The model the rain parts are stored in
if workspace:FindFirstChild("Rain Home") then
	workspace["Rain Home"]:Destroy();
end
local home = Instance.new("Model", workspace);
home.Name = "Rain Home";

-- A list of all falling raindrops
local drops = {};

-- A "quality" setting. Anything outside of the range
-- (0.5, 2) looks terribad.
local quality = 1;

-- The height to spawn rain at. (See use of this variable
-- to change spawning)
-- Rain falls to y fallTo at most
local fallTo = 0;
local height = 150;



-- Clear / recreate the model that the splashes are stored in.
if workspace:FindFirstChild("precipitationCache", true) then
	workspace["precipitationCache"]:Destroy();
end
local home = Instance.new("Model", workspace);
home.Name = "precipitationCache";

-- List of all active splashes.
local splashes = {};

-- This is the prototype from which all splashes come
local splashBase = Instance.new("Part");
splashBase.Transparency = 1;
splashBase.Anchored = true;
splashBase.CanCollide = false;
splashBase.FormFactor = "Custom";
local surface = Instance.new("SurfaceGui");
surface.CanvasSize = Vector2.new(200, 200);
surface.Face = "Top";
surface.Parent = splashBase;
surface.Name = "DropleSurface";
local image = Instance.new("ImageLabel", surface);
image.Position = UDim2.new(0, 0, 0, 0);
image.Size = UDim2.new(1, 0, 1, 0);
image.BackgroundTransparency = 1;
image.Image = "rbxassetid://221657524";
image.ImageColor3 = Color3.new(121/255, 121/255, 121/255);
image.ImageTransparency = 0.75;
image.Name = "SplashImage";




local function drople(position)
	-- Creating all of them is a bit expensive, so we throw out some.
	if math.random() < 0.25 then
		return;
	end
	
	-- Insert the part into the world
	local p = splashBase:Clone();
	p.Parent = home;
	
	-- Compute a random rotation
	local angle = math.random() * math.pi * 2;
	
	-- Save all of the important information:
	-- part, start time, position, label, random angle
	table.insert(splashes,
		{part = p, start = tick(), position = position, label = p.DropleSurface.SplashImage,
			angle = angle}
	);
end



-- Update all splashes
function splashUpdate()
	while true do
    if not ent.Enabled.Value then
       break
    end
		if not Entity.Status then
			break
		end
		-- Update all splashes (listed in "splashes")
		
		-- For mild efficiency reasons:
		local CFramenew, Vector3new = CFrame.new, Vector3.new;
		
		-- Update as often as possible:
		game:GetService("RunService").RenderStepped:wait();
		
		-- Consider all splashes. Strange for loop allows table.remove to
		-- be called simply without having the problems of the naive for
		-- loop.
		for index = #splashes, 1, -1 do
			local splash = splashes[index];
			-- Determine current time in effect:
			local t = (tick() - splash.start) * 3;
			if t > 1 then
				-- Splash is gone. Destroy it and remove it from the list.
				splash.part:Destroy();
				table.remove(splashes, index);
			else
				-- Splash is not gone.
				-- Update its transparency, size, and position as functions of time.
				splash.label.ImageTransparency = t;
				local jump = t - t*t;
				splash.part.Size = Vector3new(2/3+t,0.2,2/3+t);
				splash.part.CFrame = CFramenew(
					splash.position+Vector3new(0, jump*2, 0)) * CFrame.Angles(0, splash.angle, 0
				);
			end
		end
	end
end


function rainUpdate(ent)
	while true do
	  if not ent.Enabled.Value then
	     break
	  end
		if not Entity.Status then
			break
		end
		-- Update as quickly as possible:
		game["Run Service"].RenderStepped:wait();
		
		-- Create new drops progressively (so as to avoid
		-- the performance problems from creating 720 parts
		-- at one moment)
		for k = 1, 10 do
			if #drops < 720 * quality then
				local part = Instance.new("Part", home);
				part.CanCollide = false;
				part.Transparency = 0.5;
				part.Anchored = true;
				part.FormFactor = "Custom";
				part.Transparency = 1;
				local d = decal:Clone();
				d.Parent = part;
				local close, far, amt, size = 0, 75, 3, 8;
				if math.random(1, 3) == 1 then
					close, far, amt, size = 75, 200, 9, 24;
				end
				part.Size = Vector3new(size / quality, size / quality, 0.2);
				d.CanvasSize = Vector2.new(200,200) / quality;
				for i = 1, amt / quality do
					local label = labelBase:Clone();
					label.Position = UDim2.new(0, mathrandom() * 195, 0, mathrandom() * 100);
					label.Parent = d;
				end
				table.insert(drops,
					{
						part=part,
						x=0,y=math.random(),z=0,
						stop = -1,
						close = close,
						far = far,
						labels = part.DropSurface:GetChildren()
					});
			end
		end
		
		-- Get variables about camera we will need repeatedly
		-- to avoid calculating them in the body of the loop.
		local camera = workspace.CurrentCamera.CoordinateFrame;
		local look = camera.lookVector;
		local camerap = workspace.CurrentCamera.CoordinateFrame.p;
		
		-- These would be useful for culling, but are unused.
		-- local verticalEdge = math.cos(math.rad(workspace.CurrentCamera.FieldOfView)/2) * 1.5;
		-- local horizontalEdge = verticalEdge * mouse.ViewSizeX / mouse.ViewSizeY;
		
		-- Update all falling drops:
		for _, drop in pairs(drops) do
			-- Get the necessary properties of the drop:
			local part, x,y,z = drop.part, drop.x, drop.y, drop.z;
			-- Make the position of the drop:
			local v = Vector3new(x,y,z);
			local fwd = camera:pointToObjectSpace(v);
			
			-- Visible is whether or not the rain drop is "visible" (in the
			-- direction the player is facing)
			-- Used to cull expensive effects (like editing all drops' transparency)
			local visible = fwd.z < 0;
			
			-- The raindrop has hit the ground
			if y < drop.stop - 5 then
				
				-- Request a splash be made (only when in view)
				if visible then
					drople(Vector3new(x, drop.stop, z));
				end
				
				-- Compute a new place to fall from
				drop.x, _, drop.z = randring(drop.close, drop.far);
				drop.x, drop.z = drop.x + camerap.x, drop.z + camerap.z;
				drop.y = height;
				local position = Vector3new(drop.x, drop.y, drop.z);
				part.CFrame = CFramenew(position, Vector3new(camerap.x, y, camerap.z));
				
				-- Determine how far it should fall using FindPartOnRay.
				local ray = Raynew( position, Vector3new(0, -height - fallTo, 0));
				local any, hit = FindPartOnRay(workspace, ray, home, true);
				if any then
					drop.stop = hit.y;
				else
					drop.stop = fallTo;
				end
			else
				-- Fall 2 studs per frame (120 studs / second)
				drop.y = y - 2;
				
				-- Cull this effect when not visible:
				if visible then
					-- Fade in when appearing from sky.
					if y > height - 50 then
						for _, child in pairs(drop.labels) do
							child.ImageTransparency = (y - height + 50) * .25 / (50) + .75;
						end
					end
				end
				
				-- Position the part at its proper location, facing the camera
				part.CFrame = CFramenew(v, Vector3new(camerap.x, y, camerap.z));
			end
		end
	end
end



Entity.KeyValues = {
  ["EntityName"] = "";
  ["Enabled"] = true;
  ["Droplets"] = true;
  ["Intensity"] = 1;
  ["RainColor"] = Color3.new(121/255, 121/255, 121/255);
  ["RainType"] = "Rain";
}


Entity.Inputs = {
  ["Toggle"] = function(ent)
    ent.Enabled.Value = not ent.Enabled.Value
    if ent.Enabled.Value then
      fallTo = ent.Position.y - (ent.Size.y  / 2)
      height = ent.Position.y + (ent.Size.y  / 2)
      quality = ent.Intensity.Value
      spawn(function() 
        rainUpdate(ent) 
      end)
      spawn(function() 
        splashUpdate(ent) 
      end)
    end
  end;
}




Entity.Update = function(ent)
end


Entity.Kill = function()
	Entity.Status = false
end



return Entity