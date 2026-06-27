local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local ServerModules = ServerStorage.Modules
local ReplicatedModules = ReplicatedStorage.Shared.Modules

local StunHandler = require(ServerModules.StunHandler)
local DamageHandler = require(ServerModules.DamageHandler)
local iFramesService = require(ServerModules.iFramesService)
local PerfectKnockback = require(ServerModules.PerfectKnockback)
local RagdollHandler = require(ServerModules.RagdollHandler)
local CollisionsModule = require(ServerModules.CollisionsModule)
local ReplicatedHitboxes = require(ServerModules.ReplicatedHitboxes)

local WeldSystem = require(ReplicatedModules.WeldSystem)

local WINDUP_TIME = 0.35
local RUN_TIME = 5
local RUN_SPEED = 20
local RUN_HITBOX_SIZE = Vector3.new(9, 8, 10)
local RUN_HITBOX_OFFSET = CFrame.new(0, 0, -5)

local WELD_OFFSET = CFrame.new(0, 0, -3) * CFrame.Angles(0, math.pi, 0)
local BARRAGE_HITS = 10
local BARRAGE_INTERVAL = 0.09
local BARRAGE_DAMAGE = 1.5
local BARRAGE_HITBOX_SIZE = Vector3.new(9, 8, 9)
local BARRAGE_HITBOX_OFFSET = CFrame.new(0, 0, -4)

local FINISH_DAMAGE = 8
local BEAM_DELAY = 0.18
local BEAM_DURATION = 1.5
local BEAM_TICK = 0.2
local BEAM_DAMAGE = 2
local BEAM_SIZE = Vector3.new(15, 15, 100)
local BEAM_OFFSET = CFrame.new(0, 0, -50)

local function destroyHitbox(hitbox)
	if not hitbox then
		return
	end

	if type(hitbox.Destroy) == "function" then
		hitbox:Destroy()
	elseif type(hitbox.Stop) == "function" then
		hitbox:Stop()
	end
end

local function getFlatDirection(Humanoid, HumRP)
	local direction = Humanoid.MoveDirection
	direction = Vector3.new(direction.X, 0, direction.Z)

	if direction.Magnitude < 0.05 then
		direction = HumRP.CFrame.LookVector
		direction = Vector3.new(direction.X, 0, direction.Z)
	end

	if direction.Magnitude < 0.05 then
		return Vector3.new(0, 0, -1)
	end

	return direction.Unit
end

local function isValidEnemy(Character, EnemyCharacter, Tool)
	if not EnemyCharacter or EnemyCharacter == Character then
		return false
	end

	local EnemyHumanoid = EnemyCharacter:FindFirstChild("Humanoid")
	local EnemyHumRP = EnemyCharacter:FindFirstChild("HumanoidRootPart")
	if not EnemyHumanoid or not EnemyHumRP then
		return false
	end

	if EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then
		return false
	end

	if EnemyCharacter:HasTag("Ragdolled") then
		return false
	end

	if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) then
		return false
	end

	return true
end

