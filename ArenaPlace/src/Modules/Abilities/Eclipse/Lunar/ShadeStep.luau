local TweenService = game:GetService("TweenService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerModules = ServerStorage.Modules

local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)
local SFXModule = require(ReplicatedStorage.Shared.Modules.SFXModule)
local StunHandler = require(ServerModules.StunHandler)
local DamageHandler = require(ServerModules.DamageHandler)
local SkillCancelHandler = require(ServerModules.SkillCancelHandler)
local iFramesService = require(ServerModules.iFramesService)
local HitboxHandler = require(ServerModules.HitboxHandler)
local AnimationService = require(ServerModules.AnimationService)

local MoveAnims = ServerStorage.Assets.Animations.Moves

local UserAnimation = MoveAnims.Eclipse.Lunar.Shadestep

local DASH_RANGE = 45
local DASH_HIT_SIZE = Vector3.new(10, 10, DASH_RANGE)
local DASH_DAMAGE = 5
local DASH_STUN = 1.8
local DASH_TWEEN_TIME = 0.12
local DASH_WALL_OFFSET = 3
local DASH_BLOCK_STUN_TIME = 2

local FIREBALL_RANGE = 70
local FIREBALL_HIT_SIZE = Vector3.new(10, 10, FIREBALL_RANGE)
local FIREBALL_DAMAGE = 5
local FIREBALL_STUN = 1.5

local SAFE_RANGE_BLOCK_SIZE = Vector3.new(4, 5, 4)

local function getSafeRange(originPos, lookFlat, range, Character)
	local WallRayParams = RaycastParams.new()
	WallRayParams.FilterType = Enum.RaycastFilterType.Exclude
	WallRayParams.FilterDescendantsInstances = { Character, workspace.Live }
	WallRayParams.RespectCanCollide = true
	WallRayParams.IgnoreWater = true

	local originCF = CFrame.new(originPos, originPos + lookFlat)
	local result = workspace:Blockcast(originCF, SAFE_RANGE_BLOCK_SIZE, lookFlat * range, WallRayParams)
	if result then
		return math.max(0, result.Distance - DASH_WALL_OFFSET)
	end
	return range
end

