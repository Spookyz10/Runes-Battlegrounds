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
					"Lunar Lunge",
					"Prowl",
					"ShadeStep",
					"Grasp",
				},
				Solar = {
					"Sunquake",
					"Undawn",
					"Immolate",
					"Flarewhip",
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
				Cooldown = 5,
				Action = "SwapMode",
			},
			UltimateSpecial = {
				Cost = 5,
				Cooldown = 5,
				Action = "SwapMode",
			},
			Indicator = {
				Sound = "rbxassetid://113229409180409",
				Volume = 0.75,
			},
			Glow = Color3.new(0.8, 0.8, 0.8),
			Order = 2,
			Icon = 15124465440,
			UltimateTime = 45,
			UltimateName = "Astral Shift",
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
}
