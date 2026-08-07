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
		["Prowl"] = {
			Desc = "DUde",
		},
	},
}
