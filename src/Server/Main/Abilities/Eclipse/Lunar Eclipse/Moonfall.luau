local RunService = game:GetService("RunService")

local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local SvModules = ServerStorage.Modules

local DamageHandler = require(SvModules.DamageHandler)
local iFramesService = require(SvModules.iFramesService)
local HitboxHandler = require(SvModules.HitboxHandler)
local RagdollHandler = require(SvModules.RagdollHandler)
local AnimationService = require(SvModules.AnimationService)
local StunHandler = require(SvModules.StunHandler)
local DestructionSystem = require(SvModules.DestructionSystem)

local Remotes = ReplicatedStorage.Remotes
local ReplicateSet = Remotes.Replicate.Set
local CutscenesSet = Remotes.Cutscenes.Set

local Animations = ServerStorage.Assets.Animations.Moves
local StrikeAnim = Animations.Eclipse.Lunar.Awakening.Moonfall

local MapRayParams = RaycastParams.new()
MapRayParams.FilterType = Enum.RaycastFilterType.Include
MapRayParams.FilterDescendantsInstances = { workspace.Map }
MapRayParams.RespectCanCollide = true
MapRayParams.IgnoreWater = true

local IslandsFolder = workspace.Map.Islands
local IslandsInUse = {}

local GRAVITY_HALF_SIZE = Vector3.new(15, 15, 15)
local GRAVITY_STUN_TICK = 0.5
local JUMP_HEIGHT = 100
local ISLAND_HOVER_HEIGHT = 40
local ISLAND_TRAVEL_TIME = 1.6
local ISLAND_THROW_TIME = 1.1
local ISLAND_DESTROY_FORCE = 90
local IMPACT_SIZE = Vector3.new(45, 45, 45)
local IMPACT_DAMAGE = 30

local ActiveState = {}

local function dprint(...)
	print("[LunarStrike]", ...)
end

local function isDestroyablePart(part)
	if not part:IsA("BasePart") then
		return false
	end
	if part:GetAttribute("Destroyable") == true then
		return true
	end
	local model = part:FindFirstAncestorOfClass("Model")
	while model do
		if model:GetAttribute("Destroyable") == true then
			return true
		end
		model = model.Parent and model.Parent:FindFirstAncestorOfClass("Model")
	end
	return false
end

local function findGroundY(position)
	local ray = workspace:Raycast(position + Vector3.new(0, 10, 0), Vector3.new(0, -200, 0), MapRayParams)
	if ray then
		return ray.Position.Y
	end
	return position.Y
end

local function pickIsland(nearPosition)
	local best, bestDist = nil, math.huge
	for _, model in IslandsFolder:GetChildren() do
		if model:IsA("Model") and not IslandsInUse[model] then
			local pivotPos = model:GetPivot().Position
			local dist = (pivotPos - nearPosition).Magnitude
			if dist < bestDist then
				best, bestDist = model, dist
			end
		end
	end
	return best
end

local function getModelSize(model)
	local ok, size = pcall(function()
		return model:GetExtentsSize()
	end)
	if ok then
		return size
	end
	return Vector3.new(30, 30, 30)
end

function ActiveState.new(Character, Player)
	local data = {
		Character = Character,
		Player = Player,
		Cancelled = false,
		GravityPos = nil,
		GravityActive = false,
		GravityConn = nil,
		Island = nil,
		IslandConn = nil,
		OriginalWalkSpeed = nil,
		PreviousiFrameLevel = 0,
		GroundReturnPosition = nil,
	}
	return data
end

local function stopGravityField(data)
	if not data.GravityActive then
		return
	end
	data.GravityActive = false
	if data.GravityConn then
		data.GravityConn:Disconnect()
		data.GravityConn = nil
	end
	if data.GravityPos then
		ReplicateSet:FireAllClients("Gravity", { func = "End", char = data.Character })
	end
end

