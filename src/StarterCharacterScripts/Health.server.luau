local REGEN_RATE = 0.35/100 -- Regenerate this fraction of MaxHealth per second.
local REGEN_STEP = 1 -- Wait this long between each regeneration step.

--------------------------------------------------------------------------------

local Character = script.Parent
local Humanoid = Character:WaitForChild'Humanoid'

--------------------------------------------------------------------------------

local function CanHeal()
	return not (Character:FindFirstChild("Ragdolled") or Character:FindFirstChild("Stunned") or Character:HasTag("Blocking"))
end

--------------------------------------------------------------------------------

workspace.Configuration.HealthMult:GetPropertyChangedSignal("Value"):Connect(function()
	local NewValue = workspace.Configuration.HealthMult.Value

	if NewValue == 0 then
		Humanoid.MaxHealth = 1

	else
		Humanoid.MaxHealth = 100 * NewValue

	end
end)

while true do
	while Humanoid.Health < Humanoid.MaxHealth do
		local dt = wait(REGEN_STEP)
		local dh = dt*REGEN_RATE*Humanoid.MaxHealth
		if CanHeal() then
			Humanoid.Health = math.min(Humanoid.Health + (dh * workspace.Configuration.RegenMult.Value), Humanoid.MaxHealth)
		end
	end
	Humanoid.HealthChanged:Wait()
end