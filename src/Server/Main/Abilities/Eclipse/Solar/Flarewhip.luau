local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local ServerModules = ServerStorage.Modules
local ReplicatedModules = ReplicatedStorage.Shared.Modules

local StunHandler = require(ServerModules.StunHandler)
local DamageHandler = require(ServerModules.DamageHandler)
local iFramesService = require(ServerModules.iFramesService)
local RagdollHandler = require(ServerModules.RagdollHandler)
local BodymoverService = require(ServerModules.BodymoverService)
local PerfectKnockback = require(ServerModules.PerfectKnockback)
local WeldSystem = require(ReplicatedModules.WeldSystem)

local SEARCH_RADIUS = 300
local DAMAGE = 20
local INFERNO_DURATION = 3.5
local KICK_VELOCITY = Vector3.new(0, 30, 0)
local KICK_HORIZONTAL_FORCE = 85
local WELD_OFFSET = CFrame.new(0, 0, -3) * CFrame.Angles(0, math.pi, 0)
local PULL_OFFSET = Vector3.new(0, 0, -4)
local PULL_TIME = 0.35
local WELD_TIME = 0.15

local function isInAir(EnemyCharacter)
	if EnemyCharacter:FindFirstChild("inAir") then
		return true
	end
	local touched = EnemyCharacter:GetAttribute("TouchedGround")
	if touched and (tick() - touched) <= 0.25 then
		return true
	end
	return false
end

local function cancelAllKnockbackStates(EnemyCharacter)
	local EnemyHumanoid = EnemyCharacter:FindFirstChild("Humanoid")
	local EnemyHumRP = EnemyCharacter:FindFirstChild("HumanoidRootPart")

	PerfectKnockback:Cancel(EnemyCharacter)

	if EnemyHumRP then
		for _, v in EnemyCharacter:GetDescendants() do
			if
				v:IsA("BodyVelocity")
				or v:IsA("BodyAngularVelocity")
				or v:IsA("LinearVelocity")
				or v:IsA("AngularVelocity")
				or v:IsA("VectorForce")
				or v:IsA("Torque")
				or v:IsA("BodyPosition")
				or v:IsA("BodyGyro")
			then
				v:Destroy()
			end
		end

		for _, v in EnemyCharacter:GetDescendants() do
			if v:IsA("BasePart") then
				v.AssemblyLinearVelocity = Vector3.zero
				v.AssemblyAngularVelocity = Vector3.zero
			end
		end
	end

	if EnemyCharacter:HasTag("Ragdolled") then
		if EnemyHumanoid then
			RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, false, nil, false, true, true)
		end
	end

	EnemyCharacter:RemoveTag("Knockbacked")
end

local function applyInferno(EnemyCharacter)
	local existing = EnemyCharacter:GetAttribute("Inferno")
	EnemyCharacter:SetAttribute("Inferno", true)
	if existing then
		return
	end

	local tickStart = tick()
	local duration = INFERNO_DURATION
	local dotInterval = 0.5
	local dotDamage = 3

	task.spawn(function()
		while EnemyCharacter and EnemyCharacter.Parent and EnemyCharacter:GetAttribute("Inferno") do
			if tick() - tickStart >= duration then
				break
			end
			local Hum = EnemyCharacter:FindFirstChild("Humanoid")
			if not Hum or Hum.Health <= 0 then
				break
			end
			Hum:TakeDamage(dotDamage)
			task.wait(dotInterval)
		end
		if EnemyCharacter and EnemyCharacter.Parent then
			EnemyCharacter:SetAttribute("Inferno", nil)
		end
	end)

	task.delay(duration, function()
		if EnemyCharacter and EnemyCharacter.Parent then
			EnemyCharacter:SetAttribute("Inferno", nil)
		end
	end)
end

