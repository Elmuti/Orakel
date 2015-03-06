
	
-- soundscape/type/key/sound
-- soundId, volume, pitch

-- NOTE! Random tables have 1 extra index! A table that contains Min and Max interval! (In that order)
-- The extra index is BEFORE the soundID!



local scapes = {
	["kf_testmap_inside"] = {
		Reverb = Enum.ReverbType.Hallway;
		["Main"] = {
			["factory_indoor"] = {"http://www.roblox.com/asset/?id=157204376", .1, 1};
		};
		["Random"] = {
			["metal_creak"] = {{20, 200}, "http://www.roblox.com/asset/?id=133516489", .1, 1}
		};
	};
	
	
	["kf_testmap_inside_machinery"] = {
		Reverb = Enum.ReverbType.Hallway;
		["Main"] = {
			["factory_indoor"] = {"http://www.roblox.com/asset/?id=157204376", .1, 1};
			["indoor1"] = {"http://www.roblox.com/asset/?id=144163120", .2, 1};
		};
		["Random"] = {
			["metal_creak"] = {{20, 200}, "http://www.roblox.com/asset/?id=133516489", .2, 1}
		};
	};
	
	["kf_testmap_inside_room"] = {
		Reverb = Enum.ReverbType.Room;
		["Main"] = {
			["factory_indoor"] = {"http://www.roblox.com/asset/?id=157204376", .025, 1};
		};
		["Random"] = {
			["metal_creak"] = {{20, 200}, "http://www.roblox.com/asset/?id=133516489", .075, 1}
		};
	};
		
	["kf_testmap_outside"] = {
		Reverb = Enum.ReverbType.Hallway;
		["Main"] = {
			["plaza_amb"] = {"http://www.roblox.com/asset/?id=144163131", .08, 1};
			["desert_lp_04_light_wind"] = {"http://www.roblox.com/asset/?id=143501865", .2, 1};
		};
		["Random"] = {
			["crow"] = {{5, 120}, "http://www.roblox.com/asset/?id=130762806", .1, 1};
			["seagull"] = {{5, 120}, "http://www.roblox.com/asset/?id=130813724", .1, 1};
			["wind_howl"] = {{5, 15}, "http://www.roblox.com/asset/?id=131104992", .2, 1};-- heli 144884896
			["plane_overhead"] = {{20, 120}, "http://www.roblox.com/asset/?id=144884914", .2, 1};
		};
	};

}

return scapes




