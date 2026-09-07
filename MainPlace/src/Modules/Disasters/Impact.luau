local Ragdoll = require(script.Parent.Parent.RagdollHandler)
local Knockback = require(script.Parent.Parent.BodymoverService)
local IFrames = require(script.Parent.Parent.iFramesService)

-- Strongest to weakest knockback; Volcano keeps its original values.
local strengths = {
	Ice = { Horizontal = 130, Vertical = 75 },
	Thunder = { Horizontal = 110, Vertical = 65 },
	Volcano = { Horizontal = 90, Vertical = 55 },
	Meteor = { Horizontal = 70, Vertical = 45 },
}

return function(character, position, damage, kind, isActive)
	local hum = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	if not isActive() or not hum or not root or hum.Health <= 0 or IFrames:HasiFrame(character, 1) then
		return
	end
	local strength = assert(strengths[kind], "Unknown disaster impact: " .. kind)
	local direction = root.Position - position
	direction = Vector3.new(direction.X, 0, direction.Z)
	direction = if direction.Magnitude > 0.01 then direction.Unit else Vector3.xAxis
	hum:TakeDamage(damage)
	Ragdoll.ragdoll(hum, 5)
	task.defer(function()
		if not isActive() or not root.Parent then
			return
		end
		Knockback:Knockback(character, {
			KnockbackType = "Velocity",
			Velocity = direction * strength.Horizontal + Vector3.new(0, strength.Vertical, 0),
			MaxForce = Vector3.new(100000, 100000, 100000),
			Time = 0.3,
		})
	end)
end
