--[[
	AirborneService
	src/modules/AirborneService.luau

	Módulo reutilizável que aplica gravidade reduzida a um personagem,
	dando aquele efeito de "flutuando no ar" visto em jogos como
	The Strongest Battlegrounds.

	Técnica: VectorForce no HumanoidRootPart que contrabalanceia
	parcialmente a gravidade (workspace.Gravity * mass).

	API:
	  AirborneService.suspend(character, gravityScale, duration?)
	    gravityScale: 0.0 = gravidade normal
	                 0.5 = 50% da gravidade cancelada (cai na metade)
	                 1.0 = gravidade totalmente cancelada (flutua)
	    duration: opcional — auto-release após N segundos

	  AirborneService.release(character)
	    Remove o VectorForce e restaura estado normal.

	  AirborneService.isSuspended(character) -> bool
]]

local AirborneService = {}

local FORCE_NAME = "AirborneGravityForce"
local ATTACH_NAME = "AirborneAttachment"

local activeTimers = {}

local function getOrCreateAttachment(root)
	local existing = root:FindFirstChild(ATTACH_NAME)
	if existing then
		return existing
	end
	local att = Instance.new("Attachment")
	att.Name = ATTACH_NAME
	att.CFrame = CFrame.identity
	att.Parent = root
	return att
end

local function cleanupRoot(root)
	local att = root:FindFirstChild(ATTACH_NAME)
	if att then
		att:Destroy()
	end
	local vf = root:FindFirstChild(FORCE_NAME)
	if vf then
		vf:Destroy()
	end
end

function AirborneService.suspend(character, gravityScale, duration)
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end

	AirborneService.release(character)

	local attachment = getOrCreateAttachment(root)

	local mass = root.AssemblyMass
	local counterForce = workspace.Gravity * mass * math.clamp(gravityScale, 0, 1)

	local vf = Instance.new("VectorForce")
	vf.Name = FORCE_NAME
	vf.Attachment0 = attachment
	vf.Force = Vector3.new(0, counterForce, 0)
	vf.RelativeTo = Enum.ActuatorRelativeTo.World
	vf.ApplyAtCenterOfMass = true
	vf.Parent = root

	if duration then
		local timer = task.delay(duration, function()
			activeTimers[character] = nil
			if character and character.Parent then
				AirborneService.release(character)
			end
		end)
		activeTimers[character] = timer
	end
end

function AirborneService.release(character)
	local timer = activeTimers[character]
	if timer then
		task.cancel(timer)
		activeTimers[character] = nil
	end

	local root = character:FindFirstChild("HumanoidRootPart")
	if root then
		cleanupRoot(root)
	end
end

function AirborneService.isSuspended(character)
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return false
	end
	return root:FindFirstChild(FORCE_NAME) ~= nil
end

local Players = game:GetService("Players")
Players.PlayerAdded:Connect(function(player)
	player.CharacterRemoving:Connect(function(character)
		AirborneService.release(character)
		activeTimers[character] = nil
	end)
end)

return AirborneService
