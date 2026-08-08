local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerModules = ServerStorage.Modules
local MoveAnims = ServerStorage.Assets.Animations.Moves

local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)
local SFXModule = require(ReplicatedStorage.Shared.Modules.SFXModule)
local StunHandler = require(ServerModules.StunHandler)
local iFramesService = require(ServerModules.iFramesService)
local AnimationService = require(ServerModules.AnimationService)
local HitboxHandler = require(ServerModules.HitboxHandler)

local DURATION = 10
local DAMAGE_TAKEN_MULT = 0.8
local IMMOLATED_WALKSPEED = 10
local PULSE_HITBOX_SIZE = Vector3.new(34, 34, 34)
local ENEMY_SLOW_MULT = 0.55
local PULSE_INTERVAL = 3
local PULSE_SLOW_DURATION = 2

local function cleanUp(
	Character,
	diedConnection,
	immolateStun,
	pulseThread,
	loopSound,
	slowedEnemies,
	originalWalkSpeed
)
	if diedConnection then
		diedConnection:Disconnect()
	end
	if immolateStun then
		StunHandler:Unstun(Character, immolateStun)
	end
	if pulseThread then
		task.cancel(pulseThread)
	end

	if loopSound then
		SFXModule:Stop(loopSound)
	end

	for EnemyCharacter, baseSpeed in slowedEnemies do
		if EnemyCharacter and EnemyCharacter.Parent then
			local EnemyHumanoid = EnemyCharacter:FindFirstChild("Humanoid")
			if EnemyHumanoid then
				EnemyHumanoid.WalkSpeed = baseSpeed
			end
		end
	end

	Character:SetAttribute("Immolated", nil)
	Character:SetAttribute("DamageTakenMult", nil)
	iFramesService:RemoveiFrames(Character, "Strong")
	RemoteManager.FireAllClients("ReplicateTask", "Immolate", { Char = Character, Enabled = false })

	local Humanoid = Character:FindFirstChild("Humanoid")
	if Humanoid and originalWalkSpeed then
		Humanoid.WalkSpeed = originalWalkSpeed
	end
end

return {
	Cooldown = 30,

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

		if Character:GetAttribute("Immolated") then
			return
		end

		local CasterStun = StunHandler:Stun(Character, nil, true, 0, 0, true, nil, false)
		iFramesService:AddAlliFrames(Character)

		local UserAnimation = MoveAnims.Eclipse.Solar.Immolated
		local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)

		if not UserTrack then
			warn("[Immolated] UserTrack is nil for", Character.Name)
			iFramesService:RemoveAlliFrames(Character)
			StunHandler:Unstun(Character, CasterStun)
			return
		end

		local activated = false

		table.insert(
			UserEvents,
			UserTrack:GetMarkerReachedSignal("clap"):Once(function()
				if activated then
					return
				end
				activated = true

				iFramesService:RemoveAlliFrames(Character)
				StunHandler:Unstun(Character, CasterStun)

				local immolateStun = StunHandler:Stun(Character, 0.35, true, 0, 0, true)
				local originalWalkSpeed = Humanoid.WalkSpeed

				Character:SetAttribute("Immolated", true)
				Character:SetAttribute("DamageTakenMult", DAMAGE_TAKEN_MULT)
				iFramesService:AddStrongiFrames(Character)
				Humanoid.WalkSpeed = IMMOLATED_WALKSPEED
				RemoteManager.FireAllClients(
					"ReplicateTask",
					"Immolate",
					{ Char = Character, Enabled = true, Duration = DURATION }
				)

				SFXModule:Play("ImmolatedStart", HumRP)
				local loopSound = SFXModule:Play("immolatedLoop", HumRP)

				local diedConnection
				local slowedEnemies = {}

				local pulseThread = task.spawn(function()
					while Character:GetAttribute("Immolated") do
						if not Character:GetAttribute("Immolated") then
							break
						end
						if not HumRP.Parent then
							break
						end

						SFXModule:Play("immolatedPulse", HumRP)

						RemoteManager.FireAllClients("ReplicateTask", "ImmolatedPulse", { position = HumRP.Position })

						local pulsedThisTick = {}

						HitboxHandler:SimpleOnce(
							HumRP.Position,
							PULSE_HITBOX_SIZE,
							nil,
							{ Character },
							"Box",
							nil,
							function(EnemyCharacter)
								if pulsedThisTick[EnemyCharacter] then
									return
								end
								local EnemyHumanoid = EnemyCharacter:FindFirstChild("Humanoid")
								if not EnemyHumanoid or EnemyHumanoid.Health <= 0 then
									return
								end

								pulsedThisTick[EnemyCharacter] = true

								local baseSpeed = EnemyHumanoid.WalkSpeed
								if not slowedEnemies[EnemyCharacter] then
									slowedEnemies[EnemyCharacter] = baseSpeed
									EnemyHumanoid.WalkSpeed = math.max(baseSpeed * ENEMY_SLOW_MULT, 1)
								end

								task.delay(PULSE_SLOW_DURATION, function()
									if slowedEnemies[EnemyCharacter] then
										slowedEnemies[EnemyCharacter] = nil
										if EnemyCharacter and EnemyCharacter.Parent then
											local hum = EnemyCharacter:FindFirstChild("Humanoid")
											if hum then
												hum.WalkSpeed = baseSpeed
											end
										end
									end
								end)
							end
						)

						task.wait(PULSE_INTERVAL)
					end
				end)

				diedConnection = Humanoid.Died:Once(function()
					cleanUp(
						Character,
						diedConnection,
						immolateStun,
						pulseThread,
						loopSound,
						slowedEnemies,
						originalWalkSpeed
					)
				end)

				task.delay(DURATION, function()
					if not Character or not Character.Parent then
						return
					end
					if not Character:GetAttribute("Immolated") then
						return
					end
					cleanUp(
						Character,
						diedConnection,
						immolateStun,
						pulseThread,
						loopSound,
						slowedEnemies,
						originalWalkSpeed
					)
				end)
			end)
		)

		UserTrack.Stopped:Once(function()
			for _, v in UserEvents do
				v:Disconnect()
			end

			if not activated then
				iFramesService:RemoveAlliFrames(Character)
				StunHandler:Unstun(Character, CasterStun)
			end
		end)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, UserAnimation)
	end,
}
