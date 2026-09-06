local Shared = script.Parent.Parent

return {
	{
		Id = require(Shared.VIPPass).GamepassId,

		Name = "VIP",
		Description = "VIP aura and Crown rune cosmetic.",
	},
	{
		Id = require(Shared.EarlyAccess).GamepassId,

		Name = "Early Access",
		Description = "Access early-release runes.",
	},
	{
		Id = require(Shared.KillSoundPass).GamepassId,

		Name = "Kill Sound",
		Description = "Choose your elimination sound.",
	},
}
