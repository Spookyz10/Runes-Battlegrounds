local TweenService = game:GetService("TweenService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerModules = ServerStorage.Modules
local ReplicatedModules = ReplicatedStorage.Shared.Modules

local StunHandler = require(ServerModules.StunHandler)
local DamageHandler = require(ServerModules.DamageHandler)
local iFramesService = require(ServerModules.iFramesService)
local HitboxHandler = require(ServerModules.HitboxHandler)
local AnimationService = require(ServerModules.AnimationService)

local Freeze = require(ReplicatedModules.Utility.Freeze)

local MoveAnims = ServerStorage.Assets.Animations.Moves
local ReplicateSet = ReplicatedStorage.Remotes.Replicate.Set

local DASH_RANGE = 45
local DASH_HIT_SIZE = Vector3.new(10, 10, DASH_RANGE)
local DASH_DAMAGE = 18
local DASH_STUN = 1.2
local DASH_TWEEN_TIME = 0.12
local DASH_WALL_OFFSET = 3

local POST_CHARGE_FREE_TIME = 0.5 -- tempo livre depois do marker "charge" antes de travar
local CHARGE_LOCK_TIME = 1 -- tempo travado com o efeito de charge antes de disparar o beam
local POST_BEAM_LOCK_TIME = 1 -- tempo travado depois de disparar o beam antes de soltar o player

local BEAM_RANGE = 70
local BEAM_HIT_SIZE = Vector3.new(10, 10, BEAM_RANGE)
local BEAM_DAMAGE = 30
local BEAM_STUN = 1.5

local WallRayParams = RaycastParams.new()
WallRayParams.FilterType = Enum.RaycastFilterType.Include
WallRayParams.FilterDescendantsInstances = {
	workspace.Map:WaitForChild("Arena"),
	workspace.Map:WaitForChild("Miscellaneous"),
	workspace.Map:WaitForChild("Borders"),
}

local function getSafeRange(originPos, lookFlat, range)
	local blockSize = Vector3.new(3.5, 5, 1)
	local originCF = CFrame.new(originPos, originPos + lookFlat)
	local result = workspace:Blockcast(originCF, blockSize, lookFlat * range, WallRayParams)
	if result then
		return math.max(0, result.Distance - DASH_WALL_OFFSET)
	end
	return range
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

		local cleanupDone = false
		local activeStun = nil
		local lockAnchor = nil

		local function unstunNow()
			if activeStun then
				StunHandler:Unstun(Character, activeStun)
				activeStun = nil
			end
		end

		local function doFullCleanup()
			if cleanupDone then
				return
			end
			cleanupDone = true
			Humanoid.WalkSpeed = 16

			unstunNow()
			Freeze.Release(Character, lockAnchor, false)
			lockAnchor = nil

			iFramesService:RemoveAlliFrames(Character)
		end

		iFramesService:AddAlliFrames(Character)

		-- Windup: travado total até o dash acontecer.
		activeStun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		lockAnchor = Freeze.Lock(Character)

		ReplicateSet:FireAllClients("ShadestepBegin", { func = "ShadestepBeginStart", char = Character })
		ReplicateSet:FireAllClients("ShadestepBeam", { func = "Startup", char = Character })

		local UserAnimation = MoveAnims.Eclipse.Lunar.ShadestepBegin
		local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)

		local hitReached = false

		table.insert(
			UserEvents,
			UserTrack:GetMarkerReachedSignal("hit"):Once(function()
				hitReached = true

				local lv = HumRP.CFrame.LookVector
				local lookFlat = Vector3.new(lv.X, 0, lv.Z).Unit
				local originPos = HumRP.Position

				local safeRange = getSafeRange(originPos, lookFlat, DASH_RANGE)
				local endPos = originPos + lookFlat * safeRange
				local endCFrame = CFrame.new(endPos, endPos + lookFlat)

				local dashCenter = originPos + lookFlat * (safeRange / 2)
				local dashHitSize = Vector3.new(DASH_HIT_SIZE.X, DASH_HIT_SIZE.Y, math.max(safeRange, 1))
				local dashCF = CFrame.new(dashCenter, dashCenter + lookFlat)
				local dashHitList = {}

				HitboxHandler:SimpleOnce(dashCF, dashHitSize, CFrame.new(), { Character }, nil, nil, function(enemyChar)
					if table.find(dashHitList, enemyChar) then
						return
					end
					local EnemyHum = enemyChar:FindFirstChild("Humanoid")
					if not EnemyHum or EnemyHum.Health <= 0 then
						return
					end
					if iFramesService:HasiFrame(enemyChar, Tool.Name) then
						return
					end
					table.insert(dashHitList, enemyChar)
				end)

				-- Solta só a posição (mantém rotação travada) pra Tween poder mover o HRP.
				Freeze.Release(Character, lockAnchor, true)
				lockAnchor = nil

				local dashTween = TweenService:Create(
					HumRP,
					TweenInfo.new(DASH_TWEEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{ CFrame = endCFrame }
				)
				dashTween:Play()
				dashTween.Completed:Wait()

				ReplicateSet:FireAllClients("ShadestepBegin", { func = "ShadestepBeginEnd", char = Character })

				for _, enemyChar in dashHitList do
					local EnemyHum = enemyChar:FindFirstChild("Humanoid")
					if EnemyHum and EnemyHum.Health > 0 then
						DamageHandler:TakeDamage(
							Character,
							EnemyHum,
							DASH_DAMAGE,
							DASH_STUN,
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
				end

				ReplicateSet:FireAllClients("ShadestepBeam", { func = "DestroyStartup", char = Character })

				-- Dash acabou: devolve controle total pro player (posição + rotação livres)
				-- até o beam estar prestes a disparar.
				unstunNow()
				Character:RemoveTag("CantRotate")

				task.spawn(function()
					if not Character.Parent then
						doFullCleanup()
						return
					end

					local BeamAnimation = MoveAnims.Eclipse.Lunar.ShadestepBeam
					local BeamTrack, BeamEvents = AnimationService:getAnimationTrack(Character, BeamAnimation)

					local chargeReached = false

					table.insert(
						BeamEvents,
						BeamTrack:GetMarkerReachedSignal("charge"):Once(function()
							chargeReached = true

							-- Ainda com controle livre por mais um pouco.
							task.wait(POST_CHARGE_FREE_TIME)

							if not Character.Parent then
								doFullCleanup()
								return
							end

							-- Agora trava tudo pro efeito de charge + disparo do beam.
							BeamTrack:AdjustSpeed(0)
							activeStun = StunHandler:Stun(Character, nil, true, 0, 0, true)
							lockAnchor = Freeze.Lock(Character)

							ReplicateSet:FireAllClients("ShadestepBeam", { func = "ChargeEffect", char = Character })

							task.wait(CHARGE_LOCK_TIME)

							if not Character.Parent then
								doFullCleanup()
								return
							end

							BeamTrack:AdjustSpeed(1)

							local lv2 = HumRP.CFrame.LookVector
							local lookFlat2 = Vector3.new(lv2.X, 0, lv2.Z).Unit
							local originPos2 = HumRP.Position

							local beamCenter = originPos2 + lookFlat2 * (BEAM_RANGE / 2)
							local beamCF = CFrame.new(beamCenter, beamCenter + lookFlat2)

							local beamHitList = {}
							HitboxHandler:SimpleOnce(
								beamCF,
								BEAM_HIT_SIZE,
								CFrame.new(),
								{ Character },
								nil,
								nil,
								function(enemyChar)
									if table.find(beamHitList, enemyChar) then
										return
									end
									local EnemyHum = enemyChar:FindFirstChild("Humanoid")
									if not EnemyHum or EnemyHum.Health <= 0 then
										return
									end
									if iFramesService:HasiFrame(enemyChar, Tool.Name) then
										return
									end
									table.insert(beamHitList, enemyChar)
								end
							)

							ReplicateSet:FireAllClients("ShadestepBeam", { func = "FireBeam", char = Character })

							for _, enemyChar in beamHitList do
								local EnemyHum = enemyChar:FindFirstChild("Humanoid")
								if EnemyHum and EnemyHum.Health > 0 then
									DamageHandler:TakeDamage(
										Character,
										EnemyHum,
										BEAM_DAMAGE,
										BEAM_STUN,
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
							end

							-- Beam disparado: segura travado por mais um pouco antes de soltar o player.
							task.wait(POST_BEAM_LOCK_TIME)

							doFullCleanup()
						end)
					)

					BeamTrack.Stopped:Once(function()
						for _, v in BeamEvents do
							v:Disconnect()
						end
						if not chargeReached then
							doFullCleanup()
						end
					end)

					AnimationService:stopAll(Character)
					AnimationService:playAnimation(Character, BeamAnimation)
					Humanoid.WalkSpeed = 0
				end)
			end)
		)

		UserTrack.Stopped:Once(function()
			for _, v in UserEvents do
				v:Disconnect()
			end
			if not hitReached then
				doFullCleanup()
			end
		end)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, UserAnimation)
	end,
}
