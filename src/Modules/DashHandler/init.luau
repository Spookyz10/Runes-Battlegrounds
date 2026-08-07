local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local SvModules = ServerStorage.Modules

local StunHandler = require(SvModules.StunHandler)
local iFramesService = require(SvModules.iFramesService)
local AnimationService = require(SvModules.AnimationService)
local HitboxHandler = require(SvModules.HitboxHandler)
local DamageHandler = require(SvModules.DamageHandler)
local PerfectKnockback = require(SvModules.PerfectKnockback)
local RagdollHandler = require(SvModules.RagdollHandler)
local StatusEffectHandler = require(SvModules.StatusEffectHandler)
local CooldownSystem = require(SvModules.CooldownSystem)
local EvasiveService = require(SvModules.EvasiveService)
local SFX = require(SvModules.SFXModule)
local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)
local CheckBehind = require(ReplicatedStorage.Shared.Modules.Utility.CheckBehind)

local Configs = require(script.Configs)

local DashHandler = {}

local function getConfig(Player, Direction)
	local Moveset = Player:GetAttribute("Moveset") or "Default"
	local MovesetConfigs = Configs[Moveset] or Configs.Default
	return MovesetConfigs[Direction]
end

local function resolveNearEnemies(Character, HumRP, Radius)
	local Near = {}
	for _, Other in workspace.Live:GetChildren() do
		if Other == Character then
			continue
		end
		local OtherHumRP = Other:FindFirstChild("HumanoidRootPart")
		if OtherHumRP and (OtherHumRP.Position - HumRP.Position).Magnitude < Radius then
			table.insert(Near, Other)
		end
	end
	return Near
end

local function runAttackDash(Player, Character, HumRP, Humanoid, Config)
	local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
	local NearEnemys = resolveNearEnemies(Character, HumRP, Config.NearEnemyRadius or 15)
	local PreventVelocity = #NearEnemys > 0
	local KnockbackApplied = false
	local Hit = false
	local Ended = false

	local Animation = Config.Animation()
	local AnimTrack, AnimEvents = AnimationService:getAnimationTrack(Character, Animation)
	if not AnimTrack then
		StunHandler:Unstun(Character, Stun)
		return
	end

	local Velocity
	if not PreventVelocity then
		Velocity = Instance.new("BodyVelocity")
		Velocity.Name = Config.Id .. "Velocity"
		Velocity.MaxForce = Vector3.new(Config.Speed, 0, Config.Speed)
	end

	local function endDash()
		if Ended then
			return
		end
		Ended = true
		Character:SetAttribute("Dashing", false)
		if Velocity and Velocity.Parent then
			Velocity:Destroy()
		end
		AnimTrack:AdjustSpeed(1)
	end

	table.insert(
		AnimEvents,
		AnimTrack:GetMarkerReachedSignal("freeze"):Once(function()
			if Ended then
				AnimTrack:AdjustSpeed(1)
				return
			end
			AnimTrack:AdjustSpeed(0)
		end)
	)

	if not PreventVelocity then
		table.insert(
			AnimEvents,
			AnimTrack:GetMarkerReachedSignal("jump"):Once(function()
				if PreventVelocity then
					return
				end
				Velocity.Parent = HumRP
				Debris:AddItem(Velocity, 0.85)
			end)
		)
	end

	table.insert(
		AnimEvents,
		AnimTrack:GetMarkerReachedSignal("hit"):Once(function()
			local HitAnims = Config.HitAnimations and Config.HitAnimations()
			SFX:Play(Config.HitSound or "Hit", HumRP)

			HitboxHandler:SimpleOnce(
				HumRP,
				Config.Hitbox.Size,
				Config.Hitbox.Offset,
				{ Character },
				nil,
				nil,
				function(EnemyCharacter)
					local EnemyHumanoid = EnemyCharacter.Humanoid
					local EnemyHumRP = EnemyCharacter.HumanoidRootPart

					if EnemyHumanoid.Health <= 0 or iFramesService:HasiFrame(EnemyCharacter, "M1") then
						return
					end

					local HitInfo = DamageHandler:TakeDamage(
						Character,
						EnemyHumanoid,
						Config.Damage,
						Config.StunTime,
						HitAnims and HitAnims[tostring(math.random(1, 3))],
						true,
						true,
						true
					)

					if HitInfo.Countered then
						return
					end

					Hit = true

					local IsNear = table.find(NearEnemys, EnemyCharacter) ~= nil
					local BehindOk, IsBehind = pcall(CheckBehind, HumRP, EnemyHumRP)
					IsBehind = BehindOk and IsBehind or false

					if (IsNear or IsBehind) and not PreventVelocity then
						PreventVelocity = true
						if Velocity and Velocity.Parent then
							Velocity:Destroy()
						end
						HumRP.AssemblyLinearVelocity = Vector3.zero
					end

					if not KnockbackApplied then
						KnockbackApplied = true

						if EnemyCharacter:HasTag("Ragdolled") then
							RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, false, nil, false, true)
						end

						EnemyHumRP.AssemblyLinearVelocity = Vector3.zero

						local Forward = HumRP.CFrame.LookVector
						local LookCFrame =
							CFrame.lookAt(HumRP.Position, HumRP.Position + Vector3.new(Forward.X, 0, Forward.Z))
						local Dot = LookCFrame.LookVector:Dot((EnemyHumRP.Position - HumRP.Position).Unit)
						if EnemyHumanoid.FloorMaterial ~= Enum.Material.Air then
							Dot = 1
						end

						local KB = Config.Knockback
						local Ok, Err = pcall(function()
							PerfectKnockback:KnockBack(nil, EnemyCharacter, {
								LookVector = LookCFrame.LookVector,
								LookForce = KB.LookForce,
								LookFinalForce = KB.LookFinalForce,
								LookAt = LookCFrame,
								GroundStunTime = KB.GroundStunTime,
								Escapable = KB.Escapable,
								FallingDetectDelay = KB.FallingDetectDelay,
								Dot = Dot,
								DotParams = KB.DotParams,
							}, Character)
						end)
						if not Ok then
							warn("[DashHandler] KnockBack failed: " .. tostring(Err))
						end
					end
				end
			)

			if Hit then
				task.delay(0.05, function()
					StunHandler:Unstun(Character, Stun)
				end)
			end
		end)
	)

	AnimTrack.Stopped:Once(function()
		for _, v in AnimEvents do
			v:Disconnect()
		end
		StunHandler:Unstun(Character, Stun)
		if not Hit then
			RemoteManager.FireAllClients(
				"ReplicateTask",
				"DashMiss",
				{ PrimaryPart = HumRP, YAngle = math.pi, Front = true }
			)
		end
	end)

	AnimationService:stopAll(Character)
	AnimationService:playAnimation(Character, Animation)

	Character:SetAttribute("Dashing", true)
	RemoteManager.FireAllClients("ReplicateTask", "ActionHightlight", { char = Character, func = "Dash" })
	RemoteManager.FireAllClients("ReplicateTask", "DashMiss", { PrimaryPart = HumRP })

	task.delay(0.7, function()
		HumRP.AssemblyLinearVelocity = Vector3.new()
		endDash()
	end)

	task.delay(1.25, function()
		if Stun and Stun.Parent == Character then
			AnimTrack:AdjustSpeed(1)
			StunHandler:Unstun(Character, Stun)
		end
	end)
