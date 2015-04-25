local eng = {}
eng.Sounds = {}
eng.Player = {}


	
	-- private sounds
	
	
	-- Another Dimension   http://www.roblox.com/asset/?id=179830750
	-- HingeCreak1   http://www.roblox.com/asset/?id=177721424
	-- HingeCreak2   http://www.roblox.com/asset/?id=177721486
	-- BabyWhine   http://www.roblox.com/asset/?id=177616514
	-- AS   http://www.roblox.com/asset/?id=
	-- AS   http://www.roblox.com/asset/?id=
	-- AS   http://www.roblox.com/asset/?id=
	-- AS   http://www.roblox.com/asset/?id=
	-- AS   http://www.roblox.com/asset/?id=
	-- AS   http://www.roblox.com/asset/?id=
	-- AS   http://www.roblox.com/asset/?id=
	-- AS   http://www.roblox.com/asset/?id=
	-- AS   http://www.roblox.com/asset/?id=








eng.Textures = {
	["wall_brick_white"] = "http://www.roblox.com/asset/?id=185546217";
	["floor_metal_tile"] = "http://www.roblox.com/asset/?id=172192490";
	["wall_metal_grate"] = "http://www.roblox.com/asset/?id=172192540";
	["wall_scifi_metal"] = "http://www.roblox.com/asset/?id=172192560";
	["ceil_plaster_tile"] = "http://www.roblox.com/asset/?id=172192511";
	["door_scp_left"] = "http://www.roblox.com/asset/?id=128743810";
	["door_scp_right"] = "http://www.roblox.com/asset/?id=128743798";	
}


eng.Spritesheets = {
	["test"] = {size=64, tiles=16, id="http://www.roblox.com/asset/?id=184681878"},
	["fire"] = {size=64, tiles=16, id="http://www.roblox.com/asset/?id=184681880"},
	["smoke"] = {size=128, tiles=2, id="http://www.roblox.com/asset/?id=184681886"},
	["blood"] = {size=64, tiles=3, id="http://www.roblox.com/asset/?id=184681875"}
}

eng.Smokesprites = {
	"http://www.roblox.com/asset/?id=185041571",
	"http://www.roblox.com/asset/?id=185041566",
	"http://www.roblox.com/asset/?id=185041565",
	"http://www.roblox.com/asset/?id=185041562",
	"http://www.roblox.com/asset/?id=185041549"
}

eng.Gibs = {
	["concrete"] = game.ReplicatedStorage.Orakel.Models.Gibs.gib_concrete,
	["metal"] = game.ReplicatedStorage.Orakel.Models.Gibs.gib_metal,
	["wood"] = game.ReplicatedStorage.Orakel.Models.Gibs.gib_wood,
	["glass"] = game.ReplicatedStorage.Orakel.Models.Gibs.gib_glass,
	["dirt"] = game.ReplicatedStorage.Orakel.Models.Gibs.gib_dirt,
	["tile"] = game.ReplicatedStorage.Orakel.Models.Gibs.gib_tile,
	["flesh"] = game.ReplicatedStorage.Orakel.Models.Gibs.gib_flesh,
	["snow"] = game.ReplicatedStorage.Orakel.Models.Gibs.gib_snow,
	["fabric"] = game.ReplicatedStorage.Orakel.Models.Gibs.gib_fabric,
	["grass"] = game.ReplicatedStorage.Orakel.Models.Gibs.gib_grass
}

eng.ParticleGibs = {
  


}


eng.Particles = {
  ["dustmote_burn"] = "http://www.roblox.com/asset/?id=241751503";
  ["dustmote"] = "http://www.roblox.com/asset/?id=241559211";
}

eng.Bloodsplatter = {
	"http://www.roblox.com/asset/?id=156459226",
	"http://www.roblox.com/asset/?id=156458157",
	"http://www.roblox.com/asset/?id=156458161"
}

