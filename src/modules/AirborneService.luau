local AirborneService = {}

local Players = game:GetService("Players")

local LOCK_DEADZONE = 0.3
local LOCK_SPEED = 50

local activeState = {}

local function setVelocityAll(character, velocity)
	for _, part in character:GetDescendants() do
		if part:IsA("BasePart") then
			part.AssemblyLinearVelocity = velocity
		end
	end
end

function AirborneService.apply(character, targetY, lock, duration)
	AirborneService.release(character)

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end

	local state = { running = true, timer = nil }
	activeState[character] = state

	task.spawn(function()
		-- Fase 1: subir/descer até targetY
		while state.running and root.Parent do
			local diff = targetY - root.Position.Y
			if math.abs(diff) <= LOCK_DEADZONE then
				setVelocityAll(character, Vector3.zero)
				break
			end
			local vel = math.clamp(diff * LOCK_SPEED, -LOCK_SPEED, LOCK_SPEED)
			setVelocityAll(character, Vector3.new(0, vel, 0))
			task.wait()
		end

		if not state.running then
			return
		end

		-- Fase 2: sustentação
		while state.running and root.Parent do
			local diff = targetY - root.Position.Y
			local yVel = math.abs(diff) > LOCK_DEADZONE and math.clamp(diff * LOCK_SPEED, -LOCK_SPEED, LOCK_SPEED) or 0

			if lock then
				setVelocityAll(character, Vector3.new(0, yVel, 0))
			else
				-- só cancela gravidade; preserva X/Z do root
				local cur = root.AssemblyLinearVelocity
				setVelocityAll(character, Vector3.new(cur.X, yVel, cur.Z))
			end

			task.wait()
		end
	end)

	if duration then
		state.timer = task.delay(duration, function()
			if activeState[character] == state then
				AirborneService.release(character)
			end
		end)
	end
end

function AirborneService.release(character)
	local state = activeState[character]
	if not state then
		return
	end

	state.running = false
	if state.timer then
		task.cancel(state.timer)
		state.timer = nil
	end
	activeState[character] = nil
end

function AirborneService.isAirborne(character)
	return activeState[character] ~= nil
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterRemoving:Connect(function(character)
		AirborneService.release(character)
	end)
end)

return AirborneService
