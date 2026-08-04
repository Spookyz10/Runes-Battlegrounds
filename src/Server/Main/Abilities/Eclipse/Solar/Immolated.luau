local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ServerModules = ServerStorage.Modules
local MoveAnims = ServerStorage.Assets.Animations.Moves

local StunHandler = require(ServerModules.StunHandler)
local iFramesService = require(ServerModules.iFramesService)
local AnimationService = require(ServerModules.AnimationService)

local ReplicateSet = ReplicatedStorage.Remotes.Replicate.Set

local DURATION = 10
local DAMAGE_TAKEN_MULT = 0.8
local IMMOLATED_WALKSPEED = 10
local SLOW_RADIUS = 12
local ENEMY_SLOW_MULT = 0.55
local SLOW_UPDATE_INTERVAL = 0.3

local function cleanUp(Character, diedConnection, immolateStun, slowLoopConn, slowedEnemies, originalWalkSpeed)
	if diedConnection then
		diedConnection:Disconnect()
	end
	if immolateStun then
		StunHandler:Unstun(Character, immolateStun)
	end
	if slowLoopConn then
		slowLoopConn:Disconnect()
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
	ReplicateSet:FireAllClients("Immolate", { Char = Character, Enabled = false })

	local Humanoid = Character:FindFirstChild("Humanoid")
	if Humanoid and originalWalkSpeed then
		Humanoid.WalkSpeed = originalWalkSpeed
	end
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

		if Character:GetAttribute("Immolated") then
			return
		end

		local CasterStun = StunHandler:Stun(Character, nil, true, 0, 0, true)
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
				ReplicateSet:FireAllClients("Immolate", { Char = Character, Enabled = true, Duration = DURATION })

				local diedConnection
				local slowedEnemies = {}
				local lastUpdate = 0

				local overlapParams = OverlapParams.new()
				overlapParams.FilterType = Enum.RaycastFilterType.Include
				overlapParams.FilterDescendantsInstances = { workspace.Live }

				local slowLoopConn = RunService.Heartbeat:Connect(function()
					if not Character or not Character.Parent or not HumRP.Parent then
						return
					end

					if os.clock() - lastUpdate < SLOW_UPDATE_INTERVAL then
						return
					end
					lastUpdate = os.clock()

					local parts = workspace:GetPartBoundsInRadius(HumRP.Position, SLOW_RADIUS, overlapParams)
					local currentlyNear = {}

					for _, part in parts do
						local EnemyCharacter = part.Parent
						if not EnemyCharacter or EnemyCharacter == Character then
							continue
						end

						local EnemyHumanoid = EnemyCharacter:FindFirstChild("Humanoid")
						if not EnemyHumanoid or EnemyHumanoid.Health <= 0 then
							continue
						end

						currentlyNear[EnemyCharacter] = true

						if not slowedEnemies[EnemyCharacter] then
							slowedEnemies[EnemyCharacter] = EnemyHumanoid.WalkSpeed
							EnemyHumanoid.WalkSpeed = slowedEnemies[EnemyCharacter] * ENEMY_SLOW_MULT
						end
					end

					for EnemyCharacter, baseSpeed in slowedEnemies do
						if not currentlyNear[EnemyCharacter] then
							if EnemyCharacter and EnemyCharacter.Parent then
								local EnemyHumanoid = EnemyCharacter:FindFirstChild("Humanoid")
								if EnemyHumanoid then
									EnemyHumanoid.WalkSpeed = baseSpeed
								end
							end
							slowedEnemies[EnemyCharacter] = nil
						end
					end
				end)

				diedConnection = Humanoid.Died:Once(function()
					cleanUp(Character, diedConnection, immolateStun, slowLoopConn, slowedEnemies, originalWalkSpeed)
				end)

				task.delay(DURATION, function()
					if not Character or not Character.Parent then
						return
					end
					if not Character:GetAttribute("Immolated") then
						return
					end
					cleanUp(Character, diedConnection, immolateStun, slowLoopConn, slowedEnemies, originalWalkSpeed)
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
