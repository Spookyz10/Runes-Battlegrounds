local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ServerModules = ServerStorage.Modules

local StunHandler = require(ServerModules.StunHandler)
local HitboxHandler = require(ServerModules.HitboxHandler)
local DamageHandler = require(ServerModules.DamageHandler)
local AnimationService = require(ServerModules.AnimationService)
local iFramesService = require(ServerModules.iFramesService)
local BodymoverService = require(ServerModules.BodymoverService)
local RagdollHandler = require(ServerModules.RagdollHandler)

local MoveAnims = ServerStorage.Assets.Animations.Moves
local ReplicateSet = ReplicatedStorage.Remotes.Replicate.Set

return {
	Start = function(Player, Tool)
		local Character = Player.Character
		local HumRP = Character.HumanoidRootPart

		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		iFramesService:AddAlliFrames(Character)
		Character:AddTag("CantRotate")

		-- Impulso inicial imediato
		local DashVelocity = Instance.new("BodyVelocity")
		DashVelocity.MaxForce = Vector3.new(math.huge, 0, math.huge)
		DashVelocity.Velocity = HumRP.CFrame.LookVector * 110
		DashVelocity.P = math.huge
		DashVelocity.Parent = HumRP

		local UserAnimation = MoveAnims.Lunar:FindFirstChild("Lunar Lunge")
		local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)

		local DetectedEnemy = nil
		local DetectHitbox = nil

		-- ─── helpers ───────────────────────────────────────────────────────────────
		local function destroyVelocity()
			if DashVelocity and DashVelocity.Parent then
				DashVelocity:Destroy()
			end
		end

		local function unfreeze()
			UserTrack:AdjustSpeed(1)
		end

		-- ─── marker: freeze ────────────────────────────────────────────────────────
		table.insert(
			UserEvents,
			UserTrack:GetMarkerReachedSignal("freeze"):Once(function()
				destroyVelocity()
				UserTrack:AdjustSpeed(0)

				-- Hitbox de detecção contínua 360°, ligeiramente menor que a do slash
				DetectHitbox = HitboxHandler.new()
				DetectHitbox.Instance = HumRP
				DetectHitbox.Size = Vector3.new(20, 20, 20)
				DetectHitbox.Offset = CFrame.new(0, 0, 0)
				DetectHitbox.Ignore = { Character }
				DetectHitbox.onTouch = function(EnemyCharacter)
					local EnemyHumanoid = EnemyCharacter.Humanoid
					local Ragdolled = EnemyCharacter:HasTag("Ragdolled")
					local inAir = EnemyCharacter:FindFirstChild("inAir")
						or (
							EnemyCharacter:GetAttribute("TouchedGround")
							and tick() - EnemyCharacter:GetAttribute("TouchedGround") <= 0.25
						)

					if
						iFramesService:HasiFrame(EnemyCharacter, "M1")
						or EnemyHumanoid.Health <= 0
						or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead
						or (Ragdolled and not inAir)
					then
						return
					end

					-- Primeiro inimigo encontrado: confirma e solta
					if not DetectedEnemy then
						DetectedEnemy = EnemyCharacter
						DetectHitbox:Destroy()
						DetectHitbox = nil
						unfreeze()
					end
				end

				DetectHitbox:Start()

				-- Timeout de 0.7s: se ninguém foi encontrado, segue em frente normalmente
				task.delay(0.7, function()
					if not DetectedEnemy then
						if DetectHitbox then
							DetectHitbox:Destroy()
							DetectHitbox = nil
						end
						unfreeze()
					end
				end)
			end)
		)

		-- ─── marker: slash ─────────────────────────────────────────────────────────
		table.insert(
			UserEvents,
			UserTrack:GetMarkerReachedSignal("slash"):Once(function()
				destroyVelocity()

				local SlashCF = HumRP.CFrame

				-- VFX (reusa o evento do DashSlash; troca por um efeito lunar se tiver)
				ReplicateSet:FireAllClients("DashSlash", { Char = Character, CFrame = SlashCF })
				ReplicateSet:FireClient(Player, "ShakeCamera", { Intensity = 3, Last = 0.3 })

				local HitList = {}

				HitboxHandler:SimpleOnce(
					SlashCF,
					Vector3.new(25, 25, 25),
					CFrame.new(0, 0, 0),
					{ Character },
					"Sphere", -- 360°
					nil,
					function(EnemyCharacter)
						local EnemyPlayer = Players:GetPlayerFromCharacter(EnemyCharacter)
						local EnemyHumanoid = EnemyCharacter.Humanoid
						local EnemyHumRP = EnemyCharacter.HumanoidRootPart

						if table.find(HitList, EnemyCharacter) then
							return
						end
						if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) then
							return
						end
						if EnemyHumanoid.Health <= 0 then
							return
						end
						if EnemyCharacter:HasTag("Ragdolled") then
							return
						end

						table.insert(HitList, EnemyCharacter)

						local HitInfo = DamageHandler:TakeDamage(
							Character,
							EnemyHumanoid,
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

						if HitInfo.Countered or HitInfo.Blocked then
							return
						end

						-- Knockback radial a partir do centro do slash
						local PushDir = (EnemyHumRP.Position - SlashCF.Position).Unit
						PushDir = Vector3.new(PushDir.X, 0, PushDir.Z).Unit

						BodymoverService:Knockback(EnemyCharacter, {
							KnockbackType = "Velocity",
							MaxForce = Vector3.new(1, 1, 1) * 80000,
							Velocity = PushDir * 50 + Vector3.new(0, 18, 0),
						})

						RagdollHandler.ragdoll(EnemyHumanoid, 2)

						if EnemyPlayer then
							ReplicateSet:FireClient(EnemyPlayer, "ShakeCamera", { Intensity = 2, Last = 0.3 })
						end
					end
				)
			end)
		)

		-- ─── cleanup ───────────────────────────────────────────────────────────────
		UserTrack.Stopped:Once(function()
			for _, v in UserEvents do
				v:Disconnect()
			end

			if DetectHitbox then
				DetectHitbox:Destroy()
				DetectHitbox = nil
			end

			destroyVelocity()
			Character:RemoveTag("CantRotate")
			iFramesService:RemoveAlliFrames(Character)
			StunHandler:Unstun(Character, Stun)
		end)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, UserAnimation)
	end,
}
