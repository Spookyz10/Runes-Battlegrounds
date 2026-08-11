return {

	Admins = {
		game.CreatorId,
	},

	Movesets = {
		["Eclipse"] = {
			Modes = { "Lunar", "Solar" },
			DefaultMode = "Lunar",
			Base = {
				Lunar = {
					"Nightstalk",
					"Prowl",
					"ShadeStep",
					"Grasp",
				},
				Solar = {
					"Sunquake",
					"Undawn",
					"Immolated",
					"Tethers",
				},
			},
			Ultimate = {
				Lunar = {
					"Moonfall",
				},
				Solar = {
					"Cataclysm",
				},
			},
			Special = {
				Action = "SwapMode",
			},
			UltimateSpecial = {
				Action = "SwapMode",
			},

			Glow = Color3.new(0.8, 0.8, 0.8),
			Order = 2,
			Icon = 15124465440,
			UltimateTime = 45,
			UltimateName = "Astral Shift",
		},
	},

	MovesInfo = {
		["Nightstalk"] = {
			Desc = "Enter the ground and summon 3 spikes",
		},
		["Prowl"] = {
			Desc = "Throw 2 quick slashes and a devastating punch",
		},
		["Shadestep"] = {
			Desc = "Charge a dash, hit people in its way, turn around and throw a fireball",
		},
		["Grasp"] = {
			Desc = "Summon a hand from the shadow world to mark your enemies with a curse, anyone with that curse will be pulled to you.s",
		},
		["Sunquake"] = {
			Desc = "Use the ground a catalyst to cause an explosion around you, marks people hit with inferno",
		},
		["Immolated"] = {
			Desc = "Turn yourself into magama giving you a speed buff and from time to time emit an aura that slows nearby enemies",
		},
		["Undawn"] = {
			Desc = "Sacrifice 5 health to give yourself arms of fire for 10 seconds, with these arms your m1s deal more damage, if there are people with the 'inferno' status effect nearby summon a pillar below them that deals damage",
		},
		["Tethers"] = {
			Desc = "Can only hit people who are airborne, if someone is airborne in the range of this skills then pull them in with chains and kick them",
		},
	},

	AwakeningMovesInfo = {
		["Moonfall"] = {
			Desc = "Summon a gravity field in the area you are in, anyone that enters the field will be stunned by gravity, then fly up and throw a island below",
		},
		["Cataclysm"] = {
			Desc = "Using your strenght cause an explosion infront of you, if it hits anyone it sends them flying, then jump up and hit the victim with all your might",
		},
	},

	Special = {
		Name = "Celestial Body",
		Desc = "By activating this swap between solar and lunar mode, if used at base this consumes 15 of your awakening bar, if used at awakening it's free.",
	},
}
