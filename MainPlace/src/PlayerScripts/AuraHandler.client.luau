local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer

local AurasFolder = ReplicatedStorage.Resources.Auras.Cosmetic

local activeEmitters: { [Model]: { ParticleEmitter } } = {}

local function clearAura(Character: Model)
	local emitters = activeEmitters[Character]
	if not emitters then
		return
	end

	for _, emitter in emitters do
		if emitter and emitter.Parent then
			emitter:Destroy()
		end
	end

	activeEmitters[Character] = nil
end

local R6_PARTS = {
	Head = true,
	Torso = true,
	["Left Arm"] = true,
	["Right Arm"] = true,
	["Left Leg"] = true,
	["Right Leg"] = true,
}

local function applyAura(Character: Model, AuraName: string?)
	clearAura(Character)

	if not AuraName or AuraName == "" then
		return
	end

	local AuraFolder = AurasFolder:FindFirstChild(AuraName)
	if not AuraFolder then
		return
	end

	local Templates = {}
	for _, child in AuraFolder:GetChildren() do
		if child:IsA("ParticleEmitter") and child.Name == "All" then
			table.insert(Templates, child)
		end
	end

	if #Templates == 0 then
		return
	end

	local emitters = {}

	for partName in R6_PARTS do
		local part = Character:WaitForChild(partName, 10)
		if part and part:IsA("BasePart") then
			for _, template in Templates do
				local clone = template:Clone()
				clone.Parent = part
				table.insert(emitters, clone)
			end
		end
	end

	activeEmitters[Character] = emitters
end

local function setupCharacter(Character: Model)
	applyAura(Character, Player:GetAttribute("EquippedAura"))
end

Player:GetAttributeChangedSignal("EquippedAura"):Connect(function()
	local Character = Player.Character
	if Character then
		applyAura(Character, Player:GetAttribute("EquippedAura"))
	end
end)

if Player.Character then
	setupCharacter(Player.Character)
end

Player.CharacterAdded:Connect(setupCharacter)

Player.CharacterRemoving:Connect(function(Character)
	activeEmitters[Character] = nil
end)