end

local function runDisplacementDash(Player, Character, HumRP, Humanoid, Config)
	local Duration = Config.Duration or 1.017

	StunHandler:Stun(Character, Duration, true, 0, 0, true)

	if Config.IFrames then
		iFramesService:AddBaseiFrames(Character)
		task.delay(Duration, function()
			iFramesService:RemoveiFrames(Character, "Base")
		end)
	end

	SFX:Play(Config.Sound or "Dash", HumRP)

	local IsTeleport = StatusEffectHandler:Has(Character, "TpDash")

	if IsTeleport then
		RemoteManager.FireClient(
			Player,
			"ReplicateTask",
			"DashTeleport",
			{ Direction = Config.Id, Duration = Duration }
		)
	else
		RemoteManager.FireAllClients("ReplicateTask", "DashDebris", { func = "Start", char = Character })
		task.delay(Duration, function()
			RemoteManager.FireAllClients("ReplicateTask", "DashDebris", { func = "Stop", char = Character })
		end)
	end

	RemoteManager.FireAllClients("ReplicateTask", "ActionHightlight", { char = Character, func = "Dash" })

	local Animation = Config.Animation and Config.Animation()
	if Animation then
		AnimationService:playAnimation(Character, Animation)
	end
end

function DashHandler:Dash(Player, Direction)
	local Character = Player.Character
	if not Character then
		return
	end

	local Humanoid = Character:FindFirstChild("Humanoid")
	local HumRP = Character:FindFirstChild("HumanoidRootPart")
	if not Humanoid or not HumRP then
		return
	end

	local Trapped = EvasiveService:IsTrapped(Character)

	if Direction == "Front" and Trapped then
		local Side = HumRP.CFrame.RightVector:Dot(Humanoid.MoveDirection)
		Direction = Side < 0 and "Left" or "Right"
	end

	if Trapped then
		if not EvasiveService:CanEscape(Character) then
			return
		end
		if not EvasiveService:Escape(Character) then
			return
		end
	else
		if Character:HasTag("Stunned") then
			return
		end
		if CooldownSystem:IsOnCooldown(Character, "Dash_" .. Direction) then
			return
		end
	end

	local Config = getConfig(Player, Direction)
	if not Config then
		warn("[DashHandler] No dash config for direction " .. Direction)
		return
	end

	CooldownSystem:Set(Character, "Dash_" .. Direction, Config.Cooldown or 2)
	RemoteManager.FireClient(Player, "ExtraCds", Direction .. "Dash", Config.Cooldown or 2)

	if Config.Type == "Attack" then
		runAttackDash(Player, Character, HumRP, Humanoid, Config)
	else
		runDisplacementDash(Player, Character, HumRP, Humanoid, Config)
	end
end

return DashHandler
