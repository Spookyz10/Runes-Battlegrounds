local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local ServerModules = ServerStorage.Modules

local StunHandler = require(ServerModules.StunHandler)
local HitboxHandler = require(ServerModules.HitboxHandler)
local DamageHandler = require(ServerModules.DamageHandler)
local AnimationService = require(ServerModules.AnimationService)
local iFramesService = require(ServerModules.iFramesService)
local BodymoverService = require(ServerModules.BodymoverService)
local RagdollHandler = require(ServerModules.RagdollHandler)
local ReplicatedHitboxes = require(ServerModules.ReplicatedHitboxes)

local MoveAnims = ServerStorage.Assets.Animations.Moves
local ReplicateSet = ReplicatedStorage.Remotes.Replicate.Set

local DASH_SPEED = 60
local FREEZE_TIMEOUT = 0.7

return {
	Start = function(Player, Tool)
		local Character = Player.Character
		local HumRP = Character.HumanoidRootPart

		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		iFramesService:AddAlliFrames(Character)

		local Hit = false
		local Frozen = false

		local DashVelocity = Instance.new("BodyVelocity")
		DashVelocity.MaxForce = Vector3.new(math.huge, 0, math.huge)
		DashVelocity.Velocity = HumRP.CFrame.LookVector * DASH_SPEED
		DashVelocity.P = math.huge
		DashVelocity.Parent = HumRP

		local DirectionLoop = RunService.Heartbeat:Connect(function()
			if DashVelocity and DashVelocity.Parent then
				DashVelocity.Velocity = HumRP.CFrame.LookVector * DASH_SPEED
			end
		end)

		local function destroyVelocity()
			DirectionLoop:Disconnect()
			if DashVelocity and DashVelocity.Parent then
				DashVelocity:Destroy()
			end
		end

		local UserAnimation = MoveAnims.Lunar:FindFirstChild("Lunar Lunge")
		local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)

		local Hitbox = ReplicatedHitboxes.new(Player)
		Hitbox.Instance = HumRP
		Hitbox.Size = Vector3.new(10, 10, 14)
		Hitbox.Offset = CFrame.new(0, 0, -7)
		Hitbox.Ignore = { Character }
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
			Hitbox:Destroy()
			destroyVelocity()

			-- Se a animação estiver congelada no freeze, despausa para o soco continuar
			if Frozen then
				UserTrack:AdjustSpeed(1)
			end
		end

		Hitbox:Start()

		-- Marker freeze: pausa visual enquanto aguarda hitbox detectar alguém
		table.insert(
			UserEvents,
			UserTrack:GetMarkerReachedSignal("freeze"):Once(function()
				Frozen = true
				UserTrack:AdjustSpeed(0)

				-- Timeout: se ninguém for detectado, continua a animação e encerra
				task.delay(FREEZE_TIMEOUT, function()
					if not Hit then
						Frozen = false
						Hitbox:Destroy()
						UserTrack:AdjustSpeed(1)
					end
				end)
			end)
		)

		-- Marker slash: a animação chegou no soco, aplica dano
		table.insert(
			UserEvents,
			UserTrack:GetMarkerReachedSignal("slash"):Once(function()
				if not Hit then
					return
				end

				destroyVelocity()

				local SlashCF = HumRP.CFrame
				local HitList = {}

				ReplicateSet:FireAllClients("DashSlash", { Char = Character, CFrame = SlashCF })

				HitboxHandler:SimpleOnce(
					SlashCF,
					Vector3.new(25, 25, 25),
					CFrame.new(0, 0, 0),
					{ Character },
					"Sphere",
					nil,
					function(EnemyCharacter)
						if table.find(HitList, EnemyCharacter) then
							return
						end
						if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) then
							return
						end

						local EnemyPlayer = Players:GetPlayerFromCharacter(EnemyCharacter)
						local EnemyHumanoid = EnemyCharacter.Humanoid
						local EnemyHumRP = EnemyCharacter.HumanoidRootPart

						if EnemyHumanoid.Health <= 0 or EnemyCharacter:HasTag("Ragdolled") then
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

		UserTrack.Stopped:Once(function()
			for _, v in UserEvents do
				v:Disconnect()
			end

			destroyVelocity()

			iFramesService:RemoveAlliFrames(Character)
			StunHandler:Unstun(Character, Stun)
		end)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, UserAnimation)
	end,
}
