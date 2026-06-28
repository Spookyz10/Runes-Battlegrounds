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

local DASH_RANGE = 45
local DASH_HIT_SIZE = Vector3.new(10, 10, DASH_RANGE)
local DASH_DAMAGE = 18
local DASH_STUN = 1.2
local DASH_TWEEN_TIME = 0.12
local DASH_WALL_OFFSET = 2.5

local BALL_SIZE = Vector3.new(6, 6, 6)
local BALL_TRAVEL_TIME = 0.55
local BALL_DAMAGE = 14
local BALL_STUN = 0.8

local WallRayParams = RaycastParams.new()
WallRayParams.FilterType = Enum.RaycastFilterType.Include
WallRayParams.FilterDescendantsInstances = {
	workspace.Map:WaitForChild("Arena"),
	workspace.Map:WaitForChild("Miscellaneous"),
	workspace.Map:WaitForChild("Borders"),
}

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

		local casterStun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		iFramesService:AddAlliFrames(Character)

		ReplicateSet:FireAllClients("ShadestepBegin", { func = "ShadestepBeginStart", char = Character })

		local UserAnimation = MoveAnims.Eclipse.Lunar.ShadestepBegin
		local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)

		table.insert(
			UserEvents,
			UserTrack:GetMarkerReachedSignal("hit"):Once(function()
				local lv = HumRP.CFrame.LookVector
				local lookFlat = Vector3.new(lv.X, 0, lv.Z).Unit
				local originPos = HumRP.Position

				local wallHit = workspace:Raycast(originPos, lookFlat * DASH_RANGE, WallRayParams)
				local safeRange = if wallHit
					then math.max(0, (wallHit.Position - originPos).Magnitude - DASH_WALL_OFFSET)
					else DASH_RANGE

				local endPos = originPos + lookFlat * safeRange
				local endCFrame = CFrame.new(endPos, endPos + lookFlat)

				local actualRange = safeRange
				local dashCenter = originPos + lookFlat * (actualRange / 2)
				local dashHitSize = Vector3.new(DASH_HIT_SIZE.X, DASH_HIT_SIZE.Y, actualRange)
				local dashCF = CFrame.new(dashCenter, dashCenter + lookFlat)
				local dashHitList = {}

				HitboxHandler:SimpleOnce(
					dashCF,
					dashHitSize,
					CFrame.new(0, 0, 0),
					{ Character },
					nil,
					nil,
					function(enemyChar)
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
					end
				)

				local dashTween = TweenService:Create(
					HumRP,
					TweenInfo.new(DASH_TWEEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{ CFrame = endCFrame }
				)
				dashTween:Play()
				dashTween.Completed:Wait()

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

				task.delay(0.6, function()
					if not Character.Parent or not HumRP.Parent then
						ReplicateSet:FireAllClients("ShadestepBegin", { func = "ShadestepBeginEnd", char = Character })
						iFramesService:RemoveAlliFrames(Character)
						StunHandler:Unstun(Character, casterStun)
						return
					end

					local BallPart = Instance.new("Part")
					BallPart.Name = "ShadestepBall"
					BallPart.Anchored = true
					BallPart.CanCollide = false
					BallPart.CanTouch = false
					BallPart.Transparency = 1
					BallPart.Size = BALL_SIZE
					BallPart.CFrame = endCFrame
					BallPart.Parent = workspace

					local ballHitList = {}

					local ballHitbox = HitboxHandler.new()
					ballHitbox.Instance = BallPart
					ballHitbox.Size = BALL_SIZE
					ballHitbox.Ignore = { Character }
					ballHitbox.ResetCharactersList = true
					ballHitbox.onTouch = function(enemyChar)
						if table.find(ballHitList, enemyChar) then
							return
						end
						local EnemyHum = enemyChar:FindFirstChild("Humanoid")
						if not EnemyHum or EnemyHum.Health <= 0 then
							return
						end
						if iFramesService:HasiFrame(enemyChar, Tool.Name) then
							return
						end
						table.insert(ballHitList, enemyChar)

						DamageHandler:TakeDamage(
							Character,
							EnemyHum,
							BALL_DAMAGE,
							BALL_STUN,
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

					ballHitbox:Start()

					local ballTween = TweenService:Create(
						BallPart,
						TweenInfo.new(BALL_TRAVEL_TIME, Enum.EasingStyle.Linear),
						{ CFrame = CFrame.new(originPos, originPos + lookFlat) }
					)

					ballTween.Completed:Once(function()
						ballHitbox:Stop()
						BallPart:Destroy()

						ReplicateSet:FireAllClients("ShadestepBegin", { func = "ShadestepBeginEnd", char = Character })
						iFramesService:RemoveAlliFrames(Character)
						StunHandler:Unstun(Character, casterStun)
					end)

					ballTween:Play()
				end)
			end)
		)

		UserTrack.Stopped:Once(function()
			for _, v in UserEvents do
				v:Disconnect()
			end
		end)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, UserAnimation)
	end,
}
