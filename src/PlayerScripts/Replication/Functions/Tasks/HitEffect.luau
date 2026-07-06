local Players = game:GetService("Players")

local Constants = require(script.Parent.Shared.Constants)
local ParticlesModule = Constants.ParticlesModule
local Debris = Constants.Debris
local Resources = Constants.Resources

local HitEffectsFolder = Resources.Effects.HitEffects

local function getHitStyle(HitChar)
	local player = HitChar and Players:GetPlayerFromCharacter(HitChar)
	if not player then
		return nil
	end

	local moveset = player:GetAttribute("Moveset") or "Default"
	if moveset == "Eclipse" then
		local mode = player:GetAttribute("MovesetMode_Eclipse")
		if mode == "Solar" then
			return "Solar"
		end
		if mode == "Lunar" then
			return "Lunar"
		end
	end

	return moveset
end

return function(Params)
	local EChar = Params.EChar
	local HitChar = Params.HitChar

	if not EChar or not EChar.Parent then
		return
	end

	local HumRP = EChar:FindFirstChild("HumanoidRootPart")
	if not HumRP then
		return
	end

	local Style = getHitStyle(HitChar)

	local effectAsset = HitEffectsFolder:FindFirstChild(Style)

	if not effectAsset then
		return
	end

	local clone = effectAsset:Clone()
	clone.CFrame = HumRP.CFrame * CFrame.new(0, 0, -1)
	clone.Parent = workspace.Debris

	ParticlesModule.Emit(clone)
	Debris:AddItem(clone, 3)
end