eng.Decals = {
	["concrete"] = {
		"http://www.roblox.com/asset/?id=141998923",
		"http://www.roblox.com/asset/?id=141998929",
		"http://www.roblox.com/asset/?id=141998897",
		"http://www.roblox.com/asset/?id=141998951",
		"http://www.roblox.com/asset/?id=141998944"
	},
	["metal"] = {
		"http://www.roblox.com/asset/?id=141998965",
		"http://www.roblox.com/asset/?id=141998976"
	},
	["wood"] = {
		"http://www.roblox.com/asset/?id=142007332",
		"http://www.roblox.com/asset/?id=142007318",
		"http://www.roblox.com/asset/?id=142007304",
		"http://www.roblox.com/asset/?id=142007287",
		"http://www.roblox.com/asset/?id=142007267"
	},
	["glass"] = {
		"http://www.roblox.com/asset/?id=142081271",
		"http://www.roblox.com/asset/?id=142081276",
		"http://www.roblox.com/asset/?id=142081279"
	},
	["dirt"] = {
		"http://www.roblox.com/asset/?id=142186664",
		"http://www.roblox.com/asset/?id=142186677"
	},
	["tile"] = {
		"http://www.roblox.com/asset/?id=143590273",
		"http://www.roblox.com/asset/?id=143590281",
		"http://www.roblox.com/asset/?id=143590284",
		"http://www.roblox.com/asset/?id=143590290",
		"http://www.roblox.com/asset/?id=143590268"
	},
	["flesh"] = {
		"http://www.roblox.com/asset/?id=156459241",
		"http://www.roblox.com/asset/?id=156459246"
	},
	["snow"] = {
		"http://www.roblox.com/asset/?id=142186664",
		"http://www.roblox.com/asset/?id=142186677"
	},
	["fabric"] = {
		"http://www.roblox.com/asset/?id=142186664",
		"http://www.roblox.com/asset/?id=142186677"
	},
	["grass"] = {
		"http://www.roblox.com/asset/?id=142186664",
		"http://www.roblox.com/asset/?id=142186677"
	}
}

eng.Sounds.Impact = {
	["concrete"] = "http://www.roblox.com/asset/?id=142082166",
	["metal"] = "http://www.roblox.com/asset/?id=142082170",
	["wood"] = "http://www.roblox.com/asset/?id=142082171",
	["glass"] = "http://www.roblox.com/asset/?id=142082167",
	["dirt"] = "http://www.roblox.com/asset/?id=142082166",
	["tile"] = "http://www.roblox.com/asset/?id=142082166",
	["flesh"] = "http://www.roblox.com/asset/?id=144884872",
	["snow"] = "http://www.roblox.com/asset/?id=142082166",
	["fabric"] = "http://www.roblox.com/asset/?id=142082166",
	["grass"] = "http://www.roblox.com/asset/?id=142082166"
	
}


eng.Sounds.WaterImpact = {
	["small"] = "http://www.roblox.com/asset/?id=142431247",
	["large"] = "http://www.roblox.com/asset/?id=137304720",
	
}

eng.Sounds.Door = {
	["metal_door_open"] = "";
	["metal_door_close"] = "";
	["metal_large_start"] = "";
	["metal_large_move"] = "";
	["garage_stop"] = "http://www.roblox.com/asset/?id=219648962";
	["drawbridge_move"] = "http://www.roblox.com/asset/?id=219648765";
	["drawbridge_stop"] = "http://www.roblox.com/asset/?id=219650752";
}

eng.Sounds.Alarm = {
	["klaxon1"] = "http://www.roblox.com/asset/?id=145453683";
	["siren"] = "http://www.roblox.com/asset/?id=164450351";
}

eng.Sounds.Button = {
	["Beep"] = "http://www.roblox.com/asset/?id=142638577";
	["Click"] = "http://www.roblox.com/asset/?id=156286438";
	["Switch"] = "http://www.roblox.com/asset/?id=154904310";
	["Invalid"] = "http://www.roblox.com/asset/?id=219914630";
}

eng.Sounds.Spark = {
	["spark1"] = "http://www.roblox.com/asset/?id=184211520",
	["spark2"] = "http://www.roblox.com/asset/?id=184211507",
	["spark3"] = "http://www.roblox.com/asset/?id=184211494",
	["spark4"] = "http://www.roblox.com/asset/?id=157325701", --zap long
	["spark5"] = "http://www.roblox.com/asset/?id=177862373",
	["spark6"] = "http://www.roblox.com/asset/?id=177862344"
}

