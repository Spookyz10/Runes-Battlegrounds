local TweenService = game:GetService("TweenService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerModules = ServerStorage.Modules

local StunHandler = require(ServerModules.StunHandler)
local DamageHandler = require(ServerModules.DamageHandler)
local iFramesService = require(ServerModules.iFramesService)
local HitboxHandler = require(ServerModules.HitboxHandler)
local AnimationService = require(ServerModules.AnimationService)

local MoveAnims = ServerStorage.Assets.Animations.Moves
local ReplicateSet = ReplicatedStorage.Remotes.Replicate.Set

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

		local function doFullCleanup()
			if cleanupDone then
				return
			end
			cleanupDone = true
			Humanoid.WalkSpeed = 16

			if activeStun then
				StunHandler:Unstun(Character, activeStun)
				activeStun = nil
			end

			Character:RemoveTag("CantRotate")
			iFramesService:RemoveAlliFrames(Character)
		end

		iFramesService:AddAlliFrames(Character)
		activeStun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		Character:AddTag("CantRotate")

		local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)

		local dashBlocked = false

		table.insert(
			UserEvents,
			UserTrack:GetMarkerReachedSignal("start"):Once(function()
				ReplicateSet:FireAllClients("ShadestepBegin", { func = "ShadestepBeginStart", char = Character })
			end)
		)

		table.insert(
			UserEvents,
			UserTrack:GetMarkerReachedSignal("dash"):Once(function()
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
				local blockedByAny = false

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

					if enemyChar:HasTag("Blocking") then
						blockedByAny = true
					end
				end)

				if blockedByAny then
					dashBlocked = true

					ReplicateSet:FireAllClients("ShadestepBegin", { func = "ShadestepBeginEnd", char = Character })

					if UserTrack then
						UserTrack:Stop()
					end

					doFullCleanup()
					activeStun = StunHandler:Stun(Character, DASH_BLOCK_STUN_TIME, true)

					return
				end

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

				ReplicateSet:FireAllClients("ShadestepFireball", { func = "Attach", char = Character })
			end)
		)

		table.insert(
			UserEvents,
			UserTrack:GetMarkerReachedSignal("fire"):Once(function()
				if dashBlocked then
					return
				end

				-- personagem gira 180 na animação mas a HumanoidRootPart não muda de
				-- direção, então o beam sai pro lado contrário do LookVector (pras costas
				-- de onde o personagem tava olhando antes do giro)
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
						if iFramesService:HasiFrame(enemyChar, Tool.Name) then
							return
						end
						table.insert(fireballHitList, enemyChar)
					end
				)

				ReplicateSet:FireAllClients("ShadestepFireball", {
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

				UserTrack:AdjustSpeed(0)
				task.delay(0.5, function()
					if UserTrack and UserTrack.IsPlaying then
						UserTrack:AdjustSpeed(1)
					end
				end)

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
