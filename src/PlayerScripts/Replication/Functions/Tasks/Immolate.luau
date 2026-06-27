local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local TEXTURE_ID = "rbxassetid://94083001751844"
local OVERLAY_TEXTURE_ID = 94083001751844
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
	if data.auraObjects then
		for _, auraObject in data.auraObjects do
			auraObject:Destroy()
		end
	end
	if data.characterMeshes then
		for characterMesh, overlayTextureId in data.characterMeshes do
			if characterMesh.Parent then
				characterMesh.OverlayTextureId = overlayTextureId
			end
		end
	end
	if data.transparencies then
		for object, transparency in data.transparencies do
			if object.Parent then
				object.Transparency = transparency
			end
		end
	end
end

local function applyCharacterMeshOverlay(Character, data)
	data.characterMeshes = {}

	for _, descendant in Character:GetDescendants() do
		if descendant:IsA("CharacterMesh") then
			data.characterMeshes[descendant] = descendant.OverlayTextureId
			descendant.OverlayTextureId = OVERLAY_TEXTURE_ID
		end
	end
end

local function applyOriginalInvisibility(Character, data)
	data.transparencies = {}

	for _, descendant in Character:GetDescendants() do
		if descendant:IsA("BasePart") and not string.find(descendant.Name, "Hitbox") then
			data.transparencies[descendant] = descendant.Transparency
			descendant.Transparency = 1
		elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
			data.transparencies[descendant] = descendant.Transparency
			descendant.Transparency = 1
		end
	end
end

local function applyAura(Character, data)
	local resources = ReplicatedStorage:FindFirstChild("Resources")
	local auras = resources and resources:FindFirstChild("Auras")
	local immolatedAura = auras and auras:FindFirstChild("Immolated")
	if not immolatedAura then
		return
	end

	data.auraObjects = {}

	for _, bodyPart in Character:GetDescendants() do
		if bodyPart:IsA("BasePart") and not string.find(bodyPart.Name, "Hitbox") then
			for _, auraObject in immolatedAura:GetDescendants() do
				if auraObject:IsA("ParticleEmitter") then
					local auraClone = auraObject:Clone()
					auraClone.Enabled = true
					auraClone.Parent = bodyPart
					table.insert(data.auraObjects, auraClone)
				end
			end
		end
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
		elseif descendant:IsA("CharacterMesh") then
			descendant.OverlayTextureId = OVERLAY_TEXTURE_ID
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

	local Humanoid = Character:FindFirstChildOfClass("Humanoid")
	local data = {
		clone = nil,
	}

	applyCharacterMeshOverlay(Character, data)
	applyOriginalInvisibility(Character, data)
	applyAura(Character, data)

	local clonesFolder = ReplicatedStorage:FindFirstChild("Clones")
	local sourceClone = clonesFolder and clonesFolder:FindFirstChild(Character.Name)
	if sourceClone then
		local Clone = sourceClone:Clone()
		Clone.Name = Character.Name .. "_Immolate"
		prepClone(Character, Clone)
		Clone.Parent = getImmolateFolder()
		data.clone = Clone
	end

	data.connection = RunService.RenderStepped:Connect(function()
		if not Character.Parent then
			stop(Character)
			return
		end
		if Humanoid and Humanoid.Health <= 0 then
			stop(Character)
		end
	end)

	ACTIVE[Character] = data
	if data.clone then
		Debris:AddItem(data.clone, (Duration or 8) + 1)
	end

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
