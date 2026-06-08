local KnockbackService = {}

local function applyToAll(character, velocity)
	for _, part in character:GetDescendants() do
		if part:IsA("BasePart") then
			part.AssemblyLinearVelocity = velocity
		end
	end
end

function KnockbackService.apply(character, vector)
	applyToAll(character, vector)
end

function KnockbackService.applyFromHit(character, attackerPosition, horizontalForce, verticalForce)
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	local direction = (rootPart.Position - attackerPosition)
	direction = Vector3.new(direction.X, 0, direction.Z).Unit
	applyToAll(character, Vector3.new(direction.X * horizontalForce, verticalForce, direction.Z * horizontalForce))
end

return KnockbackService
