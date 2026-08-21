local ServerStorage = game:GetService("ServerStorage")
local StatusEffectHandler = require(ServerStorage.Modules.StatusEffectHandler)
local Base = require(script.Parent.Eclipse)

local Config = table.clone(Base)
Config.Steps = table.clone(Base.Steps)

Config.Empowered = {
	Damage = 22,
	StunTime = 0.35,
	Animation = Base.Steps[4].Animation,
	Hitbox = Base.Steps[4].Hitbox,
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