return {
	Start = function(Player, Tool)
		local Character = Player.Character
		if not Character then
			return
		end

		local Humanoid = Character:FindFirstChild("Humanoid")
		local HumRP = Character:FindFirstChild("HumanoidRootPart")
		if not Humanoid or not HumRP then
			return
		end

		local Finished = false
		local GrabbedEnemy = nil
		local CasterStun = nil
		local EnemyStun = nil
		local Weld = nil
		local RunVelocity = nil
		local RunConnection = nil
		local RunHitbox = nil

		local function cleanup()
			if Finished then
				return
			end
			Finished = true

			if RunConnection then
				RunConnection:Disconnect()
				RunConnection = nil
			end

			if RunVelocity then
				RunVelocity:Destroy()
				RunVelocity = nil
			end

			destroyHitbox(RunHitbox)
			RunHitbox = nil

			if Weld then
				pcall(function()
					Weld:Stop()
				end)
				Weld = nil
			end

			if GrabbedEnemy and GrabbedEnemy.Parent then
				if EnemyStun then
					StunHandler:Unstun(GrabbedEnemy, EnemyStun)
					EnemyStun = nil
				end

				GrabbedEnemy:RemoveTag("CantRotate")
				iFramesService:RemoveAlliFrames(GrabbedEnemy)
				CollisionsModule:SetCollisionGroup(GrabbedEnemy, "Players")
			end

			iFramesService:RemoveAlliFrames(Character)
			CollisionsModule:SetCollisionGroup(Character, "Players")

			if CasterStun then
				StunHandler:Unstun(Character, CasterStun)
				CasterStun = nil
			end
		end

		local function doBeam()
			if not Character.Parent or not Humanoid.Parent or Humanoid.Health <= 0 then
				cleanup()
				return
			end

			local BeamHitbox = ReplicatedHitboxes.new(Player)
			if not BeamHitbox then
				cleanup()
				return
			end

			local lastDamaged = {}
			BeamHitbox.Instance = HumRP
			BeamHitbox.Size = BEAM_SIZE
			BeamHitbox.Offset = BEAM_OFFSET
			BeamHitbox.Ignore = { Character }
			BeamHitbox.ResetCharactersList = true
			BeamHitbox.onTouch = function(EnemyCharacter)
				if not isValidEnemy(Character, EnemyCharacter, Tool) then
					return
				end

				local now = os.clock()
				if lastDamaged[EnemyCharacter] and now - lastDamaged[EnemyCharacter] < BEAM_TICK then
					return
				end
				lastDamaged[EnemyCharacter] = now

				DamageHandler:TakeDamage(
					Character,
					EnemyCharacter.Humanoid,
					BEAM_DAMAGE,
					0.25,
					nil,
					false,
					true,
					true,
					true,
					false,
					nil,
					nil
				)
			end

			BeamHitbox:Start(BEAM_DURATION, true)
			task.delay(BEAM_DURATION, cleanup)
		end

		local function launchEnemy(EnemyCharacter)
			if Weld then
				pcall(function()
					Weld:Stop()
				end)
				Weld = nil
			end

			if not EnemyCharacter or not EnemyCharacter.Parent then
				task.delay(BEAM_DELAY, doBeam)
				return
			end

			local EnemyHumanoid = EnemyCharacter:FindFirstChild("Humanoid")
			local EnemyHumRP = EnemyCharacter:FindFirstChild("HumanoidRootPart")
			if not EnemyHumanoid or not EnemyHumRP then
				task.delay(BEAM_DELAY, doBeam)
				return
			end

			if EnemyStun then
				StunHandler:Unstun(EnemyCharacter, EnemyStun)
				EnemyStun = nil
			end

			EnemyCharacter:RemoveTag("CantRotate")
			iFramesService:RemoveAlliFrames(EnemyCharacter)
			CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")

			EnemyHumRP.AssemblyLinearVelocity = Vector3.zero
			EnemyHumRP.AssemblyAngularVelocity = Vector3.zero

			local HitInfo = DamageHandler:TakeDamage(
				Character,
				EnemyHumanoid,
				FINISH_DAMAGE,
				nil,
				nil,
				false,
				true,
				true,
				true,
				true,
				nil,
				nil
			)

			if not HitInfo.Countered and not HitInfo.Blocked and EnemyHumanoid.Health > 0 then
				local launchDirection = HumRP.CFrame.LookVector
				launchDirection = Vector3.new(launchDirection.X, 0, launchDirection.Z)
				if launchDirection.Magnitude < 0.05 then
					launchDirection = Vector3.new(0, 0, -1)
				else
					launchDirection = launchDirection.Unit
				end

				PerfectKnockback:KnockBack(nil, EnemyCharacter, {
					LookVector = launchDirection,
					LookForce = 70,
					LookFinalForce = 60,
					LookAt = CFrame.lookAt(EnemyHumRP.Position, EnemyHumRP.Position + launchDirection),
					UpVelocity = Vector3.new(0, 35, 0),
					UpVelocityTime = 0.12,
					GroundStunTime = 1.1,
					FallingDetectDelay = 0.25,
					Dot = 1,
					DontFreeze = false,
				}, Character)
			end

			task.delay(BEAM_DELAY, doBeam)
		end

		local function doBarrage(EnemyCharacter)
			if not EnemyCharacter or not EnemyCharacter.Parent then
				cleanup()
				return
			end

			for hitIndex = 1, BARRAGE_HITS do
				task.delay((hitIndex - 1) * BARRAGE_INTERVAL, function()
					if Finished or not EnemyCharacter.Parent then
						return
					end

					local BarrageHitbox = ReplicatedHitboxes.new(Player)
					if not BarrageHitbox then
						return
					end

					local hitApplied = false
					BarrageHitbox.Instance = HumRP
					BarrageHitbox.Size = BARRAGE_HITBOX_SIZE
					BarrageHitbox.Offset = BARRAGE_HITBOX_OFFSET
					BarrageHitbox.Ignore = { Character }
					BarrageHitbox.destroyAfterOnce = true
					BarrageHitbox.onTouch = function(TouchedCharacter)
						if hitApplied or TouchedCharacter ~= EnemyCharacter then
							return
						end

						if not isValidEnemy(Character, TouchedCharacter, Tool) then
							return
						end

						hitApplied = true
						DamageHandler:TakeDamage(
							Character,
							TouchedCharacter.Humanoid,
							BARRAGE_DAMAGE,
							nil,
							nil,
							false,
							true,
							true,
							true,
							false,
							nil,
							nil
						)
					end

					BarrageHitbox:Once()
					task.delay(0.1, function()
						destroyHitbox(BarrageHitbox)
					end)
				end)
			end

			task.delay(BARRAGE_HITS * BARRAGE_INTERVAL + 0.08, function()
				if Finished then
					return
				end

				launchEnemy(EnemyCharacter)
			end)
		end

		local function grabEnemy(EnemyCharacter)
			if Finished or not isValidEnemy(Character, EnemyCharacter, Tool) then
				return
			end

			destroyHitbox(RunHitbox)
			RunHitbox = nil

			if RunConnection then
				RunConnection:Disconnect()
				RunConnection = nil
			end

			if RunVelocity then
				RunVelocity:Destroy()
				RunVelocity = nil
			end

			GrabbedEnemy = EnemyCharacter

			if CasterStun then
				StunHandler:Unstun(Character, CasterStun)
			end
			CasterStun = StunHandler:Stun(Character, nil, true, 0, 0, true)

			local EnemyHumanoid = EnemyCharacter.Humanoid
			local EnemyHumRP = EnemyCharacter.HumanoidRootPart
			local EnemyPlayer = Players:GetPlayerFromCharacter(EnemyCharacter)

			if EnemyCharacter:HasTag("Ragdolled") then
				RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, false, nil, nil, true)
			end

			EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
			EnemyCharacter:AddTag("CantRotate")
			iFramesService:AddAlliFrames(EnemyCharacter)
			CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")
			CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")

			EnemyHumRP.AssemblyLinearVelocity = Vector3.zero
			EnemyHumRP.AssemblyAngularVelocity = Vector3.zero
			HumRP.AssemblyLinearVelocity = Vector3.zero
			HumRP.AssemblyAngularVelocity = Vector3.zero

			HumRP.CFrame = CFrame.lookAt(
				HumRP.Position,
				Vector3.new(EnemyHumRP.Position.X, HumRP.Position.Y, EnemyHumRP.Position.Z)
			)

			Weld = WeldSystem.new(HumRP, EnemyHumRP, WELD_OFFSET, -1)
			Weld:Start(nil, EnemyPlayer, Player)

			DamageHandler:TakeDamage(
				Character,
				EnemyHumanoid,
				2,
				nil,
				nil,
				false,
				true,
				true,
				true,
				false,
				nil,
				nil
			)

			doBarrage(EnemyCharacter)
		end

		CasterStun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		iFramesService:AddAlliFrames(Character)

		task.delay(WINDUP_TIME, function()
			if Finished or not Character.Parent or Humanoid.Health <= 0 then
				cleanup()
				return
			end

			if CasterStun then
				StunHandler:Unstun(Character, CasterStun)
			end
			CasterStun = StunHandler:Stun(Character, nil, true, RUN_SPEED, 0, true)

			RunVelocity = Instance.new("BodyVelocity")
			RunVelocity.Name = "CataclysmRunVelocity"
			RunVelocity.MaxForce = Vector3.new(50000, 0, 50000)
			RunVelocity.P = math.huge
			RunVelocity.Parent = HumRP
			Debris:AddItem(RunVelocity, RUN_TIME + 0.2)

			RunConnection = RunService.Heartbeat:Connect(function()
				if Finished or not RunVelocity or not RunVelocity.Parent or Humanoid.Health <= 0 then
					cleanup()
					return
				end

				local direction = getFlatDirection(Humanoid, HumRP)
				RunVelocity.Velocity = direction * RUN_SPEED
				HumRP.CFrame = CFrame.lookAt(HumRP.Position, HumRP.Position + direction)
			end)

			RunHitbox = ReplicatedHitboxes.new(Player)
			if not RunHitbox then
				cleanup()
				return
			end

			RunHitbox.Instance = HumRP
			RunHitbox.Size = RUN_HITBOX_SIZE
			RunHitbox.Offset = RUN_HITBOX_OFFSET
			RunHitbox.Ignore = { Character }
			RunHitbox.onTouch = grabEnemy
			RunHitbox:Start(RUN_TIME, true)

			task.delay(RUN_TIME, function()
				if not Finished and not GrabbedEnemy then
					cleanup()
				end
			end)
		end)
	end,
}
