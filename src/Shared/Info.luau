return {
	UFWrequirement = 500,

	Passes = {
		["VIP"] = 1608372221, -- 49 Robux
	},

	Gifts = {
		["VIP"] = 3469504899, -- 49 Robux

		["500 Gold"] = 3469506232, -- 5 Robux
		["1,000 Gold"] = 3469506233, -- 10 Robux
		["2,500 Gold"] = 3469506230, -- 25 Robux
		["5,000 Gold"] = 3469506227, -- 50 Robux
	},

	Products = {
		["500 Gold"] = 3469515253, -- 5 Robux
		["1,000 Gold"] = 3469515252, -- 10 Robux
		["2,500 Gold"] = 3469515250, -- 25 Robux
		["5,000 Gold"] = 3469515251, -- 50 Robux

		["1 Cosmetic"] = 3469516106, -- 3 Robux
		["3 Cosmetics"] = 3469516107, -- 5 Robux
		["5 Cosmetics"] = 3469516101, -- 10 Robux

		["Random Emote"] = 3469516100, -- 3 Robux
		["Random Emote x5"] = 3469516099, -- 5 Robux
		["Random Emote x10"] = 3469516098, -- 10 Robux
	},

	Donations = {
		3469521892, -- 2 Robux
		3469521890, -- 3 Robux
		3469521891, -- 5 Robux
		3469521888, -- 10 Robux
		3469521889, -- 50 Robux
		3469521887, -- 100 Robux
		3469521878, -- 500 Robux
		3469521879, -- 1,000 Robux
		3469521883, -- 5,000 Robux
		3469521881, -- 10,000 Robux
		3469521893, -- 50,000 Robux
		3469521875, -- 100,000 Robux
		3469521876, -- 500,000 Robux
		3469521880, -- 1,000,000 Robux
	},

	Admins = {
		game.CreatorId,
	},

	Movesets = {
		["The Strongest Hero"] = {
			Base = {
				"Normal Punch",
				"Consecutive Punches",
				"Shove",
				"Uppercut",
			},
			Ultimate = {
				"Death Counter",
				"Table Flip",
				"Serious Punch",
				"Omni Directional Punch",
			},
			Indicator = {
				Sound = "rbxassetid://101839440038348",
				Volume = 1,
			},
			Glow = Color3.new(1, 0.52549, 0.533333),
			Order = 0,
			Icon = 15114667107,
			UltimateTime = 60,
			UltimateName = "SERIOUS MODE",
		},

		["Hero Hunter"] = {
			Base = {
				"Flowing Water",
				"Lethal Whirlwind Stream",
				"Hunter's Grasp",
				"Prey's Peril",
			},
			Ultimate = {
				"Water Stream Cutting Fist",
				"The Final Hunt",
			},
			Indicator = {
				Sound = "rbxassetid://113229409180409",
				Volume = 0.75,
			},

			Glow = Color3.new(0.364706, 0.745098, 1),
			Order = 1,
			Icon = 15124465439,
			UltimateTime = 42.5,
			UltimateName = "RAMPAGE",
		},

		["Martial Artist"] = {
			Base = {
				"Bullet Barrage",
				"Vanishing Kick",
				"Whirlwind Drop",
				"Head First",
			},
			Ultimate = {
				"Grand Fissure",
				"Twin Fangs",
				"Earth Splitting Strike",
				"Last Breath",
			},
			Indicator = {
				Sound = "rbxassetid://73015436553248",
				Volume = 0.75,
			},
			Glow = Color3.new(0.6, 0.564706, 1),
			Order = 3,
			Icon = 18434673438,
			UltimateTime = 42.5,
			UltimateName = "DRAGON'S DESCENT",
		},

		["Lunar"] = {
			Base = {
				"Lunar Lunge",
				"Eclipse",
				"Moon Cutters",
			},
			Ultimate = {
				"Crater Impact",
				"Supernova Slash",
			},
			Indicator = {
				Sound = "rbxassetid://113229409180409",
				Volume = 0.75,
			},
			Glow = Color3.new(0.8, 0.8, 0.8),
			Order = 2,
			Icon = 15124465440,
			UltimateTime = 45,
			UltimateName = "LUNAR RADIANCE",
		},
	},

	Titles = {
		[1] = {
			Description = "The true symbol of luxury.",
			Name = "VIP",
			ProgressColor = Color3.fromRGB(255, 255, 255),
			TitleColor = Color3.fromRGB(255, 224, 0),
			Type = "VIP",
		},
		[2] = {
			Description = "Humble beginnings.",
			Name = "Rookie",
			ProgressColor = Color3.fromRGB(255, 0, 0),
			Requirement = 1,
			TitleColor = Color3.fromRGB(156, 156, 156),
			Type = "Kills",
		},
		[3] = {
			Description = "A humble start to a legendary journey.",
			Name = "Novice",
			ProgressColor = Color3.fromRGB(255, 0, 0),
			Requirement = 10,
			TitleColor = Color3.fromRGB(28, 142, 255),
			Type = "Kills",
		},
		[4] = {
			Description = "Proven in battle, a rising slayer.",
			Name = "Warrior",
			ProgressColor = Color3.fromRGB(255, 0, 0),
			Requirement = 100,
			TitleColor = Color3.fromRGB(255, 157, 0),
			Type = "Kills",
		},
		[5] = {
			Description = "A force to be reckoned with.",
			Name = "Slayer",
			ProgressColor = Color3.fromRGB(255, 0, 0),
			Requirement = 500,
			TitleColor = Color3.fromRGB(110, 227, 0),
			Type = "Kills",
		},
		[6] = {
			Description = "Dominating the battlefield.",
			Name = "Conqueror",
			ProgressColor = Color3.fromRGB(255, 0, 0),
			Requirement = 1000,
			TitleColor = Color3.fromRGB(85, 87, 84),
			Type = "Kills",
		},
		[7] = {
			Description = "You specialize in one-on-one combat.",
			Name = "Duelist",
			ProgressColor = Color3.fromRGB(255, 0, 0),
			Requirement = 3500,
			TitleColor = Color3.fromRGB(0, 9, 74),
			Type = "Kills",
		},
		[8] = {
			Description = "Leaving nothing but ruin in your wake.",
			Name = "Destroyer",
			ProgressColor = Color3.fromRGB(255, 0, 0),
			Requirement = 5000,
			TitleColor = Color3.fromRGB(255, 0, 17),
			Type = "Kills",
		},
		[9] = {
			Description = "A giant among fighters.",
			Name = "Behemoth",
			ProgressColor = Color3.fromRGB(255, 0, 0),
			Requirement = 7500,
			TitleColor = Color3.fromRGB(255, 173, 51),
			Type = "Kills",
		},
		[10] = {
			Description = "Entering the field with unmatched power.",
			Name = "Warlord",
			ProgressColor = Color3.fromRGB(255, 0, 0),
			Requirement = 10000,
			TitleColor = Color3.fromRGB(163, 0, 14),
			Type = "Kills",
		},
		[11] = {
			Description = "A haunting presence on the battlefield.",
			Name = "Specter",
			ProgressColor = Color3.fromRGB(255, 0, 0),
			Requirement = 20000,
			TitleColor = Color3.fromRGB(230, 230, 230),
			Type = "Kills",
		},
		[12] = {
			Description = "Stories of your prowess are whispered in awe.",
			Name = "Myth",
			ProgressColor = Color3.fromRGB(255, 0, 0),
			Requirement = 35000,
			TitleColor = Color3.fromRGB(30, 0, 107),
			Type = "Kills",
		},
		[13] = {
			Description = "Unmatched in the art of combat.",
			Name = "Master Duelist",
			ProgressColor = Color3.fromRGB(255, 0, 0),
			Requirement = 50000,
			TitleColor = Color3.fromRGB(0, 7, 41),
			Type = "Kills",
		},
		[14] = {
			Description = "You stand on top of the world.",
			Name = "Combat Legend",
			ProgressColor = Color3.fromRGB(255, 0, 0),
			Requirement = 100000,
			TitleColor = Color3.fromRGB(227, 212, 0),
			Type = "Kills",
		},
		[15] = {
			Description = "You're starting to show some personality.",
			Name = "Groovy",
			ProgressColor = Color3.fromRGB(0, 255, 150),
			Requirement = 5,
			TitleColor = Color3.fromRGB(134, 29, 179),
			Type = "Emotes",
		},
		[16] = {
			Description = "You prefer to communicate through dance.",
			Name = "Expressive",
			ProgressColor = Color3.fromRGB(0, 255, 150),
			Requirement = 25,
			TitleColor = Color3.fromRGB(57, 50, 240),
			Type = "Emotes",
		},
		[17] = {
			Description = "Own 50 emotes.",
			Name = "Specialist",
			ProgressColor = Color3.fromRGB(0, 255, 150),
			Requirement = 50,
			TitleColor = Color3.fromRGB(247, 240, 15),
			Type = "Emotes",
		},
		[18] = {
			Description = "Own 1 cosmetic.",
			Name = "Collector",
			ProgressColor = Color3.fromRGB(255, 255, 150),
			Requirement = 1,
			TitleColor = Color3.fromRGB(81, 87, 84),
			Type = "Cosmetics",
		},
		[19] = {
			Description = "Own 5 cosmetics.",
			Name = "Stylish",
			ProgressColor = Color3.fromRGB(255, 255, 150),
			Requirement = 5,
			TitleColor = Color3.fromRGB(46, 96, 171),
			Type = "Cosmetics",
		},
		[20] = {
			Description = "Yes, we see the fit.",
			Name = "Aura Farmer",
			ProgressColor = Color3.fromRGB(255, 255, 150),
			Requirement = 10,
			TitleColor = Color3.fromRGB(84, 10, 148),
			Type = "Cosmetics",
		},
		[21] = {
			Description = "The start of a long journey.",
			Name = "Tarnished",
			ProgressColor = Color3.fromRGB(255, 150, 0),
			Requirement = 1,
			TitleColor = Color3.fromRGB(107, 102, 112),
			Type = "Awakens",
		},
		[22] = {
			Description = "Awaken 10 times.",
			Name = "Rising Legend",
			ProgressColor = Color3.fromRGB(255, 150, 0),
			Requirement = 10,
			TitleColor = Color3.fromRGB(32, 214, 19),
			Type = "Awakens",
		},
		[23] = {
			Description = "Awaken 50 times.",
			Name = "Battle Hardened",
			ProgressColor = Color3.fromRGB(255, 150, 0),
			Requirement = 50,
			TitleColor = Color3.fromRGB(232, 70, 12),
			Type = "Awakens",
		},
		[24] = {
			Description = "Awaken 100 times.",
			Name = "Ascendant",
			ProgressColor = Color3.fromRGB(255, 150, 0),
			Requirement = 100,
			TitleColor = Color3.fromRGB(232, 12, 228),
			Type = "Awakens",
		},
		[25] = {
			Description = "Awaken 250 times.",
			Name = "God Complex",
			ProgressColor = Color3.fromRGB(255, 150, 0),
			Requirement = 250,
			TitleColor = Color3.fromRGB(0, 0, 0),
			Type = "Awakens",
		},
		[26] = {
			Description = "Awaken 500 times.",
			Name = "Mastered Instinct",
			ProgressColor = Color3.fromRGB(255, 150, 0),
			Requirement = 500,
			TitleColor = Color3.fromRGB(255, 255, 255),
			Type = "Awakens",
		},
		[27] = {
			Description = "Oops. Didn't see that there.",
			Name = "Timber!",
			ProgressColor = Color3.fromRGB(0, 225, 0),
			Requirement = 1,
			TitleColor = Color3.fromRGB(59, 66, 59),
			Type = "TreesDestroyed",
		},
		[28] = {
			Description = "Do you have a permit for this?",
			Name = "Lumberjack",
			ProgressColor = Color3.fromRGB(0, 255, 0),
			Requirement = 10,
			TitleColor = Color3.fromRGB(150, 75, 0),
			Type = "TreesDestroyed",
		},
		[29] = {
			Description = "Destroy 50 trees.",
			Name = "Deforester",
			ProgressColor = Color3.fromRGB(0, 225, 0),
			Requirement = 50,
			TitleColor = Color3.fromRGB(7, 112, 0),
			Type = "TreesDestroyed",
		},
		[30] = {
			Description = "Destroy 100 trees.",
			Name = "Walking Chainsaw",
			ProgressColor = Color3.fromRGB(0, 225, 0),
			Requirement = 100,
			TitleColor = Color3.fromRGB(65, 82, 67),
			Type = "TreesDestroyed",
		},
		[31] = {
			Description = "Who even likes the color green?",
			Name = "Modernist",
			ProgressColor = Color3.fromRGB(0, 225, 0),
			Requirement = 250,
			TitleColor = Color3.fromRGB(173, 164, 163),
			Type = "TreesDestroyed",
		},
		[32] = {
			Description = "Destroy 500 trees.",
			Name = "Terrible Tornado",
			ProgressColor = Color3.fromRGB(0, 225, 0),
			Requirement = 500,
			TitleColor = Color3.fromRGB(0, 214, 25),
			Type = "TreesDestroyed",
		},
		[33] = {
			Description = "Paving your own path.",
			Name = "Phantom Thief",
			ProgressColor = Color3.fromRGB(0, 225, 0),
			Requirement = 1000,
			TitleColor = Color3.fromRGB(184, 12, 0),
			Type = "TreesDestroyed",
		},
		[34] = {
			Description = "Wall combo 1 time.",
			Name = "Resourceful",
			ProgressColor = Color3.fromRGB(0, 215, 255),
			Requirement = 1,
			TitleColor = Color3.fromRGB(89, 86, 80),
			Type = "WallCombo",
		},
		[35] = {
			Description = "Wall combo 10 times.",
			Name = "Brutalist",
			ProgressColor = Color3.fromRGB(0, 215, 255),
			Requirement = 10,
			TitleColor = Color3.fromRGB(128, 9, 29),
			Type = "WallCombo",
		},
		[36] = {
			Description = "Wall combo 50 times.",
			Name = "Punisher",
			ProgressColor = Color3.fromRGB(0, 215, 255),
			Requirement = 50,
			TitleColor = Color3.fromRGB(199, 66, 0),
			Type = "WallCombo",
		},
		[37] = {
			Description = "Wall combo 100 times.",
			Name = "Unyielding Fighter",
			ProgressColor = Color3.fromRGB(0, 215, 255),
			Requirement = 100,
			TitleColor = Color3.fromRGB(156, 21, 0),
			Type = "WallCombo",
		},
		[38] = {
			Description = "Wall combo 250 times.",
			Name = "Tactician",
			ProgressColor = Color3.fromRGB(0, 215, 255),
			Requirement = 250,
			TitleColor = Color3.fromRGB(212, 138, 0),
			Type = "WallCombo",
		},
		[39] = {
			Description = "Starting the search!",
			Name = "Oracle",
			ProgressColor = Color3.fromRGB(0, 215, 255),
			Requirement = 500,
			TitleColor = Color3.fromRGB(6, 179, 0),
			Type = "WallCombo",
		},
		[40] = {
			Description = "Counter 1 time.",
			Name = "First Impact",
			ProgressColor = Color3.fromRGB(50, 200, 155),
			Requirement = 1,
			TitleColor = Color3.fromRGB(87, 88, 89),
			Type = "Counters",
		},
		[41] = {
			Description = "Counter 10 times.",
			Name = "Distanced",
			ProgressColor = Color3.fromRGB(50, 200, 155),
			Requirement = 10,
			TitleColor = Color3.fromRGB(9, 81, 224),
			Type = "Counters",
		},
		[42] = {
			Description = "Counter 50 times.",
			Name = "Relentless",
			ProgressColor = Color3.fromRGB(50, 200, 155),
			Requirement = 50,
			TitleColor = Color3.fromRGB(143, 87, 115),
			Type = "Counters",
		},
		[43] = {
			Description = "Counter 100 times.",
			Name = "Raging Demon",
			ProgressColor = Color3.fromRGB(50, 200, 155),
			Requirement = 100,
			TitleColor = Color3.fromRGB(255, 0, 0),
			Type = "Counters",
		},
		[44] = {
			Description = "Full counter!",
			Name = "Dragon's Sin",
			ProgressColor = Color3.fromRGB(50, 200, 155),
			Requirement = 250,
			TitleColor = Color3.fromRGB(224, 196, 9),
			Type = "Counters",
		},
		[45] = {
			Description = "You're going to have a bad time.",
			Name = "Sans",
			ProgressColor = Color3.fromRGB(50, 200, 155),
			Requirement = 500,
			TitleColor = Color3.fromRGB(255, 255, 255),
			Type = "Counters",
		},
		[46] = {
			Description = "The beginning of a long massacre.",
			Name = "Assassin",
			ProgressColor = Color3.fromRGB(255, 0, 0),
			Requirement = 10,
			TitleColor = Color3.fromRGB(255, 90, 80),
			Type = "Killstreak",
		},
		[47] = {
			Description = "You stand victorious among the slain legends.",
			Name = "Killing Machine",
			ProgressColor = Color3.fromRGB(255, 0, 0),
			Requirement = 25,
			TitleColor = Color3.fromRGB(235, 0, 0),
			Type = "Killstreak",
		},
		[48] = {
			Description = "Nobody stands in your way.",
			Name = "Decimator",
			ProgressColor = Color3.fromRGB(255, 0, 0),
			Requirement = 50,
			TitleColor = Color3.fromRGB(255, 0, 0),
			Type = "Killstreak",
		},
		[49] = {
			Description = "You begin to feel the true power...",
			Name = "Annihilator",
			ProgressColor = Color3.fromRGB(255, 0, 0),
			Requirement = 75,
			TitleColor = Color3.fromRGB(255, 0, 0),
			Type = "Killstreak",
		},
		[50] = {
			Description = "You stand unshaken.",
			Name = "Immortal",
			ProgressColor = Color3.fromRGB(255, 0, 0),
			Requirement = 100,
			TitleColor = Color3.fromRGB(255, 0, 0),
			Type = "Killstreak",
		},
		[51] = {
			Description = "Your investments shape the game.",
			Name = "Supporter",
			ProgressColor = Color3.fromRGB(0, 255, 0),
			Requirement = 5,
			TitleColor = Color3.fromRGB(0, 255, 0),
			Type = "Robux",
		},
		[52] = {
			Description = "Your investments shape the game.",
			Name = "Generous",
			ProgressColor = Color3.fromRGB(0, 255, 0),
			Requirement = 100,
			TitleColor = Color3.fromRGB(0, 255, 26),
			Type = "Robux",
		},
		[53] = {
			Description = "Your investments shape the game.",
			Name = "Patron",
			ProgressColor = Color3.fromRGB(0, 255, 0),
			Requirement = 250,
			TitleColor = Color3.fromRGB(255, 21, 0),
			Type = "Robux",
		},
		[54] = {
			Description = "Your investments shape the game.",
			Name = "Investor",
			ProgressColor = Color3.fromRGB(0, 255, 0),
			Requirement = 500,
			TitleColor = Color3.fromRGB(6, 176, 0),
			Type = "Robux",
		},
		[55] = {
			Description = "Your investments shape the game.",
			Name = "Wealthy",
			ProgressColor = Color3.fromRGB(0, 255, 0),
			Requirement = 1000,
			TitleColor = Color3.fromRGB(210, 217, 0),
			Type = "Robux",
		},
		[56] = {
			Description = "Your investments shape the game.",
			Name = "Mafia Boss",
			ProgressColor = Color3.fromRGB(0, 255, 0),
			Requirement = 10000,
			TitleColor = Color3.fromRGB(0, 0, 0),
			Type = "Robux",
		},
		[57] = {
			Description = "Your investments shape the game.",
			Name = "Board of Directors",
			ProgressColor = Color3.fromRGB(0, 255, 0),
			Requirement = 50000,
			TitleColor = Color3.fromRGB(0, 163, 217),
			Type = "Robux",
		},
		[58] = {
			Description = "You must be a great entrepreneur.",
			Name = "CEO",
			ProgressColor = Color3.fromRGB(0, 255, 0),
			Requirement = 100000,
			TitleColor = Color3.fromRGB(246, 255, 0),
			Type = "Robux",
		},
		[59] = {
			Description = "You are a massive investor, building the future.",
			Name = "Investment Banker",
			ProgressColor = Color3.fromRGB(0, 255, 0),
			Requirement = 250000,
			TitleColor = Color3.fromRGB(0, 64, 17),
			Type = "Robux",
		},
		[60] = {
			Description = "Your wealth is larger than titans.",
			Name = "Wealth Titan",
			ProgressColor = Color3.fromRGB(0, 255, 0),
			Requirement = 500000,
			TitleColor = Color3.fromRGB(0, 232, 62),
			Type = "Robux",
		},
		[61] = {
			Description = "Your wealth holds great treasures.",
			Name = "Treasure Monarch",
			ProgressColor = Color3.fromRGB(0, 255, 0),
			Requirement = 750000,
			TitleColor = Color3.fromRGB(0, 36, 10),
			Type = "Robux",
		},
		[62] = {
			Description = "You have reached the pinnacle of prosperity.",
			Name = "God of Wealth",
			ProgressColor = Color3.fromRGB(0, 255, 0),
			Requirement = 1000000,
			TitleColor = Color3.fromRGB(255, 255, 0),
			Type = "Robux",
		},
		[63] = {
			Description = "The True Strongest Dev Ever.",
			Name = "Yokoso Watashi, No Soul Society",
			ProgressColor = Color3.fromRGB(85, 0, 127),
			Requirement = "Developer", -- Zay
			TitleColor = Color3.fromRGB(0, 0, 0),
			Type = "Special",
			ID = 7208460524,
		},
		[64] = {
			Description = "watching from afar. Seeking for nothing but killing sprees.",
			Name = "Death’s Salute",
			ProgressColor = Color3.fromRGB(100, 0, 2),
			Requirement = "Co-Owner", -- Beez
			TitleColor = Color3.fromRGB(115, 115, 115),
			Type = "Special",
			ID = 1369434295,
		},
		[65] = {
			Description = "The honored fih.",
			Name = "The Honored Fih",
			ProgressColor = Color3.fromRGB(0, 255, 255),
			Requirement = "Moderator", -- Murmey
			TitleColor = Color3.fromRGB(0, 255, 255),
			Type = "Special",
			ID = 5140036835,
		},
		[66] = {
			Description = "maybeagoofygoober.",
			Name = "Goofiest Goober",
			ProgressColor = Color3.fromRGB(85, 0, 0),
			Requirement = "Moderator", -- Maybe
			TitleColor = Color3.fromRGB(85, 0, 127),
			Type = "Special",
			ID = 4988712084,
		},
		[67] = {
			Description = "May justice be done and the scales be balanced again.",
			Name = "Justice",
			ProgressColor = Color3.fromRGB(155, 45, 48),
			Requirement = "Admin", -- jenzz
			TitleColor = Color3.fromRGB(155, 45, 48),
			Type = "Special",
			ID = 4072813911,
		},
		[68] = {
			Description = "Peak vampire has spawn.",
			Name = "VAMPIRE CHOOSE ONE:3",
			ProgressColor = Color3.fromRGB(128, 0, 128),
			Requirement = "CONTENT CREATOR", -- Crazy Bela
			TitleColor = Color3.fromRGB(128, 0, 128),
			Type = "Special",
			ID = 7719606051,
		},
		[69] = {
			Description = "Great and invincible. Chosen by ancestors to protect the homeland.",
			Name = "Purple Warrior",
			ProgressColor = Color3.fromRGB(75, 0, 130),
			Requirement = "Moderator", -- Pele4Chicken
			TitleColor = Color3.fromRGB(75, 0, 130),
			Type = "Special",
			ID = 1208817235,
		},
		[70] = {
			Description = "Traveling through many dimension to find her leek - will she able to find it here?",
			Name = "Leek Hunter",
			ProgressColor = Color3.fromRGB(206, 255, 206),
			Requirement = "Moderator",
			TitleColor = Color3.fromRGB(141, 255, 142),
			Type = "Special",
			ID = 2978147707,
		},
		[71] = {
			Description = "Forged the realms, shaped every fate — the origin of all battles.",
			Name = "Architect Of Worlds",
			ProgressColor = Color3.fromRGB(85, 0, 0),
			Requirement = "Creator",
			TitleColor = Color3.fromRGB(85, 0, 0),
			Type = "Special",
			ID = 9904096067,
		},
		[72] = {
			Description = "Only for the red description.",
			Name = "Mr.red",
			ProgressColor = Color3.fromRGB(85, 0, 0),
			Requirement = "Moderator",
			TitleColor = Color3.fromRGB(85, 0, 0),
			Type = "Special",
			ID = 5686429939,
		},
		[73] = {
			Description = "Uhhh YES YAYY!.",
			Name = "The Cracked One",
			ProgressColor = Color3.fromRGB(255, 255, 255),
			Requirement = "Moderator",
			TitleColor = Color3.fromRGB(255, 255, 255),
			Type = "Special",
			ID = 2660756049,
		},
		[74] = {
			Description = "boii ts so tuff",
			Name = "Pirates On A Boat",
			ProgressColor = Color3.fromRGB(255, 255, 255),
			Requirement = "Does it Matter?",
			TitleColor = Color3.fromRGB(85, 0, 0),
			Type = "Special",
			ID = 4738699321,
		},
		[75] = {
			Description = "Skibidi",
			Name = "FH",
			ProgressColor = Color3.fromRGB(255, 0, 0),
			Requirement = "Moderator",
			TitleColor = Color3.fromRGB(255, 0, 0),
			Type = "Special",
			ID = 9162675835,
		},
		[76] = {
			Description = "Its Him.",
			Name = "Owner",
			ProgressColor = Color3.fromRGB(85, 0, 0),
			Requirement = "Creator",
			TitleColor = Color3.fromRGB(85, 0, 0),
			Type = "Special",
			ID = 9904096067,
		},
		[77] = {
			Description = "Its Him.",
			Name = "Creator",
			ProgressColor = Color3.fromRGB(85, 0, 0),
			Requirement = "Creator",
			TitleColor = Color3.fromRGB(85, 0, 0),
			Type = "Special",
			ID = 9904096067,
		},
		[78] = {
			Description = "Skibidi toilet",
			Name = "Chief Staff",
			ProgressColor = Color3.fromRGB(255, 255, 0),
			Requirement = "Staff",
			TitleColor = Color3.fromRGB(255, 255, 0),
			Type = "Special",
			ID = 2573453648,
		},
	},

	GetSerial = function(Object)
		local Serial1 = Random.new():NextInteger(-10000000000, 10000000000)
		local Serial2 = math.floor(Object.Position.X) + math.floor(Object.Position.Y) + math.floor(Object.Position.Z)
		local Serial3 = math.random(-100, 100)
		local Serial4 = ""

		for _ = 1, Random.new():NextNumber(1, 5) do
			local RandomNumber = string.char(math.random(97, 122))
			if math.random(1, 2) == 1 then
				RandomNumber = RandomNumber:upper()
			end

			Serial4 = Serial4 .. RandomNumber
		end

		if math.random(1, 2) == 1 then
			return tostring(Serial1 + Serial2 + Serial3) .. Serial4
		else
			return Serial4 .. tostring(Serial1 + Serial2 + Serial3)
		end
	end,

	UpdateLog = [[
BIGGERRR **<font color="#ADD8E6">The End Of The Long Wait</font>**
-# — Still in development

## ✨

## ✶ **<font color="#5cc9ff">Hero Hunter</font>** 🌟
* first move: **Flowing Water**
* second move: **Lethal Whirlwind Stream**
* third move: **Hunter's Grasp**

* **RAMPAGE**
* first move: **Water Stream Rock Smashing Fist**
* second move: **The Final Hunt**

    ## ✶ **Monster Form**
    * first move: **Crowd Buster**
    * second move: **Hammer Heel**
    * third move: **Binding Cloth**
    * **LIMIT BREAKER**
    * first move: **Hunter's Mark**


## ✶ **<font color="#003d99">Volt Viper</font>** 🌟
* first move: **Twister Kick**
* second move: **Hypernova Fist**
* third move: **Abyssal Quake**
* fourth move: **Tectonic Vice**


## ✶ **<font color="#a8eaff">Frozen Warrior</font>** 🌟
* first move: **Ice Skate**
* second move: **Glacial Crush**
* third move: **Hammer Breaker**
* fourth move: **Frozen Barrier**

    **Specials**
    C: (DLeft+ButtonR1) **Potent Cascade**
    Z: (DLeft+ButtonL1) **Aerial Slam**
  
* **BELOW ZERO** Currently Attack


* **Bald Hero**
* Slight base damage reduction

* **Black**
* Slight hitbox buff
* New finisher for Move 4
* New Move for Awakening (4th last move)
* QoL improvements

* **Cursed Child**
* Ultimate aura now properly ends
* Fixed special hell text issue (Changed)
* Hitbox overhauled (no more lingering too long/too short)

* **KJ**
* UFW fixed


* **NEW FEATURES**
* Frontdash Techs: Faithful 1:1 TSB Combo 3 timing
* Frontdash Cancel: Removes velocity; improved air-hit knockback logic
* AntiTeam Update: Two move variants now available


* **SYSTEM CHANGES**
* Stun system reworked (cannot dash out of M1 strings)
* Better replication & asset loading
* Titles remain under Cosmetics


* **PS+**
* Added Config "No Attack"
* Added Config "Kill"
* Fixed Dummy not doing his damn job after re spawning


## 🛠️
* Reworked land-knockback (no more freeze-locking)
* Enhanced client systems: 
    camera, 
    character states, 
    running detection, 
    velocity & NoRotate fixes
    
* Combat detection significantly smoother
* Replication & preload system improved
* Added Gold currency (earned from kills, quests, etc.)
* New map by Astral, modified by @Famzedo
* Entire game engine recoded back to TSB-style (Astral :))
* Topbar reverted
* Ultimate gain logic fixed
* Fixed players getting free admin character


* **Game Info**
  * **Gold**
    * **Earn Gold by defeating other players.**
    * **Quests:** Coming soon.
    
    
  * **VIP**
    * **VIP grants access to all exclusive content, including PS+ features.**
    * **You can obtain VIP by purchasing the Gamepass or by buying it with Gold in Settings > Market.**
    
    
* **Moveset Info**
  * **The Frozen Soul**
    * **Unlock this moveset by achieving a 30+ Killstreak, or purchase it with Gold in Settings > Market.**
    
    
]],
}
