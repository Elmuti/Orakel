
	
	
	-- ~ Orakel ~
	
	--   File:            physLib.lua
	--   Author:          StealthKing95
	--   Description:     Library with many custom physics features
	
	--   Functions:
	-- 	Rope.new
	-- 	SpawnGibs






-- Rope Documentation

-- Construction:
-- Rope.New(Parent)
-- 	Makes a new Rope who's Parent is Parent. Parent defaults to Workspace

-- (Both Read and Write) Properties:
-- .Length Number
-- 	Length in studs of the Rope

-- .Thickness Number
-- 	Thickness in studs of the Rope

-- .Material String
-- 	Part Material of the Rope

-- .Transparency Number
-- 	Part Transparency of the Rope

-- .Reflectance Number
-- 	Part Reflectance of the Rope

-- .Parent Userdata
-- 	Parent of the Rope

-- .FrontPosition Vector3
-- 	The Position of the front end of the Rope

-- .EndPosition Vector3
-- 	The Position of the end end of the Rope

-- .FrontAnchored Bool
-- 	Whether the front end is anchored
	
-- .EndAnchored Bool
-- 	Whether the end end is anchored

-- .FrontAttach Userdata Part
-- 	The Part that the front end of the Rope is attached too

-- .EndAttach Userdata Part
-- 	The Part that the end end of the Rope is attached too

-- .FrontOffset Vector3
-- 	The offset applied relative to FrontAttach

-- .EndOffset Vector3
-- 	The offset applied relative to EndAttach


-- Methods:
-- :Remove()
-- 	Removes the Rope --I probably need to fix this to work completely.

-- :PositionAtLength(Length)
-- 	Returns the Position on the Rope at a specified length from the front


local lib = {}
local Rope = {}
local Orakel = require(game.ReplicatedStorage.Orakel.Main)
local mathLib = Orakel.LoadModule("MathLib")
local assetLib = Orakel.LoadModule("AssetLib")

do
	local cf=CFrame.new
	local v3=Vector3.new
	local RenderStepped=game:GetService("RunService").RenderStepped
	local garbagecollect=garbagecollect
	local setmetatable=setmetatable

	function Rope.new(Parent)
-- 		Naming convention:
-- 			CurrentPosition XElementOfVector Point0		cx0
-- 			LastPosition YElementOfVector Point4		ly4
			
-- 			<cx0,cy,cz0> is the vector of the current position of the
-- 			zeroth point of the string.
-- 			<lx8,ly8,lz8> is the vector of the last position of the
-- 			zeroth point of the string.
			
-- 			r2 is the (target radius between points)^2

-- 			Attach8 is the Part Point8 is attached to
-- 			Offset0 is the offset that is applied to the CFrame of the Attach0 Part.
			
-- 			Part1 is the part which connectes Point0 and Point1
-- 			Mesh5 is the mesh which defines the size of Part5

