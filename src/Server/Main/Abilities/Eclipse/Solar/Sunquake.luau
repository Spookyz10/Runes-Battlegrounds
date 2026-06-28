local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SvSt = ServerStorage
local ServerModules = ServerStorage.Modules

local StunHandler = require(ServerModules.StunHandler)
local HitboxHandler = require(ServerModules.HitboxHandler)
local DamageHandler = require(ServerModules.DamageHandler)
local AnimationService = require(ServerModules.AnimationService)
local iFramesService = require(ServerModules.iFramesService)
local PerfectKnockback = require(ServerModules.PerfectKnockback)

local MoveAnims = ServerStorage.Assets.Animations.Moves
local ReplicateSet = ReplicatedStorage.Remotes.Replicate.Set

local HITBOX_SIZE = Vector3.new(30, 30, 30)
local HITBOX_OFFSET = CFrame.new(0, 0, 0)
local DAMAGE = 1
local STUN_TIME = 0.4
local INFERNO_DURATION = 10

local function applyInferno(EnemyCharacter)
	local existing = EnemyCharacter:GetAttribute("Inferno")
	EnemyCharacter:SetAttribute("Inferno", true)
	if existing then
		return
	end

	local tickStart = tick()
	local duration = INFERNO_DURATION
	local dotInterval = 3
	local dotDamage = 1

	task.spawn(function()
		while EnemyCharacter and EnemyCharacter.Parent and EnemyCharacter:GetAttribute("Inferno") do
			if tick() - tickStart >= duration then
				break
			end
			local Hum = EnemyCharacter:FindFirstChild("Humanoid")
			if not Hum or Hum.Health <= 0 then
				break
			end
			Hum:TakeDamage(dotDamage)
			task.wait(dotInterval)
		end
		if EnemyCharacter and EnemyCharacter.Parent then
			EnemyCharacter:SetAttribute("Inferno", nil)
		end
	end)

	task.delay(duration, function()
		if EnemyCharacter and EnemyCharacter.Parent then
			EnemyCharacter:SetAttribute("Inferno", nil)
		end
	end)
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

		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		iFramesService:AddAlliFrames(Character)

		local UserAnimation = MoveAnims.Eclipse.Solar.Sunquake
		local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)

		table.insert(
			UserEvents,
			UserTrack:GetMarkerReachedSignal("freeze"):Once(function()
				UserTrack:AdjustSpeed(0)

				ReplicateSet:FireAllClients("SunquakeVFX", { char = Character })

				task.delay(1, function()
					if not UserTrack.IsPlaying then
						return
					end

					UserTrack:AdjustSpeed(1)

					local HitList = {}

					HitboxHandler:SimpleOnce(
						HumRP,
						HITBOX_SIZE,
						HITBOX_OFFSET,
						{ Character },
						"Box",
						nil,
						function(EnemyCharacter)
							if table.find(HitList, EnemyCharacter) then
								return
							end

							local EnemyHumanoid = EnemyCharacter:FindFirstChild("Humanoid")
							local EnemyHumRP = EnemyCharacter:FindFirstChild("HumanoidRootPart")
							if not EnemyHumanoid or not EnemyHumRP then
								return
							end
							if EnemyHumanoid.Health <= 0 or EnemyCharacter:HasTag("Ragdolled") then
								return
							end
							if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) then
								return
							end

							table.insert(HitList, EnemyCharacter)

							local HitInfo = DamageHandler:TakeDamage(
								Character,
								EnemyHumanoid,
								DAMAGE,
								STUN_TIME,
								nil,
								false,
								false,
								true,
								true,
								false,
								nil,
								nil
							)

							if HitInfo.Countered or HitInfo.Blocked then
								return
							end

							EnemyHumRP.AssemblyLinearVelocity = Vector3.zero

							local pushDir = (EnemyHumRP.Position - HumRP.Position)
							pushDir = Vector3.new(pushDir.X, 0, pushDir.Z)
							if pushDir.Magnitude > 0 then
								pushDir = pushDir.Unit
							else
								pushDir = HumRP.CFrame.LookVector
							end

							local lookCF = CFrame.lookAt(EnemyHumRP.Position, EnemyHumRP.Position + pushDir)

							PerfectKnockback:KnockBack(nil, EnemyCharacter, {
								LookVector = pushDir,
								LookForce = 20,
								LookFinalForce = 50,
								LookAt = lookCF,
								UpVelocity = Vector3.new(0, 45, 0),
								UpVelocityTime = 0.4,
								GroundStunTime = 1.0,
								FallingDetectDelay = 0.5,
								Dot = 1,
								DontFreeze = false,
							}, Character)

							SvSt.Bindables.AirDetector:Fire(EnemyCharacter, nil, true)
							applyInferno(EnemyCharacter)
						end
					)
				end)
			end)
		)

		UserTrack.Stopped:Once(function()
			for _, v in UserEvents do
				v:Disconnect()
			end

			iFramesService:RemoveAlliFrames(Character)
			StunHandler:Unstun(Character, Stun)
		end)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, UserAnimation)
	end,
}
