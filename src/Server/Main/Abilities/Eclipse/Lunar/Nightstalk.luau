local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local ServerModules = ServerStorage.Modules

local StunHandler = require(ServerModules.StunHandler)
local HitboxHandler = require(ServerModules.HitboxHandler)
local DamageHandler = require(ServerModules.DamageHandler)
local AnimationService = require(ServerModules.AnimationService)
local iFramesService = require(ServerModules.iFramesService)
local KnockbackModules = require(ServerModules.KnockbackModule)
local BodymoverService = require(ServerModules.BodymoverService)

local ReplicatedHitboxes = require(ServerModules.ReplicatedHitboxes)

local MoveAnims = ServerStorage.Assets.Animations.Moves
local ReplicateSet = ReplicatedStorage.Remotes.Replicate.Set

local DASH_SPEED = 90
local FREEZE_TIMEOUT = 1
local CLOSE_UPPERCUT_SIZE = Vector3.new(10, 10, 10)
local CLOSE_UPPERCUT_OFFSET = CFrame.new(0, 0, -4)
local UPPERCUT_DAMAGE = 18
local UPPERCUT_STUN = 1.5
local UPPERCUT_UP_FORCE = 85

return {
	Start = function(Player, Tool)
		local Character = Player.Character
		local HumRP = Character.HumanoidRootPart

		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		iFramesService:AddAlliFrames(Character)

		local function isValidEnemy(EnemyCharacter)
			local EnemyHumanoid = EnemyCharacter and EnemyCharacter:FindFirstChild("Humanoid")
			local EnemyHumRP = EnemyCharacter and EnemyCharacter:FindFirstChild("HumanoidRootPart")
			if not EnemyHumanoid or not EnemyHumRP then
				return false
			end

			local Ragdolled = EnemyCharacter:HasTag("Ragdolled")
			local inAir = EnemyCharacter:FindFirstChild("inAir")
				or (
					EnemyCharacter:GetAttribute("TouchedGround")
					and tick() - EnemyCharacter:GetAttribute("TouchedGround") <= 0.25
				)

			return not iFramesService:HasiFrame(EnemyCharacter, Tool.Name)
				and EnemyHumanoid.Health > 0
				and EnemyHumanoid:GetState() ~= Enum.HumanoidStateType.Dead
				and not (Ragdolled and not inAir)
		end

		local function findCloseEnemy()
			local CloseEnemy = nil

			HitboxHandler:SimpleOnce(
				HumRP,
				CLOSE_UPPERCUT_SIZE,
				CLOSE_UPPERCUT_OFFSET,
				{ Character },
				"Box",
				"Single",
				function(EnemyCharacter)
					if isValidEnemy(EnemyCharacter) then
						CloseEnemy = EnemyCharacter
					end
				end
			)

			return CloseEnemy
		end

		local function doCloseUppercut(EnemyCharacter)
			local EnemyHumanoid = EnemyCharacter.Humanoid
			local EnemyHumRP = EnemyCharacter.HumanoidRootPart
			local EnemyPlayer = Players:GetPlayerFromCharacter(EnemyCharacter)
			local UppercutAnimation = ServerStorage.Assets.Animations.Combat.Punches.Uppercut
			local UppercutTrack = AnimationService:getAnimationTrack(Character, UppercutAnimation)
			local HitApplied = false

			local function cleanup()
				iFramesService:RemoveAlliFrames(Character)
				StunHandler:Unstun(Character, Stun)
			end

			local function applyUppercut()
				if HitApplied or not isValidEnemy(EnemyCharacter) then
					return
				end
				HitApplied = true

				ReplicateSet:FireClient(Player, "ShakeCamera", { Intensity = 1, Last = 0.3 })

				local HitInfo = DamageHandler:TakeDamage(
					Character,
					EnemyHumanoid,
					UPPERCUT_DAMAGE,
					UPPERCUT_STUN,
					nil,
					true,
					true,
					true,
					true,
					true,
					nil,
					nil
				)

				if HitInfo.Countered or HitInfo.Blocked then
					return
				end

				EnemyHumRP.AssemblyLinearVelocity = Vector3.zero
				BodymoverService:makeEnemyFaceCharacter(EnemyCharacter, Character)

				local BodyAngularVelocity = Instance.new("BodyAngularVelocity")
				BodyAngularVelocity.MaxTorque = Vector3.new(50000, 50000, 50000)
				BodyAngularVelocity.AngularVelocity =
					Vector3.new(math.random(2.5, 5), math.random(2.5, 5), math.random(2.5, 5))
				BodyAngularVelocity.Parent = EnemyHumRP
				Debris:AddItem(BodyAngularVelocity, 0.1)

				BodymoverService:Knockback(EnemyCharacter, {
					KnockbackType = "Velocity",
					MaxForce = Vector3.new(0, 1, 0) * 10000,
					Velocity = Vector3.new(0, UPPERCUT_UP_FORCE, 0),
				})

				ServerStorage.Bindables.AirDetector:Fire(EnemyCharacter, nil, true, nil, 6.2)

				if EnemyPlayer then
					ReplicateSet:FireClient(EnemyPlayer, "ShakeCamera", { Intensity = 2, Last = 0.3 })
				end
			end

			UppercutTrack:GetMarkerReachedSignal("hit"):Once(applyUppercut)
			UppercutTrack.Stopped:Once(function()
				applyUppercut()
				cleanup()
			end)

			task.delay(0.2, applyUppercut)

			AnimationService:stopAll(Character)
			AnimationService:playAnimation(Character, UppercutAnimation)
		end

		local CloseEnemy = findCloseEnemy()
		if CloseEnemy then
			doCloseUppercut(CloseEnemy)
			return
		end

		local Hit = false
		local Frozen = false
		local HitCharacter = nil

		ReplicateSet:FireAllClients("LunarDash", { char = Character })
		ReplicateSet:FireAllClients("Ground Crater", {
			start = Character.PrimaryPart,
			Seed = math.random(1, 2147483647),
			["end"] = Vector3.new(0, -7, 0),
			nosound = true,
		})
		ReplicateSet:FireClient(Player, "ShakeCamera", { Intensity = 1, Last = 0.3 })
		ReplicateSet:FireClient(Player, "createLungeVelocity", { Speed = DASH_SPEED, DashDuration = FREEZE_TIMEOUT })

		local function destroyVelocity()
			ReplicateSet:FireClient(Player, "deleteLungeVelocity", {})
		end

		local UserAnimation = MoveAnims.Eclipse.Lunar:FindFirstChild("Lunar Lunge")
		local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)

		local Hitbox = ReplicatedHitboxes.new(Player)
		Hitbox.Instance = HumRP
		Hitbox.Size = Vector3.new(10, 10, 14)
		Hitbox.Offset = CFrame.new(0, 0, -7)
		Hitbox.Ignore = { Character }

		local function destroyHitbox()
			if Hitbox and type(Hitbox.Destroy) == "function" then
				Hitbox:Destroy()
			elseif Hitbox and type(Hitbox.Stop) == "function" then
				Hitbox:Stop()
			end
		end

		local function applyHit(EnemyCharacter)
			local EnemyHumanoid = EnemyCharacter.Humanoid
			local EnemyHumRP = EnemyCharacter.HumanoidRootPart
			local EnemyPlayer = Players:GetPlayerFromCharacter(EnemyCharacter)

			local SlashCF = HumRP.CFrame
			local HitList = { EnemyCharacter }

			ReplicateSet:FireClient(Player, "ShakeCamera", { Intensity = 1, Last = 0.3 })

			local HitInfo =
				DamageHandler:TakeDamage(Character, EnemyHumanoid, 18, 1.5, nil, true, true, true, true, true, nil, nil)

			if not HitInfo.Countered and not HitInfo.Blocked then
				local PushDir = (EnemyHumRP.Position - SlashCF.Position)
				PushDir = Vector3.new(PushDir.X, 0, PushDir.Z)
				if PushDir.Magnitude > 0 then
					PushDir = PushDir.Unit
				else
					PushDir = HumRP.CFrame.LookVector
				end

				KnockbackModules:Knockback(
					EnemyCharacter,
					PushDir * 100 + Vector3.new(0, 18, 0),
					nil,
					nil,
					nil,
					nil,
					false
				)

				if EnemyPlayer then
					ReplicateSet:FireClient(EnemyPlayer, "ShakeCamera", { Intensity = 2, Last = 0.3 })
				end
			end

			HitboxHandler:SimpleOnce(
				SlashCF,
				25,
				CFrame.new(0, 0, 0),
				{ Character },
				"Sphere",
				nil,
				function(OtherCharacter)
					if table.find(HitList, OtherCharacter) then
						return
					end
					if iFramesService:HasiFrame(OtherCharacter, Tool.Name) then
						return
					end

					local OtherHumanoid = OtherCharacter.Humanoid
					local OtherHumRP = OtherCharacter.HumanoidRootPart
					local OtherPlayer = Players:GetPlayerFromCharacter(OtherCharacter)

					if OtherHumanoid.Health <= 0 or OtherCharacter:HasTag("Ragdolled") then
						return
					end

					table.insert(HitList, OtherCharacter)

					local OtherHitInfo = DamageHandler:TakeDamage(
						Character,
						OtherHumanoid,
						18,
						1.5,
						nil,
						true,
						true,
						true,
						true,
						true,
						nil,
						nil
					)

					if OtherHitInfo.Countered or OtherHitInfo.Blocked then
						return
					end

					local PushDir = (OtherHumRP.Position - SlashCF.Position)
					PushDir = Vector3.new(PushDir.X, 0, PushDir.Z)
					if PushDir.Magnitude > 0 then
						PushDir = PushDir.Unit
					else
						PushDir = HumRP.CFrame.LookVector
					end

					KnockbackModules:Knockback(
						OtherCharacter,
						PushDir * 100 + Vector3.new(0, 18, 0),
						nil,
						nil,
						nil,
						nil,
						false
					)

					if OtherPlayer then
						ReplicateSet:FireClient(OtherPlayer, "ShakeCamera", { Intensity = 2, Last = 0.3 })
					end
				end
			)
		end

		Hitbox.onTouch = function(EnemyCharacter)
			if Hit then
				return
			end

			if not isValidEnemy(EnemyCharacter) then
				return
			end

			Hit = true
			HitCharacter = EnemyCharacter
			destroyHitbox()
			destroyVelocity()

			if Frozen then
				Frozen = false
				UserTrack:AdjustSpeed(1)
			else
				applyHit(EnemyCharacter)
			end
		end

		Hitbox:Start()

		table.insert(
			UserEvents,
			UserTrack:GetMarkerReachedSignal("freeze"):Once(function()
				if Hit then
					return
				end

				Frozen = true
				UserTrack:AdjustSpeed(0)

				task.delay(FREEZE_TIMEOUT, function()
					if not Hit then
						Frozen = false

						UserTrack:AdjustSpeed(1)
					end
				end)
			end)
		)

		table.insert(
			UserEvents,
			UserTrack:GetMarkerReachedSignal("hit"):Once(function()
				if not Hit or not HitCharacter then
					return
				end

				destroyVelocity()
				applyHit(HitCharacter)
			end)
		)

		UserTrack.Stopped:Once(function()
			for _, v in UserEvents do
				v:Disconnect()
			end

			destroyVelocity()

			if not Hit then
				destroyHitbox()
			end

			iFramesService:RemoveAlliFrames(Character)
			StunHandler:Unstun(Character, Stun)
		end)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, UserAnimation)
	end,
}