-- 			The rest is self explanatory

		local Attach0,Attach8
		local Offset0,Offset8=v3(),v3()
		local Length=8
		local Thickness=1
		local Material="Plastic"
		local Transparency=0
		local Reflectance=0

		local r2=1
		local Anchored0,Anchored8=true,false
		local Model=Instance.new("Model",Parent or game.Workspace)

		local cx0,cy0,cz0=0,0,0
		local lx0,ly0,lz0=0,0,0

		local cx1,cy1,cz1=1,0,0.1
		local lx1,ly1,lz1=1,0,0.1

		local cx2,cy2,cz2=2,-0.1,0
		local lx2,ly2,lz2=2,-0.1,0

		local cx3,cy3,cz3=3,0,-0.1
		local lx3,ly3,lz3=3,0,-0.1

		local cx4,cy4,cz4=4,0.1,0
		local lx4,ly4,lz4=4,0.1,0

		local cx5,cy5,cz5=5,0,0.1
		local lx5,ly5,lz5=5,0,0.1

		local cx6,cy6,cz6=6,-0.1,0
		local lx6,ly6,lz6=6,-0.1,0

		local cx7,cy7,cz7=7,0,-0.1
		local lx7,ly7,lz7=7,0,-0.1

		local cx8,cy8,cz8=8,0,0
		local lx8,ly8,lz8=8,0,0

		local Part1=Instance.new("Part",Model)
		local Mesh1=Instance.new("BlockMesh",Part1)
		Part1.Anchored=true
		Part1.CanCollide=false
		Part1.FormFactor="Custom"
		Part1.Size=v3(0.2,0.2,0.2)
		Part1.RightSurface="SmoothNoOutlines"
		Part1.LeftSurface="SmoothNoOutlines"
		Part1.TopSurface="SmoothNoOutlines"
		Part1.BottomSurface="SmoothNoOutlines"
		Part1.BackSurface="SmoothNoOutlines"
		Part1.FrontSurface="SmoothNoOutlines"

		local Part2=Part1:Clone()
		local Mesh2=Instance.new("BlockMesh",Part2)
		Part2.Parent=Model

		local Part3=Part1:Clone()
		local Mesh3=Instance.new("BlockMesh",Part3)
		Part3.Parent=Model

		local Part4=Part1:Clone()
		local Mesh4=Instance.new("BlockMesh",Part4)
		Part4.Parent=Model

		local Part5=Part1:Clone()
		local Mesh5=Instance.new("BlockMesh",Part5)
		Part5.Parent=Model

		local Part6=Part1:Clone()
		local Mesh6=Instance.new("BlockMesh",Part6)
		Part6.Parent=Model

		local Part7=Part1:Clone()
		local Mesh7=Instance.new("BlockMesh",Part7)
		Part7.Parent=Model

		local Part8=Part1:Clone()
		local Mesh8=Instance.new("BlockMesh",Part8)
		Part8.Parent=Model


		local function AttachUpdate()
			if Attach0 then
				local p=Attach0.CFrame*Offset0
				cx0,cy0,cz0=p.x,p.y,p.z
			end
			if Attach8 then
				local p=Attach8.CFrame*Offset8
				cx8,cy8,cz8=p.x,p.y,p.z
			end
		end

		local function PhysicsUpdate()
			local rx,ry,rz,lr,m,mx,my,mz--Relative x,y,z, l^2 over r^2 - 1, m is.. eh.
			if not Anchored0 then
				cx0,lx0=cx0*2-lx0,cx0
				cy0,ly0=cy0*2-ly0,cy0+0.0545--0.0545 is for ROBLOX gravity. 9.81*20/60^2
				cz0,lz0=cz0*2-lz0,cz0
			end
			cx1,lx1=cx1*2-lx1,cx1
			cy1,ly1=cy1*2-ly1,cy1+0.0545
			cz1,lz1=cz1*2-lz1,cz1

			cx2,lx2=cx2*2-lx2,cx2
			cy2,ly2=cy2*2-ly2,cy2+0.0545
			cz2,lz2=cz2*2-lz2,cz2

			cx3,lx3=cx3*2-lx3,cx3
			cy3,ly3=cy3*2-ly3,cy3+0.0545
			cz3,lz3=cz3*2-lz3,cz3

			cx4,lx4=cx4*2-lx4,cx4
			cy4,ly4=cy4*2-ly4,cy4+0.0545
			cz4,lz4=cz4*2-lz4,cz4

			cx5,lx5=cx5*2-lx5,cx5
			cy5,ly5=cy5*2-ly5,cy5+0.0545
			cz5,lz5=cz5*2-lz5,cz5

			cx6,lx6=cx6*2-lx6,cx6
			cy6,ly6=cy6*2-ly6,cy6+0.0545
			cz6,lz6=cz6*2-lz6,cz6

			cx7,lx7=cx7*2-lx7,cx7
			cy7,ly7=cy7*2-ly7,cy7+0.0545
			cz7,lz7=cz7*2-lz7,cz7

			if not Anchored8 then
				cx8,lx8=cx8*2-lx8,cx8
				cy8,ly8=cy8*2-ly8,cy8+0.0545
				cz8,lz8=cz8*2-lz8,cz8
			end
			--local asd=tick()
			for i=1,16 do
				local avg=0
				rx,ry,rz=cx1-cx0,cy1-cy0,cz1-cz0
				if Anchored0 then
					lr=(rx*rx+ry*ry+rz*rz)/r2-1
					avg,m=avg+lr*lr,lr/(lr*2+2)
					cx1,cy1,cz1=cx1-rx*m,cy1-ry*m,cz1-rz*m
				else
					lr=(rx*rx+ry*ry+rz*rz)/r2-1
					avg,m=avg+lr*lr,lr/(lr*4+4)
					mx,my,mz=rx*m,ry*m,rz*m
					cx0,cy0,cz0=cx0+mx,cy0+my,cz0+mz
					cx1,cy1,cz1=cx1-mx,cy1-my,cz1-mz
				end

				rx,ry,rz=cx3-cx2,cy3-cy2,cz3-cz2
				lr=(rx*rx+ry*ry+rz*rz)/r2-1
				avg,m=avg+lr*lr,lr/(lr*4+4)
				mx,my,mz=rx*m,ry*m,rz*m
				cx2,cy2,cz2=cx2+mx,cy2+my,cz2+mz
				cx3,cy3,cz3=cx3-mx,cy3-my,cz3-mz

				rx,ry,rz=cx5-cx4,cy5-cy4,cz5-cz4
				lr=(rx*rx+ry*ry+rz*rz)/r2-1
				avg,m=avg+lr*lr,lr/(lr*4+4)
				mx,my,mz=rx*m,ry*m,rz*m
				cx4,cy4,cz4=cx4+mx,cy4+my,cz4+mz
				cx5,cy5,cz5=cx5-mx,cy5-my,cz5-mz

				rx,ry,rz=cx7-cx6,cy7-cy6,cz7-cz6
				lr=(rx*rx+ry*ry+rz*rz)/r2-1
				avg,m=avg+lr*lr,lr/(lr*4+4)
				mx,my,mz=rx*m,ry*m,rz*m
				cx6,cy6,cz6=cx6+mx,cy6+my,cz6+mz
				cx7,cy7,cz7=cx7-mx,cy7-my,cz7-mz

				rx,ry,rz=cx2-cx1,cy2-cy1,cz2-cz1
				lr=(rx*rx+ry*ry+rz*rz)/r2-1
				avg,m=avg+lr*lr,lr/(lr*4+4)
				mx,my,mz=rx*m,ry*m,rz*m
				cx1,cy1,cz1=cx1+mx,cy1+my,cz1+mz
				cx2,cy2,cz2=cx2-mx,cy2-my,cz2-mz

				rx,ry,rz=cx4-cx3,cy4-cy3,cz4-cz3
				lr=(rx*rx+ry*ry+rz*rz)/r2-1
				avg,m=avg+lr*lr,lr/(lr*4+4)
				mx,my,mz=rx*m,ry*m,rz*m
				cx3,cy3,cz3=cx3+mx,cy3+my,cz3+mz
				cx4,cy4,cz4=cx4-mx,cy4-my,cz4-mz

				rx,ry,rz=cx6-cx5,cy6-cy5,cz6-cz5
				lr=(rx*rx+ry*ry+rz*rz)/r2-1
				avg,m=avg+lr*lr,lr/(lr*4+4)
				mx,my,mz=rx*m,ry*m,rz*m
				cx5,cy5,cz5=cx5+mx,cy5+my,cz5+mz
				cx6,cy6,cz6=cx6-mx,cy6-my,cz6-mz

				rx,ry,rz=cx8-cx7,cy8-cy7,cz8-cz7
				if Anchored8 then
					lr=(rx*rx+ry*ry+rz*rz)/r2-1
					avg,m=avg+lr*lr,lr/(lr*2+2)
					cx7,cy7,cz7=cx7+rx*m,cy7+ry*m,cz7+rz*m
				else
					lr=(rx*rx+ry*ry+rz*rz)/r2-1
					avg,m=avg+lr*lr,lr/(lr*4+4)
					mx,my,mz=rx*m,ry*m,rz*m
					cx7,cy7,cz7=cx7+mx,cy7+my,cz7+mz
					cx8,cy8,cz8=cx8-mx,cy8-my,cz8-mz
				end
				
				if avg/8<0.015625 then break end
			end
			--local asdf=tick()-asd--Actual bad names
			--print("Time to process physics: "..asdf)
		end

		local function DrawUpdate()
			--local asd=tick()
			local rx,ry,rz
			Part1.CFrame=cf(v3((cx0+cx1)/2,(cy0+cy1)/2,(cz0+cz1)/2),v3(cx1,cy1,cz1))
			Part2.CFrame=cf(v3((cx1+cx2)/2,(cy1+cy2)/2,(cz1+cz2)/2),v3(cx2,cy2,cz2))
			Part3.CFrame=cf(v3((cx2+cx3)/2,(cy2+cy3)/2,(cz2+cz3)/2),v3(cx3,cy3,cz3))
			Part4.CFrame=cf(v3((cx3+cx4)/2,(cy3+cy4)/2,(cz3+cz4)/2),v3(cx4,cy4,cz4))
			Part5.CFrame=cf(v3((cx4+cx5)/2,(cy4+cy5)/2,(cz4+cz5)/2),v3(cx5,cy5,cz5))
			Part6.CFrame=cf(v3((cx5+cx6)/2,(cy5+cy6)/2,(cz5+cz6)/2),v3(cx6,cy6,cz6))
			Part7.CFrame=cf(v3((cx6+cx7)/2,(cy6+cy7)/2,(cz6+cz7)/2),v3(cx7,cy7,cz7))
			Part8.CFrame=cf(v3((cx7+cx8)/2,(cy7+cy8)/2,(cz7+cz8)/2),v3(cx8,cy8,cz8))

			rx,ry,rz=cx1-cx0,cy1-cy0,cz1-cz0
			Mesh1.Scale=v3(Thickness,Thickness,5*(rx*rx+ry*ry+rz*rz)^0.5)

			rx,ry,rz=cx2-cx1,cy2-cy1,cz2-cz1
			Mesh2.Scale=v3(Thickness,Thickness,5*(rx*rx+ry*ry+rz*rz)^0.5)

			rx,ry,rz=cx3-cx2,cy3-cy2,cz3-cz2
			Mesh3.Scale=v3(Thickness,Thickness,5*(rx*rx+ry*ry+rz*rz)^0.5)

			rx,ry,rz=cx4-cx3,cy4-cy3,cz4-cz3
			Mesh4.Scale=v3(Thickness,Thickness,5*(rx*rx+ry*ry+rz*rz)^0.5)

			rx,ry,rz=cx5-cx4,cy5-cy4,cz5-cz4
			Mesh5.Scale=v3(Thickness,Thickness,5*(rx*rx+ry*ry+rz*rz)^0.5)
	
			rx,ry,rz=cx6-cx5,cy6-cy5,cz6-cz5
			Mesh6.Scale=v3(Thickness,Thickness,5*(rx*rx+ry*ry+rz*rz)^0.5)

			rx,ry,rz=cx7-cx6,cy7-cy6,cz7-cz6
			Mesh7.Scale=v3(Thickness,Thickness,5*(rx*rx+ry*ry+rz*rz)^0.5)

			rx,ry,rz=cx8-cx7,cy8-cy7,cz8-cz7
			Mesh8.Scale=v3(Thickness,Thickness,5*(rx*rx+ry*ry+rz*rz)^0.5)
			--local asdf=tick()-asd--Actual bad names
			--print("Time to process physics: "..asdf)
		end
		local RenderObject=RenderStepped:connect(function() AttachUpdate() PhysicsUpdate() DrawUpdate() end)

		return setmetatable({
			PositionAtLength=function(self,l)
				local d=l/Length*8
				if d<0 then
					return v3(cx0,cy0,cz0)
				elseif d<1 then
					local t=d-0
					return v3((cx1-cx0)*t+cx0,(cy1-cy0)*t+cy0,(cz1-cz0)*t+cz0)
				elseif d<2 then
					local t=d-1
					return v3((cx2-cx1)*t+cx1,(cy2-cy1)*t+cy1,(cz2-cz1)*t+cz1)
				elseif d<3 then
					local t=d-2
					return v3((cx3-cx2)*t+cx2,(cy3-cy2)*t+cy2,(cz3-cz2)*t+cz2)
				elseif d<4 then
					local t=d-3
					return v3((cx4-cx3)*t+cx3,(cy4-cy3)*t+cy3,(cz4-cz3)*t+cz3)
				elseif d<5 then
					local t=d-4
					return v3((cx5-cx4)*t+cx4,(cy5-cy4)*t+cy4,(cz5-cz4)*t+cz4)
				elseif d<6 then
					local t=d-5
					return v3((cx6-cx5)*t+cx5,(cy6-cy5)*t+cy5,(cz6-cz5)*t+cz5)
				elseif d<7 then
					local t=d-6
					return v3((cx7-cx6)*t+cx6,(cy7-cy6)*t+cy6,(cz7-cz6)*t+cz6)
				elseif d<8 then
					local t=d-7
					return v3((cx8-cx7)*t+cx7,(cy8-cy7)*t+cy7,(cz8-cz7)*t+cz7)
				else
					return v3(cx8,cy8,cz8)
				end
			end;

			Remove=function(self)
				Part1:Destroy()
				Part2:Destroy()
				Part3:Destroy()
				Part4:Destroy()
				Part5:Destroy()
				Part6:Destroy()
				Part7:Destroy()
				Part8:Destroy()
				RenderObject:disconnect()
				RenderObject=nil
				self.Remove=nil
				self.PositionAtLength=nil
				PositionUpdate=nil
				AttachUpdate=nil
				DrawUpdate=nil
				--What do I do about all of those variables I made? lol
				--Do I have to set each one to nil so that GC can delete the numbers?
				garbagecollect()
			end;
		},{
			__index=function(self,i)
				if i=="Length" then
					return Length
				elseif i=="Thickness" then
					return Thickness/5
				elseif i=="Material" then
					return Material
				elseif i=="Transparency" then
					return Transparency
				elseif i=="Reflectance" then
					return Reflectance
				elseif i=="Parent" then
					return Model.Parent
				elseif i=="FrontPosition" then
					return v3(cx0,cy0,cz0)
				elseif i=="EndPosition" then
					return v3(cx8,cy8,cz8)
				elseif i=="FrontAnchored" then
					return Anchored0
				elseif i=="EndAnchored" then
					return Anchored8
				elseif i=="FrontAttach" then
					return Attach0
				elseif i=="EndAttach" then
					return Attach8
				elseif i=="FrontOffset" then
					return Offset0
				elseif i=="EndOffset" then
					return Offset8
				else
					error(i.." is not a valid member of Rope")
				end
			end;

			__newindex=function(self,i,v)
				if i=="Length" then
					Length=v
					r2=v*v/64
				elseif i=="Thickness" then
					Thickness=v*5
				elseif i=="Parent" then
					Model.Parent=v
				elseif i=="Material" then
					Material=v
					Part1.Material=v
					Part2.Material=v
					Part3.Material=v
					Part4.Material=v
					Part5.Material=v
					Part6.Material=v
					Part7.Material=v
					Part8.Material=v
				elseif i=="Transparency" then
					Transparency=v
					Part1.Transparency=v
					Part2.Transparency=v
					Part3.Transparency=v
					Part4.Transparency=v
					Part5.Transparency=v
					Part6.Transparency=v
					Part7.Transparency=v
					Part8.Transparency=v
				elseif i=="Reflectance" then
					Reflectance=v
					Part1.Reflectance=v
					Part2.Reflectance=v
					Part3.Reflectance=v
					Part4.Reflectance=v
					Part5.Reflectance=v
					Part6.Reflectance=v
					Part7.Reflectance=v
					Part8.Reflectance=v
				elseif i=="FrontPosition" then
					cx0,cy0,cz0=v.x,v.y,v.z
					Attach0=nil
				elseif i=="EndPosition" then
					cx8,cy8,cz8=v.x,v.y,v.z
					Attach8=nil
				elseif i=="FrontAnchored" then
					Anchored0=v
					if not v then
						Attach0=nil
						Offset0=v3()
					end
				elseif i=="EndAnchored" then
					Anchored8=v
					if not v then
						Attach8=nil
						Offset8=v3()
					end
				elseif i=="FrontAttach" then
					Attach0=v
					if v then
						Anchored0=true
					else
						Offset0=v3()
					end
				elseif i=="EndAttach" then
					Attach8=v
					if v then
						Anchored8=true
					else
						Offset8=v3()
					end
				elseif i=="FrontOffset" then
					Offset0=v
				elseif i=="EndOffset" then
					Offset8=v
				else
					error(i.." is not a valid member of Rope")
				end
			end;
		})
	end