return {
	Cooldown = 15,
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
		local cancelled = false
		local onDamageCancel

		local function doFullCleanup()
			if cleanupDone then
				return
			end
			cleanupDone = true
			Humanoid.WalkSpeed = 16

			RemoteManager.FireAllClients(
				"ReplicateTask",
				"ShadestepBegin",
				{ func = "ShadestepBeginEnd", char = Character }
			)

			if activeStun then
				StunHandler:Unstun(Character, activeStun)
				activeStun = nil
			end

			Character:RemoveTag("CantRotate")
			RemoteManager.FireAllClients("ReplicateTask", "ShadestepFireball", { func = "Cancel", char = Character })
			SkillCancelHandler:Unregister(Character, onDamageCancel)
		end

		activeStun = StunHandler:Stun(Character, nil, true, 0, 0, true, nil, false)
		Character:AddTag("CantRotate")

		local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)

		if not UserTrack then
			Character:RemoveTag("CantRotate")
			StunHandler:Unstun(Character, activeStun)
			Humanoid.WalkSpeed = 16
			return
		end

		onDamageCancel = function()
			if cancelled then
				return
			end
			cancelled = true
			if UserTrack then
				UserTrack:Stop()
			end
		end

		SkillCancelHandler:Register(Character, onDamageCancel)

		local dashBlocked = false

		table.insert(
			UserEvents,
			UserTrack:GetMarkerReachedSignal("start"):Once(function()
				SFXModule:Play("shadestepCharge", HumRP)
				RemoteManager.FireAllClients(
					"ReplicateTask",
					"ShadestepBegin",
					{ func = "ShadestepBeginStart", char = Character }
				)
			end)
		)

		table.insert(
			UserEvents,
			UserTrack:GetMarkerReachedSignal("dash"):Once(function()
				local lv = HumRP.CFrame.LookVector
				local lookFlat = Vector3.new(lv.X, 0, lv.Z).Unit
				local originPos = HumRP.Position

				-- calculado ANTES do teleporte, com a range máxima de sempre
				-- (DASH_RANGE) — só clampa pra baixo se tiver algo colidível
				-- no caminho.
				local safeRange = getSafeRange(originPos, lookFlat, DASH_RANGE, Character)
				local endPos = originPos + lookFlat * safeRange
				local endCFrame = CFrame.new(endPos, endPos + lookFlat)

				local dashCenter = originPos + lookFlat * (safeRange / 2)
				local dashHitSize = Vector3.new(DASH_HIT_SIZE.X, DASH_HIT_SIZE.Y, math.max(safeRange, 1))
				local dashCF = CFrame.new(dashCenter, dashCenter + lookFlat)
				local dashHitList = {}
				local blockedByAny = false

				HitboxHandler:SimpleOnce(dashCF, dashHitSize, CFrame.new(), { Character }, nil, nil, function(enemyChar)
					if table.find(dashHitList, enemyChar) then
						return
					end
					local EnemyHum = enemyChar:FindFirstChild("Humanoid")
					if not EnemyHum or EnemyHum.Health <= 0 then
						return
					end
					if iFramesService:HasiFrame(enemyChar, 1) then
						return
					end
					table.insert(dashHitList, enemyChar)

					if enemyChar:HasTag("Blocking") then
						blockedByAny = true
					end
				end)

				if blockedByAny then
					dashBlocked = true

					RemoteManager.FireAllClients(
						"ReplicateTask",
						"ShadestepBegin",
						{ func = "ShadestepBeginEnd", char = Character }
					)

					if UserTrack then
						UserTrack:Stop()
					end

					doFullCleanup()
					activeStun = StunHandler:Stun(Character, DASH_BLOCK_STUN_TIME, true)

					return
				end

				SFXModule:Play("shadestepTeleport", HumRP)

				local dashTween = TweenService:Create(
					HumRP,
					TweenInfo.new(DASH_TWEEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{ CFrame = endCFrame }
				)
				dashTween:Play()
				dashTween.Completed:Wait()

				RemoteManager.FireAllClients(
					"ReplicateTask",
					"ShadestepBegin",
					{ func = "ShadestepBeginEnd", char = Character }
				)

				for _, enemyChar in dashHitList do
					local EnemyHum = enemyChar:FindFirstChild("Humanoid")
					if EnemyHum and EnemyHum.Health > 0 then
						DamageHandler:TakeDamage(
							Character,
							EnemyHum,
							DASH_DAMAGE,
							DASH_STUN,
							nil,
							true,
							false,
							true,
							true,
							false,
							nil,
							nil
						)
					end
				end

				Humanoid.WalkSpeed = 16

				RemoteManager.FireAllClients(
					"ReplicateTask",
					"ShadestepFireball",
					{ func = "Attach", char = Character }
				)
			end)
		)

		table.insert(
			UserEvents,
			UserTrack:GetMarkerReachedSignal("fire"):Once(function()
				if dashBlocked then
					return
				end

				local lv = HumRP.CFrame.LookVector
				local lookFlat = Vector3.new(-lv.X, 0, -lv.Z).Unit
				local originPos = HumRP.Position

				local fireballCenter = originPos + lookFlat * (FIREBALL_RANGE / 2)
				local fireballCF = CFrame.new(fireballCenter, fireballCenter + lookFlat)

				local fireballHitList = {}
				HitboxHandler:SimpleOnce(
					fireballCF,
					FIREBALL_HIT_SIZE,
					CFrame.new(),
					{ Character },
					nil,
					nil,
					function(enemyChar)
						if table.find(fireballHitList, enemyChar) then
							return
						end
						local EnemyHum = enemyChar:FindFirstChild("Humanoid")
						if not EnemyHum or EnemyHum.Health <= 0 then
							return
						end
						if iFramesService:HasiFrame(enemyChar, 1) then
							return
						end
						table.insert(fireballHitList, enemyChar)
					end
				)

				SFXModule:Play("shadestepBeam", HumRP)

				RemoteManager.FireAllClients("ReplicateTask", "ShadestepFireball", {
					func = "Launch",
					char = Character,
					direction = lookFlat,
				})

				for _, enemyChar in fireballHitList do
					local EnemyHum = enemyChar:FindFirstChild("Humanoid")
					if EnemyHum and EnemyHum.Health > 0 then
						DamageHandler:TakeDamage(
							Character,
							EnemyHum,
							FIREBALL_DAMAGE,
							FIREBALL_STUN,
							nil,
							true,
							false,
							true,
							true,
							false,
							nil,
							nil
						)
					end
				end

				doFullCleanup()
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
}
