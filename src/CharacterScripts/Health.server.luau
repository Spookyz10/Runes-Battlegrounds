local REGEN_RATE = 0.35 / 100
local REGEN_STEP = 1

local Character = script.Parent
local Humanoid

repeat
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	task.wait()
until Humanoid

local function CanHeal()
	return not (
		Character:FindFirstChild("Ragdolled")
		or Character:FindFirstChild("Stunned")
		or Character:HasTag("Blocking")
	)
end

while true do
	while Humanoid.Health < Humanoid.MaxHealth do
		local dt = task.wait(REGEN_STEP)
		local dh = dt * REGEN_RATE * Humanoid.MaxHealth
		if CanHeal() then
			Humanoid.Health =
				math.min(Humanoid.Health + (dh * workspace.Configuration.RegenMult.Value), Humanoid.MaxHealth)
		end
	end
	Humanoid.HealthChanged:Wait()
end
