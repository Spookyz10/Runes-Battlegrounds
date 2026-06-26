local Constants = require(script.Parent.Shared.Constants)
local Debris = Constants.Debris
local ParticlesModule = Constants.ParticlesModule
local CharacterAssets = Constants.CharacterAssets

return function(Params)
	local Index = Params.Index
	local Char = Params.Char
	if not Char or not Char.Parent then
		return
	end

	local HumRP = Char:FindFirstChild("HumanoidRootPart")
	if not HumRP then
		return
	end

	local SlashAsset = CharacterAssets.Eclipse.Lunar:FindFirstChild("Slash" .. Index)
	if not SlashAsset then
		return
	end

	local SlashClone = SlashAsset:Clone()
	SlashClone.CFrame = HumRP.CFrame * CFrame.new(0, 0, -4.5)
	SlashClone.Anchored = true
	SlashClone.Parent = workspace.Debris

	ParticlesModule.Emit(SlashClone)
	Debris:AddItem(SlashClone, 3)
end
