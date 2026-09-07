local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local ServerModules = ServerStorage.Modules

local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)
local SFXModule = require(ReplicatedStorage.Shared.Modules.SFXModule)
local StunHandler = require(ServerModules.StunHandler)
local RagdollHandler = require(ServerModules.RagdollHandler)
local DamageHandler = require(ServerModules.DamageHandler)
local SkillCancelHandler = require(ServerModules.SkillCancelHandler)
local iFramesService = require(ServerModules.iFramesService)
local HitboxHandler = require(ServerModules.HitboxHandler)
local AnimationService = require(ServerModules.AnimationService)
local CharacterLifetime = require(ServerModules.CharacterLifetime)

local MoveAnims = ServerStorage.Assets.Animations.Moves

local COOLDOWN = 20

local HAND_TRAVEL_TIME = 0.5
local HAND_START_DIST = 3
local HAND_END_DIST = 20
local HITBOX_SIZE = Vector3.new(10, 10, 20)

local HAND_DAMAGE = 5
local PULL_DAMAGE = 5

local PULL_DISTANCE = 3
local PULL_TIME = 0.35
local PULL_STUN_TIME = 2

local Marks = {}
local PullAvailable = {}

local function clearMark(EnemyCharacter, Silent)
	local Entry = Marks[EnemyCharacter]
	if not Entry then
		return
	end
	Marks[EnemyCharacter] = nil
	if Entry.DisconnectOwner then
		Entry.DisconnectOwner()
	end
	if Entry.DisconnectVictim then
		Entry.DisconnectVictim()
	end

	if Entry.ExpireThread then
		pcall(task.cancel, Entry.ExpireThread)
	end

	if not Silent and EnemyCharacter and EnemyCharacter.Parent then
		EnemyCharacter:SetAttribute("ShadowMark", nil)
		RemoteManager.FireAllClients(
			"ReplicateTask",
			"AuraFX",
			{ func = "End", char = EnemyCharacter, aura = "ShadowMark" }
		)
	end
end

local function setMark(EnemyCharacter, CasterCharacter, CasterPlayer)
	clearMark(EnemyCharacter)

	EnemyCharacter:SetAttribute("ShadowMark", true)
	RemoteManager.FireAllClients(
		"ReplicateTask",
		"AuraFX",
		{ func = "Start", char = EnemyCharacter, aura = "ShadowMark" }
	)

	local Entry = {
		OwnerCharacter = CasterCharacter,
		OwnerPlayer = CasterPlayer,
	}

	Entry.ExpireThread = task.delay(COOLDOWN, function()
		Entry.ExpireThread = nil
		if Marks[EnemyCharacter] == Entry then
			clearMark(EnemyCharacter)
		end
	end)

	Marks[EnemyCharacter] = Entry

	Entry.DisconnectOwner = CharacterLifetime.Watch(CasterCharacter, function()
		if Marks[EnemyCharacter] == Entry then
			clearMark(EnemyCharacter)
		end
	end)
	Entry.DisconnectVictim = CharacterLifetime.Watch(EnemyCharacter, function()
		if Marks[EnemyCharacter] == Entry then
			clearMark(EnemyCharacter)
		end
	end)
end

local function releasePulled(EnemyCharacter, CasterCharacter, FreezeToken)
	local EnemyHumanoid = EnemyCharacter:FindFirstChild("Humanoid")
	local EnemyHumRP = EnemyCharacter:FindFirstChild("HumanoidRootPart")

	if FreezeToken then
		StunHandler:Unstun(EnemyCharacter, FreezeToken)
	end

	if not EnemyCharacter.Parent or not EnemyHumanoid or not EnemyHumRP then
		return
	end

	EnemyHumRP.AssemblyLinearVelocity = Vector3.zero
	EnemyHumRP.AssemblyAngularVelocity = Vector3.zero

	if EnemyHumanoid.Health > 0 and CasterCharacter.Parent then
		DamageHandler:TakeDamage(
			CasterCharacter,
			EnemyHumanoid,
			PULL_DAMAGE,
			nil,
			nil,
			false,
			false,
			true,
			true,
			false,
			nil,
			nil
		)
	end

	EnemyHumanoid.PlatformStand = false
	EnemyHumanoid.AutoRotate = true
	if EnemyHumanoid.Health > 0 then
		EnemyHumanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
		StunHandler:Stun(EnemyCharacter, PULL_STUN_TIME, true, 0, 0, true)
	end
