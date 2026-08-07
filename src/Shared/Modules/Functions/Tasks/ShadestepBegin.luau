local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FadeOut = require(ReplicatedStorage.Shared.Modules.Utility.FadeOut)
local StartUp = ReplicatedStorage.Resources.CharacterAssets.Eclipse.Lunar.Shadestep.Startup

local R6_BODY_PARTS = {
	"Head",
	"Torso",
	"Left Arm",
	"Right Arm",
	"Left Leg",
	"Right Leg",
}

local AURA_ATTR = "ShadestepAura"
local SHADOW_TRANSPARENCY = 0.8

local savedTransparencies = {} -- [char] = { [part] = originalTransparency }
local savedStartupVFX = {}

local Handlers = {}

function Handlers.ShadestepBeginStart(params)
	local char = params.char
	if not char or not char.Parent then
		return
	end

	savedTransparencies[char] = {}

	for _, part in char:GetDescendants() do
		if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and not string.find("Hitbox", part.Name) then
			savedTransparencies[char][part] = part.Transparency
			part.Transparency = SHADOW_TRANSPARENCY
		end
	end

	local shadowAura = ReplicatedStorage.Resources.Auras.Shadow
	for _, partName in R6_BODY_PARTS do
		local bodyPart = char:FindFirstChild(partName)
		if not bodyPart then
			continue
		end

		for _, auraChild in shadowAura:GetChildren() do
			local clone = auraChild:Clone()
			clone:SetAttribute(AURA_ATTR, true)
			clone.Parent = bodyPart
		end
	end

	local Clone = StartUp:Clone()
	Clone.Parent = workspace
	Clone.CFrame = char.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(180), 0)
	savedStartupVFX[char] = Clone
end

function Handlers.ShadestepBeginEnd(params)
	local char = params.char
	if not char or not char.Parent then
		return
	end

	local saved = savedTransparencies[char]
	if saved then
		for part, transparency in saved do
			if part and part.Parent then
				part.Transparency = transparency
			end
		end
		savedTransparencies[char] = nil
	end

	for _, obj in char:GetDescendants() do
		if obj:GetAttribute(AURA_ATTR) then
			FadeOut.OutAndDestroy(obj, 0.5)
		end
	end

	local startupVFX = savedStartupVFX[char]
	if startupVFX then
		FadeOut.OutAndDestroy(startupVFX, 0.5)
		savedStartupVFX[char] = nil
	end
end

return function(params)
	local handler = Handlers[params.func]
	if handler then
		handler(params)
	end
end
