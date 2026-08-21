local CosmeticsInfo = {}

CosmeticsInfo.Auras = {
	VIP = {
		DisplayName = "VIP",
	},
}

CosmeticsInfo.RuneCosmetics = {
	Crown = {
		DisplayName = "Crown",
		Offset = Vector3.new(0, 2, 0),
		Spin = true,
		SpinSpeed = 1.4,
	},
}

CosmeticsInfo.DefaultRuneCosmeticOffset = Vector3.new(0, 0, 0)
CosmeticsInfo.DefaultRuneCosmeticSpin = false
CosmeticsInfo.DefaultRuneCosmeticSpinSpeed = 0

return CosmeticsInfo
