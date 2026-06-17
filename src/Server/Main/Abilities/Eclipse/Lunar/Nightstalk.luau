local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ServerModules = ServerStorage.Modules

local StunHandler = require(ServerModules.StunHandler)
local HitboxHandler = require(ServerModules.HitboxHandler)
local DamageHandler = require(ServerModules.DamageHandler)
local AnimationService = require(ServerModules.AnimationService)
local iFramesService = require(ServerModules.iFramesService)
local KnockbackModules = require(ServerModules.KnockbackModule)

local ReplicatedHitboxes = require(ServerModules.ReplicatedHitboxes)

local MoveAnims = ServerStorage.Assets.Animations.Moves
local ReplicateSet = ReplicatedStorage.Remotes.Replicate.Set

local DASH_SPEED = 90
local FREEZE_TIMEOUT = 1

return {
	Start = function(Player, Tool)
		local Character = Player.Character
		local HumRP = Character.HumanoidRootPart

		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		iFramesService:AddAlliFrames(Character)

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

		local UserAnimation = MoveAnims.Lunar:FindFirstChild("Lunar Lunge")
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

			local EnemyHumanoid = EnemyCharacter.Humanoid
			local Ragdolled = EnemyCharacter:HasTag("Ragdolled")
			local inAir = EnemyCharacter:FindFirstChild("inAir")
				or (
					EnemyCharacter:GetAttribute("TouchedGround")
					and tick() - EnemyCharacter:GetAttribute("TouchedGround") <= 0.25
				)

			if
				iFramesService:HasiFrame(EnemyCharacter, Tool.Name)
				or EnemyHumanoid.Health <= 0
				or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead
				or (Ragdolled and not inAir)
			then
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
