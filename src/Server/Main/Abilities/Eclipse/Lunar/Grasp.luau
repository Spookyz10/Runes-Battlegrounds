local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local ServerModules = ServerStorage.Modules
local ReplicatedModules = ReplicatedStorage.Shared.Modules

local StunHandler = require(ServerModules.StunHandler)
local DamageHandler = require(ServerModules.DamageHandler)
local RagdollHandler = require(ServerModules.RagdollHandler)
local iFramesService = require(ServerModules.iFramesService)
local HitboxHandler = require(ServerModules.HitboxHandler)
local WeldSystem = require(ReplicatedModules.WeldSystem)

local GROW_DISTANCE = 30
local GROW_TIME = 0.55
local PULL_TIME = 0.35
local HOLD_TIME = 2.0
local HITBOX_WIDTH = 8
local PULL_DAMAGE = 25

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

		local lv = HumRP.CFrame.LookVector
		local lookFlat = Vector3.new(lv.X, 0, lv.Z).Unit
		local originPos = HumRP.Position

		local casterStun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		task.wait(0.5)

		local HitboxPart = Instance.new("Part")
		HitboxPart.Name = "GraspHitbox"
		HitboxPart.Anchored = true
		HitboxPart.CanCollide = false
		HitboxPart.CanTouch = false
		HitboxPart.Transparency = 1
		HitboxPart.Size = Vector3.new(HITBOX_WIDTH, HITBOX_WIDTH, 0.05)
		HitboxPart.CFrame = CFrame.new(originPos, originPos + lookFlat)
		HitboxPart.Parent = workspace

		local grabbed = {}
		local hitSet = {}

		local function releaseAll()
			for _, data in grabbed do
				local EnemyHumRP = data.character:FindFirstChild("HumanoidRootPart")
				local hum = data.humanoid

				data.wsys:Stop()

				if EnemyHumRP and hum then
					EnemyHumRP.AssemblyLinearVelocity = Vector3.zero
					EnemyHumRP.AssemblyAngularVelocity = Vector3.zero

					hum.PlatformStand = false

					hum:ChangeState(Enum.HumanoidStateType.GettingUp)
				end

				if data.freezeToken then
					StunHandler:Unstun(data.character, data.freezeToken)
				end

				if hum and hum.Health > 0 then
					DamageHandler:TakeDamage(
						Character,
						hum,
						PULL_DAMAGE,
						0,
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

			HitboxPart:Destroy()
		end

		local function beginHold()
			StunHandler:Unstun(Character, casterStun)

			task.delay(HOLD_TIME, releaseAll)
		end

		local function pullBack()
			local pullTarget = CFrame.new(HumRP.Position, HumRP.Position + lookFlat)
			local tween = TweenService:Create(
				HitboxPart,
				TweenInfo.new(PULL_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{ CFrame = pullTarget }
			)
			tween.Completed:Once(beginHold)
			tween:Play()
		end

		local function tryCapture(enemyChar)
			if hitSet[enemyChar] then
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

			hitSet[enemyChar] = true

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

			local captureOffset = HitboxPart.CFrame:ToObjectSpace(EnemyHumRP.CFrame)
			local wsys = WeldSystem.new(HitboxPart, EnemyHumRP, captureOffset, -1)
			wsys:Start(0.1, nil)

			table.insert(grabbed, {
				character = enemyChar,
				wsys = wsys,
				humanoid = EnemyHum,
				freezeToken = freezeToken,
			})
		end

		local hitbox = HitboxHandler.new()
		hitbox.Instance = HitboxPart
		hitbox.Size = Vector3.new(HITBOX_WIDTH, HITBOX_WIDTH, 0.05)
		hitbox.Ignore = { Character }
		hitbox.ResetCharactersList = true
		hitbox.onTouch = tryCapture

		local elapsed = 0
		local growConn

		growConn = RunService.Heartbeat:Connect(function(dt)
			elapsed += dt
			local alpha = math.clamp(elapsed / GROW_TIME, 0, 1)
			local currentLen = GROW_DISTANCE * alpha

			local centerPos = originPos + lookFlat * (currentLen / 2)
			local newSize = Vector3.new(HITBOX_WIDTH, HITBOX_WIDTH, math.max(currentLen, 0.05))

			HitboxPart.Size = newSize
			HitboxPart.CFrame = CFrame.new(centerPos, centerPos + lookFlat)
			hitbox.Size = newSize

			if alpha >= 1 then
				growConn:Disconnect()
				hitbox:Stop()
				pullBack()
			end
		end)

		hitbox:Start()
	end,
}