local function startGravityField(data, position)
	data.GravityPos = position
	data.GravityActive = true

	ReplicateSet:FireAllClients("Gravity", { func = "start", char = data.Character, pos = position })

	for _, plr in Players:GetPlayers() do
		local otherChar = plr.Character
		if not otherChar or otherChar == data.Character then
			continue
		end
		local otherHumRP = otherChar:FindFirstChild("HumanoidRootPart")
		local otherHum = otherChar:FindFirstChild("Humanoid")
		if not otherHumRP or not otherHum or otherHum.Health <= 0 then
			continue
		end
		local delta = otherHumRP.Position - position
		if
			math.abs(delta.X) <= GRAVITY_HALF_SIZE.X
			and math.abs(delta.Y) <= GRAVITY_HALF_SIZE.Y
			and math.abs(delta.Z) <= GRAVITY_HALF_SIZE.Z
		then
			StunHandler:Stun(otherChar, 2, true)
			RagdollHandler.ragdoll(otherHum, 2)
		end
	end

	local lastTick = os.clock()
	data.GravityConn = RunService.Heartbeat:Connect(function()
		if not data.GravityActive then
			return
		end
		if os.clock() - lastTick < GRAVITY_STUN_TICK then
			return
		end
		lastTick = os.clock()

		for _, plr in Players:GetPlayers() do
			local otherChar = plr.Character
			if not otherChar then
				continue
			end
			local otherHumRP = otherChar:FindFirstChild("HumanoidRootPart")
			local otherHum = otherChar:FindFirstChild("Humanoid")
			if not otherHumRP or not otherHum or otherHum.Health <= 0 then
				continue
			end
			local delta = otherHumRP.Position - data.GravityPos
			if
				math.abs(delta.X) <= GRAVITY_HALF_SIZE.X
				and math.abs(delta.Y) <= GRAVITY_HALF_SIZE.Y
				and math.abs(delta.Z) <= GRAVITY_HALF_SIZE.Z
			then
				StunHandler:Stun(otherChar, GRAVITY_STUN_TICK + 0.4, true)
				RagdollHandler.ragdoll(otherHum, GRAVITY_STUN_TICK + 0.4)
			end
		end
	end)
end

local function destroyIsland(data, withFade)
	local Island = data.Island
	data.Island = nil
	if data.IslandConn then
		data.IslandConn:Disconnect()
		data.IslandConn = nil
	end
	if Island then
		IslandsInUse[Island] = nil
		if Island.Parent then
			if withFade then
				task.delay(0.05, function()
					if Island and Island.Parent then
						Island:Destroy()
					end
				end)
			else
				Island:Destroy()
			end
		end
	end
end

local function impactIsland(data, impactPosition)
	local Character = data.Character
	local Player = data.Player

	ReplicateSet:FireAllClients("Ground Crater", {
		Seed = math.random(1, 2147483647),
		amount = 80,
		start = impactPosition + Vector3.new(0, 6, 0),
		["end"] = Vector3.new(0, -20, 0),
		rings = 4,
		ringSpacing = 20,
		ringSizeGrowth = 1.9,
		ringGap = 0.24,
		outwardTilt = true,
		debrisSizeMin = 8,
		debrisSizeMax = 20,
		debrisHeightMin = 5,
		debrisHeightMax = 10,
		sizemult = 1.8,
	})

	if Player then
		ReplicateSet:FireClient(Player, "ShakeCamera", { Intensity = 12, Last = 1 })
	end

	HitboxHandler:SimpleOnce(impactPosition, IMPACT_SIZE, nil, { Character }, "Box", nil, function(EnemyCharacter)
		local EnemyHumanoid = EnemyCharacter:FindFirstChild("Humanoid")
		if not EnemyHumanoid or EnemyHumanoid.Health <= 0 then
			return
		end
		DamageHandler:TakeDamage(
			Character,
			EnemyHumanoid,
			IMPACT_DAMAGE,
			1.5,
			nil,
			false,
			false,
			true,
			true,
			true,
			nil,
			nil
		)
		RagdollHandler.ragdoll(EnemyHumanoid, 3)
	end)

	destroyIsland(data, false)
	stopGravityField(data)
