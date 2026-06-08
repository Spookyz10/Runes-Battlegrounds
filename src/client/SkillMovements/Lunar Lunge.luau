local LunarLungeMovement = {}

local function doDash(root, speed, duration)
	local bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(1e5, 0, 1e5)
	bv.P = 1e4
	bv.Parent = root

	local elapsed = 0
	while elapsed < duration do
		local dt = task.wait()
		elapsed += dt
		if not root.Parent then
			break
		end
		local look = root.CFrame.LookVector
		bv.Velocity = Vector3.new(look.X, 0, look.Z).Unit * speed
	end

	bv:Destroy()
end

function LunarLungeMovement.execute(character, params)
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	humanoid.JumpPower = 0
	humanoid.WalkSpeed = 0

	doDash(root, params.speed, params.duration)

	humanoid.JumpPower = 50
	humanoid.WalkSpeed = 16
end

return LunarLungeMovement
