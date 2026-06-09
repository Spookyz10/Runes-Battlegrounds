local AirborneService = {}

--[[
	AirborneService
	src/modules/AirborneService.luau

	Leva um personagem a uma altura Y e cancela a gravidade enquanto o efeito
	está ativo.

	Dois modos:
	  lock = true   → Trava na Y: corrige ativamente se o personagem sair dela
	                  (empurrado, knockback, etc.).
	  lock = false  → Leva até Y e apenas cancela a gravidade; o personagem pode
	                  se mover livremente no espaço mas não cai.

	API:
	  AirborneService.apply(character, targetY, lock, duration?)
	    targetY  : number  – posição Y alvo do HumanoidRootPart
	    lock     : bool    – se true, corrige desvios ativamente
	    duration : number? – auto-release após N segundos (nil = manual)

	  AirborneService.release(character)
	    Para o efeito imediatamente.

	  AirborneService.isAirborne(character) -> bool
]]

local Players = game:GetService("Players")

local FORCE_NAME = "AirborneGravityForce"
local ATTACH_NAME = "AirborneAttachment"
local LOCK_DEADZONE = 0.3 -- diferença mínima pra acionar correção (studs)
local LOCK_SPEED = 50 -- velocidade máxima de correção (studs/s)

local activeState = {} -- { [character] = { running=bool, timer=thread? } }

local function getOrCreateAttachment(root)
	local att = root:FindFirstChild(ATTACH_NAME)
	if att then
		return att
	end
	att = Instance.new("Attachment")
	att.Name = ATTACH_NAME
	att.CFrame = CFrame.identity
	att.Parent = root
	return att
end

local function removePhysics(root)
	local att = root:FindFirstChild(ATTACH_NAME)
	if att then
		att:Destroy()
	end
	local vf = root:FindFirstChild(FORCE_NAME)
	if vf then
		vf:Destroy()
	end
end

local function buildAntiGravity(root)
	local att = getOrCreateAttachment(root)
	local mass = root.AssemblyMass
	local vf = root:FindFirstChild(FORCE_NAME)
	if not vf then
		vf = Instance.new("VectorForce")
		vf.Name = FORCE_NAME
		vf.Attachment0 = att
		vf.RelativeTo = Enum.ActuatorRelativeTo.World
		vf.ApplyAtCenterOfMass = true
		vf.Parent = root
	end
	vf.Force = Vector3.new(0, workspace.Gravity * mass, 0)
	return vf
end

function AirborneService.apply(character, targetY, lock, duration)
	AirborneService.release(character)

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end

	local state = { running = true, timer = nil }
	activeState[character] = state

	buildAntiGravity(root)

	task.spawn(function()
		-- Fase 1: subir / descer até a targetY
		while state.running and root.Parent do
			local diff = targetY - root.Position.Y
			if math.abs(diff) <= LOCK_DEADZONE then
				-- Chegou — zera velocidade vertical
				for _, part in character:GetDescendants() do
					if part:IsA("BasePart") then
						local v = part.AssemblyLinearVelocity
						part.AssemblyLinearVelocity = Vector3.new(v.X, 0, v.Z)
					end
				end
				break
			end
			local vel = math.clamp(diff * LOCK_SPEED, -LOCK_SPEED, LOCK_SPEED)
			for _, part in character:GetDescendants() do
				if part:IsA("BasePart") then
					local v = part.AssemblyLinearVelocity
					part.AssemblyLinearVelocity = Vector3.new(v.X, vel, v.Z)
				end
			end
			task.wait()
		end

		if not state.running then
			return
		end

		-- Fase 2: sustentação
		if lock then
			-- Mantém na Y ativamente
			while state.running and root.Parent do
				local diff = targetY - root.Position.Y
				if math.abs(diff) > LOCK_DEADZONE then
					local vel = math.clamp(diff * LOCK_SPEED, -LOCK_SPEED, LOCK_SPEED)
					for _, part in character:GetDescendants() do
						if part:IsA("BasePart") then
							local v = part.AssemblyLinearVelocity
							part.AssemblyLinearVelocity = Vector3.new(v.X, vel, v.Z)
						end
					end
				end
				task.wait()
			end
		else
			-- Só cancela gravidade; não corrige posição
			while state.running and root.Parent do
				task.wait()
			end
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

	local root = character:FindFirstChild("HumanoidRootPart")
	if root then
		removePhysics(root)
	end
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