return {
	Start = function(Player, Tool)
		local Character = Player.Character
		if not Character then
			return
		end

		local HumRP = Character:FindFirstChild("HumanoidRootPart")
		local Humanoid = Character:FindFirstChild("Humanoid")
		if not HumRP or not Humanoid then
			return
		end

		local CasterStun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		iFramesService:AddAlliFrames(Character)

		task.wait(0.2)

		local closestEnemy = nil
		local closestDist = math.huge

		local overlapParams = OverlapParams.new()
		overlapParams.FilterType = Enum.RaycastFilterType.Include
		overlapParams.FilterDescendantsInstances = { workspace.Live }

		local parts = workspace:GetPartBoundsInRadius(HumRP.Position, SEARCH_RADIUS, overlapParams)

		for _, part in parts do
			local char = part.Parent
			if not char or char == Character then
				continue
			end
			local hum = char:FindFirstChild("Humanoid")
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if not hum or not hrp then
				continue
			end
			if hum.Health <= 0 or hum:GetState() == Enum.HumanoidStateType.Dead then
				continue
			end
			if iFramesService:HasiFrame(char, Tool.Name) then
				continue
			end
			if not isInAir(char) then
				continue
			end

			local dist = (hrp.Position - HumRP.Position).Magnitude
			if dist < closestDist then
				closestDist = dist
				closestEnemy = char
			end
		end

		if not closestEnemy then
			iFramesService:RemoveAlliFrames(Character)
			StunHandler:Unstun(Character, CasterStun)
			return
		end

		local EnemyHumanoid = closestEnemy:FindFirstChild("Humanoid")
		local EnemyHumRP = closestEnemy:FindFirstChild("HumanoidRootPart")
		local EnemyPlayer = Players:GetPlayerFromCharacter(closestEnemy)

		if not EnemyHumanoid or not EnemyHumRP then
			iFramesService:RemoveAlliFrames(Character)
			StunHandler:Unstun(Character, CasterStun)
			return
		end

		cancelAllKnockbackStates(closestEnemy)

		local VictimStun = StunHandler:Stun(closestEnemy, nil, true, 0, 0, true)
		iFramesService:AddAlliFrames(closestEnemy)
		closestEnemy:AddTag("CantRotate")
		closestEnemy:AddTag("Knockbacked")

		HumRP.CFrame =
			CFrame.lookAt(HumRP.Position, Vector3.new(EnemyHumRP.Position.X, HumRP.Position.Y, EnemyHumRP.Position.Z))

		local PullTarget = (HumRP.CFrame * CFrame.new(PULL_OFFSET)).Position

		pcall(function()
			EnemyHumRP:SetNetworkOwner(nil)
		end)

		local PullAnchor = Instance.new("Part")
		PullAnchor.Name = "FlarewhipPullAnchor"
		PullAnchor.Anchored = true
		PullAnchor.CanCollide = false
		PullAnchor.CanTouch = false
		PullAnchor.CanQuery = false
		PullAnchor.Transparency = 1
		PullAnchor.Size = Vector3.new(0.1, 0.1, 0.1)
		PullAnchor.CFrame = EnemyHumRP.CFrame
		PullAnchor.Parent = workspace

		local PullOffset = PullAnchor.CFrame:ToObjectSpace(EnemyHumRP.CFrame)
		local PullWeld = WeldSystem.new(PullAnchor, EnemyHumRP, PullOffset, -1)
		PullWeld:Start(PULL_TIME + WELD_TIME + 0.5, EnemyPlayer, Player)

		local Weld = nil

		local function doKick()
			if Weld then
				pcall(function()
					Weld:Stop()
				end)
				Weld = nil
			end

			if not closestEnemy or not closestEnemy.Parent then
				return
			end

			StunHandler:Unstun(closestEnemy, VictimStun)
			iFramesService:RemoveAlliFrames(closestEnemy)
			closestEnemy:RemoveTag("CantRotate")
			closestEnemy:RemoveTag("Knockbacked")

			DamageHandler:TakeDamage(Character, EnemyHumanoid, DAMAGE, nil, nil, true, true, true, true, true, nil, nil)

			EnemyHumRP.AssemblyLinearVelocity = Vector3.zero
			EnemyHumRP.AssemblyAngularVelocity = Vector3.zero

			local kickDir = HumRP.CFrame.LookVector
			local kickFlat = Vector3.new(kickDir.X, 0, kickDir.Z)

			if kickFlat.Magnitude < 0.1 then
				kickFlat = Vector3.new(0, 0, -1)
			else
				kickFlat = kickFlat.Unit
			end

			RagdollHandler.ragdoll(EnemyHumanoid, 2, nil, nil, nil, nil, true)

			task.defer(function()
				if not closestEnemy or not closestEnemy.Parent then
					return
				end

				BodymoverService:Knockback(closestEnemy, {
					KnockbackType = "Velocity",
					MaxForce = Vector3.new(1, 1, 1) * 100000,
					Velocity = kickFlat * KICK_HORIZONTAL_FORCE + KICK_VELOCITY,
				})
			end)

			applyInferno(closestEnemy)

			if EnemyPlayer then
				ReplicatedStorage.Remotes.Replicate.Set:FireClient(
					EnemyPlayer,
					"ShakeCamera",
					{ Intensity = 4, Last = 0.4 }
				)
			end

			iFramesService:RemoveAlliFrames(Character)
			StunHandler:Unstun(Character, CasterStun)
		end

		local function afterPull()
			pcall(function()
				PullWeld:Stop()
			end)
			PullAnchor:Destroy()

			if not closestEnemy or not closestEnemy.Parent then
				return
			end

			cancelAllKnockbackStates(closestEnemy)
			closestEnemy:AddTag("CantRotate")
			closestEnemy:AddTag("Knockbacked")

			HumRP.CFrame = CFrame.lookAt(
				HumRP.Position,
				Vector3.new(EnemyHumRP.Position.X, HumRP.Position.Y, EnemyHumRP.Position.Z)
			)

			Weld = WeldSystem.new(HumRP, EnemyHumRP, WELD_OFFSET, -1)
			Weld:Start(WELD_TIME, EnemyPlayer, Player)

			task.delay(WELD_TIME, doKick)
		end

		local PullTween = TweenService:Create(
			PullAnchor,
			TweenInfo.new(PULL_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ CFrame = CFrame.new(PullTarget, PullTarget + HumRP.CFrame.LookVector) }
		)
		PullTween.Completed:Once(afterPull)
		PullTween:Play()
	end,
}