end

return {
	Cooldown = COOLDOWN,

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

		PullAvailable[Character] = true
		Character.Destroying:Once(function()
			PullAvailable[Character] = nil
		end)

		Humanoid.WalkSpeed = 0

		local casterStun = StunHandler:Stun(Character, nil, true, 0, 0, true, nil, false)
		local cancelled = false
		local onDamageCancel

		local hitList = {}
		local hitbox = nil
		local HitboxPart = nil
		local travelConn = nil
		local disconnectHand

		local function tryMark(enemyChar)
			if table.find(hitList, enemyChar) then
				return
			end

			local EnemyHum = enemyChar:FindFirstChild("Humanoid")
			local EnemyHumRP = enemyChar:FindFirstChild("HumanoidRootPart")

			if not EnemyHum or not EnemyHumRP then
				return
			end
			if EnemyHum.Health <= 0 then
				return
			end
			if iFramesService:HasiFrame(enemyChar, 1) then
				return
			end

			local HitInfo = DamageHandler:TakeDamage(
				Character,
				EnemyHum,
				HAND_DAMAGE,
				nil,
				nil,
				true,
				true,
				true,
				true,
				false,
				nil,
				nil
			)

			if HitInfo.Countered or HitInfo.Blocked then
				return
			end

			table.insert(hitList, enemyChar)

			SFXModule:Play("graspHit", EnemyHumRP)

			setMark(enemyChar, Character, Player)
		end

		local function stopHand()
			if disconnectHand then
				disconnectHand()
				disconnectHand = nil
			end
			if travelConn then
				travelConn:Disconnect()
				travelConn = nil
			end
			if hitbox then
				hitbox:Stop()
				hitbox = nil
			end
			if HitboxPart and HitboxPart.Parent then
				HitboxPart:Destroy()
			end
			HitboxPart = nil
		end

		local cleanedUp = false
		local function doFullCleanup()
			if cleanedUp then
				return
			end
			cleanedUp = true

			StunHandler:Unstun(Character, casterStun)
			SkillCancelHandler:Unregister(Character, onDamageCancel)
			iFramesService:RemoveiFrames(Character, "Base")
			if Humanoid and Humanoid.Parent then
				Humanoid.WalkSpeed = 16
			end
		end

		local UserAnimation = MoveAnims.Eclipse.Lunar.Grasp
		local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)

		if not UserTrack then
			stopHand()
			doFullCleanup()
			return
		end

		onDamageCancel = function()
			if cancelled then
				return
			end
			cancelled = true
			stopHand()
			if UserTrack and UserTrack.IsPlaying then
				UserTrack:Stop()
			end
		end

		SkillCancelHandler:Register(Character, onDamageCancel)

		table.insert(
			UserEvents,
			UserTrack:GetMarkerReachedSignal("summon"):Once(function()
				if cancelled or cleanedUp then
					return
				end
				disconnectHand = CharacterLifetime.Watch(Character, stopHand)
				SkillCancelHandler:Unregister(Character, onDamageCancel)
				iFramesService:AddiFrames(Character, "Base")

				SFXModule:Play("graspTravel", HumRP)

				local lv = HumRP.CFrame.LookVector
				local lookFlat = Vector3.new(lv.X, 0, lv.Z).Unit
				local originPos = HumRP.Position

				RemoteManager.FireAllClients("ReplicateTask", "hand", {
					char = Character,
					position = originPos + Vector3.new(0, -2, 0),
					direction = lookFlat,
					duration = HAND_TRAVEL_TIME,
					startDist = HAND_START_DIST,
					endDist = HAND_END_DIST,
				})

				HitboxPart = Instance.new("Part")
				HitboxPart.Name = "GraspHandHitbox"
				HitboxPart.Anchored = true
				HitboxPart.CanCollide = false
				HitboxPart.CanTouch = false
				HitboxPart.Transparency = 1
				HitboxPart.Size = HITBOX_SIZE
				HitboxPart.CFrame = CFrame.new(
					originPos + lookFlat * HAND_START_DIST,
					originPos + lookFlat * HAND_START_DIST + lookFlat
				)
				HitboxPart.Parent = workspace

				hitbox = HitboxHandler.new()
				hitbox.Instance = HitboxPart
				hitbox.Size = HITBOX_SIZE
				hitbox.Ignore = { Character }
				hitbox.ResetCharactersList = true
				hitbox.onTouch = tryMark

				local startTime = os.clock()
				travelConn = RunService.Heartbeat:Connect(function()
					local t = math.clamp((os.clock() - startTime) / HAND_TRAVEL_TIME, 0, 1)
					local dist = HAND_START_DIST + (HAND_END_DIST - HAND_START_DIST) * t
					local center = originPos + lookFlat * dist

					if HitboxPart and HitboxPart.Parent then
						HitboxPart.CFrame = CFrame.new(center, center + lookFlat)
					end

					if t >= 1 then
						stopHand()
					end
				end)

				hitbox:Start()

				if UserTrack and UserTrack.IsPlaying then
					UserTrack:Stop()
				end
			end)
		)

		UserTrack.Stopped:Once(function()
			for _, v in UserEvents do
				v:Disconnect()
			end

			doFullCleanup()
		end)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, UserAnimation)
	end,

	TryPull = function(Player, Tool)
		local Character = Player.Character
		if not Character then
			return
		end

		local HumRP = Character:FindFirstChild("HumanoidRootPart")
		local Humanoid = Character:FindFirstChild("Humanoid")
		if not HumRP or not Humanoid or Humanoid.Health <= 0 then
			return
		end

		if not PullAvailable[Character] then
			return
		end

		local targets = {}
		for EnemyCharacter, Entry in Marks do
			if Entry.OwnerCharacter == Character and EnemyCharacter and EnemyCharacter.Parent then
				table.insert(targets, EnemyCharacter)
			end
		end

		if #targets == 0 then
			return
		end

		PullAvailable[Character] = false

		local lookFlat = HumRP.CFrame.LookVector
		lookFlat = Vector3.new(lookFlat.X, 0, lookFlat.Z)
		lookFlat = lookFlat.Magnitude > 0 and lookFlat.Unit or Vector3.new(0, 0, -1)

		local targetPos = HumRP.Position + lookFlat * PULL_DISTANCE
		local targetCFrame = CFrame.new(targetPos, HumRP.Position)

		SFXModule:Play("graspPull", HumRP)

		for _, EnemyCharacter in targets do
			local EnemyHumRP = EnemyCharacter:FindFirstChild("HumanoidRootPart")
			local EnemyHumanoid = EnemyCharacter:FindFirstChild("Humanoid")

			clearMark(EnemyCharacter)

			if EnemyHumRP and EnemyHumanoid and EnemyHumanoid.Health > 0 then
				if EnemyCharacter:HasTag("Ragdolled") then
					RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, false, nil, true, true, false)
				end

				EnemyHumRP.AssemblyLinearVelocity = Vector3.zero
				EnemyHumRP.AssemblyAngularVelocity = Vector3.zero
				EnemyHumanoid:ChangeState(Enum.HumanoidStateType.PlatformStanding)

				local freezeToken = StunHandler:Stun(EnemyCharacter, PULL_TIME + 1, true, 0, 0, true)

				SFXModule:Play("graspPull", EnemyHumRP)

				TweenService:Create(
					EnemyHumRP,
					TweenInfo.new(PULL_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
					{ CFrame = targetCFrame }
				):Play()

				task.delay(PULL_TIME, function()
					releasePulled(EnemyCharacter, Character, freezeToken)
				end)
			end
		end
	end,
}
