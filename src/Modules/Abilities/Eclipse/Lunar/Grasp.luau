local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local ServerModules = ServerStorage.Modules

local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)
local StunHandler = require(ServerModules.StunHandler)
local RagdollHandler = require(ServerModules.RagdollHandler)
local DamageHandler = require(ServerModules.DamageHandler)
local iFramesService = require(ServerModules.iFramesService)
local HitboxHandler = require(ServerModules.HitboxHandler)
local AnimationService = require(ServerModules.AnimationService)
local SFX = require(ServerModules.SFXModule)

local MoveAnims = ServerStorage.Assets.Animations.Moves

local HAND_TRAVEL_TIME = 0.5
local HAND_START_DIST = 3
local HAND_END_DIST = 20
local HITBOX_SIZE = Vector3.new(10, 10, 20)
local PULL_DISTANCE = 3
local PULL_TIME = 0.35
local POST_PULL_STUN_EXTRA = 2

local HAND_DAMAGE = 5
local PULL_DAMAGE = 5

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

		Humanoid.WalkSpeed = 0

		local casterStun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		iFramesService:AddAlliFrames(Character)

		local grabbed = {}
		local hitbox = nil
		local HitboxPart = nil
		local travelConn = nil

		local function tryCapture(enemyChar)
			if grabbed[enemyChar] then
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
			if iFramesService:HasiFrame(enemyChar, Tool.Name) then
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

			SFX:Play("graspHit", EnemyHumRP)

			if enemyChar:HasTag("Ragdolled") then
				RagdollHandler.cancelRagdoll(EnemyHum, nil, false, nil, true, true, false)
			end

			EnemyHumRP.AssemblyLinearVelocity = Vector3.zero
			EnemyHumRP.AssemblyAngularVelocity = Vector3.zero

			pcall(function()
				EnemyHumRP:SetNetworkOwner(nil)
			end)

			EnemyHum:ChangeState(Enum.HumanoidStateType.PlatformStanding)

			local freezeToken = StunHandler:Stun(enemyChar, nil, true, 0, 0, true)

			enemyChar:SetAttribute("LunarMark", true)
			RemoteManager.FireAllClients(
				"ReplicateTask",
				"AuraFX",
				{ func = "Start", char = enemyChar, aura = "LunarMark" }
			)

			grabbed[enemyChar] = {
				humanoid = EnemyHum,
				freezeToken = freezeToken,
			}
		end

		local function stopHand()
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

		local function releaseGrabbed(extraStunTime)
			for enemyChar, data in grabbed do
				local EnemyHumRP = enemyChar:FindFirstChild("HumanoidRootPart")
				local Hum = data.humanoid

				local function finalize()
					if EnemyHumRP and EnemyHumRP.Parent and Hum then
						EnemyHumRP.AssemblyLinearVelocity = Vector3.zero
						EnemyHumRP.AssemblyAngularVelocity = Vector3.zero
						Hum.PlatformStand = false
						Hum:ChangeState(Enum.HumanoidStateType.GettingUp)
					end
					if data.freezeToken then
						StunHandler:Unstun(enemyChar, data.freezeToken)
					end
					if enemyChar:GetAttribute("LunarMark") then
						enemyChar:SetAttribute("LunarMark", nil)
						RemoteManager.FireAllClients(
							"ReplicateTask",
							"AuraFX",
							{ func = "End", char = enemyChar, aura = "LunarMark" }
						)
					end
				end

				if extraStunTime and extraStunTime > 0 then
					task.delay(extraStunTime, finalize)
				else
					finalize()
				end
			end

			grabbed = {}
		end

		local function doFullCleanup()
			StunHandler:Unstun(Character, casterStun)
			iFramesService:RemoveAlliFrames(Character)
			Humanoid.WalkSpeed = 16
		end

		local UserAnimation = MoveAnims.Eclipse.Lunar.Grasp
		local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)

		table.insert(
			UserEvents,
			UserTrack:GetMarkerReachedSignal("summon"):Once(function()
				UserTrack:AdjustSpeed(0)

				SFX:Play("graspTravel", HumRP)

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
				hitbox.onTouch = tryCapture

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

						if UserTrack.IsPlaying then
							UserTrack:AdjustSpeed(1)
						end
					end
				end)

				hitbox:Start()
			end)
		)

		table.insert(
			UserEvents,
			UserTrack:GetMarkerReachedSignal("pull"):Once(function()
				stopHand()

				local lv = HumRP.CFrame.LookVector
				local lookFlat = Vector3.new(lv.X, 0, lv.Z).Unit
				local targetPos = HumRP.Position + lookFlat * PULL_DISTANCE
				local targetCFrame = CFrame.new(targetPos, HumRP.Position)

				local pullList = {}
				for enemyChar in grabbed do
					table.insert(pullList, enemyChar)
				end

				for _, enemyChar in pullList do
					local EnemyHumRP = enemyChar:FindFirstChild("HumanoidRootPart")
					if EnemyHumRP and EnemyHumRP.Parent then
						SFX:Play("graspPull", EnemyHumRP)
						TweenService:Create(
							EnemyHumRP,
							TweenInfo.new(PULL_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
							{ CFrame = targetCFrame }
						):Play()
					end
				end

				task.wait(PULL_TIME)

				for _, enemyChar in pullList do
					local EnemyHumRP = enemyChar:FindFirstChild("HumanoidRootPart")
					if EnemyHumRP and EnemyHumRP.Parent then
						EnemyHumRP.AssemblyLinearVelocity = Vector3.zero
						EnemyHumRP.AssemblyAngularVelocity = Vector3.zero

						local EnemyHum = enemyChar:FindFirstChild("Humanoid")
						if EnemyHum and EnemyHum.Health > 0 then
							DamageHandler:TakeDamage(
								Character,
								EnemyHum,
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
					end

					if enemyChar:GetAttribute("LunarMark") then
						enemyChar:SetAttribute("LunarMark", nil)
						RemoteManager.FireAllClients(
							"ReplicateTask",
							"AuraFX",
							{ func = "End", char = enemyChar, aura = "LunarMark" }
						)
					end
				end
			end)
		)

		UserTrack.Stopped:Once(function()
			for _, v in UserEvents do
				v:Disconnect()
			end

			stopHand()
			releaseGrabbed(POST_PULL_STUN_EXTRA)
			doFullCleanup()
		end)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, UserAnimation)
	end,
}
