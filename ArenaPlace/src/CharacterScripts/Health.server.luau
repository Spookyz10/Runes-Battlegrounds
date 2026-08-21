local REGEN_AMOUNT = 1
local REGEN_STEP = 2

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
		if CanHeal() then
			Humanoid.Health = math.min(Humanoid.Health + REGEN_AMOUNT, Humanoid.MaxHealth)
		end
	end
	Humanoid.HealthChanged:Wait()
end
