local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local TEXTURE_ID = "rbxassetid://95599664835536"
local ACTIVE = {}

local function getImmolateFolder()
	local debrisFolder = workspace:FindFirstChild("Debris")
	if not debrisFolder then
		return workspace
	end

	local bodyEffects = debrisFolder:FindFirstChild("BodyEffects")
	if not bodyEffects then
		bodyEffects = Instance.new("Folder")
		bodyEffects.Name = "BodyEffects"
		bodyEffects.Parent = debrisFolder
	end

	local immolateFolder = bodyEffects:FindFirstChild("Immolate")
	if not immolateFolder then
		immolateFolder = Instance.new("Folder")
		immolateFolder.Name = "Immolate"
		immolateFolder.Parent = bodyEffects
	end

	return immolateFolder
end

local function getPath(instance, root)
	local path = {}
	local current = instance

	while current and current ~= root do
		table.insert(path, 1, current.Name)
		current = current.Parent
	end

	return path
end

local function findByPath(root, path)
	local current = root

	for _, name in path do
		current = current and current:FindFirstChild(name)
		if not current then
			return nil
		end
	end

	return current
end

local function stop(Character)
	local data = ACTIVE[Character]
	if not data then
		return
	end

	ACTIVE[Character] = nil

	if data.connection then
		data.connection:Disconnect()
	end
	if data.clone then
		data.clone:Destroy()
	end
end

local function prepClone(Character, Clone)
	local rootPart = Clone:FindFirstChild("HumanoidRootPart")
	if rootPart then
		Clone.PrimaryPart = rootPart
	end

	local humanoid = Clone:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
		humanoid.PlatformStand = true
	end

	for _, descendant in Clone:GetDescendants() do
		if descendant:IsA("Script") or descendant:IsA("LocalScript") then
			descendant:Destroy()
		elseif descendant:IsA("JointInstance") or descendant:IsA("Constraint") then
			descendant:Destroy()
		elseif descendant:IsA("SpecialMesh") then
			descendant.TextureId = TEXTURE_ID
		elseif descendant:IsA("BasePart") then
			local sourcePart = findByPath(Character, getPath(descendant, Clone))
			descendant.Anchored = false
			descendant.CanCollide = false
			descendant.CanTouch = false
			descendant.CanQuery = false
			descendant.Massless = true

			if sourcePart and sourcePart:IsA("BasePart") then
				descendant.CFrame = sourcePart.CFrame

				local weld = Instance.new("WeldConstraint")
				weld.Part0 = sourcePart
				weld.Part1 = descendant
				weld.Parent = descendant
			end
		end
	end
end

local function start(Character, Duration)
	stop(Character)

	if not Character or not Character.Parent then
		return
	end

	local clonesFolder = ReplicatedStorage:FindFirstChild("Clones")
	local sourceClone = clonesFolder and clonesFolder:FindFirstChild(Character.Name)
	if not sourceClone then
		return
	end

	local Clone = sourceClone:Clone()
	Clone.Name = Character.Name .. "_Immolate"
	prepClone(Character, Clone)
	Clone.Parent = getImmolateFolder()

	local Humanoid = Character:FindFirstChildOfClass("Humanoid")
	local data = {
		clone = Clone,
	}

	data.connection = RunService.RenderStepped:Connect(function()
		if not Character.Parent or not Clone.Parent then
			stop(Character)
			return
		end
		if Humanoid and Humanoid.Health <= 0 then
			stop(Character)
		end
	end)

	ACTIVE[Character] = data
	Debris:AddItem(Clone, (Duration or 8) + 1)

	task.delay(Duration or 8, function()
		stop(Character)
	end)
end

return function(Params)
	local Character = Params and (Params.Char or Params.char)
	if not Character then
		return
	end

	if Params.Enabled == false then
		stop(Character)
	else
		start(Character, Params.Duration)
	end
end
