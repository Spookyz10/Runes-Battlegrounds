local RNS = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local DebugHitboxes = true

local Remotes = RS.Remotes
local ReplicateSet = Remotes.Replicate.Set

local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include
overlapParams.FilterDescendantsInstances = { workspace.Live }

local getCframe = {
	["Instance"] = function(point)
		return point.CFrame
	end,

	["CFrame"] = function(point)
		return point
	end,

	["Vector3"] = function(point)
		return CFrame.new(point)
	end,
}

local HB = {}
HB.__index = HB

local function GetPartBoundsInBox(params, customOVP)
	return workspace:GetPartBoundsInBox(params.cf, params.size, customOVP or overlapParams)
end

local function GetPartBoundsInRadius(params, customOVP)
	return workspace:GetPartBoundsInRadius(params.pos, params.radius, customOVP or overlapParams)
end

function HB.new()
	return setmetatable({
		Size = Vector3.new(1, 1, 1) * 7,
		HitType = nil,
		Ignore = {},
		Instance = nil,
		Offset = CFrame.new(0, 0, 0),
		Characters = {},
		onTouch = function(EnemyCharacter) end,
		Connection = nil,
		Method = "Box",
		ResetCharactersList = false,
		DestroyAmbient = nil,
		Voxels = nil,
	}, HB)
end

function HB:_Cast(dt)
	assert(self.Instance, "There's no instance set for the hitbox")
	assert(self.Size, "There's no size set for the hitbox")

	if game.PlaceId == workspace:GetAttribute("DuelsHubPlaceId") then
		return
	end

	local HitboxCFrame = getCframe[typeof(self.Instance)]
	if not HitboxCFrame then
		return
	end

	HitboxCFrame = HitboxCFrame(self.Instance)
	if not HitboxCFrame then
		return self:Destroy()
	end

	HitboxCFrame = HitboxCFrame * self.Offset

	if RNS:IsStudio() and DebugHitboxes then
		task.spawn(function()
			ReplicateSet:FireAllClients("Hitbox", { Method = self.Method, Size = self.Size, CFrame = HitboxCFrame })
		end)
	end

	local params
	local detectFunction

	if self.Method == "Box" then
		detectFunction = GetPartBoundsInBox
		params = { cf = HitboxCFrame, size = self.Size }
	else
		detectFunction = GetPartBoundsInRadius
		params = { pos = HitboxCFrame.Position, radius = self.Size }
	end

	if self.ResetCharactersList == true then
		self.Characters = {}
	end

	shared.VoxelDestruction(detectFunction, params, self.DestroyAmbient, self.Voxels)

	local closestCharacter = nil
	local touchedCharacters = {}
	local touchingParts = detectFunction(params)

	for _, v in touchingParts do
		if not v or not v.Parent then
			continue
		end

		local Character = v.Parent
		if not Character then
			continue
		end

		local Player = Players:GetPlayerFromCharacter(Character)
		if Player and not Player:FindFirstChild("LoadedData") then
			continue
		end

		local Humanoid = Character:FindFirstChild("Humanoid")

		if Humanoid and not table.find(self.Characters, Character) and not table.find(self.Ignore, Character) then
			table.insert(self.Characters, Character)
			table.insert(touchedCharacters, Character)

			if Humanoid.Health > 0 and Humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
				if closestCharacter ~= nil then
					if
						(Character.HumanoidRootPart.Position - HitboxCFrame.Position).Magnitude
						< (closestCharacter.HumanoidRootPart.Position - HitboxCFrame.Position).Magnitude
					then
						closestCharacter = Character
					end
				else
					closestCharacter = Character
				end
			end
		end
	end

	if #touchedCharacters > 0 and closestCharacter ~= nil then
		self.onTouch(closestCharacter, dt)

		if self.HitType ~= "Single" then
			for _, Character in touchedCharacters do
				if Character == closestCharacter then
					continue
				end
				self.onTouch(Character, dt)
			end
		end
	end

	return touchedCharacters
