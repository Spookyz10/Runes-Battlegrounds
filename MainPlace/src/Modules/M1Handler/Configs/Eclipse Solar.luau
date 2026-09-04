local ServerStorage = game:GetService("ServerStorage")
local StatusEffectHandler = require(ServerStorage.Modules.StatusEffectHandler)
local buildEclipseConfig = require(script.Parent.EclipseBase)

local Config = buildEclipseConfig("Solar")

Config.Steps[4] = table.clone(Config.Steps[4])
Config.Steps[4].Blockable = false
Config.Steps[4].IgnoreRagdollCheck = true
Config.Steps[4].Knockback = "RagdollDownslam"

Config.Empowered = {
	Damage = 22,
	StunTime = 0.35,
	Animation = Config.Steps[4].Animation,
	Hitbox = Config.Steps[4].Hitbox,
	Blockable = true,
	BypassStunImmunity = true,
	DoFinisher = false,
	PlayHitEffect = false,
	Knockback = "PerfectFinisher",
	HitSound = "M3",
	Condition = function(Character)
		return StatusEffectHandler:GetStacks(Character, "FireArms") > 0
	end,
	OnHit = function(Character, EnemyCharacter, HitInfo, Combo)
		StatusEffectHandler:ConsumeStack(Character, "FireArms", 1)
	end,
}

return Config