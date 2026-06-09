--// Services \\--

local RNS = game:GetService("RunService")
local RS = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')



--// Remotes \\--

local Remotes = RS.Remotes

local ReplicateSet = Remotes.Replicate.Set



--// ReplicatedModules \\--

local ReplicatedModules = RS.Shared.Modules

local Utility = require(ReplicatedModules.Utility)



--// Params \\--

local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include
overlapParams.FilterDescendantsInstances = { workspace.Live }



--// Variables \\--

local getCframe = {
	["Instance"] = function(point)
		return point.CFrame
	end,

	["CFrame"] = function(point)
		return point
	end,

	["Vector3"] = function(point)
		return CFrame.new(point)
	end
}



--// Metatable \\--

local HB = {}
HB.__index = HB



--// Functions \\--

local function GetPartBoundsInBox(params, customOVP)
	return workspace:GetPartBoundsInBox(params.cf, params.size, customOVP or overlapParams)
end

local function GetPartBoundsInRadius(params, customOVP)
	return workspace:GetPartBoundsInRadius(params.pos, params.radius, customOVP or overlapParams)
end

function HB.new()
	return setmetatable({
		Size = Vector3.new(1,1,1) * 7,
		HitType = nil,
		Ignore = {},
		Instance = nil,
		Offset = CFrame.new(0, 0, 0),
		Characters = {},
		onTouch = function(EnemyCharacter: Model) end,
		Connection = nil,
		Method = 'Box',
		ResetCharactersList = false,
		DestroyAmbient = nil,
		Voxels = nil
	}, HB)
end


function HB:_Cast(dt)
	assert(self.Instance,'There\'s no instance set for the hitbox')
	assert(self.Size,'There\'s no size set for the hitbox')
	if game.PlaceId == workspace:GetAttribute("DuelsHubPlaceId") then return end


	local params
	local detectFunction
	local HitboxCFrame: CFrame = getCframe[typeof(self.Instance)]
	if not HitboxCFrame then return end
	HitboxCFrame = HitboxCFrame(self.Instance)
	if not HitboxCFrame then return self:Destroy() end
	HitboxCFrame *= self.Offset

	task.spawn(function()
		if not RNS:IsStudio() or self.Visualize == false then return end

		ReplicateSet:FireAllClients('Hitbox', { Method = self.Method, Size = self.Size, CFrame = HitboxCFrame })
	end)

	if self.Method == 'Box' then
		detectFunction = GetPartBoundsInBox
		params = { cf = HitboxCFrame, size = self.Size }
	else
		detectFunction = GetPartBoundsInRadius
		params = { pos = HitboxCFrame.Position, radius = self.Size }
	end

	local closestCharacter = nil

	if self.ResetCharactersList == true then
		self.Characters = {}
	end


	shared.VoxelDestruction(detectFunction, params, self.DestroyAmbient, self.Voxels)


	local touchedCharacters = {}
	local touchingParts = detectFunction(params)
	for _,v in touchingParts do
		if v and v.Parent then
			local Character: Model = v.Parent

			if Character then
				local Player = Players:GetPlayerFromCharacter(Character)
				if Player and not Player:FindFirstChild("LoadedData") then
					continue
				end

				local Humanoid: Humanoid = Character:FindFirstChild('Humanoid')

				if Humanoid and not table.find(self.Characters, Character) and not table.find(self.Ignore, Character) then
					table.insert(self.Characters, Character)
					table.insert(touchedCharacters, Character)

					if Humanoid.Health > 0 and Humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
						if closestCharacter ~= nil then
							if (Character.HumanoidRootPart.Position - HitboxCFrame.Position).Magnitude < (closestCharacter.HumanoidRootPart.Position - HitboxCFrame.Position).Magnitude then
								closestCharacter = Character
							end
						else
							closestCharacter = Character
						end
					end
				end
			end
		end
	end

	if #touchedCharacters > 0 and closestCharacter ~= nil then
		self.onTouch(closestCharacter, dt)

		if self.HitType ~= 'Single' then
			for _, Character: Model in touchedCharacters do
				if Character == closestCharacter then continue end

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
	end
end

function HB:Start()
	spawn(function()
		self.Connection = RNS.Heartbeat:Connect(function(dt)
			if not pcall(function()
					self:_Cast(dt)
				end) then
				self.Connection:Disconnect()
			end
		end)
	end)
end


function HB:Stop()
	self:Clear()
end


function HB:Destroy()
	self:Clear()
	setmetatable(self,nil)

	if self.HitboxPart then
		self.HitboxPart:Destroy()
	end

	if self.Connection then
		self.Connection:Disconnect()
	end
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
	assert(Object, "No instance set for simple-once hitbox")
	assert(Size, "No size set for simple-once hitbox")
	assert(onTouch, "No onTouch set for simple-once hitbox")
	if game.PlaceId == workspace:GetAttribute("DuelsHubPlaceId") then return end

	Offset = Offset or CFrame.new(0, 0, 0)
	Ignore = Ignore or {}
	Method = Method or "Box"


	local params
	local detectFunction
	local HitboxCFrame: CFrame = getCframe[typeof(Object)](Object) * Offset

	task.spawn(function()
		if not RNS:IsStudio() then return end

		ReplicateSet:FireAllClients('Hitbox', { Method = Method, Size = Size, CFrame = HitboxCFrame })
	end)

	if Method == 'Box' then
		detectFunction = GetPartBoundsInBox
		params = { cf = HitboxCFrame, size = Size }
	else
		detectFunction = GetPartBoundsInRadius
		params = { pos = HitboxCFrame.Position, radius = Size }
	end

	local closestCharacter = nil
	local touchedCharacters = {}
	local touchingParts = detectFunction(params)
	for _,v in touchingParts do
		if v and v.Parent then
			local Character: Model = v.Parent

			if Character then
				local Player = Players:GetPlayerFromCharacter(Character)
				if Player and not Player:FindFirstChild("LoadedData") then
					continue
				end

				local Humanoid: Humanoid = Character:FindFirstChild('Humanoid')

				if Humanoid and not table.find(touchedCharacters, Character) and not table.find(Ignore, Character) then
					table.insert(touchedCharacters, Character)

					if Humanoid.Health > 0 and Humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
						if closestCharacter ~= nil then
							if (Character.HumanoidRootPart.Position - HitboxCFrame.Position).Magnitude < (closestCharacter.HumanoidRootPart.Position - HitboxCFrame.Position).Magnitude then
								closestCharacter = Character
							end
						else
							closestCharacter = Character
						end
					end
				end
			end
		end
	end

	if #touchedCharacters > 0 and closestCharacter ~= nil then
		onTouch(closestCharacter)

		if HitType ~= 'Single' then
			for _, Character: Model in touchedCharacters do
				if Character == closestCharacter then continue end

				onTouch(Character)
			end
		end
	end

	shared.VoxelDestruction(detectFunction, params, DestroyParams, Voxels)
end



return HB