end

local function travelIslandToPlayer(data, Character, HumRP)
	local Island = data.Island
	local startPos = Island:GetPivot().Position
	local startRot = Island:GetPivot().Rotation
	local targetPos = HumRP.Position + Vector3.new(0, ISLAND_HOVER_HEIGHT, 0)

	local hitSet = {}
	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Include
	overlapParams.FilterDescendantsInstances = { workspace.Map.Destroyables }

	local islandSize = getModelSize(Island) + Vector3.new(6, 6, 6)

	local startTime = os.clock()
	local completed = false

	data.IslandConn = RunService.Heartbeat:Connect(function()
		if data.Cancelled or not Island.Parent then
			completed = true
			return
		end

		local t = math.clamp((os.clock() - startTime) / ISLAND_TRAVEL_TIME, 0, 1)
		local eased = 1 - (1 - t) ^ 3
		local pos = startPos:Lerp(targetPos, eased)
		local pivot = CFrame.new(pos) * startRot
		Island:PivotTo(pivot)

		local touching = workspace:GetPartBoundsInBox(pivot, islandSize, overlapParams)
		local direction = (targetPos - startPos)
		direction = direction.Magnitude > 0.01 and direction.Unit or Vector3.new(0, 1, 0)

		for _, part in touching do
			if not hitSet[part] and isDestroyablePart(part) then
				hitSet[part] = true
				DestructionSystem:ApplyImpact(pos, ISLAND_DESTROY_FORCE, data.Player, part, direction)
			end
		end

		if t >= 1 then
			completed = true
		end
	end)

	repeat
		task.wait()
	until completed or data.Cancelled

	if data.IslandConn then
		data.IslandConn:Disconnect()
		data.IslandConn = nil
	end
end

local function throwIslandToGravity(data)
	local Island = data.Island
	if not Island or not Island.Parent then
		return
	end

	local startPos = Island:GetPivot().Position
	local startRot = Island:GetPivot().Rotation
	local groundY = findGroundY(data.GravityPos)
	local targetPos = Vector3.new(data.GravityPos.X, groundY, data.GravityPos.Z)

	local startTime = os.clock()
	local completed = false

	data.IslandConn = RunService.Heartbeat:Connect(function()
		if data.Cancelled or not Island.Parent then
			completed = true
			return
		end

		local t = math.clamp((os.clock() - startTime) / ISLAND_THROW_TIME, 0, 1)
		local eased = t * t
		local pos = startPos:Lerp(targetPos, eased)
		Island:PivotTo(CFrame.new(pos) * startRot)

		if t >= 1 then
			completed = true
		end
	end)

	repeat
		task.wait()
	until completed or data.Cancelled

	if data.IslandConn then
		data.IslandConn:Disconnect()
		data.IslandConn = nil
	end

	if not data.Cancelled and Island.Parent then
		impactIsland(data, targetPos)
	end
end

local function cleanup(data)
	if data.Cancelled then
		return
	end
	data.Cancelled = true

	stopGravityField(data)
	destroyIsland(data, true)

	local Character = data.Character
	if Character and Character.Parent then
		local Humanoid = Character:FindFirstChild("Humanoid")
		if Humanoid and data.OriginalWalkSpeed then
			Humanoid.WalkSpeed = data.OriginalWalkSpeed
		end
		Character:SetAttribute("iFrames", data.PreviousiFrameLevel or 0)
	end

	ActiveState[Character] = nil
end