end




function lib.SpawnGibs(origin, realmat, realSize, texture)
	local maxgibs, fadetime
	if _G.breakablemaxgibs == nil then
		maxgibs = game.ReplicatedStorage.Events.GetServerVar:InvokeServer("sv_breakablemaxgibs")
	else
		maxgibs = _G.breakablemaxgibs
	end
	if _G.gibfadetime == nil then
		fadetime = game.ReplicatedStorage.Events.GetServerVar:InvokeServer("sv_gibfadetime")
	else
		fadetime = _G.gibfadetime
	end
	local gibs = math.random(math.ceil(maxgibs / 2), maxgibs)
	--print("spawning "..gibs.." "..realmat.." gibs with "..fadetime.." fade delay")
	for num = 1, gibs do
		local gib = game.ReplicatedStorage.Orakel.Models.Gibs["gib_"..realmat]:clone()
		
		if texture ~= nil then
			local sides = {
				Enum.NormalId.Top;
				Enum.NormalId.Bottom;
				Enum.NormalId.Back;
				Enum.NormalId.Front;
				Enum.NormalId.Right;
				Enum.NormalId.Left;
			}
			for side = 1, 6 do
				local nt = texture:clone()
				nt.Parent = gib
				nt.Face = sides[side]
			end
		end

		gib.Parent = workspace
		gib.CFrame = CFrame.new(Vector3.new(
			origin.x + (math.random(-realSize.x, realSize.x) / 2),
			origin.y + (math.random(-realSize.y, realSize.y) / 2),
			origin.z + (math.random(-realSize.z, realSize.z) / 2)
		))
		gib.Size = Vector3.new(
				realSize.x / math.random(3,6),
				realSize.y / math.random(3,6),
				realSize.z / math.random(3,6)
			)
		if gib.Mesh.MeshId ~= "" then
			gib.Mesh.Scale = Vector3.new(
				realSize.x / (math.random(3,6) / 2),
				realSize.y / (math.random(3,6) / 2),
				realSize.z / (math.random(3,6) / 2)
			)
		end
		gib.Rotation = Vector3.new(math.random(1,100),math.random(1,100),math.random(1,100))
		gib.Anchored = true
		gib.CanCollide = true
		gib.Velocity = Vector3.new(
			math.random(-35, 35),
			math.random(-35, 35),
			math.random(-35, 35)
		)
		gib.Anchored = false
		game.Debris:AddItem(gib, fadetime)
	end
