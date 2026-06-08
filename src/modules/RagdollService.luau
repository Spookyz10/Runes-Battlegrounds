local RagdollService = {}

local RAGDOLL_ATTR = "Ragdolled"
local CONSTRAINT_ATTR = "RagdollConstraint"
local ATTACH_ATTR = "RagdollAttachment"

local function buildConstraints(character)
	for _, motor in character:GetDescendants() do
		if not motor:IsA("Motor6D") then
			continue
		end
		if not motor.Part0 or not motor.Part1 then
			continue
		end

		local a0 = Instance.new("Attachment")
		a0.CFrame = motor.C0
		a0.Parent = motor.Part0
		a0:SetAttribute(ATTACH_ATTR, true)

		local a1 = Instance.new("Attachment")
		a1.CFrame = motor.C1
		a1.Parent = motor.Part1
		a1:SetAttribute(ATTACH_ATTR, true)

		local constraint = Instance.new("BallSocketConstraint")
		constraint.Attachment0 = a0
		constraint.Attachment1 = a1
		constraint.LimitsEnabled = true
		constraint.TwistLimitsEnabled = true
		constraint.UpperAngle = 60
		constraint.TwistUpperAngle = 90
		constraint:SetAttribute(CONSTRAINT_ATTR, true)
		constraint.Parent = motor.Part0

		motor.Enabled = false
	end
end

local function destroyConstraints(character)
	local toDestroy = {}
	for _, desc in character:GetDescendants() do
		if
			(desc:IsA("BallSocketConstraint") and desc:GetAttribute(CONSTRAINT_ATTR))
			or (desc:IsA("Attachment") and desc:GetAttribute(ATTACH_ATTR))
		then
			toDestroy[#toDestroy + 1] = desc
		end
	end
	for _, inst in toDestroy do
		inst:Destroy()
	end
end

local function restoreMotors(character)
	for _, motor in character:GetDescendants() do
		if motor:IsA("Motor6D") then
			motor.Enabled = true
		end
	end
end

function RagdollService.isRagdolled(character)
	return character:GetAttribute(RAGDOLL_ATTR) == true
end

--[[
	RagdollService.apply(character, duration?)
	  Aplica ragdoll puro, sem velocidade.
	  Use KnockbackService separadamente se quiser knockback.
]]
function RagdollService.apply(character, duration)
	if RagdollService.isRagdolled(character) then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	character:SetAttribute(RAGDOLL_ATTR, true)
	humanoid.RequiresNeck = false
	humanoid.PlatformStand = true
	humanoid:ChangeState(Enum.HumanoidStateType.Physics)
	buildConstraints(character)

	if duration then
		task.delay(duration, function()
			if character:GetAttribute(RAGDOLL_ATTR) then
				RagdollService.remove(character)
			end
		end)
	end
end

function RagdollService.remove(character)
	if not RagdollService.isRagdolled(character) then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	character:SetAttribute(RAGDOLL_ATTR, false)
	destroyConstraints(character)
	restoreMotors(character)
	humanoid.PlatformStand = false
	humanoid.RequiresNeck = true
	humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
end

-- Aliases para compatibilidade
RagdollService.applyRagdoll = RagdollService.apply
RagdollService.removeRagdoll = RagdollService.remove

return RagdollService
