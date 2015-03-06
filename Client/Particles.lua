local experimentalParticlesEnabled = false

local player = game.Players.LocalPlayer
local char = player.CharacterAdded:wait()
local torso = char:WaitForChild("Torso")
local cam = workspace.CurrentCamera
local head = char:WaitForChild("Head")
local events = game.ReplicatedStorage
local maxParticleDist = 200
local minParticleDist = 40
local map

repeat wait() until _G.entityignore ~= nil
local Orakel = require(events.Orakel.Main)

warn(Orakel.Configuration.PrintHeader.."Loading particle system dependencies")

local alib = Orakel.LoadModule("AssetLib")
local plib = Orakel.LoadModule("ParticleLib")
local nlib = Orakel.LoadModule("NpcLib")

warn(Orakel.Configuration.PrintHeader.."Particle system dependencies loaded")
Orakel.PrintStatus(script:GetFullName())

function updateParticles()
	warn(Orakel.Configuration.PrintHeader.."Updating particle emitters")
	map = Orakel.GetMap()
	if map ~= nil then
		local ents = map.Entities
		for _, e in pairs(ents:GetChildren()) do
			if e.Name == "env_spark" then
				coroutine.resume(coroutine.create(function()
					while true do
						if map == nil then
							break
						end
						local interval = math.random(e.MinInterval.Value, e.MaxInterval.Value)
						wait(interval)
						local los = nlib.LineOfSight(cam.CoordinateFrame.p, e, 75, _G.entityignore)
						local dist = (e.Position - cam.CoordinateFrame.p).magnitude
						if dist <= maxParticleDist then
							if los then
								local snd = Instance.new("Sound", e)
								snd.SoundId = alib.Sounds.Spark[math.random(1,#alib.Sounds.Spark)]
								snd.Pitch = math.random(0.9,1.1)
								snd.Volume = 1 * _G.volume
								snd:Play()
								game.Debris:AddItem(snd, 5)
								coroutine.resume(coroutine.create(function()
									plib.CreateSparks(e, e.MinAmount.Value, e.MaxAmount.Value, e.VelocityModifier.Value,e.VelocityModifierY.Value, e.Life.Value)
								end))
							else
								if dist <= minParticleDist then
									local snd = Instance.new("Sound", e)
									snd.SoundId = alib.Sounds.Spark[math.random(1,#alib.Sounds.Spark)]
									snd.Pitch = math.random(0.9,1.1)
									snd.Volume = 1 * _G.volume
									snd:Play()
									game.Debris:AddItem(snd, 5)
									coroutine.resume(coroutine.create(function()
										plib.CreateSparks(e, e.MinAmount.Value, e.MaxAmount.Value, e.VelocityModifier.Value,e.VelocityModifierY.Value, e.Life.Value)
									end))
								end
							end
						end
					end
				end))
			elseif e.Name == "env_fire" then
				if experimentalParticlesEnabled then
					coroutine.resume(coroutine.create(function()
						while true do
							local los = nlib.LineOfSight(cam.CoordinateFrame.p, e, 75, _G.entityignore)
							local dist = (e.Position - cam.CoordinateFrame.p).magnitude
							if dist <= maxParticleDist then
								if los then
									--emit particles
									if e.Enabled.Value then
										plib.CreateFire(e, e.FireSize.Value)
										break
									end
								else
									if dist <= minParticleDist then
										--emit particles
										if e.Enabled.Value then
											plib.CreateFire(e, e.FireSize.Value)
											break
										end
									end
								end
							end
							wait(.25)
						end
					end))
				else
					if e:FindFirstChild("Enabled") then
						if e.Enabled.Value then
							local f = Instance.new("Fire", e)
							f.Heat = e.FireSize.Value * 2
							f.Size = e.FireSize.Value
						end
					end
				end
			elseif e.Name == "env_smoke" then
				if experimentalParticlesEnabled then
					coroutine.resume(coroutine.create(function()
						while true do
							local los = nlib.LineOfSight(cam.CoordinateFrame.p, e, 75, _G.entityignore)
							local dist = (e.Position - cam.CoordinateFrame.p).magnitude
							if dist <= maxParticleDist then
								if los then
									--emit particles
									if e.Enabled.Value then
										plib.CreateSmoke(e, e.SmokeSize.Value, e.RiseVelocity.Value, e.SmokeColor.Value, e.SmokeTransparency.Value, e.Life.Value)
										break
									end
								else
									if dist <= minParticleDist then
										--emit particles
										if e.Enabled.Value then
											plib.CreateSmoke(e, e.SmokeSize.Value, e.RiseVelocity.Value, e.SmokeColor.Value, e.SmokeTransparency.Value, e.Life.Value)
											break
										end
									end
								end
							end
							wait(.25)
						end
					end))
				else
					if e.Enabled.Value then
						local sm = Instance.new("Smoke", e)
						sm.RiseVelocity = e.RiseVelocity.Value
						sm.Size = e.SmokeSize.Value
						sm.Color = e.SmokeColor.Value
						sm.Opacity = e.SmokeTransparency.Value
					end
				end
			end
		end
	end
end

wait(2)
updateParticles()

events.Events.MapChange.OnClientEvent:connect(updateParticles)


