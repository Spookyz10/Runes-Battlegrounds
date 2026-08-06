local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(script.Parent.Shared.Constants)
local Resources = Constants.Resources

local FadeOut = require(ReplicatedStorage.Shared.Modules.Utility.FadeOut)

local AURA_ATTR = "AuraFXName"

local Handlers = {}

function Handlers.Start(params)
	local char = params.char
	local auraName = params.aura
	if not char or not char.Parent or not auraName then
		return
	end

	local HumRP = char:FindFirstChild("HumanoidRootPart")
	if not HumRP then
		return
	end

	local AuraFolder = Resources.Auras:FindFirstChild(auraName)
	if not AuraFolder then
		return
	end

	for _, existing in HumRP:GetChildren() do
		if existing:GetAttribute(AURA_ATTR) == auraName then
			existing:Destroy()
		end
	end

	for _, particle in AuraFolder:GetChildren() do
		local clone = particle:Clone()
		clone:SetAttribute(AURA_ATTR, auraName)
		clone.Parent = HumRP

		if clone:IsA("ParticleEmitter") or clone:IsA("Trail") or clone:IsA("Beam") then
			clone.Enabled = true
		end
	end
end

function Handlers.End(params)
	local char = params.char
	local auraName = params.aura
	if not char then
		return
	end

	local HumRP = char:FindFirstChild("HumanoidRootPart")
	if not HumRP then
		return
	end

	for _, existing in HumRP:GetChildren() do
		if existing:GetAttribute(AURA_ATTR) and (not auraName or existing:GetAttribute(AURA_ATTR) == auraName) then
			FadeOut.OutAndDestroy(existing, 0.4)
		end
	end
end

return function(params)
	local handler = Handlers[params.func]
	if handler then
		handler(params)
	end
end
