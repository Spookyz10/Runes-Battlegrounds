local meta = {}
local audioLookup = {
	{ -- Concrete
		Sounds = {2302070094, 2302070284, 2302070458, 2302070592, 2302070707, 2302070844, 2302070966, 2302071087};
		Materials = {
			Enum.Material.Basalt;
			Enum.Material.Slate;
			--Enum.Material.CrackedLava; --Moved to tile
			Enum.Material.Limestone;
			Enum.Material.Pavement;
			Enum.Material.Brick;
			Enum.Material.Cobblestone;
			Enum.Material.Rock;
			Enum.Material.Sandstone;
			Enum.Material.Asphalt;
			Enum.Material.Glass;
			Enum.Material.Ice;
			Enum.Material.Glacier;
		};
	};
	{ -- Dirt
		Sounds = {738484818, 738484890, 738484962, 738485221, 738485290, 738485364};
		Materials = {
			Enum.Material.Grass;
			Enum.Material.LeafyGrass;
			Enum.Material.Mud;
			Enum.Material.Ground;
		};
	};
	{ -- Gravel
		Sounds = {743048910, 743048927, 743048941, 743048953, 743048965, 743048979};
		Materials = {
			Enum.Material.Pebble;
		};
	};
	{ -- Metal
		Sounds = {744281043, 744281081, 744281118, 744281156, 744281205, 744281233};
		Materials = {
			Enum.Material.CorrodedMetal;
			Enum.Material.DiamondPlate;
			Enum.Material.Foil;
			Enum.Material.Metal;
		};
	};
	{ -- Sand
		Sounds = {743048910, 743048927, 743048941, 743048953, 743048965, 743048979};
		Materials = {
			Enum.Material.Sand;
			Enum.Material.Fabric;
			Enum.Material.Snow;
		};
	};
	{ -- Tile
		Sounds = {6357398877,6357398834,6357398791,6357398757};
		Materials = {
			Enum.Material.Plastic;
			Enum.Material.SmoothPlastic;
			Enum.Material.Neon;
			Enum.Material.Marble;
			Enum.Material.Granite;
			Enum.Material.Salt;
			Enum.Material.CrackedLava;
			Enum.Material.Concrete;
		};
	};
	{ -- Wood
		Sounds = {739361221, 739361264, 739361281, 739361317, 739361357, 739361379};
		Materials = {
			Enum.Material.Wood;
			Enum.Material.WoodPlanks;
		};
	};
	{ -- Water
		Sounds = {12721623939, 12721625086, 12721625226, 12721627647};
		Materials = {
			Enum.Material.Water;
		};
	};
}

local soundsByMaterial = {}
for _,data in pairs(audioLookup) do
	for i,sound in pairs(data.Sounds) do
		if type(sound) == "number" then
			data.Sounds[i] = "rbxassetid://" .. (tostring(sound))
		end
	end
	
	for _, material in pairs(data.Materials) do
		soundsByMaterial[material] = data.Sounds
	end
end

local preloadedSounds = {}
for material, sounds in pairs(soundsByMaterial) do
	local folder = Instance.new("Folder")
	folder.Name = "token" .. tostring(game:GetService("HttpService"):GenerateGUID(false))
	folder.Parent = script
	preloadedSounds[material] = folder
	
	for _,soundId in pairs(sounds) do
		local sound = Instance.new("Sound")
		sound.Name = "meta" .. tostring(game:GetService("HttpService"):GenerateGUID(false))
		sound.SoundId = soundId
		--sound.SoundGroup = game.SoundService.General
		sound.Parent = folder
	end
end

function meta:GetSoundsForMaterial(material)
	return preloadedSounds[material]
end

function meta:GetRawLookup()
	return audioLookup
end

return meta