return {
	Start = function(Player, Tool)
		print("Starting Lunar Strike for", Player.Name)
		local Character = Player.Character
		if not Character or not Character.Parent then
			return
		end

		local Humanoid = Character:FindFirstChild("Humanoid")
		local HumRP = Character:FindFirstChild("HumanoidRootPart")
		if not Humanoid or not HumRP or Humanoid.Health <= 0 then
			return
		end

		if ActiveState[Character] then
			cleanup(ActiveState[Character])
		end

		local data = ActiveState.new(Character, Player)
		ActiveState[Character] = data

		AnimationService:stopAll(Character)

		local AnimTrack, AnimEvents = AnimationService:getAnimationTrack(Character, StrikeAnim)
		if not AnimTrack then
			warn("[LunarStrike] AnimTrack is nil for", Character.Name)
			ActiveState[Character] = nil
			return
		end

		data.OriginalWalkSpeed = Humanoid.WalkSpeed
		data.PreviousiFrameLevel = iFramesService:GetLevel(Character)
		data.GroundReturnPosition = HumRP.Position

		StunHandler:Stun(Character, 8, true)
		Humanoid.WalkSpeed = 0
		iFramesService:RemoveAlliFrames(Character)

		local removingConn
		local diedConn

		local function onInterrupt()
			cleanup(data)
		end

		removingConn = Players.PlayerRemoving:Connect(function(leavingPlayer)
			if leavingPlayer == Player then
				onInterrupt()
			end
		end)
		diedConn = Humanoid.Died:Connect(onInterrupt)
		Character.AncestryChanged:Connect(function(_, parent)
			if not parent then
				onInterrupt()
			end
		end)

		table.insert(
			AnimEvents,
			AnimTrack:GetMarkerReachedSignal("clap"):Connect(function()
				if data.Cancelled or not Character.Parent or Humanoid.Health <= 0 then
					return
				end
				iFramesService:AddAlliFrames(Character)
				startGravityField(data, HumRP.Position)
			end)
		)

		table.insert(
			AnimEvents,
			AnimTrack:GetMarkerReachedSignal("jump"):Connect(function()
				if data.Cancelled or not Character.Parent or Humanoid.Health <= 0 then
					return
				end
				ReplicateSet:FireAllClients("LunarImpact", { char = Character })
				HumRP.CFrame = HumRP.CFrame + Vector3.new(0, JUMP_HEIGHT, 0)
			end)
		)

		table.insert(
			AnimEvents,
			AnimTrack:GetMarkerReachedSignal("start"):Connect(function()
				if data.Cancelled or not Character.Parent or Humanoid.Health <= 0 then
					return
				end

				AnimTrack:AdjustSpeed(0)

				local Island = pickIsland(HumRP.Position)
				if not Island then
					warn("[LunarStrike] Nenhuma ilha disponível em workspace.Map.Islands")
					AnimTrack:AdjustSpeed(1)
					return
				end

				IslandsInUse[Island] = true
				data.Island = Island

				travelIslandToPlayer(data, Character, HumRP)

				if data.Cancelled then
					return
				end

				AnimTrack:AdjustSpeed(1)
			end)
		)

		table.insert(
			AnimEvents,
			AnimTrack:GetMarkerReachedSignal("throw"):Connect(function()
				if data.Cancelled or not data.Island then
					return
				end
				task.spawn(function()
					throwIslandToGravity(data)
				end)
			end)
		)

		AnimTrack.Stopped:Once(function()
			if removingConn then
				removingConn:Disconnect()
			end
			if diedConn then
				diedConn:Disconnect()
			end

			if not data.Cancelled then
				if Character and Character.Parent and data.GroundReturnPosition then
					local groundY = findGroundY(data.GroundReturnPosition)
					HumRP.CFrame = CFrame.new(Vector3.new(HumRP.Position.X, groundY + 3, HumRP.Position.Z))
					ReplicateSet:FireAllClients("LunarImpact", { char = Character })
				end

				if Humanoid then
					Humanoid.WalkSpeed = data.OriginalWalkSpeed
				end
				if Character then
					Character:SetAttribute("iFrames", data.PreviousiFrameLevel)
				end
				ActiveState[Character] = nil
			end
		end)

		AnimationService:playAnimation(Character, StrikeAnim)
		CutscenesSet:FireClient(Player, "LunarAwaken", "Start", { Offset = CFrame.new(0, -3, 0) })
	end,
}