eng.Sounds.Destroy = {
	["concrete"] = "http://www.roblox.com/asset/?id=142082166",
	["metal"] = "http://www.roblox.com/asset/?id=132758217",
	["wood"] = "http://www.roblox.com/asset/?id=142082171",
	["glass"] = "http://www.roblox.com/asset/?id=144884907",
	["dirt"] = "http://www.roblox.com/asset/?id=142082166",
	["tile"] = "http://www.roblox.com/asset/?id=142082166",
	["flesh"] = "http://www.roblox.com/asset/?id=142082166",
	["snow"] = "http://www.roblox.com/asset/?id=142082166",
	["fabric"] = "http://www.roblox.com/asset/?id=142082166",
	["grass"] = "http://www.roblox.com/asset/?id=142082166"
}

eng.Sounds.Explosion = {
	["c4"] = "http://www.roblox.com/asset/?id=133680244",
	["crumble"] = "http://www.roblox.com/asset/?id=134854740",
	["grenade"] = "http://www.roblox.com/asset/?id=142070127"
}

	-- ["concrete"] = {
	-- 	"http://www.roblox.com/asset/?id=142335214",
	-- 	"http://www.roblox.com/asset/?id=142548009",
	-- 	"http://www.roblox.com/asset/?id=142548015",
	-- 	"http://www.roblox.com/asset/?id=142548001"
	-- },

eng.Player.Sounds = {
	["concrete"] = "http://www.roblox.com/asset/?id=142335214",
	["metal"] = "http://www.roblox.com/asset/?id=145180178",
	["wood"] = "rbxasset://sounds/woodgrass3.ogg",
	["glass"] = "http://www.roblox.com/asset/?id=145180170",
	["dirt"] = "http://www.roblox.com/asset/?id=145180183",
	["tile"] = "http://www.roblox.com/asset/?id=142335214",
	["flesh"] = "http://www.roblox.com/asset/?id=142335214",
	["snow"] = "http://www.roblox.com/asset/?id=19326880",
	["jump"] = "http://www.roblox.com/asset/?id=130778269",
	["ladder"] = "http://www.roblox.com/asset/?id=145180175",
	["fabric"] = "http://www.roblox.com/asset/?id=133705377",
	["grass"] = "http://www.roblox.com/asset/?id=16720281"
}

eng.Player.Hurt = {
	["BURN"] = "http://www.roblox.com/asset/?id=220194580";
	["FALL"] = "http://www.roblox.com/asset/?id=220194573";
	["DROWN"] = "http://www.roblox.com/asset/?id=220194561";
	["BLAST"] = "http://www.roblox.com/asset/?id=220194573";
	["BULLET"] = "http://www.roblox.com/asset/?id=144884872";
	["DEATH"] = {
		"http://www.roblox.com/asset/?id=132236792";
		"http://www.roblox.com/asset/?id=132236803";
	}
}

eng.RealMaterial = {
	Names = {
		["snow"] = "Snow";
		["flesh"] = {"Head", "Right Arm", "Left Arm", "Right Leg", "Left Leg", "Torso", "flesh"};
	};
	Mats = {
		["fabric"] = {Enum.Material.Fabric};
		["concrete"] = {Enum.Material.Concrete, Enum.Material.Slate, Enum.Material.Granite, Enum.Material.Pebble, Enum.Material.Plastic, Enum.Material.Cobblestone};
		["tile"] = {Enum.Material.Brick, Enum.Material.Marble};
		["glass"] = {Enum.Material.Ice, Enum.Material.SmoothPlastic};
		["metal"] = {Enum.Material.CorrodedMetal, Enum.Material.DiamondPlate, Enum.Material.Foil};
		["wood"] = {Enum.Material.Wood, Enum.Material.WoodPlanks};
		["dirt"] = {Enum.Material.Sand};
		["grass"] = {Enum.Material.Grass};
	};
	
	IsPartOf = function(self, val, tab)
		if tab[val] then
			return true
		end
		return false
	end;
	
	Get = function(self, p)
		local mat = p.Material
		local nam = p.Name
		
		if self:IsPartOf(nam, self.Names["snow"]) then
			return "snow"
		elseif self:IsPartOf(nam, self.Names["flesh"]) then
			return "flesh"
		end
	
		for real, enumTab in pairs(self.Mats) do
			for _, enum in pairs(enumTab) do
				if mat == enum then
					return real
				end
			end
		end
	end;
}


return eng