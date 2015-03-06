local lib = {}

local function NewInstance(class,properties)
	local instance = Instance.new(class)
	if properties then
		for prop,val in pairs (properties) do
			instance[prop] = val
		end
	end
	return instance
end



function lib.ScaleCharacter(scale, parent)
	local scale = scale or 1
	local parent = parent or workspace
	local Model = Instance.new('Model',parent)
		do
			NewInstance('Part',{
				Name = "HumanoidRootPart";
				FormFactor = "Custom";
				Anchored = false;
				CanCollide = false;
				Transparency = 1;
				Size = Vector3.new(2*scale, 2*scale, 1*scale);
				Parent = Model;
				BottomSurface = "Smooth";
				TopSurface = "Smooth";
			})	
			NewInstance('Part',{
				Name = "Torso";
				Material = "SmoothPlastic";
				FormFactor = "Custom";
				Anchored = false;
				CanCollide = true;
				Size = Vector3.new(2*scale, 2*scale, 1*scale);
				Parent = Model;
				BottomSurface = "Smooth";
				TopSurface = "Smooth";
			})
			NewInstance('Part',{
				Name = "Left Leg";
				Material = "SmoothPlastic";
				FormFactor = "Custom";
				Anchored = false;
				CanCollide = false;
				Size = Vector3.new(1*scale, 2*scale, 1*scale);
				Parent = Model;
				BottomSurface = "Smooth";
				TopSurface = "Smooth";
			})
			NewInstance('Part',{
				Name = "Right Leg";
				Material = "SmoothPlastic";
				FormFactor = "Custom";
				Anchored = false;
				CanCollide = false;
				Size = Vector3.new(1*scale, 2*scale, 1*scale);
				Parent = Model;
				BottomSurface = "Smooth";
				TopSurface = "Smooth";
			})
			NewInstance('Part',{
				Name = "Left Arm";
				Material = "SmoothPlastic";
				FormFactor = "Custom";
				Anchored = false;
				CanCollide = false;
				Size = Vector3.new(1*scale, 2*scale, 1*scale);
				Parent = Model;
				BottomSurface = "Smooth";
				TopSurface = "Smooth";
			})
			NewInstance('Part',{
				Name = "Right Arm";
				Material = "SmoothPlastic";
				FormFactor = "Custom";
				Anchored = false;
				CanCollide = false;
				Size = Vector3.new(1*scale, 2*scale, 1*scale);
				Parent = Model;
				BottomSurface = "Smooth";
				TopSurface = "Smooth";
			})
			NewInstance('Part',{
				Name = "Head";
				Material = "SmoothPlastic";
				FormFactor = "Custom";
				Anchored = false;
				CanCollide = false;
				Size = Vector3.new(2*scale, 1*scale, 1*scale);
				Parent = Model;
				BottomSurface = "Smooth";
				TopSurface = "Smooth";		
			})
			
			Instance.new("Humanoid",Model)
			Instance.new('BodyColors',Model)
			
			NewInstance('Decal',{
				Parent = Model.Head;
				Name = "face";
				Texture = "rbxasset://textures/face.png";
			})
			NewInstance('SpecialMesh',{
				Parent = Model.Head;
				Scale = Vector3.new(1.25,1.25,1.25);
				Name = "Mesh"
			})
		
			NewInstance('Motor6D',{
				Part0 = Model.HumanoidRootPart;
				Part1 = Model.Torso;
				C0 = CFrame.new(0,0,0,-1,0,0,0,0,1,0,1,0);
				C1 = CFrame.new(0,0,0,-1,0,0,0,0,1,0,1,0);
				Parent = Model.HumanoidRootPart;
				Name = "Root Hip",
				MaxVelocity = .1
			})
			NewInstance('Motor6D',{
				Part0 = Model.Torso;
				Part1 = Model['Left Leg'];
				C0 = CFrame.new(-1*scale,-1*scale,0)*CFrame.fromAxisAngle(Vector3.new(0,1,0),-math.pi/2);
				C1 = CFrame.new(-0.5*scale,1*scale,0)*CFrame.fromAxisAngle(Vector3.new(0,1,0),-math.pi/2);
				Parent = Model.Torso;
				Name = "Left Hip",
				MaxVelocity = .1
			})
			NewInstance('Motor6D',{
				Part0 = Model.Torso;
				Part1 = Model['Right Leg'];
				C0 = CFrame.new(1*scale,-1*scale,0)*CFrame.fromAxisAngle(Vector3.new(0,-1,0),-math.pi/2);
				C1 = CFrame.new(0.5*scale,1*scale,0)*CFrame.fromAxisAngle(Vector3.new(0,1,0),math.pi/2);
				Parent = Model.Torso;
				Name = "Right Hip",
				MaxVelocity = .1
			})
			NewInstance('Motor6D',{
				Part0 = Model.Torso;
				Part1 = Model['Left Arm'];
				C0 = CFrame.new(-1.0*scale,0.5*scale,0)*CFrame.fromAxisAngle(Vector3.new(0,1,0),-math.pi/2);
				C1 = CFrame.new(0.5*scale,0.5*scale,0)*CFrame.fromAxisAngle(Vector3.new(0,1,0),-math.pi/2);
				Parent = Model.Torso;
				Name = "Left Shoulder",
				MaxVelocity = .1
			})
			NewInstance('Motor6D',{
				Part0 = Model.Torso;
				Part1 = Model['Right Arm'];
				C0 = CFrame.new(1.0*scale,0.5*scale,0)*CFrame.fromAxisAngle(Vector3.new(0,-1,0),-math.pi/2);
				C1 = CFrame.new(-0.5*scale,0.5*scale,0)*CFrame.fromAxisAngle(Vector3.new(0,1,0),math.pi/2);
				Parent = Model.Torso;
				Name = "Right Shoulder",
				MaxVelocity = .1
			})
			NewInstance('Motor6D',{
				Part0 = Model.Torso;
				Part1 = Model.Head;
				C0 = CFrame.new(0,1*scale,0,-1,0,0,0,0,1,0,1,0);
				C1 = CFrame.new(0,-0.5*scale,0,-1,0,0,0,0,1,0,1,0);
				Parent = Model.Torso;
				Name = "Neck",
				MaxVelocity = .1
			})
		end
	Model.PrimaryPart = Model.Torso
	Model.Name = "x"..scale.." scale character"
	
	return Model
end

return lib