end

function HB:Clear()
	self.Characters = {}

	if self.Connection then
		self.Connection:Disconnect()
		self.Connection = nil
	end
end

function HB:Start()
	task.spawn(function()
		self.Connection = RNS.Heartbeat:Connect(function(dt)
			if not pcall(function()
				self:_Cast(dt)
			end) then
				self.Connection:Disconnect()
				self.Connection = nil
			end
		end)
	end)
end

function HB:Stop()
	self:Clear()
end

function HB:Destroy()
	self:Clear()

	if self.HitboxPart then
		self.HitboxPart:Destroy()
	end

	setmetatable(self, nil)
end

function HB:Clone()
	return setmetatable({
		Size = self.Size,
		HitType = self.HitType,
		Ignore = self.Ignore,
		Instance = self.Instance,
		Offset = self.Offset,
		Characters = {},
		onTouch = self.onTouch,
		Connection = nil,
		Method = self.Method,
		ResetCharactersList = self.ResetCharactersList,
	}, HB)
end

function HB:Once()
	return self:_Cast()
end

function HB:SimpleOnce(Object, Size, Offset, Ignore, Method, HitType, onTouch, DestroyParams, Voxels)
	print("[DEBUG SimpleOnce] ====== START =====")
	print("[DEBUG SimpleOnce] Object:", Object, typeof(Object))
	print("[DEBUG SimpleOnce] Size:", Size)
	print("[DEBUG SimpleOnce] Offset:", Offset)
	print("[DEBUG SimpleOnce] Ignore:", Ignore)
	print("[DEBUG SimpleOnce] Method:", Method)
	print("[DEBUG SimpleOnce] HitType:", HitType)
	print("[DEBUG SimpleOnce] onTouch:", onTouch)
	print("[DEBUG SimpleOnce] DestroyParams:", DestroyParams)
	print("[DEBUG SimpleOnce] Voxels:", Voxels)

	assert(Object, "No instance set for simple-once hitbox")
	print("[DEBUG SimpleOnce] assert Object passed")
	assert(Size, "No size set for simple-once hitbox")
	print("[DEBUG SimpleOnce] assert Size passed")
	assert(onTouch, "No onTouch set for simple-once hitbox")
	print("[DEBUG SimpleOnce] assert onTouch passed")

	Offset = Offset or CFrame.new(0, 0, 0)
	Ignore = Ignore or {}
	Method = Method or "Box"
	print("[DEBUG SimpleOnce] defaults applied — Offset:", Offset, "Method:", Method)

	local cframeFunc = getCframe[typeof(Object)]
	print("[DEBUG SimpleOnce] cframeFunc:", cframeFunc, "typeof(Object):", typeof(Object))

	if not cframeFunc then
		warn("[DEBUG SimpleOnce] NO CFrame function found for type:", typeof(Object))
		return
	end

	local HitboxBase = cframeFunc(Object)
	print("[DEBUG SimpleOnce] HitboxBase:", HitboxBase)

	local HitboxCFrame = HitboxBase * Offset
	print("[DEBUG SimpleOnce] HitboxCFrame:", HitboxCFrame)

	if RNS:IsStudio() and DebugHitboxes then
		print("[DEBUG SimpleOnce] firing debug hitbox visual")
		task.spawn(function()
			ReplicateSet:FireAllClients("Hitbox", { Method = Method, Size = Size, CFrame = HitboxCFrame })
		end)
	end

	local params
	local detectFunction

	if Method == "Box" then
		detectFunction = GetPartBoundsInBox
		params = { cf = HitboxCFrame, size = Size }
		print("[DEBUG SimpleOnce] Using Box method — params:", params)
	else
		detectFunction = GetPartBoundsInRadius
		params = { pos = HitboxCFrame.Position, radius = Size }
		print("[DEBUG SimpleOnce] Using Radius method — params:", params)
	end

	local closestCharacter = nil
	local touchedCharacters = {}
	local touchingParts = detectFunction(params)
	print("[DEBUG SimpleOnce] touchingParts count:", #touchingParts)

	for i, v in touchingParts do
		print("[DEBUG SimpleOnce] touchingParts[" .. i .. "]:", v, v and v.Parent)

		if not v or not v.Parent then
			print("[DEBUG SimpleOnce] skipping — v or parent nil")
			continue
		end

		local Character = v.Parent
		print("[DEBUG SimpleOnce] Character:", Character)

		if not Character then
			print("[DEBUG SimpleOnce] skipping — Character nil")
			continue
		end

		local Player = Players:GetPlayerFromCharacter(Character)
		print("[DEBUG SimpleOnce] Player:", Player)

		if Player and not Player:FindFirstChild("LoadedData") then
			print("[DEBUG SimpleOnce] skipping — Player has no LoadedData")
			continue
		end

		local Humanoid = Character:FindFirstChild("Humanoid")
		print("[DEBUG SimpleOnce] Humanoid:", Humanoid)

		local alreadyTouched = table.find(touchedCharacters, Character)
		local inIgnore = table.find(Ignore, Character)
		print("[DEBUG SimpleOnce] alreadyTouched:", alreadyTouched, "inIgnore:", inIgnore)

		if Humanoid and not alreadyTouched and not inIgnore then
			table.insert(touchedCharacters, Character)
			print("[DEBUG SimpleOnce] added to touchedCharacters, count now:", #touchedCharacters)

			if Humanoid.Health > 0 and Humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
				print("[DEBUG SimpleOnce] Humanoid alive, Health:", Humanoid.Health)

				local dist = (Character.HumanoidRootPart.Position - HitboxCFrame.Position).Magnitude
				print("[DEBUG SimpleOnce] distance:", dist)

				if closestCharacter ~= nil then
					local closestDist = (closestCharacter.HumanoidRootPart.Position - HitboxCFrame.Position).Magnitude
					print("[DEBUG SimpleOnce] comparing — current closest dist:", closestDist)

					if dist < closestDist then
						print("[DEBUG SimpleOnce] new closestCharacter")
						closestCharacter = Character
					end
				else
					print("[DEBUG SimpleOnce] first alive character, setting as closest")
					closestCharacter = Character
				end
			else
				print(
					"[DEBUG SimpleOnce] Humanoid dead or dying — Health:",
					Humanoid and Humanoid.Health,
					"State:",
					Humanoid and Humanoid:GetState()
				)
			end
		else
			print(
				"[DEBUG SimpleOnce] condition failed — Humanoid:",
				Humanoid,
				"alreadyTouched:",
				alreadyTouched,
				"inIgnore:",
				inIgnore
			)
		end
	end

	print("[DEBUG SimpleOnce] final touchedCharacters:", #touchedCharacters)
	print("[DEBUG SimpleOnce] closestCharacter:", closestCharacter)

	if #touchedCharacters > 0 and closestCharacter ~= nil then
		print("[DEBUG SimpleOnce] calling onTouch(closestCharacter)")
		onTouch(closestCharacter)

		if HitType ~= "Single" then
			print("[DEBUG SimpleOnce] HitType not Single, iterating remaining")
			for _, Character in touchedCharacters do
				if Character == closestCharacter then
					continue
				end
				print("[DEBUG SimpleOnce] calling onTouch(remaining):", Character)
				onTouch(Character)
			end
		else
			print("[DEBUG SimpleOnce] HitType is Single, only called on closest")
		end
	else
		print("[DEBUG SimpleOnce] NO TouchedCharacters — nothing was hit")
	end

	shared.VoxelDestruction(detectFunction, params, DestroyParams, Voxels)
	print("[DEBUG SimpleOnce] ====== END =====")
end

return HB
