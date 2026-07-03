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
					"Immolate",
					"Solar Chains",
				},
			},
			Ultimate = {
				Lunar = {
					"Crater Impact",
					"Supernova Slash",
				},
				Solar = {
					-- ults solares
				},
			},
			Special = {
				Cost = 0,
				Cooldown = 1,
				Action = "SwapMode",
			},
			UltimateSpecial = {
				Cost = 5,
				Cooldown = 5,
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
