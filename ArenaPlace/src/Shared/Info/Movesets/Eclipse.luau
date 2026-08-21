return {
	Info = {
		Order = 0,
		Modes = { "Lunar", "Solar" },
		Icon = "rbxassetid://111134146151301",
		DefaultMode = "Lunar",

		Special = {
			Action = "SwapMode",
		},
		UltimateSpecial = {
			Action = "SwapMode",
		},

		UltimateTime = 45,
		UltimateName = "Astral Shift",
	},

	Moves = {
		["Nightstalk"] = {
			Desc = "Enter the ground and summon 3 spikes",
			Icon = "rbxassetid://139163039010250",
			CustomGradient = "Lunar",
		},
		["Prowl"] = {
			Desc = "Throw 2 quick slashes and a devastating punch",
			Icon = "rbxassetid://115798487279169",
			CustomGradient = "Lunar",
		},
		["Shadestep"] = {
			Desc = "Charge a dash, hit people in its way, turn around and throw a fireball",
			Icon = "rbxassetid://73222123676380",
			CustomGradient = "Lunar",
		},
		["Grasp"] = {
			Desc = "Summon a hand from the shadow world to mark your enemies with a curse, anyone with that curse will be pulled to you.s",
			Icon = "rbxassetid://94952065887229",
			CustomGradient = "Lunar",
		},
		["Sunquake"] = {
			Desc = "Use the ground a catalyst to cause an explosion around you, marks people hit with inferno",
			Icon = "rbxassetid://85441827496324",
			CustomGradient = "Solar",
		},
		["Immolated"] = {
			Desc = "Turn yourself into magama giving you a speed buff and from time to time emit an aura that slows nearby enemies",
			Icon = "rbxassetid://102476784401363",
			CustomGradient = "Solar",
		},
		-- ["Undawn"] = {
		-- 	Desc = "Sacrifice 5 health to give yourself arms of fire for 10 seconds, with these arms your m1s deal more damage, if there are people with the 'inferno' status effect nearby summon a pillar below them that deals damage",
		-- 	Icon = "rbxassetid://70988053103965",
		-- 	CustomGradient = "Solar",
		-- },
		["Tethers"] = {
			Desc = "Can only hit people who are airborne, if someone is airborne in the range of this skills then pull them in with chains and kick them",
			Icon = "rbxassetid://139007402456420",
			CustomGradient = "Solar",
		},
	},

	AwakeningMoves = {
		["Moonfall"] = {
			Desc = "Summon a gravity field in the area you are in, anyone that enters the field will be stunned by gravity, then fly up and throw a island below",
			Icon = "rbxassetid://94648720465031",
			CustomGradient = "Lunar",
		},
		["Cataclysm"] = {
			Desc = "Using your strenght cause an explosion infront of you, if it hits anyone it sends them flying, then jump up and hit the victim with all your might",
			Icon = "rbxassetid://112305150624921",
			CustomGradient = "Solar",
		},
	},

	SpecialDisplay = {
		Name = "Celestial Body",
		Desc = "By activating this swap between solar and lunar mode, if used at base this consumes 15 of your awakening bar, if used at awakening it's free.",
	},
}