end



function lib.Explosion(position, isVisual, damageMult, maxRadius, killRadius)
	local map = Orakel.GetMap()
	local ex = Instance.new("Explosion", workspace)
	ex.BlastRadius = maxRadius
	ex.Position = position
	ex.BlastPressure = 0
	for _, player in pairs(game.Players:GetPlayers()) do
	    if player.Character ~= nil then
	        if player.Character:findFirstChild("Torso") then
	            local dist = (player.Character.Torso.Position - position).magnitude
	            if not (dist >= maxRadius) then
	                local mult = ((maxRadius - killRadius) / 100)
	                local dmg = (maxRadius - dist) / mult
	                dmg = mathLib.Round(dmg * damageMult)
        					local npcLib = Orakel.LoadModule("NpcLib")
        				  npcLib.DealDamage(player.Character.Humanoid, dmg, "BLAST")
	            end
	        end
	    end
	end
	
--	for _, ent in pairs(map.Entities:children()) do
--		if ent.Name == "func_breakable" then
--			local dist = (ent.Position - position).magnitude
--			if not (dist >= maxRadius) then
--				local a, b, c = ent.Position, assetLib.RealMaterial:Get(ent), ent.Size
--				ent:Destroy()
--				local tex = ent:FindFirstChild("Texture")
--				lib.SpawnGibs(a, b, c, tex)
--			end
--		end
--	end
end



lib.Rope = Rope
return lib