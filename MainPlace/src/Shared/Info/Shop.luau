return {
	Categories = {
		{ Id = "Auras", Name = "Auras", OwnedField = "OwnedAuras" },
		{ Id = "RuneCosmetics", Name = "Rune cosmetics", OwnedField = "OwnedRuneCosmetics" },
		{ Id = "RuneSkins", Name = "Rune skins", ComingSoon = true },
	},
	Items = {
		{
			Id = "Crown",
			Category = "RuneCosmetics",
			Name = "Crown",
			Description = "A crown worthy of your rune.",
			Price = 100000,
			ModelPath = { "Resources", "RuneCosmetics", "Crown" },
		},
	},
}
