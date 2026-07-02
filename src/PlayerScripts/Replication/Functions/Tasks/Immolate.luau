local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TEXTURE_ID = "rbxassetid://84851255852909"
local BLACK_COLOR = BrickColor.new("Really black").Color

local ACTIVE = {}

local function shouldSkip(part, character)
	if part.Name == "HumanoidRootPart" or string.find(part.Name, "Hitbox") ~= nil then
		return true
	end

	local EquippedRune = character:FindFirstChild("EquippedRune")
	if EquippedRune and part:IsDescendantOf(EquippedRune) then
		return true
	end

	return false
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

	if data.colors then
		for part, color in data.colors do
			if part and part.Parent then
				part.Color = color
			end
		end
	end

	if data.textures then
		for obj, info in data.textures do
			if obj and obj.Parent then
				pcall(function()
					obj[info.property] = info.value
				end)
			end
		end
	end

	if data.auraObjects then
		for _, auraObject in data.auraObjects do
			if auraObject and auraObject.Parent then
				auraObject:Destroy()
			end
		end
	end
end

local function applyBurntLook(Character, data)
	data.colors = {}
	data.textures = {}

	for _, descendant in Character:GetDescendants() do
		if descendant:IsA("BasePart") then
			if not shouldSkip(descendant, Character) then
				data.colors[descendant] = descendant.Color
				descendant.Color = BLACK_COLOR
			end
		elseif descendant:IsA("CharacterMesh") then
			data.textures[descendant] = { property = "BaseTextureContent", value = descendant.BaseTextureContent }
			pcall(function()
				descendant.BaseTextureContent = Content.fromUri(TEXTURE_ID)
			end)
		elseif descendant:IsA("SpecialMesh") then
			data.textures[descendant] = { property = "TextureContent", value = descendant.TextureContent }
			pcall(function()
				descendant.TextureContent = Content.fromUri(TEXTURE_ID)
			end)
		elseif descendant:IsA("Shirt") then
			data.textures[descendant] = { property = "ShirtTemplate", value = descendant.ShirtTemplate }
			pcall(function()
				descendant.ShirtTemplate = ""
			end)
		elseif descendant:IsA("Pants") then
			data.textures[descendant] = { property = "PantsTemplate", value = descendant.PantsTemplate }
			pcall(function()
				descendant.PantsTemplate = ""
			end)
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
		if bodyPart:IsA("BasePart") and not shouldSkip(bodyPart, Character) then
			for _, auraObject in immolatedAura:GetChildren() do
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

local function start(Character, Duration)
	stop(Character)

	if not Character or not Character.Parent then
		return
	end

	local Humanoid = Character:FindFirstChildOfClass("Humanoid")
	local data = {}

	applyBurntLook(Character, data)
	applyAura(Character, data)

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
